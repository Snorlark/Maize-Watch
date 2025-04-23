import { useState, useRef } from "react";
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer } from "recharts";
import { Download } from "lucide-react";
import { handleExport } from "../../utils/ExportUtils";

const dataDay = [
  { day: "Monday", value: 75 },
  { day: "Tuesday", value: 60 },
  { day: "Wednesday", value: 90 },
  { day: "Thursday", value: 50 },
  { day: "Friday", value: 100 },
  { day: "Saturday", value: 70 },
  { day: "Sunday", value: 85 },
];

const dataWeek = [
  { week: "Week 1", value: 200 },
  { week: "Week 2", value: 300 },
  { week: "Week 3", value: 250 },
  { week: "Week 4", value: 280 },
];

const dataMonth = [
  { month: "Jan", value: 75 },
  { month: "Feb", value: 50 },
  { month: "Mar", value: 65 },
  { month: "Apr", value: 90 },
  { month: "May", value: 70 },
  { month: "Jun", value: 80 },
  { month: "Jul", value: 85 },
  { month: "Aug", value: 100 },
  { month: "Sep", value: 70 },
  { month: "Oct", value: 75 },
  { month: "Nov", value: 70 },
  { month: "Dec", value: 85 },
];

const SoilMoistureChart = () => {
  const [overview, setOverview] = useState("days");
  const chartRef = useRef(null);

  let chartData;
  let xKey;

  if (overview === "days") {
    chartData = dataDay;
    xKey = "day";
  } else if (overview === "weeks") {
    chartData = dataWeek;
    xKey = "week";
  } else {
    chartData = dataMonth;
    xKey = "month";
  }

  return (
    <div className="bg-[#E6F0D3] p-4 rounded-2xl">
      <h2 className="text-[#356B2C] text-lg font-semibold mb-2">Soil Moisture</h2>

      <div className="flex justify-between items-center mb-3">
        <div>
          <label htmlFor="overview" className="block text-xs text-[#356B2C] mb-1">View by :</label>
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

        <div className="relative group">
          <button className="flex items-center gap-1 text-[#356B2C] text-xs hover:underline">
            <Download size={13} />
            Export
          </button>
          <div className="absolute right-0 mt-1 bg-white border border-[#356B2C] rounded shadow-md text-xs hidden group-hover:block z-10">
            <button onClick={() => handleExport("pdf", chartRef.current, chartData, xKey, "Soil Moisture")} className="block px-4 py-2 hover:bg-[#E6F0D3] w-full text-left">PDF</button>
            <button onClick={() => handleExport("csv", chartRef.current, chartData, xKey, "Soil Moisture")} className="block px-4 py-2 hover:bg-[#E6F0D3] w-full text-left">CSV</button>
            <button onClick={() => handleExport("svg", chartRef.current, chartData, xKey, "Soil Moisture")} className="block px-4 py-2 hover:bg-[#E6F0D3] w-full text-left">SVG</button>
          </div>
        </div>
      </div>

      <div ref={chartRef} className="bg-white py-9 pr-8 rounded-xl border border-[#356B2C]" style={{ height: 420 }}>
        <ResponsiveContainer width="100%" height={360}>
          <LineChart data={chartData}>
            <XAxis dataKey={xKey} />
            <YAxis />
            <Tooltip />
            <Line type="monotone" dataKey="value" stroke="#79A842" fill="#D6E8B5" />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default SoilMoistureChart;