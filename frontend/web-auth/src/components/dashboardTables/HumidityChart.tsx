import React, { useState, useRef, useEffect } from "react";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from "recharts";
import { Download, X } from "lucide-react";
import { fetchAndFormatData, getDefaultData, DataItem } from "../../utils/dataAveraging";
import { handleExport } from "../../utils/ExportUtils";

type ExportModalProps = {
  isOpen: boolean;
  onClose: () => void;
  chartRef: React.RefObject<HTMLDivElement | null>;
  chartData: DataItem[];
  xKey: string;
};

const ExportModal = ({ isOpen, onClose, chartRef, chartData, xKey }: ExportModalProps) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white p-4 rounded-lg">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-semibold text-[#356B2C]">Export Chart</h3>
          <button onClick={onClose} className="text-[#356B2C] hover:text-[#79A842]">
            <X size={20} />
          </button>
        </div>
        <div className="space-y-2">
          <button
            onClick={() => handleExport("pdf", chartRef.current, chartData, xKey, "Humidity")}
            className="w-full px-4 py-2 bg-[#356B2C] text-white rounded hover:bg-[#79A842]"
          >
            Export as PDF
          </button>
          <button
            onClick={() => handleExport("csv", chartRef.current, chartData, xKey, "Humidity")}
            className="w-full px-4 py-2 bg-[#356B2C] text-white rounded hover:bg-[#79A842]"
          >
            Export as CSV
          </button>
          <button
            onClick={() => handleExport("svg", chartRef.current, chartData, xKey, "Humidity")}
            className="w-full px-4 py-2 bg-[#356B2C] text-white rounded hover:bg-[#79A842]"
          >
            Export as SVG
          </button>
        </div>
      </div>
    </div>
  );
};

const HumidityChart = () => {
  const [overview, setOverview] = useState<string>("days");
  const [chartData, setChartData] = useState<DataItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const chartRef = useRef<HTMLDivElement>(null);
  const [showExportModal, setShowExportModal] = useState<boolean>(false);
  const [xKey, setXKey] = useState<string>("day");

  useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true);
      try {
        const { chartData: newData, xKey: newXKey } = await fetchAndFormatData(overview, 'humidity');
        setChartData(newData);
        setXKey(newXKey);
      } catch (error) {
        console.error("Error fetching humidity data:", error);
        const { chartData: defaultData, xKey: defaultXKey } = getDefaultData(overview);
        setChartData(defaultData);
        setXKey(defaultXKey);
      } finally {
        setIsLoading(false);
      }
    };

    fetchData();
  }, [overview]);

  return (
    <div className="bg-[#E6F0D3] p-4 rounded-2xl">
      <h2 className="text-[#356B2C] text-lg font-semibold mb-2">Humidity</h2>

      <div className="flex justify-between items-center mb-3">
        <div>
          <label htmlFor="overview" className="block text-xs text-[#356B2C] mb-1">
            View by :
          </label>
          <select
            id="overview"
            className="text-xs border px-3 py-2 rounded shadow bg-white text-[#356B2C]"
            value={overview}
            onChange={(e) => setOverview(e.target.value)}
          >
            <option value="days">Days</option>
            <option value="weeks">Weeks</option>
            <option value="months">Months</option>
          </select>
        </div>

        <button
          onClick={() => setShowExportModal(true)}
          className="flex items-center gap-1 text-[#356B2C] text-xs hover:bg-[#d6e3bc] px-2 py-1 rounded transition-colors"
        >
          <Download size={13} />
          Export
        </button>
      </div>

      <div
        ref={chartRef}
        className="bg-white py-9 pr-8 rounded-xl border border-[#356B2C]"
        style={{ height: 420 }}
      >
        {isLoading ? (
          <div className="flex items-center justify-center h-full">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#356B2C]"></div>
          </div>
        ) : (
          <ResponsiveContainer width="100%" height={360}>
            <BarChart data={chartData}>
              <XAxis dataKey={xKey} />
              <YAxis />
              <Tooltip />
              <Bar dataKey="value" fill="#79A842" radius={[100, 100, 100, 100]} barSize={10} />
            </BarChart>
          </ResponsiveContainer>
        )}
      </div>

      <ExportModal
        isOpen={showExportModal}
        onClose={() => setShowExportModal(false)}
        chartRef={chartRef}
        chartData={chartData}
        xKey={xKey}
      />
    </div>
  );
};

export default HumidityChart;