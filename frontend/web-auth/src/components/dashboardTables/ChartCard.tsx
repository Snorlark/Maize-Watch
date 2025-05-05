import { Download } from "lucide-react";
import { handleExport } from "../../utils/ExportUtils"; // also fix: make sure you're using named import
import { JSX, useRef } from "react";

type ChartDataPoint = {
  [key: string]: string | number;
  value: number;
};

type ChartCardProps = {
  title: string;
  chart: JSX.Element;
  data: ChartDataPoint[]; // ✅ correct type here
  xKey: string;
};

const ChartCard = ({ title, chart, data, xKey }: ChartCardProps) => {
  const chartRef = useRef<HTMLDivElement>(null);

  return (
    <div className="bg-[#E6F0D3] p-4 rounded-2xl">
      <h2 className="text-[#356B2C] text-lg font-semibold mb-2">{title}</h2>

      <div className="flex justify-between items-center mb-3">
        <div></div>
        <div className="relative group">
          <button className="flex items-center gap-1 text-[#356B2C] text-xs hover:underline">
            <Download size={13} />
            Export
          </button>
          <div className="absolute right-0 mt-1 bg-white border border-[#356B2C] rounded shadow-md text-xs hidden group-hover:block z-10">
            <button className="block px-4 py-2 hover:bg-[#E6F0D3] w-full text-left" onClick={() => handleExport("pdf", chartRef.current, data, xKey, title)}>PDF</button>
            <button className="block px-4 py-2 hover:bg-[#E6F0D3] w-full text-left" onClick={() => handleExport("csv", chartRef.current, data, xKey, title)}>CSV</button>
            <button className="block px-4 py-2 hover:bg-[#E6F0D3] w-full text-left" onClick={() => handleExport("svg", chartRef.current, data, xKey, title)}>SVG</button>
          </div>
        </div>
      </div>

      <div ref={chartRef} className="bg-white py-9 pr-8 rounded-xl border border-[#356B2C]" style={{ height: 420 }}>
        {chart}
      </div>
    </div>
  );
};

export default ChartCard;