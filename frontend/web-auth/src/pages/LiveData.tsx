import React, { useEffect, useState } from 'react'
import axios from 'axios'
import Footer from '../components/Footer'
import { FaThermometerHalf, FaExclamationCircle, FaMountain } from 'react-icons/fa'
import { IoWaterOutline } from 'react-icons/io5'
import { BsSun } from 'react-icons/bs'

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
        const response = await axios.get('http://localhost:8080/api/sensors/latest');
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
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <main className="py-10">
        <div className="text-center">Loading sensor data...</div>
      </main>
      <Footer />
    </div>
  );

  if (error) return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <main className="py-10">
        <div className="text-center text-red-500">{error}</div>
      </main>
      <Footer />
    </div>
  );

  if (!sensorData) return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <main className="py-10">
        <div className="text-center">No sensor data available</div>
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
    <div className="bg-white rounded-xl p-4 shadow-md">
      <h2 className="text-lg font-bold text-[#406326] mb-4">Sensor Status:</h2>
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <FaThermometerHalf className="text-[#e74c3c]" />
            <span className="text-sm font-medium">Temperature Sensor</span>
          </div>
          <span className={`px-3 py-1 rounded-full text-xs font-medium ${
            sensorStatus.temperature 
              ? 'bg-green-100 text-green-800' 
              : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.temperature ? 'Active' : 'Inactive'}
          </span>
        </div>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <IoWaterOutline className="text-[#2d67c4]" />
            <span className="text-sm font-medium">Humidity Sensor</span>
          </div>
          <span className={`px-3 py-1 rounded-full text-xs font-medium ${
            sensorStatus.humidity 
              ? 'bg-green-100 text-green-800' 
              : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.humidity ? 'Active' : 'Inactive'}
          </span>
        </div>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <FaMountain className="text-[#7a5c2d]" />
            <span className="text-sm font-medium">Soil Moisture Sensor</span>
          </div>
          <span className={`px-3 py-1 rounded-full text-xs font-medium ${
            sensorStatus.soil_moisture 
              ? 'bg-green-100 text-green-800' 
              : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.soil_moisture ? 'Active' : 'Inactive'}
          </span>
        </div>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <FaMountain className="text-[#7a5c2d]" />
            <span className="text-sm font-medium">Soil pH Sensor</span>
          </div>
          <span className={`px-3 py-1 rounded-full text-xs font-medium ${
            sensorStatus.soil_ph 
              ? 'bg-green-100 text-green-800' 
              : 'bg-red-100 text-red-800'
          }`}>
            {sensorStatus.soil_ph ? 'Active' : 'Inactive'}
          </span>
        </div>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <BsSun className="text-[#deb83c]" />
            <span className="text-sm font-medium">Light Intensity Sensor</span>
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

      <div className="mt-4 pt-4 border-t border-gray-200">
        <div className="flex items-center justify-between text-sm">
          <span className="text-gray-600">Last Updated:</span>
          <span className="font-medium">
            {sensorData?.timestamp 
              ? new Date(sensorData.timestamp).toLocaleTimeString() 
              : 'N/A'}
          </span>
        </div>
      </div>
    </div>
  );

  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <main className="py-10">
        <div className="flex flex-col lg:flex-row gap-10">
          <div className="w-full lg:w-1/3 space-y-6">
            {/* Temperature Card */}
            <div className="bg-white flex items-center gap-4 rounded-xl p-4 shadow-md">
              <FaThermometerHalf className="text-[#e74c3c] text-3xl" />
              <div className="text-md font-semibold">
                TEMPERATURE: <span className="text-[#356B2C]"> {measurements.temperature}°C</span>
              </div>
            </div>

            {/* Sensor Status */}
            {renderSensorStatus()}
          </div>
          <div className="w-full lg:w-2/3 grid grid-cols-1 sm:grid-cols-2 gap-6">
            {/* Soil Moisture */}
            <div className="bg-(--color-rwhite) rounded-xl p-5 shadow-md text-center">
              <FaMountain className="text-3xl mb-2 mx-auto text-[#7a5c2d]" />
              <p className="text-sm font-semibold uppercase">Soil Moisture:</p>
              <div className="text-4xl text-(--color-dgreen) font-bold my-2">{measurements.soil_moisture}</div>
              <span className={`inline-block ${
                measurements.soil_moisture < 30 
                  ? 'bg-(--color-lred) text-(--color-red)' 
                  : 'bg-(--color-llgreen) text-(--color-dgreen)'
              } text-xs font-medium px-3 py-1 rounded-full`}>
                {measurements.soil_moisture < 30 ? 'Low Moisture' : 'Good Condition'}
              </span>            
            </div>

            {/* Soil Ph Level */}
            <div className="bg-(--color-rwhite) rounded-xl p-5 shadow-md text-center">
              <FaMountain className="text-3xl mb-2 mx-auto text-[#7a5c2d]" />
              <p className="text-sm font-semibold uppercase">Soil pH Level:</p>
              <div className="text-4xl text-(--color-dgreen) font-bold my-2">{measurements.soil_ph}</div>
              <span className={`inline-block ${
                measurements.soil_ph > 7 
                  ? 'bg-(--color-lred) text-(--color-red)' 
                  : 'bg-(--color-llgreen) text-(--color-dgreen)'
              } text-xs font-medium px-3 py-1 rounded-full`}>
                {measurements.soil_ph < 7 ? 'Good Condition' : 'Soil pH indicates alkalinity'}
              </span>          
            </div>

            {/* Humidity */}
            <div className="bg-(--color-rwhite) rounded-2xl p-6 shadow-md text-left space-y-4">
              <div className="flex items-center gap-2">
                <IoWaterOutline className="text-2xl text-[#2d67c4]" />
                <p className="text-sm font-semibold uppercase">Humidity:</p>
              </div>
              <div className="relative w-full h-10 bg-[#e0e0e1] rounded-full overflow-hidden">
                <div 
                  className="bg-[#2d67c4] h-full rounded-full flex items-center justify-center text-white text-sm font-semibold"
                  style={{ width: `${measurements.humidity}%` }}
                >
                  {measurements.humidity}%
                </div>
              </div>
              <div className="text-center">
                <span className={`inline-block ${
                  measurements.humidity < 40 
                    ? 'bg-(--color-lred) text-(--color-red)' 
                    : 'bg-(--color-llgreen) text-(--color-dgreen)'
                } text-xs font-medium px-3 py-1 rounded-full`}>
                  {measurements.humidity < 40 ? 'Too Low' : 'Good Condition'}
                </span>
              </div>
            </div>

            {/* Light Intensity */}
            <div className="bg-(--color-rwhite) rounded-2xl p-6 shadow-md text-left space-y-4">
              <div className="flex items-center gap-2">
                <BsSun className="text-2xl text-[#deb83c]" />
                <p className="text-sm font-semibold uppercase">Light Intensity:</p>
              </div>
              <div className="relative w-full h-10 bg-[#e0e0e1] rounded-full overflow-hidden">
                <div 
                  className={`h-full rounded-full flex items-center justify-center text-white text-sm font-semibold" ${
                    measurements.light_level < 20}`}
                  style={{
                    width: `${measurements.light_level} LUX`,
                    backgroundColor: '#e0bc46',
                  }}
                >
                  {measurements.light_level} LUX
                </div>
              </div>
              <div className="text-center">
                <span className={`inline-block ${
                  measurements.light_level < 50 
                    ? 'bg-(--color-lred) text-(--color-red)' 
                    : 'bg-(--color-llgreen) text-(--color-dgreen)'
                } text-xs font-medium px-3 py-1 rounded-full`}>
                  {measurements.light_level < 50 ? 'Low Light' : 'Best Condition'}
                </span>
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