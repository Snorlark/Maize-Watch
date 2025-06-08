import React, { useState, useRef, useEffect } from "react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
  ReferenceLine,
} from "recharts";
import {
  Download,
  X,
  Calendar as CalendarIcon,
  ChevronLeft,
  ChevronRight,
  Filter,
  RefreshCw,
  FileText,
  BarChart3,
  LineChart as LineChartIcon,
  Droplet,
  TrendingUp,
  TrendingDown,
} from "lucide-react";
import html2canvas from 'html2canvas';
import jsPDF from 'jspdf';
import { saveAs } from 'file-saver';
import { Calendar as CalendarPicker } from "../ui/calendar";

// Types
interface DataItem {
  [key: string]: string | number | { min: number; max: number; critical: number } | undefined;
  value: number;
  dataPoints?: number;
  threshold: {
    min: number;
    max: number;
    critical: number;
  };
}

interface ThingSpeakEntry {
  created_at: string;
  entry_id: number;
  field2: string;
}

interface ThingSpeakResponse {
  feeds: ThingSpeakEntry[];
  channel: {
    id: number;
    name: string;
    last_entry_id: number;
  };
}

interface ExportModalProps {
  isOpen: boolean;
  onClose: () => void;
  chartData: DataItem[];
  xKey: string;
  currentOverview: string;
  dateRange: string;
  viewType: string;
  chartRef: React.RefObject<HTMLDivElement | null>;
}

interface DatePickerProps {
  selectedDate: string;
  onDateSelect: (date: string) => void;
  isVisible: boolean;
  setIsVisible: (visible: boolean) => void;
}

interface DateRange {
  start: Date;
  end: Date;
}

// Add ThingSpeakData type
interface ThingSpeakData {
  created_at: string;
  field2: string;
}

// API Configuration
const THINGSPEAK_CONFIG = {
  channelId: '2965485',
  apiKey: 'EQ3MYH5XBDSB6K2A',
  field: '2',
  baseUrl: 'https://api.thingspeak.com/channels'
};

// Add humidity thresholds
const HUMIDITY_THRESHOLDS = {
  min: 40, // Minimum optimal humidity
  max: 80, // Maximum optimal humidity
  critical: 90, // Critical humidity
};

// Update the color constants
const HUMIDITY_COLORS = {
  primary: "#3B82F6", // Blue-500
  min: "#93C5FD", // Blue-300
  max: "#1D4ED8", // Blue-700
  critical: "#1E40AF", // Blue-800
  background: "#EFF6FF", // Blue-50
  text: "#1E40AF", // Blue-800
  trend: {
    up: "#22C55E", // Green-500
    down: "#EF4444", // Red-500
    neutral: "#6B7280", // Gray-500
  }
};

// Utility Functions
const getTimescaleForPeriod = (period: string): number => {
  switch (period) {
    case "hourly":
      return 86400; // 24 hours
    case "weekly":
      return 604800; // 7 days
    case "monthly":
      return 2592000; // 30 days
    default:
      return 86400;
  }
};

const fetchThingSpeakData = async (period: string): Promise<ThingSpeakResponse> => {
  const timescale = getTimescaleForPeriod(period);
  const url = `${THINGSPEAK_CONFIG.baseUrl}/${THINGSPEAK_CONFIG.channelId}/fields/${THINGSPEAK_CONFIG.field}.json?api_key=${THINGSPEAK_CONFIG.apiKey}&timescale=${timescale}`;
  
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Failed to fetch data: ${response.statusText}`);
    }
    
    const data = await response.json();
    console.log(`Fetched ${period} data:`, data); // Debug log
    
    return data;
  } catch (error) {
    console.error(`Error fetching ${period} data:`, error);
    throw error;
  }
};

const getWeekRange = (date: Date): { start: Date; end: Date } => {
  const start = new Date(date);
  const day = start.getDay();
  const diff = start.getDate() - day;
  start.setDate(diff);
  start.setHours(0, 0, 0, 0);
  
  const end = new Date(start);
  end.setDate(start.getDate() + 6);
  end.setHours(23, 59, 59, 999);
  
  return { start, end };
};

const getMonthRange = (date: Date): { start: Date; end: Date } => {
  const start = new Date(date.getFullYear(), date.getMonth(), 1);
  const end = new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59, 999);
  return { start, end };
};

const formatDateRange = (start: Date, end: Date): string => {
  const options: Intl.DateTimeFormatOptions = { 
    month: 'short', 
    day: 'numeric', 
    year: 'numeric',
    timeZone: 'Asia/Manila'
  };
  return `${start.toLocaleDateString('en-PH', options)} - ${end.toLocaleDateString('en-PH', options)}`;
};

const convertToPhilippineTime = (utcDateString: string): Date => {
  const utcDate = new Date(utcDateString);
  // Philippines is UTC+8
  const philippineTime = new Date(utcDate.getTime() + (8 * 60 * 60 * 1000));
  return philippineTime;
};

const getCurrentPhilippineTime = (): Date => {
  const now = new Date();
  // Convert current time to Philippine time (UTC+8)
  const philippineTime = new Date(now.getTime() + (8 * 60 * 60 * 1000));
  return philippineTime;
};

const getDayOfWeekName = (dayIndex: number): string => {
  const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  return dayNames[dayIndex];
};

const processHumidityData = (
  data: ThingSpeakData[],
  period: string,
  dateRange?: DateRange
): {
  chartData: DataItem[];
  xKey: string;
  dateRange: string;
} => {
  if (!data || data.length === 0) {
    return getDefaultData(period);
  }

  // Log the first and last few entries from the API
  console.log("API Data Sample:", {
    firstEntry: data[0],
    lastEntry: data[data.length - 1],
    totalEntries: data.length,
  });

  const latestEntry = data[data.length - 1];
  const latestDate = convertToPhilippineTime(latestEntry.created_at);
  
  let chartData: DataItem[] = [];
  let xKey = "";
  let dateRangeStr = "";

  switch (period) {
    case "hourly": {
      // Process hourly data
      const hourlyData: { [key: string]: { sum: number; count: number; dates: string[] } } = {};
      
      // Initialize all hours
      for (let i = 0; i < 24; i++) {
        hourlyData[i.toString()] = { sum: 0, count: 0, dates: [] };
      }
      
      // Process the data
      data.forEach(entry => {
        if (entry.field2) {
          const entryDate = convertToPhilippineTime(entry.created_at);
          const hour = entryDate.getHours().toString();
          const value = parseFloat(entry.field2);
          const dateStr = entryDate.toLocaleTimeString('en-PH');
          
          if (!isNaN(value)) {
            hourlyData[hour].sum += value;
            hourlyData[hour].count += 1;
            if (!hourlyData[hour].dates.includes(dateStr)) {
              hourlyData[hour].dates.push(dateStr);
            }
          }
        }
      });
      
      // Create chart data with averages
      chartData = Object.entries(hourlyData).map(([hour, data]) => ({
        hour,
        value: data.count > 0 ? Math.round(data.sum / data.count * 10) / 10 : 0,
        dataPoints: data.count,
        dates: data.dates.join(', '),
        threshold: {
          min: HUMIDITY_THRESHOLDS.min,
          max: HUMIDITY_THRESHOLDS.max,
          critical: HUMIDITY_THRESHOLDS.critical,
        },
      }));
      
      // Set date range for the last 24 hours
      const endDate = new Date(latestDate);
      const startDate = new Date(endDate);
      startDate.setDate(startDate.getDate() - 1);
      dateRangeStr = formatDateRange(startDate, endDate);
      xKey = 'hour';
      break;
    }
    
    case "weekly": {
      const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      const now = dateRange?.start || new Date();
      const startOfWeek = new Date(now);
      startOfWeek.setDate(now.getDate() - now.getDay()); // Start from Sunday
      const endOfWeek = new Date(startOfWeek);
      endOfWeek.setDate(startOfWeek.getDate() + 6); // End on Saturday

      // Initialize data for each day of the week
      const weeklyData = dayNames.map((day) => ({
        day,
        value: 0,
        count: 0,
      }));

      // Process entries for the week
      data.forEach((entry) => {
        const entryDate = new Date(entry.created_at);
        if (entryDate >= startOfWeek && entryDate <= endOfWeek) {
          const dayIndex = entryDate.getDay(); // 0 for Sunday, 6 for Saturday
          weeklyData[dayIndex].value += parseFloat(entry.field2);
          weeklyData[dayIndex].count += 1;
        }
      });

      // Calculate averages and format data with threshold
      const processedData: DataItem[] = weeklyData.map((day) => ({
        day: day.day,
        value: day.count > 0 ? day.value / day.count : 0,
        threshold: {
          min: HUMIDITY_THRESHOLDS.min,
          max: HUMIDITY_THRESHOLDS.max,
          critical: HUMIDITY_THRESHOLDS.critical,
        },
      }));

      return {
        chartData: processedData,
        xKey: "day",
        dateRange: `${startOfWeek.toLocaleDateString()} - ${endOfWeek.toLocaleDateString()}`,
      };
    }
    
    case "monthly": {
      // Process monthly averages
      const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const monthsData: { [key: string]: { sum: number; count: number } } = {};
      
      // Initialize last 12 months
      for (let i = 11; i >= 0; i--) {
        const monthDate = new Date(latestDate);
        monthDate.setMonth(monthDate.getMonth() - i);
        const monthLabel = monthNames[monthDate.getMonth()];
        monthsData[monthLabel] = { sum: 0, count: 0 };
      }
      
      // Process the data
      data.forEach(entry => {
        if (entry.field2) {
          const entryDate = convertToPhilippineTime(entry.created_at);
          const monthLabel = monthNames[entryDate.getMonth()];
          const value = parseFloat(entry.field2);
          
          if (!isNaN(value) && monthsData[monthLabel]) {
            monthsData[monthLabel].sum += value;
            monthsData[monthLabel].count += 1;
          }
        }
      });
      
      const firstMonth = new Date(latestDate);
      firstMonth.setMonth(firstMonth.getMonth() - 11, 1);
      const lastMonth = new Date(latestDate);
      lastMonth.setMonth(lastMonth.getMonth() + 1, 0);
      dateRangeStr = formatDateRange(firstMonth, lastMonth);
      
      chartData = monthNames.map(month => ({
        month,
        value: monthsData[month].count > 0 ? Math.round(monthsData[month].sum / monthsData[month].count * 10) / 10 : 0,
        dataPoints: monthsData[month].count,
        threshold: {
          min: HUMIDITY_THRESHOLDS.min,
          max: HUMIDITY_THRESHOLDS.max,
          critical: HUMIDITY_THRESHOLDS.critical,
        },
      }));
      xKey = 'month';
      break;
    }
  }

  return { chartData, xKey, dateRange: dateRangeStr };
};

const getDefaultData = (period: string, baseDate?: Date): { chartData: DataItem[]; xKey: string; dateRange: string } => {
  const today = baseDate ? new Date(baseDate) : getCurrentPhilippineTime();
  const defaultThreshold = {
    min: HUMIDITY_THRESHOLDS.min,
    max: HUMIDITY_THRESHOLDS.max,
    critical: HUMIDITY_THRESHOLDS.critical,
  };
  switch (period) {
    case 'hourly': {
      const currentDate = new Date(today);
      const dayOfWeek = currentDate.getDay();
      const startOfWeek = new Date(currentDate);
      startOfWeek.setDate(currentDate.getDate() - dayOfWeek);
      startOfWeek.setHours(0, 0, 0, 0);
      const endOfWeek = new Date(startOfWeek);
      endOfWeek.setDate(startOfWeek.getDate() + 6);
      const dayNames = [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
      ];
      const chartData = dayNames.map((day) => ({
        day,
        value: 0,
        dataPoints: 0,
        dates: "",
        threshold: defaultThreshold,
      }));
      return {
        chartData,
        xKey: 'day',
        dateRange: formatDateRange(startOfWeek, endOfWeek),
      };
    }
    case 'weekly': {
      const weeks = [];
      let start = new Date(today);
      start.setHours(0, 0, 0, 0);
      for (let i = 3; i >= 0; i--) {
        const weekStart = new Date(start);
        weekStart.setDate(start.getDate() - i * 7 - start.getDay());
        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekStart.getDate() + 6);
        weeks.push({
          week: `Week ${4 - i}`,
          value: 0,
          dataPoints: 0,
          threshold: defaultThreshold,
        });
      }
      const firstWeekStart = new Date(start);
      firstWeekStart.setDate(start.getDate() - 21 - start.getDay());
      const lastWeekEnd = new Date(start);
      lastWeekEnd.setDate(start.getDate() + 6 - start.getDay());
      return {
        chartData: weeks,
        xKey: 'week',
        dateRange: formatDateRange(firstWeekStart, lastWeekEnd),
      };
    }
    case 'monthly': {
      const monthNames = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      const chartData = [];
      let monthCursor = new Date(today);
      monthCursor.setDate(1);
      monthCursor.setHours(0, 0, 0, 0);
      for (let i = 11; i >= 0; i--) {
        const month = new Date(monthCursor);
        month.setMonth(monthCursor.getMonth() - i);
        chartData.push({
          month: monthNames[month.getMonth()],
          value: 0,
          dataPoints: 0,
          threshold: defaultThreshold,
        });
      }
      const firstMonth = new Date(today);
      firstMonth.setMonth(firstMonth.getMonth() - 11, 1);
      const lastMonth = new Date(today);
      lastMonth.setMonth(lastMonth.getMonth() + 1, 0);
      return {
        chartData,
        xKey: 'month',
        dateRange: formatDateRange(firstMonth, lastMonth),
      };
    }
    default:
      return { chartData: [], xKey: '', dateRange: '' };
  }
};

// Date Picker Component
const DatePicker: React.FC<DatePickerProps> = ({
  selectedDate,
  onDateSelect,
  isVisible,
  setIsVisible,
}) => {
  return (
    <div className="relative">
      <input
        type="text"
        value={selectedDate}
        readOnly
        className="w-full p-2 border border-gray-300 rounded-md cursor-pointer focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        onClick={() => setIsVisible(!isVisible)}
      />
      <CalendarIcon
        size={16}
        className="absolute right-3 top-3 text-gray-400"
      />
      {isVisible && (
        <CalendarPicker
          selectedDate={new Date(selectedDate)}
          onDateSelect={(date) => {
            onDateSelect(date.toISOString().split('T')[0]);
            setIsVisible(false);
          }}
          isVisible={isVisible}
          setIsVisible={setIsVisible}
        />
      )}
    </div>
  );
};

// Export Modal Component
const ExportModal: React.FC<ExportModalProps> = ({
  isOpen,
  onClose,
  chartData,
  xKey,
  currentOverview,
  dateRange,
  viewType,
  chartRef,
}) => {
  const [exportFormat, setExportFormat] = useState<string>("CSV");
  const [exportType, setExportType] = useState<string>("current");
  const [startDate, setStartDate] = useState<Date>(new Date());
  const [endDate, setEndDate] = useState<Date>(new Date());
  const [showStartCalendar, setShowStartCalendar] = useState<boolean>(false);
  const [showEndCalendar, setShowEndCalendar] = useState<boolean>(false);
  const [isLoadingExport, setIsLoadingExport] = useState<boolean>(false);

  const handleExport = async () => {
    setIsLoadingExport(true);
    
    try {
      if (exportFormat === "CSV") {
        // Create CSV content with headers
        const headers = [
          xKey.charAt(0).toUpperCase() + xKey.slice(1),
          "Humidity",
          "Data Points",
          "Status",
          "Thresholds"
        ];
        
        const rows = chartData.map((item) => {
          const value = item.value as number;
          const threshold = (item as any).threshold as {
            min: number;
            max: number;
            critical: number;
          };
          let status = "Normal";
          if (value < threshold.min) status = "Too Dry";
          else if (value > threshold.critical) status = "Critical";
          else if (value > threshold.max) status = "Too Humid";
          
          return [
            item[xKey],
            value.toFixed(1),
            item.dataPoints || "N/A",
            status,
            `Min: ${threshold.min}, Max: ${threshold.max}, Critical: ${threshold.critical}`
          ];
        });

        const csvContent = [
          headers.join(","),
          ...rows.map(row => row.join(","))
        ].join("\n");
        
        const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8" });
        saveAs(blob, `humidity-data-${currentOverview}-${viewType}-${new Date().toISOString().split('T')[0]}.csv`);
      } else if (exportFormat === "PDF") {
        if (!chartRef.current) {
          throw new Error("Chart reference not found");
        }

        // Create a temporary container for the chart
        const container = document.createElement('div');
        container.style.width = '1200px';
        container.style.height = '800px';
        container.style.position = 'absolute';
        container.style.left = '-9999px';
        container.style.top = '-9999px';
        document.body.appendChild(container);

        // Clone the chart content
        const chartClone = chartRef.current.cloneNode(true) as HTMLElement;
        container.appendChild(chartClone);

        try {
          const canvas = await html2canvas(container, {
            scale: 2,
            useCORS: true,
            logging: false,
            width: 1200,
            height: 800,
            backgroundColor: '#ffffff'
          });

          const imgData = canvas.toDataURL('image/png');
          const pdf = new jsPDF({
            orientation: 'landscape',
            unit: 'mm',
            format: 'a4',
          });

          const pdfWidth = pdf.internal.pageSize.getWidth();
          const pdfHeight = pdf.internal.pageSize.getHeight();
          const imgWidth = canvas.width;
          const imgHeight = canvas.height;
          const ratio = Math.min(pdfWidth / imgWidth, pdfHeight / imgHeight);

          const imgX = (pdfWidth - imgWidth * ratio) / 2;
          const imgY = 20;

          // Add title
          pdf.setFontSize(16);
          pdf.setTextColor(124, 58, 237); // #7C3AED
          pdf.text('Humidity Dashboard', pdfWidth / 2, 15, { align: 'center' });

          // Add subtitle
          pdf.setFontSize(12);
          pdf.setTextColor(75, 85, 99); // text-gray-600
          pdf.text(`${currentOverview.charAt(0).toUpperCase() + currentOverview.slice(1)} View - ${dateRange}`, pdfWidth / 2, 25, { align: 'center' });

          // Add chart
          pdf.addImage(imgData, 'PNG', imgX, imgY, imgWidth * ratio, imgHeight * ratio);

          // Add footer
          pdf.setFontSize(10);
          pdf.setTextColor(107, 114, 128); // text-gray-500
          pdf.text(`Generated on ${new Date().toLocaleString()}`, pdfWidth / 2, pdfHeight - 10, { align: 'center' });

          pdf.save(`humidity-dashboard-${currentOverview}-${viewType}-${new Date().toISOString().split('T')[0]}.pdf`);
        } finally {
          // Clean up
          document.body.removeChild(container);
        }
      } else if (exportFormat === "SVG") {
        if (!chartRef.current) {
          throw new Error("Chart reference not found");
        }

        const svgElement = chartRef.current.querySelector('svg');
        if (!svgElement) {
          throw new Error("SVG element not found");
        }

        // Create a temporary container for the SVG
        const container = document.createElement('div');
        container.style.width = '1200px';
        container.style.height = '800px';
        container.style.position = 'absolute';
        container.style.left = '-9999px';
        container.style.top = '-9999px';
        document.body.appendChild(container);

        // Clone the SVG
        const svgClone = svgElement.cloneNode(true) as SVGElement;
        svgClone.setAttribute('width', '1200');
        svgClone.setAttribute('height', '800');
        container.appendChild(svgClone);

        try {
          const svgData = new XMLSerializer().serializeToString(svgClone);
          const svgBlob = new Blob([svgData], { type: 'image/svg+xml;charset=utf-8' });
          saveAs(svgBlob, `humidity-chart-${currentOverview}-${viewType}-${new Date().toISOString().split('T')[0]}.svg`);
        } finally {
          // Clean up
          document.body.removeChild(container);
        }
      }
      
      onClose();
    } catch (error) {
      console.error("Export failed:", error);
      alert("Export failed. Please try again.");
    } finally {
      setIsLoadingExport(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-2xl max-w-md w-full mx-4 p-6">
        <div className="flex justify-between items-center mb-6">
          <h3 className="text-lg font-semibold text-gray-800">
            Export Humidity Data
          </h3>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Export Format
            </label>
            <div className="grid grid-cols-3 gap-2">
              {[
                { format: "CSV", icon: <FileText size={16} />, label: "CSV" },
                { format: "PDF", icon: <FileText size={16} />, label: "PDF" },
                { format: "SVG", icon: <FileText size={16} />, label: "SVG" },
              ].map(({ format, icon, label }) => (
                <button
                  key={format}
                  onClick={() => setExportFormat(format)}
                  className={`px-3 py-2 rounded-md text-sm font-medium flex items-center justify-center gap-2 transition-colors ${
                    exportFormat === format
                      ? "bg-purple-100 text-purple-600 border-2 border-purple-600"
                      : "bg-gray-50 text-gray-700 hover:bg-gray-100 border-2 border-transparent"
                  }`}
                >
                  {icon}
                  <span>{label}</span>
                </button>
              ))}
            </div>
          </div>

          <div className="p-3 bg-gray-50 rounded-md border border-gray-200">
            <p className="text-sm text-gray-600">
              <strong>Current Range:</strong> {dateRange}
            </p>
            <p className="text-sm text-gray-600">
              <strong>View:</strong> {currentOverview} ({viewType})
            </p>
          </div>

          <div className="flex justify-end gap-3 pt-4">
            <button
              onClick={onClose}
              className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition-colors"
              disabled={isLoadingExport}
            >
              Cancel
            </button>
            <button
              onClick={handleExport}
              className="px-4 py-2 bg-[#8B5C2A] text-white rounded-md hover:bg-[#A9743A] disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2 transition-colors"
              disabled={isLoadingExport}
            >
              {isLoadingExport ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  <span>Exporting...</span>
                </>
              ) : (
                <>
                  <Download size={16} />
                  <span>Export</span>
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

// Custom Tooltip
const CustomTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    const data = payload[0].payload;
    const value = payload[0].value;
    const threshold = data.threshold;
    let status = "Normal";
    let statusColor = "text-green-600";
    let statusIcon = <Droplet className="w-4 h-4" />;
    if (value < threshold.min) {
      status = "Too Dry";
      statusColor = "text-blue-600";
    } else if (value > threshold.critical) {
      status = "Critical";
      statusColor = "text-purple-600";
    } else if (value > threshold.max) {
      status = "Too Humid";
      statusColor = "text-blue-800";
    }
    return (
      <div className="bg-white border border-gray-200 rounded-lg p-3 shadow-lg">
        <div className="flex items-center gap-2 mb-2">
          <div className={`p-2 rounded-full ${HUMIDITY_COLORS.background}`}>
            <Droplet className={`w-4 h-4 ${HUMIDITY_COLORS.text}`} />
          </div>
          <p className="font-semibold text-gray-800">{label}</p>
        </div>
        <p className={`text-[${HUMIDITY_COLORS.primary}]`}>{`Humidity: ${value}%`}</p>
        <p className={`${statusColor} text-sm flex items-center gap-1`}>
          {statusIcon}
          {`Status: ${status}`}
        </p>
        {data.dataPoints !== undefined && (
          <p className="text-gray-500 text-sm">{`Data Points: ${data.dataPoints}`}</p>
        )}
        <div className="mt-2 text-xs text-gray-500">
          <p>Thresholds:</p>
          <p className="text-[#60A5FA]">Min: {threshold.min}%</p>
          <p className="text-[#1D4ED8]">Max: {threshold.max}%</p>
          <p className="text-[#7C3AED]">Critical: {threshold.critical}%</p>
        </div>
      </div>
    );
  }
  return null;
};

// Add the date range utility functions
const getPreviousWeek = (date: Date): DateRange => {
  const start = new Date(date);
  start.setDate(start.getDate() - 7);
  const end = new Date(start);
  end.setDate(start.getDate() + 6);
  return { start, end };
};

const getNextWeek = (date: Date): DateRange => {
  const start = new Date(date);
  start.setDate(start.getDate() + 7);
  const end = new Date(start);
  end.setDate(start.getDate() + 6);
  return { start, end };
};

const getPreviousMonth = (date: Date): DateRange => {
  const start = new Date(date);
  start.setMonth(start.getMonth() - 1);
  const end = new Date(start);
  end.setMonth(end.getMonth() + 1);
  end.setDate(0);
  return { start, end };
};

const getNextMonth = (date: Date): DateRange => {
  const start = new Date(date);
  start.setMonth(start.getMonth() + 1);
  const end = new Date(start);
  end.setMonth(end.getMonth() + 1);
  end.setDate(0);
  return { start, end };
};

// Add trend analysis function
const calculateTrend = (data: DataItem[]): { trend: 'up' | 'down' | 'neutral', percentage: number } => {
  if (data.length < 2) return { trend: 'neutral', percentage: 0 };

  const values = data.map(item => item.value as number);
  const firstValue = values[0];
  const lastValue = values[values.length - 1];
  const percentageChange = ((lastValue - firstValue) / firstValue) * 100;

  if (Math.abs(percentageChange) < 1) return { trend: 'neutral', percentage: percentageChange };
  return {
    trend: percentageChange > 0 ? 'up' : 'down',
    percentage: Math.abs(percentageChange)
  };
};

// Main Component
const HumidityDashboard = () => {
  const [overview, setOverview] = useState<string>("hourly");
  const [viewType, setViewType] = useState<string>("chart");
  const [chartData, setChartData] = useState<DataItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [dateRange, setDateRange] = useState<string>("");
  const [xKey, setXKey] = useState<string>("hour");
  const [showExportModal, setShowExportModal] = useState<boolean>(false);
  const [lastUpdated, setLastUpdated] = useState<Date>(new Date());
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [customDateRange, setCustomDateRange] = useState<DateRange | undefined>(undefined);
  const [trend, setTrend] = useState<{ trend: 'up' | 'down' | 'neutral', percentage: number }>({ trend: 'neutral', percentage: 0 });
  const chartRef = useRef<HTMLDivElement | null>(null);

  const fetchDataForPeriod = async (date?: Date, range?: DateRange) => {
    setIsLoading(true);
    setError(null);
    try {
      const response = await fetchThingSpeakData(overview);
      const {
        chartData: newData,
        xKey: newXKey,
        dateRange: newDateRange,
      } = processHumidityData(response.feeds, overview, range);
      setChartData(newData);
      setXKey(newXKey);
      setDateRange(newDateRange);
      setLastUpdated(new Date());
      setTrend(calculateTrend(newData));
    } catch (error) {
      console.error("Error fetching humidity data:", error);
      setError("Failed to fetch live data. Showing sample data.");
      let baseDate = date;
      if (!baseDate && range) baseDate = range.start;
      const {
        chartData: defaultData,
        xKey: defaultXKey,
        dateRange: defaultDateRange,
      } = getDefaultData(overview, baseDate);
      setChartData(defaultData);
      setXKey(defaultXKey);
      setDateRange(defaultDateRange);
    } finally {
      setIsLoading(false);
    }
  };

  const handleFetchData = (e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();
    void fetchDataForPeriod(selectedDate, customDateRange);
  };

  useEffect(() => {
    void fetchDataForPeriod(selectedDate, customDateRange);
  }, [overview, selectedDate, customDateRange]);

  const handlePreviousPeriod = () => {
    if (customDateRange) {
      if (overview === "hourly") {
        const newDate = new Date(customDateRange.start);
        newDate.setDate(newDate.getDate() - 1);
        setCustomDateRange({ start: newDate, end: newDate });
      } else if (overview === "weekly") {
        const newRange = getPreviousWeek(customDateRange.start);
        setCustomDateRange(newRange);
      } else if (overview === "monthly") {
        const newRange = getPreviousMonth(customDateRange.start);
        setCustomDateRange(newRange);
      }
    } else {
      if (overview === "hourly") {
        const newDate = new Date(selectedDate);
        newDate.setDate(newDate.getDate() - 1);
        setSelectedDate(newDate);
      } else if (overview === "weekly") {
        const newRange = getPreviousWeek(selectedDate);
        setSelectedDate(newRange.start);
      } else if (overview === "monthly") {
        const newRange = getPreviousMonth(selectedDate);
        setSelectedDate(newRange.start);
      }
    }
  };

  const handleNextPeriod = () => {
    if (customDateRange) {
      if (overview === "hourly") {
        const newDate = new Date(customDateRange.start);
        newDate.setDate(newDate.getDate() + 1);
        setCustomDateRange({ start: newDate, end: newDate });
      } else if (overview === "weekly") {
        const newRange = getNextWeek(customDateRange.start);
        setCustomDateRange(newRange);
      } else if (overview === "monthly") {
        const newRange = getNextMonth(customDateRange.start);
        setCustomDateRange(newRange);
      }
    } else {
      if (overview === "hourly") {
        const newDate = new Date(selectedDate);
        newDate.setDate(newDate.getDate() + 1);
        setSelectedDate(newDate);
      } else if (overview === "weekly") {
        const newRange = getNextWeek(selectedDate);
        setSelectedDate(newRange.start);
      } else if (overview === "monthly") {
        const newRange = getNextMonth(selectedDate);
        setSelectedDate(newRange.start);
      }
    }
  };

  const handleCustomDateSelect = (start: Date, end: Date) => {
    setCustomDateRange({ start, end });
  };

  const handleResetDateRange = () => {
    setCustomDateRange(undefined);
    setSelectedDate(new Date());
  };

  const renderChart = () => {
    if (viewType === "table") {
      return (
        <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    {xKey.charAt(0).toUpperCase() + xKey.slice(1)}
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Humidity (%)
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Status
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Data Points
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Thresholds
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {chartData.map((item, index) => {
                  const value = item.value as number;
                  const threshold = (item as any).threshold as {
                    min: number;
                    max: number;
                    critical: number;
                  };
                  const label = (item as any)[xKey] as string;
                  let status = "Normal";
                  let statusColor = "text-green-600";
                  if (value < threshold.min) {
                    status = "Too Dry";
                    statusColor = "text-blue-600";
                  } else if (value > threshold.critical) {
                    status = "Critical";
                    statusColor = "text-purple-600";
                  } else if (value > threshold.max) {
                    status = "Too Humid";
                    statusColor = "text-blue-800";
                  }
                  return (
                    <tr key={index} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {label}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {value}%
                      </td>
                      <td className={`px-6 py-4 whitespace-nowrap text-sm ${statusColor}`}>
                        {status}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {item.dataPoints || "N/A"}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <div className="text-xs">
                          <p>Min: {threshold.min}%</p>
                          <p>Max: {threshold.max}%</p>
                          <p>Critical: {threshold.critical}%</p>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      );
    }
    return (
      <div className="bg-white rounded-lg border border-gray-200 p-6">
        <ResponsiveContainer width="100%" height={400}>
          {viewType === "line" ? (
            <LineChart data={chartData}>
              <XAxis
                dataKey={xKey}
                tick={{ fontSize: 12, fill: "#374151" }}
                axisLine={{ stroke: "#D1D5DB" }}
              />
              <YAxis
                tick={{ fontSize: 12, fill: "#374151" }}
                axisLine={{ stroke: "#D1D5DB" }}
                label={{
                  value: "Humidity (%)",
                  angle: -90,
                  position: "insideLeft",
                  style: { textAnchor: "middle", fill: "#374151" },
                }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Line
                type="monotone"
                dataKey="value"
                stroke={HUMIDITY_COLORS.primary}
                strokeWidth={2}
                dot={{ fill: HUMIDITY_COLORS.primary, strokeWidth: 2, r: 4 }}
              />
              <ReferenceLine
                y={HUMIDITY_THRESHOLDS.min}
                stroke={HUMIDITY_COLORS.min}
                strokeDasharray="3 3"
                label={{ value: "Min", position: "right", fill: HUMIDITY_COLORS.min }}
              />
              <ReferenceLine
                y={HUMIDITY_THRESHOLDS.max}
                stroke={HUMIDITY_COLORS.max}
                strokeDasharray="3 3"
                label={{ value: "Max", position: "right", fill: HUMIDITY_COLORS.max }}
              />
              <ReferenceLine
                y={HUMIDITY_THRESHOLDS.critical}
                stroke={HUMIDITY_COLORS.critical}
                strokeDasharray="3 3"
                label={{ value: "Critical", position: "right", fill: HUMIDITY_COLORS.critical }}
              />
            </LineChart>
          ) : (
            <BarChart data={chartData}>
              <XAxis
                dataKey={xKey}
                tick={{ fontSize: 12, fill: "#374151" }}
                axisLine={{ stroke: "#D1D5DB" }}
              />
              <YAxis
                tick={{ fontSize: 12, fill: "#374151" }}
                axisLine={{ stroke: "#D1D5DB" }}
                label={{
                  value: "Humidity (%)",
                  angle: -90,
                  position: "insideLeft",
                  style: { textAnchor: "middle", fill: "#374151" },
                }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Bar dataKey="value" fill={HUMIDITY_COLORS.primary} radius={[4, 4, 0, 0]} />
              <ReferenceLine
                y={HUMIDITY_THRESHOLDS.min}
                stroke={HUMIDITY_COLORS.min}
                strokeDasharray="3 3"
                label={{ value: "Min", position: "right", fill: HUMIDITY_COLORS.min }}
              />
              <ReferenceLine
                y={HUMIDITY_THRESHOLDS.max}
                stroke={HUMIDITY_COLORS.max}
                strokeDasharray="3 3"
                label={{ value: "Max", position: "right", fill: HUMIDITY_COLORS.max }}
              />
              <ReferenceLine
                y={HUMIDITY_THRESHOLDS.critical}
                stroke={HUMIDITY_COLORS.critical}
                strokeDasharray="3 3"
                label={{ value: "Critical", position: "right", fill: HUMIDITY_COLORS.critical }}
              />
            </BarChart>
          )}
        </ResponsiveContainer>
      </div>
    );
  };

  return (
    <div className="max-w-7xl mx-auto p-6 space-y-6">
      {/* Header */}
      <div className="bg-white rounded-lg border border-gray-200 p-6">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div className="flex items-center gap-3">
            <div className={`p-3 rounded-full ${HUMIDITY_COLORS.background}`}>
              <Droplet className={`w-6 h-6 ${HUMIDITY_COLORS.text}`} />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900">
                Humidity Dashboard
              </h2>
              <div className="flex items-center gap-2">
                <p className="text-sm text-gray-500">
                  Last updated: {lastUpdated.toLocaleTimeString()}
                </p>
                {trend.trend !== 'neutral' && (
                  <div className={`flex items-center gap-1 text-sm ${
                    trend.trend === 'up' ? 'text-green-500' : 'text-red-500'
                  }`}>
                    {trend.trend === 'up' ? (
                      <TrendingUp size={16} />
                    ) : (
                      <TrendingDown size={16} />
                    )}
                    <span>{trend.percentage.toFixed(1)}% {trend.trend === 'up' ? 'increase' : 'decrease'}</span>
                  </div>
                )}
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={handleFetchData}
              className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-md"
              title="Refresh Data"
            >
              <RefreshCw size={20} />
            </button>
            <button
              onClick={() => setShowExportModal(true)}
              className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-md"
              title="Export Data"
            >
              <Download size={20} />
            </button>
          </div>
        </div>
      </div>
      {/* Controls */}
      <div className="bg-white rounded-lg border border-gray-200 p-6">
        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
          <div className="flex items-center gap-4">
            <div>
              <label
                htmlFor="overview"
                className="block text-sm font-medium text-gray-700 mb-1"
              >
                Time Period
              </label>
              <select
                id="overview"
                value={overview}
                onChange={(e) => {
                  setOverview(e.target.value);
                  setCustomDateRange(undefined);
                  setSelectedDate(new Date());
                }}
                className="block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm rounded-md"
              >
                <option value="hourly">Hourly</option>
                <option value="weekly">Weekly</option>
                <option value="monthly">Monthly</option>
              </select>
            </div>
            <div>
              <label
                htmlFor="viewType"
                className="block text-sm font-medium text-gray-700 mb-1"
              >
                View Type
              </label>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setViewType("chart")}
                  className={`p-2 rounded-md ${
                    viewType === "chart"
                      ? "bg-blue-100 text-blue-600"
                      : "text-gray-500 hover:text-gray-700 hover:bg-gray-100"
                  }`}
                  title="Bar Chart"
                >
                  <BarChart3 size={20} />
                </button>
                <button
                  onClick={() => setViewType("line")}
                  className={`p-2 rounded-md ${
                    viewType === "line"
                      ? "bg-blue-100 text-blue-600"
                      : "text-gray-500 hover:text-gray-700 hover:bg-gray-100"
                  }`}
                  title="Line Chart"
                >
                  <LineChartIcon size={20} />
                </button>
                <button
                  onClick={() => setViewType("table")}
                  className={`p-2 rounded-md ${
                    viewType === "table"
                      ? "bg-blue-100 text-blue-600"
                      : "text-gray-500 hover:text-gray-700 hover:bg-gray-100"
                  }`}
                  title="Table View"
                >
                  <FileText size={20} />
                </button>
              </div>
            </div>
          </div>
          <div className="flex flex-col items-end gap-2">
            <div className="text-sm text-gray-500">
              <strong>Date Range:</strong> {dateRange}
            </div>
            <div className="flex items-center gap-2">
              <button
                onClick={handlePreviousPeriod}
                className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-md"
                title="Previous Period"
              >
                <ChevronLeft size={20} />
              </button>
              <button
                onClick={handleResetDateRange}
                className="px-3 py-1 text-sm text-gray-600 hover:text-gray-800 hover:bg-gray-100 rounded-md"
                title="Reset to Current Period"
              >
                Today
              </button>
              <button
                onClick={handleNextPeriod}
                className="p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-md"
                title="Next Period"
              >
                <ChevronRight size={20} />
              </button>
            </div>
          </div>
        </div>
      </div>
      {/* Chart/Table */}
      {isLoading ? (
        <div className="bg-white rounded-lg border border-gray-200 p-6 flex items-center justify-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      ) : error ? (
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="text-center">
            <div className="text-red-500 mb-2">
              <X size={24} />
            </div>
            <p className="text-gray-700">{error}</p>
            <button
              onClick={handleFetchData}
              className="mt-4 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              Retry
            </button>
          </div>
        </div>
      ) : (
        renderChart()
      )}
      {/* Export Modal */}
      <ExportModal
        isOpen={showExportModal}
        onClose={() => setShowExportModal(false)}
        chartData={chartData}
        xKey={xKey}
        currentOverview={overview}
        dateRange={dateRange}
        viewType={viewType}
        chartRef={chartRef}
      />
    </div>
  );
};

export default HumidityDashboard;