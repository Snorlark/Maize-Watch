import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import { Download } from "lucide-react";
import { jsPDF } from "jspdf";
import * as htmlToImage from "html-to-image";
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  ComposedChart
} from "recharts";
import { useState, useRef } from "react";





const dataDay = [
  { day: "Monday", value: 75 },
  { day: "Tuesday", value: 60 },
  { day: "Wednesday", value: 90 },
  { day: "Thursday", value: 50 },
  { day: "Friday", value: 100 },
  { day: "Saturday", value: 70 },
  { day: "Sunday", value: 85 }
];

const dataWeek = [
  { week: "Week 1", value: 200 },
  { week: "Week 2", value: 300 },
  { week: "Week 3", value: 250 },
  { week: "Week 4", value: 280 }
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
  { month: "Dec", value: 85 }
];

const dataYear = [
  { year: 2021, value: 90 },
  { year: 2022, value: 60 },
  { year: 2023, value: 95 },
  { year: 2024, value: 70 },
  { year: 2025, value: 85 }
];

type ChartDataItem = {
  [key: string]: string | number;
  value: number;
};



const ChartCard = ({ title, type }: { title: string; type: string }) => {
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







  const handleExport = async (format: string) => {
    const chartNode = chartRef.current;
  
    if (!chartNode) return;
  
    if (format === "pdf") {
      const dataUrl = await htmlToImage.toPng(chartNode);
      const pdf = new jsPDF("landscape", "mm", "a4");
      const imgProps = pdf.getImageProperties(dataUrl);
      const pdfWidth = pdf.internal.pageSize.getWidth();
      const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;
      pdf.addImage(dataUrl, "PNG", 10, 20, pdfWidth - 20, pdfHeight);
      pdf.setFontSize(16);
      pdf.text(title, 10, 15);
      pdf.save(`${title}.pdf`);
    }
  
    if (format === "svg") {
      htmlToImage.toSvg(chartNode).then((dataUrl) => {
        const link = document.createElement("a");
        link.download = `${title}.svg`;
        link.href = dataUrl;
        link.click();
      });
    }
  
    if (format === "csv") {
      const rows = (chartData as ChartDataItem[]).map((row) =>
        `${row[xKey]},${row.value}`
      );
      const csv = `${xKey},value\n${rows.join("\n")}`;
      const blob = new Blob([csv], { type: "text/csv" });
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.download = `${title}.csv`;
      link.href = url;
      link.click();
    }
  };
  




  return (
    <div className="bg-[#E6F0D3] p-4 rounded-2xl">
      <h2 className="text-[#356B2C] text-lg font-semibold mb-2">{title}</h2>

      <div className="flex justify-between items-center mb-3">
        <div>
          <label htmlFor="overview" className="block text-xs text-[#356B2C] mb-1">
            View by :
          </label>
          <select
            id="overview"
            className="text-xs border px-3 py-2 rounded shadow bg-(--color-rwhite)  text-[#356B2C]"
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
          <div className="absolute right-0 mt-1 bg-(--color-rwhite) border border-[#356B2C] rounded shadow-md text-xs hidden group-hover:block z-10">
            <button className="block px-4 py-2 hover:bg-[#E6F0D3] w-full text-left" onClick={() => handleExport("pdf")}>PDF</button>
            <button className="block px-4 py-2 hover:bg-[#E6F0D3] w-full text-left" onClick={() => handleExport("csv")}>CSV</button>
            <button className="block px-4 py-2 hover:bg-[#E6F0D3] w-full text-left" onClick={() => handleExport("svg")}>SVG</button>
          </div>
        </div>
      </div>

      <div ref={chartRef} className="bg-(--color-rwhite) py-9 pr-8 rounded-xl  border border-[#356B2C] space-y-2" style={{ height: 420 }}>
      <ResponsiveContainer width="100%" height={360}>
        {
          type === "bar" ? (
            <BarChart data={chartData}>
              <XAxis dataKey={xKey} />
              <YAxis />
              <Tooltip />
              <Bar dataKey="value" fill="#79A842" radius={[100, 100, 100, 100]} barSize={10} />
            </BarChart>
          ) : type === "line" ? (
            <LineChart data={chartData}>
              <XAxis dataKey={xKey} />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="value" stroke="#79A842" fill="#D6E8B5" />
            </LineChart>
          ) : (
            <ComposedChart data={dataYear}>
              <XAxis dataKey="year" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="value" barSize={20} fill="#79A842" />
            </ComposedChart>
          )
        }
      </ResponsiveContainer>

      </div>
    </div>
  );
};




const Dashboard = () => {
  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <Navbar />
      <div className="max-w-7xl mx-auto space-y-10">
        <ChartCard title="Temperature" type="bar" />
        <ChartCard title="Soil Moisture" type="line" />
        <ChartCard title="Humidity" type="bar" />
        <ChartCard title="Light Intensity" type="bar" />
        <ChartCard title="Soil Ph Level" type="line" />
      </div>
      <br/>
      <Footer />
    </div>
  );
};

export default Dashboard;