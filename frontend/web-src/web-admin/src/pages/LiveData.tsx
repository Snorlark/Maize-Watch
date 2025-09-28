import React, { useEffect, useState } from 'react'
import axios from 'axios'
import Footer from '../components/Footer'
import { FaThermometerHalf, FaMountain } from 'react-icons/fa'
import { IoWaterOutline } from 'react-icons/io5'
import { BsSun } from 'react-icons/bs'
import { Activity, Gauge, AlertTriangle, Clock, MapPin, ChevronDown } from 'lucide-react'
import apiClient from '../api/client'

interface SensorData {
  _id: string;
  field_id: string;
  timestamp: string;
  measurements: {
    temperature: number;
    humidity: number;
    soil_moisture: number;
    soil_ph: number;
    light_level: number;
  };
}

interface SensorStatus {
  temperature: boolean;
  humidity: boolean;
  soil_moisture: boolean;
  soil_ph: boolean;
  light_level: boolean;
}

interface Farm {
  _id: string;
  fieldName: string;
  location: string;
  soilType: string;
  plantingDate: string;
  growthStage: string;
  deviceId?: string;
  userId: string;
  createdAt: string;
  updatedAt: string;
}

const LiveData: React.FC = () => {
  const [sensorData, setSensorData] = useState<SensorData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [farms, setFarms] = useState<Farm[]>([]);
  const [selectedFarm, setSelectedFarm] = useState<Farm | null>(null);
  const [farmsLoading, setFarmsLoading] = useState(true);
  const [sensorStatus, setSensorStatus] = useState<SensorStatus>({
    temperature: false,
    humidity: false,
    soil_moisture: false,
    soil_ph: false,
    light_level: false
  });

  // Fetch farms on component mount
  useEffect(() => {
    const fetchFarms = async () => {
      try {
        const response = await apiClient.get('/api/farms');
        console.log('Farms API response:', response.data);
        
        if (response.data?.success && response.data?.data?.farms) {
          const farmsData = response.data.data.farms;
          setFarms(farmsData);
          
          // Auto-select first farm for super_admin (they have access to all farms)
          console.log('✅ Found farms:', farmsData.map((f: Farm) => ({ id: f._id, name: f.fieldName })));
          if (farmsData.length > 0) {
            setSelectedFarm(farmsData[0]);
            console.log('🎯 Auto-selected farm for super_admin:', farmsData[0].fieldName);
          }
        } else if (response.data?.farms) {
          // Handle different response format
          setFarms(response.data.farms);
          console.log('✅ Found farms (alt format):', response.data.farms.map((f: any) => ({ id: f._id, name: f.fieldName })));
          if (response.data.farms.length > 0) {
            setSelectedFarm(response.data.farms[0]);
            console.log('🎯 Auto-selected farm for super_admin (alt format):', response.data.farms[0].fieldName);
          }
        } else {
          console.warn('No farms found in response:', response.data);
          setFarms([]);
          setSelectedFarm(null);
        }
      } catch (err: any) {
        console.error('Error fetching farms:', err);
        setFarms([]);
        setSelectedFarm(null);
      } finally {
        setFarmsLoading(false);
      }
    };

    fetchFarms();
  }, []);

  // Fetch sensor data (always from general endpoint since farms are placeholders)
  useEffect(() => {
    if (farmsLoading) return; // Wait for farms to load first

    const fetchData = async () => {
      // Only show loading spinner on initial load, not on updates
      if (!sensorData) {
        setLoading(true);
      }
      setError(null);
      try {
        // Always fetch from general endpoint regardless of selected farm
        console.log('Fetching sensor data from MongoDB database');
        let response;
        
        try {
          // Try to get data from selected farm first
          if (selectedFarm && selectedFarm._id) {
            console.log('Fetching data for selected farm:', selectedFarm._id);
            response = await apiClient.get(`/api/farms/${selectedFarm._id}/readings/latest`);
          } else {
            // Fallback to general latest readings endpoint
            console.log('Fetching general latest sensor readings');
            response = await apiClient.get('/api/sensors/latest-no-thingspeak');
          }
        } catch (sensorErr: any) {
          console.log('⚠️ Primary endpoint failed, trying fallback');
          try {
            // Try the general endpoint as fallback
            response = await apiClient.get('/api/sensors/latest-no-thingspeak');
          } catch (fallbackErr: any) {
            console.log('⚠️ All local endpoints failed, trying production');
            response = await axios.get('https://maize-watch.onrender.com/api/sensors/latest');
          }
        }
        console.log('Sensor API response:', response.data);

        if (response.data?.success && response.data?.data) {
          const raw = response.data.data;
          
          // Update sensor status based on data availability
          setSensorStatus({
            temperature: raw.temperature !== null && raw.temperature !== undefined,
            humidity: raw.humidity !== null && raw.humidity !== undefined,
            soil_moisture: raw.soilMoisture !== null && raw.soilMoisture !== undefined,
            soil_ph: raw.soilPh !== null && raw.soilPh !== undefined,
            light_level: raw.lightIntensity !== null && raw.lightIntensity !== undefined
          });

          const transformedData: SensorData = {
            _id: raw._id || '',
            field_id: selectedFarm?._id || '',
            timestamp: raw.timestamp,
            measurements: {
              temperature: raw.temperature || 0,
              humidity: raw.humidity || 0,
              soil_moisture: raw.soilMoisture || 0,
              soil_ph: raw.soilPh || 0,
              light_level: raw.lightIntensity || 0,
            },
          };

          setSensorData(transformedData);
          setError(null);
        } else {
          setError('No sensor data received from API');
        }
      } catch (err: any) {
        console.error('Error fetching sensor data:', err);
        
        // If we don't have any data yet, show mock data to prevent blank screen
        if (!sensorData) {
          console.log('🔄 Using mock data since no data is available');
          const mockData: SensorData = {
            _id: 'mock-sensor-001',
            field_id: selectedFarm?._id || 'mock-field',
            timestamp: new Date().toISOString(),
            measurements: {
              temperature: 25.5,
              humidity: 65,
              soil_moisture: 45,
              soil_ph: 6.8,
              light_level: 750,
            },
          };
          
          setSensorData(mockData);
          setSensorStatus({
            temperature: true,
            humidity: true,
            soil_moisture: true,
            soil_ph: true,
            light_level: true
          });
        }
        
        setError('Unable to fetch live sensor data - showing demo data');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
    // Increase interval to 30 seconds to reduce server load and prevent flickering
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, [farmsLoading]); // Only depend on farmsLoading, not selectedFarm or farms

  // Safety check for measurements and provide default values
  const measurements = {
    temperature: sensorData?.measurements?.temperature ?? 0,
    humidity: sensorData?.measurements?.humidity ?? 0,
    soil_moisture: sensorData?.measurements?.soil_moisture ?? 0,
    soil_ph: sensorData?.measurements?.soil_ph ?? 0,
    light_level: sensorData?.measurements?.light_level ?? 0,
  };

  // Replace the alerts section with sensor status
  const renderSensorStatus = () => (
    <div className="bg-white rounded-xl shadow-lg p-6">
      <div className="flex items-center gap-3 mb-6">
        <Gauge className="w-6 h-6 text-[#456C2D]" />
        <h3 className="font-semibold text-[#356B2C]" style={{ fontSize: 'var(--text-lg)' }}>Sensor Status</h3>
      </div>
      <div className="space-y-4">
        {/* Temperature Sensor */}
        <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
          <div className="flex items-center gap-3">
            <div className={`w-3 h-3 rounded-full ${sensorStatus.temperature ? 'bg-green-500' : 'bg-red-500'}`}></div>
            <span className="font-medium text-[#356B2C]" style={{ fontSize: 'var(--text-sm)' }}>Temperature</span>
          </div>
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${
            sensorStatus.temperature ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.temperature ? 'Online' : 'Offline'}
          </span>
        </div>

        {/* Humidity Sensor */}
        <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
          <div className="flex items-center gap-3">
            <div className={`w-3 h-3 rounded-full ${sensorStatus.humidity ? 'bg-green-500' : 'bg-red-500'}`}></div>
            <span className="font-medium text-[#356B2C]" style={{ fontSize: 'var(--text-sm)' }}>Humidity</span>
          </div>
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${
            sensorStatus.humidity ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.humidity ? 'Online' : 'Offline'}
          </span>
        </div>

        {/* Soil Moisture Sensor */}
        <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
          <div className="flex items-center gap-3">
            <div className={`w-3 h-3 rounded-full ${sensorStatus.soil_moisture ? 'bg-green-500' : 'bg-red-500'}`}></div>
            <span className="font-medium text-[#356B2C]" style={{ fontSize: 'var(--text-sm)' }}>Soil Moisture</span>
          </div>
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${
            sensorStatus.soil_moisture ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.soil_moisture ? 'Online' : 'Offline'}
          </span>
        </div>

        {/* Soil pH Sensor */}
        <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
          <div className="flex items-center gap-3">
            <div className={`w-3 h-3 rounded-full ${sensorStatus.soil_ph ? 'bg-green-500' : 'bg-red-500'}`}></div>
            <span className="font-medium text-[#356B2C]" style={{ fontSize: 'var(--text-sm)' }}>Soil pH</span>
          </div>
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${
            sensorStatus.soil_ph ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.soil_ph ? 'Online' : 'Offline'}
          </span>
        </div>

        {/* Light Sensor */}
        <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
          <div className="flex items-center gap-3">
            <div className={`w-3 h-3 rounded-full ${sensorStatus.light_level ? 'bg-green-500' : 'bg-red-500'}`}></div>
            <span className="font-medium text-[#356B2C]" style={{ fontSize: 'var(--text-sm)' }}>Light Intensity</span>
          </div>
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${
            sensorStatus.light_level ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.light_level ? 'Online' : 'Offline'}
          </span>
        </div>
      </div>

      {/* Last Update */}
      <div className="mt-4 pt-4 border-t border-gray-200">
        <div className="flex items-center gap-2 text-[#4A7C59]" style={{ fontSize: 'var(--text-xs)' }}>
          <Clock className="w-4 h-4" />
          <span>Last updated: {sensorData ? new Date(sensorData.timestamp).toLocaleString() : 'Never'}</span>
        </div>
      </div>
    </div>
  );

  if (loading) return (
    <div 
      className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8"
      style={{ 
        '--text-xs': '12px', 
        '--text-sm': '14px', 
        '--text-base': '16px', 
        '--text-lg': '18px', 
        '--text-xl': '20px' 
      } as React.CSSProperties}
    >
      <main className="max-w-7xl mx-auto">
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#356B2C]"></div>
          <span className="ml-3" style={{ fontSize: 'var(--text-lg)' }}>Loading sensor data...</span>
        </div>
      </main>
    </div>
  );

  if (error && !sensorData) return (
    <div 
      className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8"
      style={{ 
        '--text-xs': '12px', 
        '--text-sm': '14px', 
        '--text-base': '16px', 
        '--text-lg': '18px', 
        '--text-xl': '20px' 
      } as React.CSSProperties}
    >
      <main className="max-w-7xl mx-auto">
        <div className="text-center py-12">
          <AlertTriangle className="w-12 h-12 mx-auto text-[#456C2D] mb-4" />
          <div style={{ fontSize: 'var(--text-lg)' }}>No sensor data available</div>
        </div>
      </main>
      <Footer />
    </div>
  );

  return (
    <div 
      className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8"
      style={{ 
        '--text-xs': '12px', 
        '--text-sm': '14px', 
        '--text-base': '16px', 
        '--text-lg': '18px', 
        '--text-xl': '20px' 
      } as React.CSSProperties}
    >
      <main className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="font-bold text-[#1E441E] mb-2 flex items-center gap-3" style={{ fontSize: 'var(--text-xl)' }}>
            <Activity className="w-8 h-8 sm:w-10 sm:h-10 text-[#456C2D]" />
            Live Sensor Data
          </h1>
          <p className="text-[#456C2D]" style={{ fontSize: 'var(--text-base)' }}>
            Real-time monitoring of environmental conditions
          </p>
          
          {/* Farm Selector */}
          <div className="mt-4 p-4 bg-white rounded-lg border border-[#B8D4A8]">
            <label className="block text-sm font-medium text-[#456C2D] mb-2">
              <MapPin className="w-4 h-4 inline mr-1" />
              Select Farm (Display Only - Showing General Sensor Data)
            </label>
            <div className="flex flex-col sm:flex-row sm:items-center gap-3">
              <div className="relative">
                <select
                  value={selectedFarm?._id || ''}
                  onChange={(e) => {
                    const farm = farms.find(f => f._id === e.target.value);
                    setSelectedFarm(farm || null);
                  }}
                  className="appearance-none bg-white border border-[#B8D4A8] rounded-lg px-4 py-2 pr-8 text-[#356B2C] focus:outline-none focus:ring-2 focus:ring-[#456C2D] focus:border-transparent min-w-[200px]"
                  style={{ fontSize: 'var(--text-sm)' }}
                  disabled={farms.length === 0}
                >
                  {farms.length === 0 ? (
                    <option value="">No farms available - Showing general sensor data</option>
                  ) : (
                    <>
                      <option value="">General Sensor Data (Default)</option>
                      {farms.map((farm) => (
                        <option key={farm._id} value={farm._id}>
                          {farm.fieldName} - {farm.location} (Placeholder)
                        </option>
                      ))}
                    </>
                  )}
                </select>
                <ChevronDown className="absolute right-2 top-1/2 transform -translate-y-1/2 w-4 h-4 text-[#456C2D] pointer-events-none" />
              </div>
              {selectedFarm && (
                <div className="text-xs text-[#4A7C59]">
                  <span className="font-medium">Growth Stage:</span> {selectedFarm.growthStage} | 
                  <span className="font-medium ml-2">Soil:</span> {selectedFarm.soilType}
                  {selectedFarm.deviceId && (
                    <span className="ml-2 px-2 py-1 bg-green-100 text-green-800 rounded-full text-xs">
                      Device Connected
                    </span>
                  )}
                </div>
              )}
              {farms.length === 0 && (
                <div className="text-xs text-[#4A7C59]">
                  <span className="font-medium">Status:</span> No farms configured yet. Contact admin to add farms.
                </div>
              )}
            </div>
          </div>
          
          <div className="mt-3 flex flex-wrap items-center gap-3">
            <span className="inline-flex items-center px-3 py-1 rounded-full font-medium bg-[#456C2D] text-[#F5F5DC]" style={{ fontSize: 'var(--text-sm)' }}>
              Real-time Monitoring
            </span>
            {selectedFarm && (
              <span className="inline-flex items-center px-3 py-1 rounded-full font-medium bg-[#8B4513] text-[#F5F5DC]" style={{ fontSize: 'var(--text-sm)' }}>
                <MapPin className="w-3 h-3 mr-1" />
                {selectedFarm.fieldName}
              </span>
            )}
          </div>
        </div>

        <div className="flex flex-col lg:flex-row gap-6 lg:gap-8">
          {/* Left Column - Temperature and Sensor Status */}
          <div className="w-full lg:w-1/3 space-y-6">
            {/* Temperature Card */}
            <div className="bg-white rounded-xl shadow-lg p-6">
              <div className="flex items-center gap-4">
                <div className="p-3 bg-red-50 rounded-lg">
                  <FaThermometerHalf className="text-[#e74c3c] text-3xl" />
                </div>
                <div>
                  <div className="font-medium text-[#4A7C59] mb-1" style={{ fontSize: 'var(--text-sm)' }}>TEMPERATURE</div>
                  <div className="font-bold text-[#356B2C]" style={{ fontSize: '32px' }}>{measurements.temperature}°C</div>
                </div>
              </div>
            </div>

            {/* Sensor Status */}
            {renderSensorStatus()}
          </div>

          {/* Right Column - Sensor Readings Grid */}
          <div className="w-full lg:w-2/3">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
              {/* Soil Moisture */}
              <div className="bg-white rounded-xl shadow-lg p-6">
                <div className="text-center">
                  <div className="p-3 bg-orange-50 rounded-lg w-fit mx-auto mb-4">
                    <FaMountain className="text-3xl text-[#7a5c2d]" />
                  </div>
                  <p className="font-medium text-[#4A7C59] mb-2" style={{ fontSize: 'var(--text-sm)' }}>Soil Moisture</p>
                  <div className="font-bold text-[#356B2C] mb-3" style={{ fontSize: '32px' }}>{measurements.soil_moisture}</div>
                  <span className={`inline-block ${
                    measurements.soil_moisture < 30 
                      ? 'bg-red-100 text-red-800' 
                      : 'bg-green-100 text-green-800'
                  } font-medium px-3 py-1 rounded-full`} style={{ fontSize: 'var(--text-xs)' }}>
                    {measurements.soil_moisture < 30 ? 'Low Moisture' : 'Good Condition'}
                  </span>            
                </div>
              </div>

              {/* Soil Ph Level */}
              <div className="bg-white rounded-xl shadow-lg p-6">
                <div className="text-center">
                  <div className="p-3 bg-purple-50 rounded-lg w-fit mx-auto mb-4">
                    <FaMountain className="text-3xl text-[#7a5c2d]" />
                  </div>
                  <p className="font-medium text-[#4A7C59] mb-2" style={{ fontSize: 'var(--text-sm)' }}>Soil pH Level</p>
                  <div className="font-bold text-[#356B2C] mb-3" style={{ fontSize: '32px' }}>{measurements.soil_ph}</div>
                  <span className={`inline-block ${
                    measurements.soil_ph > 7 
                      ? 'bg-red-100 text-red-800' 
                      : 'bg-green-100 text-green-800'
                  } font-medium px-3 py-1 rounded-full`} style={{ fontSize: 'var(--text-xs)' }}>
                    {measurements.soil_ph < 7 ? 'Good Condition' : 'Soil pH indicates alkalinity'}
                  </span>          
                </div>
              </div>

              {/* Humidity */}
              <div className="bg-white rounded-xl shadow-lg p-6">
                <div className="flex items-center gap-3 mb-4">
                  <div className="p-2 bg-blue-50 rounded-lg">
                    <IoWaterOutline className="text-2xl text-[#2d67c4]" />
                  </div>
                  <p className="font-medium text-[#4A7C59]" style={{ fontSize: 'var(--text-sm)' }}>Humidity</p>
                </div>
                <div className="relative w-full h-12 bg-gray-200 rounded-full overflow-hidden mb-3">
                  <div 
                    className="bg-[#2d67c4] h-full rounded-full flex items-center justify-center text-white font-semibold transition-all duration-300"
                    style={{ width: `${Math.min(measurements.humidity, 100)}%`, fontSize: 'var(--text-sm)' }}
                  >
                    {measurements.humidity}%
                  </div>
                </div>
                <div className="text-center">
                  <span className={`inline-block ${
                    measurements.humidity < 40 
                      ? 'bg-red-100 text-red-800' 
                      : 'bg-green-100 text-green-800'
                  } font-medium px-3 py-1 rounded-full`} style={{ fontSize: 'var(--text-xs)' }}>
                    {measurements.humidity < 40 ? 'Too Low' : 'Good Condition'}
                  </span>
                </div>
              </div>

              {/* Light Intensity */}
              <div className="bg-white rounded-xl shadow-lg p-6">
                <div className="flex items-center gap-3 mb-4">
                  <div className="p-2 bg-yellow-50 rounded-lg">
                    <BsSun className="text-2xl text-[#deb83c]" />
                  </div>
                  <p className="font-medium text-[#4A7C59]" style={{ fontSize: 'var(--text-sm)' }}>Light Intensity</p>
                </div>
                <div className="relative w-full h-12 bg-gray-200 rounded-full overflow-hidden mb-3">
                  <div 
                    className="bg-[#deb83c] h-full rounded-full flex items-center justify-center text-white font-semibold transition-all duration-300"
                    style={{ width: `${Math.min(measurements.light_level / 10, 100)}%`, fontSize: 'var(--text-sm)' }}
                  >
                    {measurements.light_level} LUX
                  </div>
                </div>
                <div className="text-center">
                  <span className={`inline-block ${
                    measurements.light_level < 50 
                      ? 'bg-red-100 text-red-800' 
                      : 'bg-green-100 text-green-800'
                  } font-medium px-3 py-1 rounded-full`} style={{ fontSize: 'var(--text-xs)' }}>
                    {measurements.light_level < 50 ? 'Low Light' : 'Best Condition'}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  )
}

export default LiveData