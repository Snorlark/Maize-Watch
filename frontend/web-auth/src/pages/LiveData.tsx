import React, { useEffect, useState } from 'react'
import axios from 'axios'
import Footer from '../components/Footer'
import { FaThermometerHalf, FaMountain } from 'react-icons/fa'
import { IoWaterOutline } from 'react-icons/io5'
import { BsSun } from 'react-icons/bs'
import { Activity, Gauge, AlertTriangle, Clock, RefreshCw } from 'lucide-react'

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

// Add new interface for sensor status
interface SensorStatus {
  temperature: boolean;
  humidity: boolean;
  soil_moisture: boolean;
  soil_ph: boolean;
  light_level: boolean;
}

const LiveData: React.FC = () => {
  const [sensorData, setSensorData] = useState<SensorData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sensorStatus, setSensorStatus] = useState<SensorStatus>({
    temperature: false,
    humidity: false,
    soil_moisture: false,
    soil_ph: false,
    light_level: false
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get('https://maize-watch.onrender.com/api/sensors/latest');
        console.log('Full API response:', response.data);
        
        if (response.data && response.data.data) {
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
            _id: '',
            field_id: '',
            timestamp: raw.timestamp,
            measurements: {
              temperature: raw.temperature,
              humidity: raw.humidity,
              soil_moisture: raw.soilMoisture,
              soil_ph: raw.soilPh,
              light_level: raw.lightIntensity,
            },
          };

          setSensorData(transformedData);
        } else {
          setError('No sensor data received from API');
        }
        setLoading(false);
      } catch (err) {
        setError('Failed to fetch sensor data');
        setLoading(false);
        console.error('Error fetching data:', err);
      }
    };

    fetchData();
    const interval = setInterval(fetchData, 3000);
    return () => clearInterval(interval);
  }, []);

  if (loading) return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8">
      <main className="max-w-7xl mx-auto">
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#356B2C]"></div>
          <span className="ml-3 text-lg">Loading sensor data...</span>
        </div>
      </main>
      <Footer />
    </div>
  );

  if (error) return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8">
      <main className="max-w-7xl mx-auto">
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6">
          <div className="flex items-center justify-between">
            <span className="font-medium">Error: {error}</span>
            <button
              onClick={() => window.location.reload()}
              className="px-3 py-1 bg-red-600 text-white text-sm rounded-md hover:bg-red-700 transition-colors"
            >
              Retry
            </button>
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );

  if (!sensorData) return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8">
      <main className="max-w-7xl mx-auto">
        <div className="text-center py-12">
          <AlertTriangle className="w-12 h-12 mx-auto text-[#456C2D] mb-4" />
          <div className="text-lg">No sensor data available</div>
        </div>
      </main>
      <Footer />
    </div>
  );

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
        <h2 className="text-xl font-semibold text-[#1E441E]">Sensor Status</h2>
      </div>
      <div className="space-y-4">
        <div className="flex items-center justify-between p-3 bg-[#F5F9F1] rounded-lg">
          <div className="flex items-center gap-3">
            <FaThermometerHalf className="text-[#e74c3c] text-lg" />
            <span className="font-medium text-[#356B2C]">Temperature Sensor</span>
          </div>
          <span className={`px-3 py-1 rounded-full text-xs font-medium ${
            sensorStatus.temperature 
              ? 'bg-green-100 text-green-800' 
              : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.temperature ? 'Active' : 'Inactive'}
          </span>
        </div>

        <div className="flex items-center justify-between p-3 bg-[#F5F9F1] rounded-lg">
          <div className="flex items-center gap-3">
            <IoWaterOutline className="text-[#2d67c4] text-lg" />
            <span className="font-medium text-[#356B2C]">Humidity Sensor</span>
          </div>
          <span className={`px-3 py-1 rounded-full text-xs font-medium ${
            sensorStatus.humidity 
              ? 'bg-green-100 text-green-800' 
              : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.humidity ? 'Active' : 'Inactive'}
          </span>
        </div>

        <div className="flex items-center justify-between p-3 bg-[#F5F9F1] rounded-lg">
          <div className="flex items-center gap-3">
            <FaMountain className="text-[#7a5c2d] text-lg" />
            <span className="font-medium text-[#356B2C]">Soil Moisture Sensor</span>
          </div>
          <span className={`px-3 py-1 rounded-full text-xs font-medium ${
            sensorStatus.soil_moisture 
              ? 'bg-green-100 text-green-800' 
              : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.soil_moisture ? 'Active' : 'Inactive'}
          </span>
        </div>

        <div className="flex items-center justify-between p-3 bg-[#F5F9F1] rounded-lg">
          <div className="flex items-center gap-3">
            <FaMountain className="text-[#7a5c2d] text-lg" />
            <span className="font-medium text-[#356B2C]">Soil pH Sensor</span>
          </div>
          <span className={`px-3 py-1 rounded-full text-xs font-medium ${
            sensorStatus.soil_ph 
              ? 'bg-green-100 text-green-800' 
              : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.soil_ph ? 'Active' : 'Inactive'}
          </span>
        </div>

        <div className="flex items-center justify-between p-3 bg-[#F5F9F1] rounded-lg">
          <div className="flex items-center gap-3">
            <BsSun className="text-[#deb83c] text-lg" />
            <span className="font-medium text-[#356B2C]">Light Intensity Sensor</span>
          </div>
          <span className={`px-3 py-1 rounded-full text-xs font-medium ${
            sensorStatus.light_level 
              ? 'bg-green-100 text-green-800' 
              : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.light_level ? 'Active' : 'Inactive'}
          </span>
        </div>
      </div>

      <div className="mt-6 pt-4 border-t border-[#B8D4A8]">
        <div className="flex items-center justify-between text-sm">
          <div className="flex items-center gap-2 text-[#4A7C59]">
            <Clock className="w-4 h-4" />
            <span>Last Updated:</span>
          </div>
          <span className="font-medium text-[#356B2C]">
            {sensorData?.timestamp 
              ? new Date(sensorData.timestamp).toLocaleTimeString() 
              : 'N/A'}
          </span>
        </div>
      </div>
    </div>
  );

  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8">
      <main className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#1E441E] mb-2 flex items-center gap-3">
            <Activity className="w-8 h-8 sm:w-10 sm:h-10 text-[#456C2D]" />
            Live Data
          </h1>
          <p className="text-[#456C2D] text-sm sm:text-base">
            Real-time monitoring of your farm's environmental conditions
          </p>
          <div className="mt-3 flex items-center gap-3">
            <span className="inline-flex items-center px-3 py-1 rounded-full text-xs sm:text-sm font-medium bg-[#456C2D] text-[#F5F5DC]">
              Real-time Monitoring
            </span>
            <div className="flex items-center gap-2 text-[#4A7C59] text-sm">
              <RefreshCw className="w-4 h-4 animate-spin" />
              <span>Auto-refreshing every 3 seconds</span>
            </div>
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
                  <div className="text-sm font-medium text-[#4A7C59] mb-1">TEMPERATURE</div>
                  <div className="text-3xl font-bold text-[#356B2C]">{measurements.temperature}°C</div>
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
                  <p className="text-sm font-medium text-[#4A7C59] mb-2">Soil Moisture</p>
                  <div className="text-3xl font-bold text-[#356B2C] mb-3">{measurements.soil_moisture}</div>
              <span className={`inline-block ${
                measurements.soil_moisture < 30 
                      ? 'bg-red-100 text-red-800' 
                      : 'bg-green-100 text-green-800'
              } text-xs font-medium px-3 py-1 rounded-full`}>
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
                  <p className="text-sm font-medium text-[#4A7C59] mb-2">Soil pH Level</p>
                  <div className="text-3xl font-bold text-[#356B2C] mb-3">{measurements.soil_ph}</div>
              <span className={`inline-block ${
                measurements.soil_ph > 7 
                      ? 'bg-red-100 text-red-800' 
                      : 'bg-green-100 text-green-800'
              } text-xs font-medium px-3 py-1 rounded-full`}>
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
                  <p className="text-sm font-medium text-[#4A7C59]">Humidity</p>
              </div>
                <div className="relative w-full h-12 bg-gray-200 rounded-full overflow-hidden mb-3">
                <div 
                    className="bg-[#2d67c4] h-full rounded-full flex items-center justify-center text-white text-sm font-semibold transition-all duration-300"
                    style={{ width: `${Math.min(measurements.humidity, 100)}%` }}
                >
                  {measurements.humidity}%
                </div>
              </div>
              <div className="text-center">
                <span className={`inline-block ${
                  measurements.humidity < 40 
                      ? 'bg-red-100 text-red-800' 
                      : 'bg-green-100 text-green-800'
                } text-xs font-medium px-3 py-1 rounded-full`}>
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
                  <p className="text-sm font-medium text-[#4A7C59]">Light Intensity</p>
              </div>
                <div className="relative w-full h-12 bg-gray-200 rounded-full overflow-hidden mb-3">
                  <div 
                    className="bg-[#deb83c] h-full rounded-full flex items-center justify-center text-white text-sm font-semibold transition-all duration-300"
                    style={{ width: `${Math.min(measurements.light_level / 10, 100)}%` }}
                >
                  {measurements.light_level} LUX
                </div>
              </div>
              <div className="text-center">
                <span className={`inline-block ${
                  measurements.light_level < 50 
                      ? 'bg-red-100 text-red-800' 
                      : 'bg-green-100 text-green-800'
                } text-xs font-medium px-3 py-1 rounded-full`}>
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