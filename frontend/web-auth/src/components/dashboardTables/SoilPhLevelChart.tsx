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
  TestTube,
  TrendingUp,
  TrendingDown,
} from "lucide-react";
import html2canvas from 'html2canvas';
import jsPDF from 'jspdf';
import { saveAs } from 'file-saver';
import { Calendar as CalendarPicker } from "../ui/calendar";

// Types
interface DataItem {
  [key: string]:
    | string
    | number
    | { min: number; max: number; critical: number }
    | undefined;
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
  field4: string;
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

interface CalendarProps {
  selectedDate: Date;
  onDateSelect: (date: Date) => void;
  isVisible: boolean;
  setIsVisible: (visible: boolean) => void;
  minDate?: Date;
  maxDate?: Date;
}

interface DateRange {
  start: Date;
  end: Date;
}

// API Configuration
const THINGSPEAK_CONFIG = {
  channelId: "2965485",
  apiKey: "EQ3MYH5XBDSB6K2A",
  field: "4",
  baseUrl: "https://api.thingspeak.com/channels",
};

// Add soil pH thresholds
const SOIL_PH_THRESHOLDS = {
  min: 5.5, // Minimum optimal pH
  max: 7.5, // Maximum optimal pH
  critical: 8.0, // Critical pH
};

// Update the color constants with more vibrant colors and status indicators
const SOIL_PH_COLORS = {
  primary: "#0EA5E9", // Sky-500
  min: "#BAE6FD", // Sky-200
  max: "#0369A1", // Sky-700
  critical: "#075985", // Sky-800
  background: "#F0F9FF", // Sky-50
  text: "#0369A1", // Sky-700
  trend: {
    up: "#22C55E", // Green-500
    down: "#EF4444", // Red-500
    neutral: "#6B7280", // Gray-500
  },
  status: {
    optimal: "#22C55E", // Green-500
    tooAcidic: "#F97316", // Orange-500
    tooAlkaline: "#8B5CF6", // Purple-500
    critical: "#EF4444", // Red-500
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
    console.log("Fetching from URL:", url);
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Failed to fetch data: ${response.statusText}`);
    }
    
    const data = await response.json();
    console.log("Raw API response:", data);
    
    if (!data.feeds || data.feeds.length === 0) {
      throw new Error("No data available from the sensor");
    }

    // Check if all field4 values are null
    const hasNullValues = data.feeds.every(feed => feed.field4 === null);
    if (hasNullValues) {
      throw new Error("Soil pH sensor is not sending data");
    }

    // Log the first few entries to verify data
    console.log("Sample feeds:", data.feeds.slice(0, 3));
    
    return data;
  } catch (error) {
    console.error("Error fetching ThingSpeak data:", error);
    throw error;
  }
};

const convertToPhilippineTime = (utcDateString: string): Date => {
  const utcDate = new Date(utcDateString);
  const philippineTime = new Date(utcDate.getTime() + 8 * 60 * 60 * 1000);
  return philippineTime;
};

const formatDateRange = (start: Date, end: Date): string => {
  const options: Intl.DateTimeFormatOptions = {
    month: "short",
    day: "numeric",
    year: "numeric",
    timeZone: "Asia/Manila",
  };
  return `${start.toLocaleDateString(
    "en-PH",
    options
  )} - ${end.toLocaleDateString("en-PH", options)}`;
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

const processSoilPhLevelData = (
  response: ThingSpeakResponse,
  period: string,
  customRange?: { start: Date; end: Date }
): { 
  chartData: DataItem[]; 
  xKey: string; 
  dateRange: string;
  hasRealData: boolean;
} => {
  if (!response.feeds || response.feeds.length === 0) {
    console.log("No feeds data available");
    return getDefaultData(period);
  }

  // Filter and validate the data
  const validFeeds = response.feeds.filter(feed => {
    const value = parseFloat(feed.field4);
    return !isNaN(value) && value > 0;
  });

  console.log("Valid feeds count:", validFeeds.length);
  if (validFeeds.length === 0) {
    console.log("No valid feeds after filtering");
    return getDefaultData(period);
  }

  // Log the first and last few entries from the API
  console.log("API Data Sample:", {
    firstEntry: response.feeds[0],
    lastEntry: response.feeds[response.feeds.length - 1],
    totalEntries: response.feeds.length,
  });

  const latestEntry = response.feeds[response.feeds.length - 1];
  const latestDate = convertToPhilippineTime(latestEntry.created_at);
  
  let chartData: DataItem[] = [];
  let xKey = "";
  let dateRange = "";

  switch (period) {
    case "hourly": {
      const dayNames = [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
      ];
      const hourlyData: {
        [key: string]: { sum: number; count: number; hours: string[] };
      } = {};

      // Initialize 24 hours
      for (let hour = 0; hour < 24; hour++) {
        const hourKey = `${hour.toString().padStart(2, "0")}:00`;
        hourlyData[hourKey] = { sum: 0, count: 0, hours: [] };
      }

      // Get the start of the current week (Sunday)
      const currentDate = new Date(latestDate);
      const day = currentDate.getDay();
      const diff = currentDate.getDate() - day;
      const startOfWeek = new Date(currentDate);
      startOfWeek.setDate(diff);
      startOfWeek.setHours(0, 0, 0, 0);

      // Get the end of the week (Saturday)
      const endOfWeek = new Date(startOfWeek);
      endOfWeek.setDate(startOfWeek.getDate() + 6);
      endOfWeek.setHours(23, 59, 59, 999);

      console.log("Date Range:", {
        startOfWeek: startOfWeek.toISOString(),
        endOfWeek: endOfWeek.toISOString(),
        latestDate: latestDate.toISOString(),
      });

      // Process the data
      response.feeds.forEach((entry) => {
        if (entry.field4) {
          const entryDate = convertToPhilippineTime(entry.created_at);
          const value = parseFloat(entry.field4);

          // Debug log for entries near the start of the week
          if (entryDate.getDay() <= 1) {
            // Sunday (0) or Monday (1)
            console.log("Entry near start of week:", {
              date: entryDate.toISOString(),
              value: value,
              day: entryDate.getDay(),
              isInRange: entryDate >= startOfWeek && entryDate <= endOfWeek,
            });
          }

          if (
            !isNaN(value) &&
            entryDate >= startOfWeek &&
            entryDate <= endOfWeek
          ) {
            const hour = entryDate.getHours();
            const hourKey = `${hour.toString().padStart(2, "0")}:00`;
            hourlyData[hourKey].sum += value;
            hourlyData[hourKey].count += 1;
            hourlyData[hourKey].hours.push(entryDate.toISOString());
          }
        }
      });
      
      // Debug log for hourly data
      console.log(
        "Hourly Data Summary:",
        Object.entries(hourlyData).map(([hour, data]) => ({
          hour,
          count: data.count,
          average: data.count > 0 ? data.sum / data.count : 0,
          timestamps: data.hours,
        }))
      );

      chartData = Object.keys(hourlyData).map((hour) => ({
        hour,
        value:
          hourlyData[hour].count > 0
            ? Math.round((hourlyData[hour].sum / hourlyData[hour].count) * 10) /
              10
            : 0,
        dataPoints: hourlyData[hour].count,
        threshold: {
          min: SOIL_PH_THRESHOLDS.min,
          max: SOIL_PH_THRESHOLDS.max,
          critical: SOIL_PH_THRESHOLDS.critical,
        },
      }));

      dateRange = formatDateRange(startOfWeek, endOfWeek);
      xKey = "hour";
      break;
    }
    
    case "weekly": {
      const dayNames = [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
      ];
      const dayData: {
        [key: string]: { sum: number; count: number; dates: string[] };
      } = {};

      // Initialize all days
      dayNames.forEach((day) => {
        dayData[day] = { sum: 0, count: 0, dates: [] };
      });

      // Get the latest entry date in Philippine time
      const latestEntry = response.feeds[response.feeds.length - 1];
      const latestDate = convertToPhilippineTime(latestEntry.created_at);

      // Calculate current week range (Sunday to Saturday) in Philippine time
      const currentDate = new Date(latestDate);
      const dayOfWeek = currentDate.getDay(); // 0 = Sunday, 1 = Monday, etc.

      // Get start of current week (Sunday)
      const startOfWeek = new Date(currentDate);
      startOfWeek.setDate(currentDate.getDate() - dayOfWeek);
      startOfWeek.setHours(0, 0, 0, 0);

      // Get end of current week (Saturday)
      const endOfWeek = new Date(startOfWeek);
      endOfWeek.setDate(startOfWeek.getDate() + 6);
      endOfWeek.setHours(23, 59, 59, 999);

      console.log("Weekly Date Range (Philippine Time):", {
        latestDate: latestDate.toLocaleString("en-PH", {
          timeZone: "Asia/Manila",
        }),
        startOfWeek: startOfWeek.toLocaleString("en-PH", {
          timeZone: "Asia/Manila",
        }),
        endOfWeek: endOfWeek.toLocaleString("en-PH", {
          timeZone: "Asia/Manila",
        }),
        dayOfWeek: dayOfWeek,
      });

      // Process all the data entries
      let processedCount = 0;
      let totalEntries = response.feeds.length;

      response.feeds.forEach((entry, index) => {
        if (entry.field4) {
          const entryDate = convertToPhilippineTime(entry.created_at);
            const value = parseFloat(entry.field4);

          // Check if entry is within the current week
          if (
            !isNaN(value) &&
            entryDate >= startOfWeek &&
            entryDate <= endOfWeek
          ) {
            const dayName = dayNames[entryDate.getDay()];
            const entryDateStr = entryDate.toLocaleDateString("en-PH", {
              timeZone: "Asia/Manila",
            });

            dayData[dayName].sum += value;
            dayData[dayName].count += 1;
            if (!dayData[dayName].dates.includes(entryDateStr)) {
              dayData[dayName].dates.push(entryDateStr);
            }

            processedCount++;

            // Log some sample entries for debugging
            if (processedCount <= 10 || index % 50 === 0) {
              console.log(`Entry ${index + 1}/${totalEntries}:`, {
                originalUTC: entry.created_at,
                philippineTime: entryDate.toLocaleString("en-PH", {
                  timeZone: "Asia/Manila",
                }),
                dayName: dayName,
                value: value,
                inRange: true,
              });
            }
          }
        }
      });

      console.log(
        `Total entries processed: ${processedCount} out of ${totalEntries}`
      );

      // Debug log for daily data summary
      console.log(
        "Daily Data Summary:",
        Object.entries(dayData).map(([day, data]) => ({
          day,
          count: data.count,
          average:
            data.count > 0 ? Math.round((data.sum / data.count) * 10) / 10 : 0,
          dates: data.dates,
        }))
      );

      // Create chart data with all days, even if they have no data
      chartData = dayNames.map((day) => ({
        day,
        value:
          dayData[day].count > 0
            ? Math.round((dayData[day].sum / dayData[day].count) * 10) / 10
            : 0,
        dataPoints: dayData[day].count,
        dates: dayData[day].dates.join(", "),
        threshold: {
          min: SOIL_PH_THRESHOLDS.min,
          max: SOIL_PH_THRESHOLDS.max,
          critical: SOIL_PH_THRESHOLDS.critical,
        },
      }));

      dateRange = formatDateRange(startOfWeek, endOfWeek);
      xKey = "day";
      break;
    }
    
    case "monthly": {
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
      const monthsData: { [key: string]: { sum: number; count: number } } = {};
      
      for (let i = 11; i >= 0; i--) {
        const monthDate = new Date(latestDate);
        monthDate.setMonth(monthDate.getMonth() - i);
        const monthLabel = monthNames[monthDate.getMonth()];
        monthsData[monthLabel] = { sum: 0, count: 0 };
        
        response.feeds.forEach((entry) => {
          const entryDate = convertToPhilippineTime(entry.created_at);
          const monthLabel = monthNames[entryDate.getMonth()];

          if (monthsData[monthLabel] && entry.field4) {
            const value = parseFloat(entry.field4);
            if (!isNaN(value)) {
              monthsData[monthLabel].sum += value;
              monthsData[monthLabel].count += 1;
            }
          }
        });
      }
      
      const firstMonth = new Date(latestDate);
      firstMonth.setMonth(firstMonth.getMonth() - 11, 1);
      const lastMonth = new Date(latestDate);
      lastMonth.setMonth(lastMonth.getMonth() + 1, 0);

      chartData = monthNames.map((month) => ({
        month,
        value:
          monthsData[month] && monthsData[month].count > 0
            ? Math.round(
                (monthsData[month].sum / monthsData[month].count) * 10
              ) / 10
            : 0,
        threshold: {
          min: SOIL_PH_THRESHOLDS.min,
          max: SOIL_PH_THRESHOLDS.max,
          critical: SOIL_PH_THRESHOLDS.critical,
        },
      }));

      dateRange = formatDateRange(firstMonth, lastMonth);
      xKey = "month";
      break;
    }
  }

  return {
    chartData,
    xKey,
    dateRange,
    hasRealData: true
  };
};

const getDefaultData = (period: string, baseDate?: Date): { 
  chartData: DataItem[]; 
  xKey: string; 
  dateRange: string;
  hasRealData: boolean;
} => {
  const today = baseDate ? new Date(baseDate) : getCurrentPhilippineTime();
  const defaultThreshold = {
    min: SOIL_PH_THRESHOLDS.min,
    max: SOIL_PH_THRESHOLDS.max,
    critical: SOIL_PH_THRESHOLDS.critical,
  };

  // Return empty data structure with hasRealData flag
  return {
    chartData: [], // Return empty array instead of dummy data
    xKey: period === 'hourly' ? 'hour' : period === 'weekly' ? 'day' : 'month',
    dateRange: formatDateRange(today, today),
    hasRealData: false
  };
};

// Calendar Component
const Calendar: React.FC<CalendarProps> = ({
  selectedDate,
  onDateSelect,
  isVisible,
  setIsVisible,
  minDate,
  maxDate,
}) => {
  const [currentMonth, setCurrentMonth] = useState(new Date(selectedDate));

  if (!isVisible) return null;

  const year = currentMonth.getFullYear();
  const month = currentMonth.getMonth();
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const firstDay = new Date(year, month, 1).getDay();

  const days: React.ReactElement[] = [];

  // Empty cells for days before the first day
  for (let i = 0; i < firstDay; i++) {
    days.push(<div key={`empty-${i}`} className="h-8 w-8"></div>);
  }

  // Days of the month
  for (let i = 1; i <= daysInMonth; i++) {
    const date = new Date(year, month, i);
    const isSelected = date.toDateString() === selectedDate.toDateString();
    const isDisabled =
      (minDate && date < minDate) || (maxDate && date > maxDate);

    days.push(
      <button
        key={i}
        onClick={() => {
          if (!isDisabled) {
            onDateSelect(date);
          setIsVisible(false);
          }
        }}
        disabled={isDisabled}
        className={`h-8 w-8 rounded-full text-sm ${
          isSelected
            ? "bg-blue-600 text-white"
            : isDisabled
            ? "text-gray-300 cursor-not-allowed"
            : "hover:bg-blue-100 text-gray-700"
        }`}
      >
        {i}
      </button>
    );
  }

  return (
    <div className="absolute z-50 mt-1 p-4 bg-white border border-gray-300 rounded-lg shadow-xl">
      <div className="flex justify-between items-center mb-4">
        <button
          onClick={() => setCurrentMonth(new Date(year, month - 1))}
          className="p-1 hover:bg-gray-100 rounded"
        >
          <ChevronLeft size={16} />
        </button>
        <div className="text-center font-semibold text-gray-800">
          {new Date(year, month).toLocaleString("default", { month: "long" })}{" "}
          {year}
        </div>
        <button
          onClick={() => setCurrentMonth(new Date(year, month + 1))}
          className="p-1 hover:bg-gray-100 rounded"
        >
          <ChevronRight size={16} />
        </button>
      </div>
      <div className="grid grid-cols-7 gap-1 text-center">
        {["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"].map((day) => (
          <div key={day} className="font-semibold text-gray-600 text-sm">
            {day}
          </div>
        ))}
        {days}
      </div>
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
          "Soil pH Level",
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
          if (value < threshold.min) status = "Too Acidic";
          else if (value > threshold.critical) status = "Critical";
          else if (value > threshold.max) status = "Too Alkaline";
          
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
        saveAs(blob, `soil-ph-data-${currentOverview}-${viewType}-${new Date().toISOString().split('T')[0]}.csv`);
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
          pdf.text('Soil pH Level Dashboard', pdfWidth / 2, 15, { align: 'center' });

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

          pdf.save(`soil-ph-dashboard-${currentOverview}-${viewType}-${new Date().toISOString().split('T')[0]}.pdf`);
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
          saveAs(svgBlob, `soil-ph-chart-${currentOverview}-${viewType}-${new Date().toISOString().split('T')[0]}.svg`);
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
            Export Soil pH Level Data
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

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Export Range
            </label>
            <div className="grid grid-cols-2 gap-2">
              {[
                { type: "current", label: "Current Period" },
                { type: "custom", label: "Custom Range" },
              ].map(({ type, label }) => (
                <button
                  key={type}
                  onClick={() => setExportType(type)}
                  className={`px-3 py-2 rounded-md text-sm font-medium transition-colors ${
                    exportType === type
                      ? "bg-purple-100 text-purple-600 border-2 border-purple-600"
                      : "bg-gray-50 text-gray-700 hover:bg-gray-100 border-2 border-transparent"
                  }`}
                >
                  {label}
                </button>
              ))}
            </div>
          </div>

          {exportType === "custom" && (
            <div className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Start Date
                </label>
                <div className="relative">
                  <input
                    type="text"
                    value={startDate.toLocaleDateString()}
                    readOnly
                    className="w-full p-2 border border-gray-300 rounded-md cursor-pointer focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                    onClick={() => setShowStartCalendar(!showStartCalendar)}
                  />
                  <CalendarIcon
                    size={16}
                    className="absolute right-3 top-3 text-gray-400"
                  />
                  <CalendarPicker
                    selectedDate={startDate}
                    onDateSelect={setStartDate}
                    isVisible={showStartCalendar}
                    setIsVisible={setShowStartCalendar}
                    maxDate={endDate}
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  End Date
                </label>
                <div className="relative">
                  <input
                    type="text"
                    value={endDate.toLocaleDateString()}
                    readOnly
                    className="w-full p-2 border border-gray-300 rounded-md cursor-pointer focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
                    onClick={() => setShowEndCalendar(!showEndCalendar)}
                  />
                  <CalendarIcon
                    size={16}
                    className="absolute right-3 top-3 text-gray-400"
                  />
                  <CalendarPicker
                    selectedDate={endDate}
                    onDateSelect={setEndDate}
                    isVisible={showEndCalendar}
                    setIsVisible={setShowEndCalendar}
                    minDate={startDate}
                  />
                </div>
              </div>
            </div>
          )}

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

// Update the calculateTrend function to be more robust
const calculateTrend = (data: DataItem[]): { trend: 'up' | 'down' | 'neutral', percentage: number, isValid: boolean } => {
  if (!data || data.length < 2) {
    return { trend: 'neutral', percentage: 0, isValid: false };
  }

  // Filter out any invalid values
  const validValues = data
    .map(item => item.value as number)
    .filter(value => !isNaN(value) && value !== null && value !== undefined);

  if (validValues.length < 2) {
    return { trend: 'neutral', percentage: 0, isValid: false };
  }

  const firstValue = validValues[0];
  const lastValue = validValues[validValues.length - 1];

  // Check if values are valid numbers
  if (isNaN(firstValue) || isNaN(lastValue) || firstValue === 0) {
    return { trend: 'neutral', percentage: 0, isValid: false };
  }

  const percentageChange = ((lastValue - firstValue) / firstValue) * 100;

  // If the change is very small, consider it neutral
  if (Math.abs(percentageChange) < 1) {
    return { trend: 'neutral', percentage: 0, isValid: true };
  }

  return {
    trend: percentageChange > 0 ? 'up' : 'down',
    percentage: Math.abs(percentageChange),
    isValid: true
  };
};

// Update the CustomTooltip component with better status indicators
const CustomTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    const data = payload[0].payload;
    const value = payload[0].value;
    const threshold = data.threshold;
    let status = "Optimal";
    let statusColor = SOIL_PH_COLORS.status.optimal;
    let statusIcon = <TestTube className="w-4 h-4" />;

    if (value < threshold.min) {
      status = "Too Acidic";
      statusColor = SOIL_PH_COLORS.status.tooAcidic;
    } else if (value > threshold.critical) {
      status = "Critical";
      statusColor = SOIL_PH_COLORS.status.critical;
    } else if (value > threshold.max) {
      status = "Too Alkaline";
      statusColor = SOIL_PH_COLORS.status.tooAlkaline;
    }

    return (
      <div className="bg-white border border-gray-200 rounded-lg p-3 shadow-lg">
        <div className="flex items-center gap-2 mb-2">
          <div className={`p-2 rounded-full ${SOIL_PH_COLORS.background}`}>
            <TestTube className={`w-4 h-4 ${SOIL_PH_COLORS.text}`} />
          </div>
          <p className="font-semibold text-gray-800">{label}</p>
        </div>
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-gray-600">pH Level:</span>
            <span className={`font-semibold ${SOIL_PH_COLORS.text}`}>{value.toFixed(1)}</span>
          </div>
          <div className="flex items-center gap-2">
            <div className={`w-2 h-2 rounded-full`} style={{ backgroundColor: statusColor }} />
            <span className={`text-sm font-medium`} style={{ color: statusColor }}>{status}</span>
          </div>
          {data.dataPoints !== undefined && (
            <div className="text-sm text-gray-500">
              Data Points: {data.dataPoints}
            </div>
          )}
          <div className="mt-2 pt-2 border-t border-gray-100">
            <p className="text-xs font-medium text-gray-500 mb-1">Thresholds:</p>
            <div className="space-y-1">
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full" style={{ backgroundColor: SOIL_PH_COLORS.min }} />
                <span className="text-xs text-gray-600">Min: {threshold.min}</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full" style={{ backgroundColor: SOIL_PH_COLORS.max }} />
                <span className="text-xs text-gray-600">Max: {threshold.max}</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full" style={{ backgroundColor: SOIL_PH_COLORS.critical }} />
                <span className="text-xs text-gray-600">Critical: {threshold.critical}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
  return null;
};

// Add these helper functions before the main component
const getPreviousWeek = (date: Date): DateRange => {
  const start = new Date(date);
  start.setDate(start.getDate() - 7);
  const end = new Date(start);
  end.setDate(end.getDate() + 6);
  return { start, end };
};

const getNextWeek = (date: Date): DateRange => {
  const start = new Date(date);
  start.setDate(start.getDate() + 7);
  const end = new Date(start);
  end.setDate(end.getDate() + 6);
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

// Add this utility if missing
const getCurrentPhilippineTime = (): Date => {
  const now = new Date();
  // Convert current time to Philippine time (UTC+8)
  const philippineTime = new Date(now.getTime() + (8 * 60 * 60 * 1000));
  return philippineTime;
};

// Update the main component
const SoilPhLevelDashboard = () => {
  const [overview, setOverview] = useState<string>("hourly");
  const [viewType, setViewType] = useState<string>("chart");
  const [chartData, setChartData] = useState<DataItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [dateRange, setDateRange] = useState<string>("");
  const [xKey, setXKey] = useState<string>("day");
  const [showExportModal, setShowExportModal] = useState<boolean>(false);
  const [lastUpdated, setLastUpdated] = useState<Date>(new Date());
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [customDateRange, setCustomDateRange] = useState<DateRange | undefined>(undefined);
  const [trend, setTrend] = useState<{ trend: 'up' | 'down' | 'neutral', percentage: number, isValid: boolean }>({ 
    trend: 'neutral', 
    percentage: 0,
    isValid: false 
  });
  const chartRef = useRef<HTMLDivElement>(null);

  const fetchDataForPeriod = async (date?: Date, range?: DateRange) => {
    setIsLoading(true);
    setError(null);
    try {
      console.log("Fetching data for period:", overview);
      const response = await fetchThingSpeakData(overview);
      console.log("Received response:", response);

      const {
        chartData: newData,
        xKey: newXKey,
        dateRange: newDateRange,
        hasRealData
      } = processSoilPhLevelData(response, overview, range);

      console.log("Processed chart data:", newData);
      
      setChartData(newData);
      setXKey(newXKey);
      setDateRange(newDateRange);
      setLastUpdated(new Date());

      if (hasRealData && newData.length > 0) {
        const trendResult = calculateTrend(newData);
        console.log("Calculated trend:", trendResult);
        setTrend(trendResult);
      } else {
        console.log("No real data available, setting neutral trend");
        setTrend({ trend: 'neutral', percentage: 0, isValid: false });
      }
    } catch (error) {
      console.error("Error fetching soil pH data:", error);
      let errorMessage = "Failed to fetch data. ";
      
      if (error instanceof Error) {
        if (error.message.includes("not sending data")) {
          errorMessage = "Soil pH sensor is not sending data. Please check the sensor connection.";
        } else if (error.message.includes("No data available")) {
          errorMessage = "No data available from the sensor. Please try again later.";
        } else {
          errorMessage += error.message;
        }
      }
      
      setError(errorMessage);
      const {
        chartData: defaultData,
        xKey: defaultXKey,
        dateRange: defaultDateRange,
      } = getDefaultData(overview, date);
      setChartData(defaultData);
      setXKey(defaultXKey);
      setDateRange(defaultDateRange);
      setTrend({ trend: 'neutral', percentage: 0, isValid: false });
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
    if (error) {
      return (
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="text-center">
            <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-red-100 mb-4">
              <X size={24} className="text-red-600" />
            </div>
            <p className="text-gray-700 mb-4">{error}</p>
            <div className="flex flex-col sm:flex-row gap-3 justify-center">
              <button
                onClick={handleFetchData}
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
              >
                Retry
              </button>
              <button
                onClick={() => setError(null)}
                className="px-4 py-2 border border-gray-300 text-gray-700 rounded-md hover:bg-gray-50 transition-colors"
              >
                Dismiss
              </button>
            </div>
          </div>
        </div>
      );
    }

    if (chartData.length === 0) {
      return (
        <div className="bg-white rounded-lg border border-gray-200 p-6">
          <div className="text-center">
            <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-yellow-100 mb-4">
              <TestTube size={24} className="text-yellow-600" />
            </div>
            <p className="text-gray-700 mb-2">Soil pH sensor is not sending data</p>
            <p className="text-sm text-gray-500 mb-4">Please check the sensor connection and try again</p>
            <button
              onClick={handleFetchData}
              className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
            >
              Refresh Data
            </button>
          </div>
        </div>
      );
    }

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
                    Soil pH Level
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
                    status = "Too Acidic";
                    statusColor = "text-blue-600";
                  } else if (value > threshold.critical) {
                    status = "Critical";
                    statusColor = "text-red-600";
                  } else if (value > threshold.max) {
                    status = "Too Alkaline";
                    statusColor = "text-orange-600";
                  }

                  return (
                    <tr key={index} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {label}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {value}
                      </td>
                      <td
                        className={`px-6 py-4 whitespace-nowrap text-sm ${statusColor}`}
                      >
                        {status}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {item.dataPoints || "N/A"}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <div className="text-xs">
                          <p>Min: {threshold.min}</p>
                          <p>Max: {threshold.max}</p>
                          <p>Critical: {threshold.critical}</p>
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
                  value: "Soil pH Level",
                  angle: -90, 
                  position: "insideLeft",
                  style: { textAnchor: "middle", fill: "#374151" },
                }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Line 
                type="monotone" 
                dataKey="value" 
                stroke={SOIL_PH_COLORS.primary}
                strokeWidth={2}
                dot={{ 
                  fill: SOIL_PH_COLORS.primary, 
                  strokeWidth: 2, 
                  r: 4,
                  stroke: '#fff'
                }}
                activeDot={{ 
                  r: 6, 
                  stroke: SOIL_PH_COLORS.primary,
                  strokeWidth: 2,
                  fill: '#fff'
                }}
              />
              <ReferenceLine
                y={SOIL_PH_THRESHOLDS.min}
                stroke={SOIL_PH_COLORS.min}
                strokeDasharray="3 3"
                label={{ value: "Min", position: "right", fill: SOIL_PH_COLORS.min }}
              />
              <ReferenceLine
                y={SOIL_PH_THRESHOLDS.max}
                stroke={SOIL_PH_COLORS.max}
                strokeDasharray="3 3"
                label={{ value: "Max", position: "right", fill: SOIL_PH_COLORS.max }}
              />
              <ReferenceLine
                y={SOIL_PH_THRESHOLDS.critical}
                stroke={SOIL_PH_COLORS.critical}
                strokeDasharray="3 3"
                label={{ value: "Critical", position: "right", fill: SOIL_PH_COLORS.critical }}
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
                  value: "Soil pH Level",
                  angle: -90,
                  position: "insideLeft",
                  style: { textAnchor: "middle", fill: "#374151" },
                }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Bar dataKey="value" fill={SOIL_PH_COLORS.primary} radius={[4, 4, 0, 0]} />
              <ReferenceLine
                y={SOIL_PH_THRESHOLDS.min}
                stroke={SOIL_PH_COLORS.min}
                strokeDasharray="3 3"
                label={{ value: "Min", position: "right", fill: SOIL_PH_COLORS.min }}
              />
              <ReferenceLine
                y={SOIL_PH_THRESHOLDS.max}
                stroke={SOIL_PH_COLORS.max}
                strokeDasharray="3 3"
                label={{ value: "Max", position: "right", fill: SOIL_PH_COLORS.max }}
              />
              <ReferenceLine
                y={SOIL_PH_THRESHOLDS.critical}
                stroke={SOIL_PH_COLORS.critical}
                strokeDasharray="3 3"
                label={{ value: "Critical", position: "right", fill: SOIL_PH_COLORS.critical }}
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
            <div className={`p-3 rounded-full ${SOIL_PH_COLORS.background}`}>
              <TestTube className={`w-6 h-6 ${SOIL_PH_COLORS.text}`} />
            </div>
            <div>
              <h2 className="text-2xl font-bold text-gray-900">
                Soil pH Level Dashboard
              </h2>
              <div className="flex items-center gap-2">
                <p className="text-sm text-gray-500">
                  Last updated: {lastUpdated.toLocaleTimeString()}
                </p>
                {trend.isValid && trend.trend !== 'neutral' && (
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
                {!trend.isValid && (
                  <div className="flex items-center gap-1 text-sm text-gray-500">
                    <span>No trend data available</span>
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
      <div ref={chartRef}>
        {isLoading ? (
          <div className="bg-white rounded-lg border border-gray-200 p-6 flex items-center justify-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
          </div>
        ) : error ? (
          renderChart()
        ) : (
          renderChart()
        )}
      </div>

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

export default SoilPhLevelDashboard;