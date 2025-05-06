import React, { useEffect, useState } from 'react'
import axios from 'axios'
import Navbar from '../components/Navbar'
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
    light_level: number;
  };
}

const LiveData: React.FC = () => {
  const [sensorData, setSensorData] = useState<SensorData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get('http://localhost:8080/api/latest');
        if (response.data && response.data.length > 0) {
          setSensorData(response.data[0]); // Get the first field's data
        }
        setLoading(false);
      } catch (err) {
        setError('Failed to fetch sensor data');
        setLoading(false);
        console.error('Error fetching data:', err);
      }
    };

    fetchData();
    // Refresh data every 30 seconds
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, []);

  if (loading) return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <Navbar />
      <main className="py-10">
        <div className="text-center">Loading sensor data...</div>
      </main>
      <Footer />
    </div>
  );

  if (error) return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <Navbar />
      <main className="py-10">
        <div className="text-center text-red-500">{error}</div>
      </main>
      <Footer />
    </div>
  );

  if (!sensorData) return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <Navbar />
      <main className="py-10">
        <div className="text-center">No sensor data available</div>
      </main>
      <Footer />
    </div>
  );

  const { measurements } = sensorData;

  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">

      <Navbar />

      <main className="py-10">
        <div className="flex flex-col lg:flex-row gap-10">
          <div className="w-full lg:w-1/3 space-y-6">
            <div>
              <label className="text-lg font-semibold block mb-2">Status from:</label>
              <select className="bg-(--color-rwhite) rounded-md px-4 py-2 w-full shadow-sm text-(--color-dgreen) focus:outline-none ">
                <option>Select Overview</option>
                <option>Current Status</option>
                <option>Daily Summary</option>
              </select>
            </div>




          
            {/* Temperature Card */}
            <div className="bg-(--color-rwhite) flex items-center gap-4 rounded-xl p-4 shadow-md">
              <FaThermometerHalf className="text-(--color-red) text-3xl" />
              <div className="text-md font-semibold">
                TEMPERATURE: <span className="text-(--color-dgreen)"> {measurements.temperature}°C</span>
              </div>
            </div>

            {/* Alerts */}
            <div>
              <h2 className="text-lg font-bold text-[#406326] mb-2">Alerts:</h2>
              <ul className="space-y-2">
                {measurements.soil_moisture < 30 && (
                  <li className="flex items-start gap-2 text-(--color-dgreen) text-sm">
                    <FaExclamationCircle className="mt-0.5 text-(--color-red)" /> Low soil moisture
                  </li>
                )}
                {measurements.humidity < 40 && (
                  <li className="flex items-start gap-2 text-(--color-dgreen) text-sm">
                    <FaExclamationCircle className="mt-0.5 text-(--color-red)" /> Low humidity
                  </li>
                )}
              </ul>
            </div>
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

            {/* Soil Humidity */}
            <div className="bg-(--color-rwhite) rounded-xl p-5 shadow-md text-center">
              <FaMountain className="text-3xl mb-2 mx-auto text-[#7a5c2d]" />
              <p className="text-sm font-semibold uppercase">Soil Humidity:</p>
              <div className="text-4xl text-(--color-dgreen) font-bold my-2">{measurements.humidity}</div>
              <span className={`inline-block ${
                measurements.humidity < 40 
                  ? 'bg-(--color-lred) text-(--color-red)' 
                  : 'bg-(--color-llgreen) text-(--color-dgreen)'
              } text-xs font-medium px-3 py-1 rounded-full`}>
                {measurements.humidity < 40 ? 'Low Humidity' : 'Best Condition'}
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
                  className="bg-[#2d67c4] h-full rounded-full flex items-center justify-start px-2 text-white text-sm font-semibold"
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
                  className="bg-[#e0bc46] h-full rounded-full flex items-center justify-center text-white text-sm font-semibold"
                  style={{ width: `${measurements.light_level}%` }}
                >
                  {measurements.light_level}%
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