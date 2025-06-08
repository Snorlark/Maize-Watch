import React, { useState } from 'react';
import Footer from "../components/Footer";
import TemperatureChart from "../components/dashboardTables/TemperatureChart";
import SoilMoistureChart from "../components/dashboardTables/SoilMoistureChart";
import HumidityChart from "../components/dashboardTables/HumidityChart";
import LightIntensityChart from "../components/dashboardTables/LightIntensityChart";
import SoilPhLevelChart from "../components/dashboardTables/SoilPhLevelChart";
import ExportDataModal from "../components/ExportDataModal";

const Dashboard = () => {
  const [showExportModal, setShowExportModal] = useState(false);
  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      
      <div className="max-w-7xl mx-auto space-y-10">
        <TemperatureChart />
        <SoilMoistureChart />
        <HumidityChart />
        <LightIntensityChart />
        <SoilPhLevelChart />
      </div>
      <button
        onClick={() => setShowExportModal(true)}
        className="px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
      >
        Export Data
      </button>

      {/* Export Modal */}
      <ExportDataModal
        isOpen={showExportModal}
        onClose={() => setShowExportModal(false)}
      />
      <br />
      <Footer />
    </div>
  );
};

export default Dashboard;
