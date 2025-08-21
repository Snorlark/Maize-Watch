import Footer from "../components/Footer";
import TemperatureChart from "../components/dashboardTables/TemperatureChart";
import SoilMoistureChart from "../components/dashboardTables/SoilMoistureChart";
import HumidityChart from "../components/dashboardTables/HumidityChart";
import LightIntensityChart from "../components/dashboardTables/LightIntensityChart";
import SoilPhLevelChart from "../components/dashboardTables/SoilPhLevelChart";
import { LayoutDashboard, BarChart3, TrendingUp } from "lucide-react";

const Dashboard = () => {
  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8">
      <main className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#1E441E] mb-2 flex items-center gap-3">
            <LayoutDashboard className="w-8 h-8 sm:w-10 sm:h-10 text-[#456C2D]" />
            Dashboard
          </h1>
          <p className="text-[#456C2D] text-sm sm:text-base">
            Monitor your farm's environmental conditions in real-time
          </p>
          <div className="mt-3">
            <span className="inline-flex items-center px-3 py-1 rounded-full text-xs sm:text-sm font-medium bg-[#456C2D] text-[#F5F5DC]">
              Real-time Monitoring
            </span>
          </div>
        </div>

        {/* Charts Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-8 space-y-6 lg:space-y-0">
          <div className="lg:col-span-2">
            <div className="bg-white rounded-xl shadow-lg p-6 mb-6">
              <div className="flex items-center gap-3 mb-4">
                <TrendingUp className="w-6 h-6 text-[#456C2D]" />
                <h2 className="text-xl font-semibold text-[#1E441E]">Temperature Trends</h2>
              </div>
        <TemperatureChart />
            </div>
          </div>
          <div className="lg:col-span-2">
            <div className="bg-white rounded-xl shadow-lg p-6">
              <div className="flex items-center gap-3 mb-4">
                <BarChart3 className="w-6 h-6 text-[#456C2D]" />
                <h2 className="text-xl font-semibold text-[#1E441E]">Soil Moisture</h2>
              </div>
        <SoilMoistureChart />
            </div>
          </div>
          <div className="lg:col-span-2">
            <div className="bg-white rounded-xl shadow-lg p-6">
              <div className="flex items-center gap-3 mb-4">
                <BarChart3 className="w-6 h-6 text-[#456C2D]" />
                <h2 className="text-xl font-semibold text-[#1E441E]">Humidity Levels</h2>
              </div>
        <HumidityChart />
            </div>
          </div>
          <div className="lg:col-span-2">
            <div className="bg-white rounded-xl shadow-lg p-6">
              <div className="flex items-center gap-3 mb-4">
                <BarChart3 className="w-6 h-6 text-[#456C2D]" />
                <h2 className="text-xl font-semibold text-[#1E441E]">Light Intensity</h2>
              </div>
        <LightIntensityChart />
            </div>
          </div>
          <div className="lg:col-span-2">
            <div className="bg-white rounded-xl shadow-lg p-6">
              <div className="flex items-center gap-3 mb-4">
                <BarChart3 className="w-6 h-6 text-[#456C2D]" />
                <h2 className="text-xl font-semibold text-[#1E441E]">Soil pH Levels</h2>
              </div>
        <SoilPhLevelChart />
      </div>
          </div>
        </div>
      </main>
      
      <Footer />
    </div>
  );
};

export default Dashboard;
