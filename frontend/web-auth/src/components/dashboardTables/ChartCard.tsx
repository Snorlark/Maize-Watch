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
    <div className="bg-[#E6F0D3] p-4 sm:p-6 rounded-2xl shadow-lg hover:shadow-xl transition-all duration-300 border border-[#B8D4A8]/30">
      <h2 className="text-[#356B2C] text-lg sm:text-xl font-semibold mb-3 sm:mb-4">{title}</h2>

      <div className="flex justify-between items-center mb-4 sm:mb-6">
        <div></div>
        <div className="relative group">
          <button className="flex items-center gap-2 text-[#356B2C] text-sm sm:text-base hover:text-[#8B4513] transition-colors px-3 py-2 rounded-lg hover:bg-white/50 cursor-pointer">
            <Download size={16} />
            <span className="hidden sm:inline">Export</span>
          </button>
          <div className="absolute right-0 mt-2 bg-white border border-[#356B2C] rounded-lg shadow-lg text-sm hidden group-hover:block z-10 min-w-[120px]">
            <button 
              className="block px-4 py-3 hover:bg-[#8B4513] hover:text-[#F5F5DC] w-full text-left transition-colors rounded-t-lg cursor-pointer" 
              onClick={() => handleExport("pdf", chartRef.current, data, xKey, title)}
            >
              PDF
            </button>
            <button 
              className="block px-4 py-3 hover:bg-[#8B4513] hover:text-[#F5F5DC] w-full text-left transition-colors cursor-pointer" 
              onClick={() => handleExport("csv", chartRef.current, data, xKey, title)}
            >
              CSV
            </button>
            <button 
              className="block px-4 py-3 hover:bg-[#8B4513] hover:text-[#F5F5DC] w-full text-left transition-colors rounded-b-lg cursor-pointer" 
              onClick={() => handleExport("svg", chartRef.current, data, xKey, title)}
            >
              SVG
            </button>
          </div>
        </div>
      </div>

      <div 
        ref={chartRef} 
        className="bg-white py-4 sm:py-6 px-2 sm:px-4 rounded-xl border border-[#356B2C] shadow-inner overflow-hidden" 
        style={{ 
          height: 'clamp(300px, 50vh, 500px)',
          minHeight: '300px'
        }}
      >
        <div className="w-full h-full flex items-center justify-center">
        {chart}
        </div>
      </div>
    </div>
  );
};

export default ChartCard;