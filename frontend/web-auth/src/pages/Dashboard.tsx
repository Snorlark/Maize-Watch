import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import TemperatureChart from "../components/dashboardTables/TemperatureChart";
import SoilMoistureChart from "../components/dashboardTables/SoilMoistureChart";
import HumidityChart from "../components/dashboardTables/HumidityChart";
import LightIntensityChart from "../components/dashboardTables/LightIntensityChart";
import SoilPhLevelChart from "../components/dashboardTables/SoilPhLevelChart";

const Dashboard = () => {
  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <Navbar />
      <div className="max-w-7xl mx-auto space-y-10">
        <TemperatureChart />
        <SoilMoistureChart />
        <HumidityChart />
        <LightIntensityChart />
        <SoilPhLevelChart />
      </div>
      <br />
      <Footer />
    </div>
  );
};

export default Dashboard;
