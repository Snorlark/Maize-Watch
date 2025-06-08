import React, { useState, useRef, useEffect, JSX } from "react";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from "recharts";
import { Download, X, Calendar } from "lucide-react";
import { fetchAndFormatData, getDefaultData, DataItem } from "../../utils/dataAveraging";
import ExportDataModal from "../../components/ExportDataModal";

const HumidityChart = () => {
  const [overview, setOverview] = useState<string>("days");
  const [chartData, setChartData] = useState<DataItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const chartRef = useRef<HTMLDivElement>(null);
  const [showExportModal, setShowExportModal] = useState<boolean>(false);
  const [xKey, setXKey] = useState<string>("day");

  const xAxisLabels = {
    days: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
    weeks: ["Week 1", "Week 2", "Week 3", "Week 4"],
    months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  };

  useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true);
      try {
        const { chartData: newData, xKey: newXKey } = await fetchAndFormatData(overview, 'humidity');
        const formattedData = xAxisLabels[overview as keyof typeof xAxisLabels].map((label) => {
          const matchingData = newData.find(item => item[newXKey] === label);
          return {
            [newXKey]: label,
            value: matchingData ? matchingData.value : 0
          };
        });
        
        setChartData(formattedData);
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
        <h2 className="text-[#356B2C] text-lg font-semibold mb-2">Humidty</h2>
  
        <div className="flex justify-between items-center mb-3">
          <div>
            <label htmlFor="overview" className="block text-xs text-[#356B2C] mb-1">
              View by :
            </label>
            <select
              id="overview"
              className="text-xs border pl-1 py-2 rounded shadow bg-white text-[#356B2C] "
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
                <XAxis 
                  dataKey={xKey} 
                  tick={{ fontSize: 12, fill: '#356B2C' }}
                  axisLine={{ stroke: '#356B2C' }}
                />
                <YAxis 
                  tick={{ fontSize: 12, fill: '#356B2C' }}
                  axisLine={{ stroke: '#356B2C' }}
                  label={{ 
                    value: '', 
                    angle: -90, 
                    position: 'insideLeft',
                    style: { textAnchor: 'middle', fill: '#356B2C' }
                  }}
                />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#E6F0D3',
                    border: '1px solid #356B2C',
                    borderRadius: '4px'
                  }}
                  labelStyle={{ color: '#356B2C' }}
                />
                <Bar 
                  dataKey="value" 
                  fill="#79A842" 
                  radius={[100, 100, 100, 100]} 
                  barSize={10}
                />
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>

      <ExportDataModal
        isOpen={showExportModal}
        onClose={() => setShowExportModal(false)}
      />
    </div>
  );
};

export default HumidityChart;