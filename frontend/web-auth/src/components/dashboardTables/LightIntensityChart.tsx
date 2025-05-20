import { useState, useRef, RefObject, JSX } from "react";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from "recharts";
import { Download, X, Calendar } from "lucide-react";
import { handleExport } from "../../utils/ExportUtils";

// Data types
type DataItem = {
  value: number;
  [key: string]: string | number;
};

type ExportModalProps = {
  isOpen: boolean;
  onClose: () => void;
  chartRef: RefObject<HTMLDivElement | null>;
  chartData: DataItem[];
  xKey: string;
};

type DatePickerProps = {
  selectedDate: string;
  onDateSelect: (date: string) => void;
  isVisible: boolean;
  setIsVisible: (visible: boolean) => void;
};

// Sample data
const dataDay: DataItem[] = [
  { day: "Monday", value: 75 },
  { day: "Tuesday", value: 60 },
  { day: "Wednesday", value: 90 },
  { day: "Thursday", value: 50 },
  { day: "Friday", value: 100 },
  { day: "Saturday", value: 70 },
  { day: "Sunday", value: 85 },
];

const dataWeek: DataItem[] = [
  { week: "Week 1", value: 200 },
  { week: "Week 2", value: 300 },
  { week: "Week 3", value: 250 },
  { week: "Week 4", value: 280 },
];

const dataMonth: DataItem[] = [
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

const dataYear: DataItem[] = [
  { year: "2021", value: 850 },
  { year: "2022", value: 920 },
  { year: "2023", value: 880 },
  { year: "2024", value: 950 },
  { year: "2025", value: 1050 },
];

// Date Picker
const DatePicker: React.FC<DatePickerProps> = ({
  selectedDate,
  onDateSelect,
  isVisible,
  setIsVisible,
}) => {
  if (!isVisible) return null;

  const currentDate = new Date();
  const year = currentDate.getFullYear();
  const month = currentDate.getMonth();
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const firstDay = new Date(year, month, 1).getDay();

  const days: JSX.Element[] = [];

  for (let i = 0; i < firstDay; i++) {
    days.push(<div key={`empty-${i}`} className="h-8 w-8"></div>);
  }

  for (let i = 1; i <= daysInMonth; i++) {
    const dateStr = `${year}-${String(month + 1).padStart(2, "0")}-${String(i).padStart(2, "0")}`;
    days.push(
      <button
        key={i}
        onClick={() => {
          onDateSelect(dateStr);
          setIsVisible(false);
        }}
        className={`h-8 w-8 rounded-full hover:bg-[#79A842] hover:text-white ${
          dateStr === selectedDate ? "bg-[#356B2C] text-white" : ""
        }`}
      >
        {i}
      </button>
    );
  }

  return (
    <div className="absolute z-10 mt-1 p-2 bg-white border border-[#356B2C] rounded-md shadow-lg">
      <div className="text-center font-bold mb-2 text-[#356B2C]">
        {new Date(year, month).toLocaleString("default", { month: "long" })} {year}
      </div>
      <div className="grid grid-cols-7 gap-1 text-center">
        {["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"].map((day) => (
          <div key={day} className="font-semibold text-[#356B2C]">
            {day}
          </div>
        ))}
        {days}
      </div>
    </div>
  );
};

// Modal
const ExportModal: React.FC<ExportModalProps> = ({
  isOpen,
  onClose,
  chartRef,
  chartData,
  xKey,
}) => {
  const [exportFormat, setExportFormat] = useState<string>("PDF");
  const [timeFrame, setTimeFrame] = useState<string>("days");
  const [exportType, setExportType] = useState<string>("predefined");
  const [startDate, setStartDate] = useState<string>("");
  const [endDate, setEndDate] = useState<string>("");
  const [showStartCalendar, setShowStartCalendar] = useState<boolean>(false);
  const [showEndCalendar, setShowEndCalendar] = useState<boolean>(false);

  const getDataForTimeFrame = (): DataItem[] => {
    switch (timeFrame) {
      case "days":
        return dataDay;
      case "weeks":
        return dataWeek;
      case "months":
        return dataMonth;
      case "years":
        return dataYear;
      default:
        return chartData;
    }
  };

  const getXKeyForTimeFrame = (): string => {
    switch (timeFrame) {
      case "days":
        return "day";
      case "weeks":
        return "week";
      case "months":
        return "month";
      case "years":
        return "year";
      default:
        return xKey;
    }
  };

  const handleExportClick = () => {
  const dataToExport = getDataForTimeFrame();
  const keyToUse = getXKeyForTimeFrame();

  const exportConfig = {
    format: exportFormat.toLowerCase(),
    data: dataToExport,
    key: keyToUse,
    title: "Light Intensity",
    dateRange: exportType === "custom" ? { from: startDate, to: endDate } : null,
  };

  console.log("Exporting:", exportConfig);

  // Pass the timeFrame parameter to correctly filter date-specific data
  handleExport(
    exportFormat.toLowerCase(), 
    chartRef.current, 
    dataToExport, 
    keyToUse, 
    "Light Intensity", 
    exportType === "custom" ? { from: startDate, to: endDate } : null,
    timeFrame // Add this parameter
  );
  
  onClose();
};

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-lg max-w-md w-96 p-4">
        <div className="flex justify-between items-center mb-4">
          <h3 className="font-semibold text-[#356B2C]">Export Options</h3>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
            <X size={18} />
          </button>
        </div>

        <div className="mb-4">
          <label className="block text-sm text-[#356B2C] mb-1">Export Format</label>
          <div className="flex gap-2">
            {["PDF", "CSV", "SVG"].map((format) => (
              <button
                key={format}
                onClick={() => setExportFormat(format)}
                className={`px-3 py-1 rounded-md text-sm flex-1 ${
                  exportFormat === format
                    ? "bg-[#79A842] text-white"
                    : "bg-gray-100 text-[#356B2C] hover:bg-gray-200"
                }`}
              >
                {format}
              </button>
            ))}
          </div>
        </div>

        <div className="mb-4">
          <label className="block text-sm text-[#356B2C] mb-1">Export Type</label>
          <div className="flex gap-2">
            <button
              onClick={() => setExportType("predefined")}
              className={`px-3 py-1 rounded-md text-sm flex-1 ${
                exportType === "predefined"
                  ? "bg-[#79A842] text-white"
                  : "bg-gray-100 text-[#356B2C] hover:bg-gray-200"
              }`}
            >
              Predefined Period
            </button>
            <button
              onClick={() => setExportType("custom")}
              className={`px-3 py-1 rounded-md text-sm flex-1 ${
                exportType === "custom"
                  ? "bg-[#79A842] text-white"
                  : "bg-gray-100 text-[#356B2C] hover:bg-gray-200"
              }`}
            >
              Custom Range
            </button>
          </div>
        </div>

        {exportType === "predefined" ? (
          <div className="mb-4">
            <label className="block text-sm text-[#356B2C] mb-1">Time Frame</label>
            <div className="grid grid-cols-2 gap-2">
              {[
                { value: "days", label: "Day" },
                { value: "weeks", label: "Week" },
                { value: "months", label: "Month" },
                { value: "years", label: "Year" },
              ].map((option) => (
                <button
                  key={option.value}
                  onClick={() => setTimeFrame(option.value)}
                  className={`px-3 py-1 rounded-md text-sm ${
                    timeFrame === option.value
                      ? "bg-[#79A842] text-white"
                      : "bg-gray-100 text-[#356B2C] hover:bg-gray-200"
                  }`}
                >
                  {option.label}
                </button>
              ))}
            </div>
          </div>
        ) : (
          <div className="mb-4">
            {["Start", "End"].map((label, i) => {
              const isStart = label === "Start";
              const value = isStart ? startDate : endDate;
              const setValue = isStart ? setStartDate : setEndDate;
              const toggle = isStart ? showStartCalendar : showEndCalendar;
              const setToggle = isStart ? setShowStartCalendar : setShowEndCalendar;
              return (
                <div key={label} className="mb-2">
                  <label className="block text-sm text-[#356B2C] mb-1">{label} Date</label>
                  <div className="relative">
                    <div className="flex items-center">
                      <input
                        type="text"
                        value={value}
                        onChange={(e) => setValue(e.target.value)}
                        placeholder="YYYY-MM-DD"
                        className="w-full p-2 border border-[#356B2C] rounded text-sm"
                      />
                      <button
                        type="button"
                        onClick={() => setToggle(!toggle)}
                        className="absolute right-2 text-[#356B2C]"
                      >
                        <Calendar size={16} />
                      </button>
                    </div>
                    <DatePicker
                      selectedDate={value}
                      onDateSelect={setValue}
                      isVisible={toggle}
                      setIsVisible={setToggle}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        )}

        <div className="flex justify-end gap-2">
          <button
            onClick={onClose}
            className="px-4 py-2 border border-[#356B2C] rounded-md text-[#356B2C] text-sm hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            onClick={handleExportClick}
            className="px-4 py-2 bg-[#356B2C] rounded-md text-white text-sm hover:bg-[#2a5823]"
          >
            Export
          </button>
        </div>
      </div>
    </div>
  );
};

const LightIntensityChart = () => {
  const [overview, setOverview] = useState<string>("days");
  const chartRef = useRef<HTMLDivElement>(null);
  const [showExportModal, setShowExportModal] = useState<boolean>(false);

  let chartData: DataItem[];
  let xKey: string;

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
      <h2 className="text-[#356B2C] text-lg font-semibold mb-2">Light Intensity</h2>

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
        <ResponsiveContainer width="100%" height={360}>
          <BarChart data={chartData}>
            <XAxis dataKey={xKey} />
            <YAxis />
            <Tooltip />
            <Bar dataKey="value" fill="#79A842" radius={[100, 100, 100, 100]} barSize={10} />
          </BarChart>
        </ResponsiveContainer>
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

export default LightIntensityChart;