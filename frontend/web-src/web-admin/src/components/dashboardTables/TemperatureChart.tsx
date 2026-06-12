import { useState, useRef, useEffect } from "react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  BarChart,
  Bar,
  ReferenceLine,
} from "recharts";
import {
  Download,
  Calendar,
  ChevronLeft,
  ChevronRight,
  ChevronDown,
  BarChart3,
  Table,
  Thermometer,
} from "lucide-react";
import { Button } from "../ui/button";
import { Card, CardContent, CardHeader } from '../ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "../ui/select";
import { Skeleton } from '../ui/skeleton';
import { Alert, AlertDescription, AlertTitle } from '../ui/alert';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "../ui/dropdown-menu";
import UnifiedExportModal from '../UnifiedExportModal';
import { RefreshIndicator } from '../ui/refresh-indicator';
import { useIntelligentRefresh } from '../../hooks/useIntelligentRefresh';
import { format } from "date-fns";

// Types
interface DataItem {
  [key: string]: string | number | null | { min: number; max: number; critical: number } | undefined;
  value: number | null;
  dataPoints?: number;
  threshold: {
    min: number;
    max: number;
    critical: number;
  };
  day?: string;
  week?: string;
  month?: string;
  timestamp?: string;
}

interface ApiResponse {
  success: boolean;
  data: any[];
  error?: string;
  message?: string;
}

interface WeeklyOverviewItem {
  dayOfWeek: number;
  date: string;
  dayName: string;
  timestamp: string;
  hasData: boolean;
  dataPoints: number;
  measurements: {
    temperature: number | null;
    humidity: number | null;
    soil_moisture: number | null;
    soil_ph: number | null;
    light_intensity: number | null;
  };
}

// Update the SensorReading interface to match your historical API structure
interface SensorReading {
  timestamp: string;
  temperature: number;
  humidity?: number;
  soilMoisture?: number; // Changed from soil_moisture
  lightIntensity?: number; // Changed from light_intensity
  soilPh?: number; // Changed from soil_ph
  nitrogen?: number;
  phosphorus?: number;
  potassium?: number;
  created_at?: string;
}


// Temperature thresholds
const TEMPERATURE_THRESHOLDS = {
  min: 20, // Minimum optimal temperature
  max: 30, // Maximum optimal temperature
  critical: 35, // Critical temperature
};

// Color constants
const TEMPERATURE_COLORS = {
  primary: "#F97316", // Orange-500
  min: "#FDBA74", // Orange-300
  max: "#EA580C", // Orange-600
  critical: "#C2410C", // Orange-700
  background: "#FFF7ED", // Orange-50
  text: "#9A3412", // Orange-800
  trend: {
    up: "#22C55E", // Green-500
    down: "#EF4444", // Red-500
    neutral: "#6B7280", // Gray-500
  }
};

// Utility Functions
const formatDateRange = (start: Date, end: Date): string => {
  return `${format(start, 'MMM dd, yyyy')} - ${format(end, 'MMM dd, yyyy')}`;
};

const getStartOfWeek = (date: Date): Date => {
  console.log('getStartOfWeek input:', {
    inputDate: date.toISOString(),
    inputLocalDate: date.toDateString(),
    inputDay: date.getDay(),
    inputDayName: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][date.getDay()]
  });
  
  // Create a new date in local time to avoid timezone issues
  const start = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  const day = start.getDay(); // 0 = Sunday, 1 = Monday, etc.
  
  // Calculate days to subtract to get to Sunday
  // If it's already Sunday (day === 0), we don't subtract anything
  const daysToSubtract = day; 
  
  // Subtract days to get to Sunday
  start.setDate(start.getDate() - daysToSubtract);
  start.setHours(0, 0, 0, 0);
  
  console.log('getStartOfWeek calculation:', {
    originalDay: day,
    originalDayName: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][day],
    daysSubtracted: daysToSubtract,
    resultDate: start.toISOString(),
    resultLocalDate: start.toDateString(),
    resultDay: start.getDay(),
    resultDayName: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][start.getDay()],
    isSunday: start.getDay() === 0
  });
  
  // Verify we got Sunday
  if (start.getDay() !== 0) {
    console.error('CRITICAL ERROR: getStartOfWeek did not return a Sunday!', {
      expected: 0,
      actual: start.getDay(),
      date: start.toISOString()
    });
    
    // Emergency fix: force to previous Sunday
    const emergencyStart = new Date(start);
    emergencyStart.setDate(start.getDate() - start.getDay());
    emergencyStart.setHours(0, 0, 0, 0);
    
    console.log('Emergency fix applied:', {
      originalResult: start.toISOString(),
      emergencyResult: emergencyStart.toISOString(),
      emergencyDay: emergencyStart.getDay()
    });
    
    return emergencyStart;
  }
  
  return start;
};


const getEndOfWeek = (date: Date): Date => {
  const end = new Date(date);
  end.setDate(date.getDate() + 6);
  end.setHours(23, 59, 59, 999);
  return end;
};

const getStartOfMonth = (date: Date): Date => {
  return new Date(date.getFullYear(), date.getMonth(), 1);
};

const getEndOfMonth = (date: Date): Date => {
  return new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59, 999);
};

const getWeeksInMonth = (date: Date): number => {
  const firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
  const lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
  const firstWeekday = firstDay.getDay();
  const daysInMonth = lastDay.getDate();
  return Math.ceil((daysInMonth + firstWeekday) / 7);
};

const getWeekNumberInMonth = (date: Date): number => {
  const firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
  const firstWeekday = firstDay.getDay();
  const dayOfMonth = date.getDate();
  return Math.ceil((dayOfMonth + firstWeekday) / 7);
};

const getDefaultData = (period: string, baseDate?: Date): { chartData: DataItem[]; xKey: string; dateRange: string } => {
  const today = baseDate ? new Date(baseDate) : new Date();
  const defaultThreshold = {
    min: TEMPERATURE_THRESHOLDS.min,
    max: TEMPERATURE_THRESHOLDS.max,
    critical: TEMPERATURE_THRESHOLDS.critical,
  };

  switch (period) {
    case 'daily': {
      const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const chartData: DataItem[] = days.map(day => ({
        day,
        value: null,
        dataPoints: 0,
        threshold: defaultThreshold
      }));
      const startOfWeek = getStartOfWeek(today);
      const endOfWeek = getEndOfWeek(startOfWeek);
      return {
        chartData,
        xKey: 'day',
        dateRange: formatDateRange(startOfWeek, endOfWeek)
      };
    }
    case 'weekly': {
      const weeksInMonth = getWeeksInMonth(today);
      const chartData: DataItem[] = Array.from({ length: weeksInMonth }, (_, i) => ({
        week: `Week ${i + 1}`,
        value: null,
        dataPoints: 0,
        threshold: defaultThreshold
      }));
      const startOfMonth = getStartOfMonth(today);
      const endOfMonth = getEndOfMonth(today);
      return {
        chartData,
        xKey: 'week',
        dateRange: formatDateRange(startOfMonth, endOfMonth)
      };
    }
    case 'monthly': {
      const monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];
      const chartData: DataItem[] = monthNames.map(month => ({
        month,
        value: null,
        dataPoints: 0,
        threshold: defaultThreshold
      }));
      const startOfYear = new Date(today.getFullYear(), 0, 1);
      const endOfYear = new Date(today.getFullYear(), 11, 31);
      return {
        chartData,
        xKey: 'month',
        dateRange: formatDateRange(startOfYear, endOfYear)
      };
    }
    default:
      return { chartData: [], xKey: '', dateRange: '' };
  }
};

// Custom Tooltip
const CustomTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    const data = payload[0].payload;
    const value = payload[0].value;
    const threshold = data.threshold;
    
    let status = "Normal";
    let statusColor = "text-green-600";
    let statusIcon = <Thermometer className="w-4 h-4" />;
    
    if (value === null || value === 0) {
      status = "No Data";
      statusColor = "text-gray-600";
    } else if (value < threshold.min) {
      status = "Too Cold";
      statusColor = "text-blue-600";
    } else if (value > threshold.critical) {
      status = "Critical";
      statusColor = "text-purple-600";
    } else if (value > threshold.max) {
      status = "Too Hot";
      statusColor = "text-orange-600";
    }
    
    return (
      <div className="bg-white border border-gray-200 rounded-lg p-3 shadow-lg">
        <div className="flex items-center gap-2 mb-2">
          <div className={`p-2 rounded-full ${TEMPERATURE_COLORS.background}`}>
            <Thermometer className={`w-4 h-4 text-orange-800`} />
          </div>
          <p className="font-semibold text-gray-800">{label}</p>
        </div>
        <p className="text-orange-500">{`Temperature: ${value || 0}°C`}</p>
        <p className={`${statusColor} text-sm flex items-center gap-1`}>
          {statusIcon}
          {`Status: ${status}`}
        </p>
        {data.dataPoints !== undefined && (
          <p className="text-gray-500 text-sm">{`Data Points: ${data.dataPoints}`}</p>
        )}
        <div className="mt-2 text-xs text-gray-500">
          <p>Thresholds:</p>
          <p className="text-orange-300">Min: {threshold.min}°C</p>
          <p className="text-orange-600">Max: {threshold.max}°C</p>
          <p className="text-orange-700">Critical: {threshold.critical}°C</p>
        </div>
      </div>
    );
  }
  return null;
};

const calculateTrend = (data: DataItem[]): { trend: 'up' | 'down' | 'neutral'; percentage: number } => {
  const validData = data.filter(item => item.value !== null && item.value !== 0);
  if (validData.length < 2) {
    return { trend: 'neutral', percentage: 0 };
  }

  const firstValue = validData[0].value as number;
  const lastValue = validData[validData.length - 1].value as number;

  if (firstValue === 0) {
    return { trend: 'neutral', percentage: 0 };
  }

  const percentageChange = ((lastValue - firstValue) / firstValue) * 100;
  const roundedPercentage = Math.round(percentageChange * 10) / 10;

  if (Math.abs(roundedPercentage) < 1) {
    return { trend: 'neutral', percentage: 0 };
  }

  return {
    trend: roundedPercentage > 0 ? 'up' : 'down',
    percentage: Math.abs(roundedPercentage)
  };
};

const getStatusBadge = (value: number | null) => {
  if (value === null || value === 0) {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-gray-100 text-gray-800">No Data</span>;
  }
  
  if (value >= TEMPERATURE_THRESHOLDS.critical) {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">Critical</span>;
  } else if (value >= TEMPERATURE_THRESHOLDS.max) {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-orange-100 text-orange-800">High</span>;
  } else if (value >= TEMPERATURE_THRESHOLDS.min) {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">Optimal</span>;
  } else {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">Low</span>;
  }
};

type ViewType = 'line' | 'bar' | 'list' | 'tabular';

const periodOptions = [
  { label: 'Daily', value: 'daily', icon: <Calendar className="h-4 w-4 mr-1" /> },
  { label: 'Weekly', value: 'weekly', icon: <Calendar className="h-4 w-4 mr-1" /> },
  { label: 'Monthly', value: 'monthly', icon: <Calendar className="h-4 w-4 mr-1" /> },
];

const viewTypeOptions = [
  { label: 'Line', value: 'line', icon: <LineChart className="h-4 w-4 mr-1" /> },
  { label: 'Bar', value: 'bar', icon: <BarChart3 className="h-4 w-4 mr-1" /> },
  { label: 'Table', value: 'tabular', icon: <Table className="h-4 w-4 mr-1" /> },
];

// Main Component
const TemperatureDashboard = () => {
  const [chartData, setChartData] = useState<DataItem[]>([]);
  const [overview, setOverview] = useState<'daily' | 'weekly' | 'monthly'>('daily');
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [dateRange, setDateRange] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [viewType, setViewType] = useState<ViewType>('line');
  const [showExportModal, setShowExportModal] = useState<boolean>(false);
  const [xKey, setXKey] = useState<string>('day');
  const chartRef = useRef<HTMLDivElement>(null);

  // API Configuration
  const API_CONFIG = {
    baseUrl: 'https://maize-watch.onrender.com',
    endpoints: {
      historical: '/api/sensors/historical',
      weekly: '/api/sensors/weekly-overview',
      latest: '/api/sensors/latest'
    }
  };

  // Intelligent refresh hook
  const {
    isRefreshing,
    lastRefreshTime,
    toggleAutoRefresh,
    autoRefreshEnabled
  } = useIntelligentRefresh({
    refreshInterval: 30000, // 30 seconds
    enabled: true,
    onRefresh: () => fetchData(overview, selectedDate, true)
  });

  // Enhanced API call with better error handling and logging
  const makeApiCall = async (url: string): Promise<ApiResponse> => {
    console.log('Making API request to:', url);
    
    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Add timeout
        signal: AbortSignal.timeout(30000) // 30 second timeout
      });

      console.log('Response status:', response.status);
      console.log('Response headers:', Object.fromEntries(response.headers.entries()));

      if (!response.ok) {
        const errorText = await response.text();
        console.error('API error response:', errorText);
        throw new Error(`HTTP ${response.status}: ${errorText || response.statusText}`);
      }

      const data = await response.json();
      console.log('API response received:', {
        success: data.success,
        dataLength: Array.isArray(data.data) ? data.data.length : 'Not an array',
        dataType: typeof data.data,
        firstItem: Array.isArray(data.data) && data.data.length > 0 ? data.data[0] : null,
        structure: data
      });

      return data;
    } catch (error) {
      console.error('API call failed:', error);
      throw error;
    }
  };

const fetchData = async (period: string, baseDate: Date = new Date(), silent: boolean = false) => {
  if (!silent) {
    setIsLoading(true);
  }
  setError(null);

  try {
    let url: string;
    let startDate: Date;
    let endDate: Date;
    let useWeeklyOverview = false;

    // Determine which endpoint and date range to use
    switch (period) {
      case 'daily': {
        startDate = getStartOfWeek(baseDate);
        endDate = getEndOfWeek(startDate);
        
        // Use weekly-overview with date parameters for daily view
        url = `${API_CONFIG.baseUrl}${API_CONFIG.endpoints.weekly}?startDate=${startDate.toISOString()}endDate=${endDate.toISOString()}`;
        useWeeklyOverview = true;
        break;
      }
      case 'weekly': {
        startDate = getStartOfMonth(baseDate);
        endDate = getEndOfMonth(baseDate);
        
        url = `${API_CONFIG.baseUrl}${API_CONFIG.endpoints.historical}?startDate=${startDate.toISOString()}endDate=${endDate.toISOString()}`;
        break;
      }
      case 'monthly': {
        startDate = new Date(baseDate.getFullYear(), 0, 1);
        endDate = new Date(baseDate.getFullYear(), 11, 31, 23, 59, 59, 999);
        
        url = `${API_CONFIG.baseUrl}${API_CONFIG.endpoints.historical}?startDate=${startDate.toISOString()}endDate=${endDate.toISOString()}`;
        break;
      }
      default:
        throw new Error('Invalid period specified');
    }

    console.log(`Fetching ${period} data for date range:`, {
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
      url,
      useWeeklyOverview
    });

    const result = await makeApiCall(url);

    if (!result.success) {
      throw new Error(result.error || result.message || 'Failed to fetch data');
    }

    let processedData: DataItem[] = [];
    const rawData = result.data;

    // Check if we have valid data
    if (!rawData || !Array.isArray(rawData)) {
      console.warn('Invalid data format received:', rawData);
      processedData = getDefaultData(period, baseDate).chartData;
    } else if (rawData.length === 0) {
      console.warn('No data available for the selected period');
      processedData = getDefaultData(period, baseDate).chartData;
    } else {
      // Process the data based on period and data source
      processedData = await processDataByPeriod(rawData, period, baseDate, startDate, endDate, useWeeklyOverview);
    }

    console.log('Final processed data:', {
      period,
      dataLength: processedData.length,
      itemsWithData: processedData.filter(item => item.value !== null && item.value !== 0).length,
      sampleItems: processedData.slice(0, 3)
    });

    setChartData(processedData);
    setDateRange(formatDateRange(startDate, endDate));
    setError(null);

  } catch (error) {
    console.error(`Error fetching ${period} data:`, error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
    setError(`Failed to fetch data: ${errorMessage}`);
    
    // Set default data on error
    const defaultData = getDefaultData(period, baseDate);
    setChartData(defaultData.chartData);
    setXKey(defaultData.xKey);
    setDateRange(defaultData.dateRange);
  } finally {
    setIsLoading(false);
  }
};

const processDataByPeriod = async (
  rawData: any[], 
  period: string, 
  baseDate: Date,
  startDate: Date,
  endDate: Date,
  useWeeklyOverview: boolean = false
): Promise<DataItem[]> => {
  console.log(`Processing ${rawData.length} records for ${period} view`, {
    baseDate: baseDate.toISOString(),
    startDate: startDate.toISOString(),
    endDate: endDate.toISOString(),
    useWeeklyOverview,
    sampleData: rawData[0]
  });

  switch (period) {
    case 'daily': {
      const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      
      if (useWeeklyOverview) {
        // Process weekly-overview data structure
        console.log('Processing weekly-overview data for daily view');
        setXKey('day');
        
        // Filter the weekly overview data to only include items within our target date range
        const filteredData = rawData.filter((item: WeeklyOverviewItem) => {
          const itemDate = new Date(item.date);
          return itemDate >= startDate && itemDate <= endDate;
        });
        
        console.log('Filtered weekly overview data:', {
          originalCount: rawData.length,
          filteredCount: filteredData.length,
          targetDateRange: { startDate: startDate.toISOString(), endDate: endDate.toISOString() },
          filteredItems: filteredData.map(item => ({ date: item.date, dayName: item.dayName, temperature: item.measurements?.temperature }))
        });
        
        return days.map(day => {
          const dayData = filteredData.find((item: WeeklyOverviewItem) => item.dayName === day);
          
          const result = {
            day,
            value: dayData?.measurements?.temperature || null,
            dataPoints: dayData?.dataPoints || 0,
            threshold: TEMPERATURE_THRESHOLDS
          };
          
          console.log(`Day ${day}:`, result);
          return result;
        });
      } else {
        // Process historical data structure for daily view
        console.log('Processing historical data for daily view');
        const dailyData = new Map<string, { sum: number; count: number; }>();
        days.forEach(day => dailyData.set(day, { sum: 0, count: 0 }));

        rawData.forEach((item: SensorReading) => {
          if (!item.timestamp || typeof item.temperature !== 'number' || isNaN(item.temperature)) {
            return;
          }

          const date = new Date(item.timestamp);
          // Filter data to only include items within the specified date range
          if (date < startDate || date > endDate) {
            return;
          }

          const dayKey = days[date.getDay()];
          const current = dailyData.get(dayKey);
          
          if (current) {
            current.sum += item.temperature;
            current.count++;
          }
        });

        console.log('Daily data processing result:', Object.fromEntries(dailyData));
        
        setXKey('day');
        return days.map(day => {
          const data = dailyData.get(day)!;
          return {
            day,
            value: data.count > 0 ? parseFloat((data.sum / data.count).toFixed(2)) : null,
            dataPoints: data.count,
            threshold: TEMPERATURE_THRESHOLDS
          };
        });
      }
    }

    case 'weekly': {
      const weeksInMonth = getWeeksInMonth(baseDate);
      const weeklyData = new Map<string, { sum: number; count: number; }>();

      // Initialize all weeks
      for (let i = 1; i <= weeksInMonth; i++) {
        weeklyData.set(`Week ${i}`, { sum: 0, count: 0 });
      }

      // Process historical data for weekly view
      rawData.forEach((item: SensorReading) => {
        if (!item.timestamp || typeof item.temperature !== 'number' || isNaN(item.temperature)) {
          return;
        }

        const date = new Date(item.timestamp);
        // Filter data to only include items within the specified date range
        if (date < startDate || date > endDate) {
          return;
        }

        // Check if the date falls within the target month
        if (date.getMonth() !== baseDate.getMonth() || date.getFullYear() !== baseDate.getFullYear()) {
          return;
        }

        const weekNumber = getWeekNumberInMonth(date);
        const weekKey = `Week ${weekNumber}`;

        if (weeklyData.has(weekKey)) {
          const current = weeklyData.get(weekKey)!;
          current.sum += item.temperature;
          current.count++;
        }
      });

      console.log('Weekly data processing result:', Object.fromEntries(weeklyData));

      setXKey('week');
      return Array.from(weeklyData.entries()).map(([week, data]) => ({
        week,
        value: data.count > 0 ? parseFloat((data.sum / data.count).toFixed(2)) : null,
        dataPoints: data.count,
        threshold: TEMPERATURE_THRESHOLDS
      }));
    }

    case 'monthly': {
      const monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];
      const monthlyData = new Map<string, { sum: number; count: number; }>();

      // Initialize all months
      monthNames.forEach(month => monthlyData.set(month, { sum: 0, count: 0 }));

      // Process historical data for monthly view
      rawData.forEach((item: SensorReading) => {
        if (!item.timestamp || typeof item.temperature !== 'number' || isNaN(item.temperature)) {
          return;
        }

        const date = new Date(item.timestamp);
        // Filter data to only include items within the specified date range
        if (date < startDate || date > endDate) {
          return;
        }

        // Check if the date falls within the target year
        if (date.getFullYear() !== baseDate.getFullYear()) {
          return;
        }

        const monthKey = monthNames[date.getMonth()];
        const current = monthlyData.get(monthKey)!;
        current.sum += item.temperature;
        current.count++;
      });

      console.log('Monthly data processing result:', Object.fromEntries(monthlyData));

      setXKey('month');
      return monthNames.map(month => {
        const data = monthlyData.get(month)!;
        return {
          month,
          value: data.count > 0 ? parseFloat((data.sum / data.count).toFixed(2)) : null,
          dataPoints: data.count,
          threshold: TEMPERATURE_THRESHOLDS
        };
      });
    }

    default:
      return getDefaultData(period, baseDate).chartData;
  }
};

  // Fetch data when overview or selectedDate changes
  useEffect(() => {
    fetchData(overview, selectedDate);
  }, [overview, selectedDate]);

  const handleOverviewChange = (newOverview: 'daily' | 'weekly' | 'monthly') => {
    setOverview(newOverview);
  };

const handlePreviousPeriod = () => {
  let newDate: Date;
  switch (overview) {
    case 'daily':
      // Move to the previous week's Sunday
      const currentWeekStart = getStartOfWeek(selectedDate);
      console.log('Previous period - current week start:', currentWeekStart.toISOString());
      newDate = new Date(currentWeekStart.getTime() - 7 * 24 * 60 * 60 * 1000);
      console.log('Previous period - new date:', newDate.toISOString());
      break;
    case 'weekly':
      newDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth() - 1, 1);
      break;
    case 'monthly':
      newDate = new Date(selectedDate.getFullYear() - 1, selectedDate.getMonth(), 1);
      break;
    default:
      newDate = new Date(selectedDate.getTime() - 24 * 60 * 60 * 1000);
  }
  console.log('handlePreviousPeriod result:', { overview, oldDate: selectedDate.toISOString(), newDate: newDate.toISOString() });
  setSelectedDate(newDate);
};


const handleNextPeriod = () => {
  const now = new Date();
  
  let newDate: Date;
  switch (overview) {
    case 'daily':
      // Move to the next week's Sunday
      const currentWeekStart = getStartOfWeek(selectedDate);
      newDate = new Date(currentWeekStart.getTime() + 7 * 24 * 60 * 60 * 1000);
      break;
    case 'weekly':
      newDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, 1);
      break;
    case 'monthly':
      newDate = new Date(selectedDate.getFullYear() + 1, selectedDate.getMonth(), 1);
      break;
    default:
      newDate = new Date(selectedDate.getTime() + 24 * 60 * 60 * 1000);
  }

  // Don't navigate to future dates
  if (newDate > now) {
    newDate = now;
  }
  console.log('handleNextPeriod:', { overview, selectedDate, newDate, now });
  setSelectedDate(newDate);
};

  const handleExport = () => {
    setShowExportModal(true);
  };

  const renderSummary = () => {
    const validData = chartData.filter(item => item.value !== null && item.value !== 0);
    if (validData.length === 0) {
      return (
        <div className="mt-4 p-4 bg-muted rounded-lg">
          <p className="text-sm text-muted-foreground">No temperature data available for the selected period</p>
          <p className="text-xs text-muted-foreground mt-2">
            Try selecting a different time period or check if sensors are collecting data.
          </p>
        </div>
      );
    }

    const currentValue = validData[validData.length - 1].value as number;
    const averageValue = validData.reduce((sum, item) => sum + (item.value as number), 0) / validData.length;
    const trend = calculateTrend(validData);

    let status = 'Normal';
    let statusColor = 'text-green-600';
    if (currentValue < TEMPERATURE_THRESHOLDS.min) {
      status = 'Too Cold';
      statusColor = 'text-blue-600';
    } else if (currentValue > TEMPERATURE_THRESHOLDS.critical) {
      status = 'Critical';
      statusColor = 'text-red-600';
    } else if (currentValue > TEMPERATURE_THRESHOLDS.max) {
      status = 'Too Hot';
      statusColor = 'text-orange-600';
    }

    return (
      <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="p-4 bg-card rounded-lg border">
          <h3 className="text-sm font-medium text-muted-foreground">Current Status</h3>
          <p className={`text-xl lg:text-2xl font-bold ${statusColor}`}>{status}</p>
          <p className="text-sm text-muted-foreground">Current: {currentValue.toFixed(1)}°C</p>
        </div>
        <div className="p-4 bg-card rounded-lg border">
          <h3 className="text-sm font-medium text-muted-foreground">Average</h3>
          <p className="text-xl lg:text-2xl font-bold">{averageValue.toFixed(1)}°C</p>
          <p className="text-sm text-muted-foreground">Based on {validData.length} data points</p>
        </div>
        <div className="p-4 bg-card rounded-lg border">
          <h3 className="text-sm font-medium text-muted-foreground">Trend</h3>
          <div className="flex items-center gap-2">
            <span className={`text-xl lg:text-2xl font-bold ${trend.trend === 'up' ? 'text-green-600' :
                trend.trend === 'down' ? 'text-red-600' :
                  'text-gray-600'
              }`}>
              {trend.trend === 'up' ? '↑' : trend.trend === 'down' ? '↓' : '→'}
            </span>
            <p className="text-xl lg:text-2xl font-bold">
              {trend.percentage > 0 ? `${trend.percentage}%` : 'Stable'}
            </p>
          </div>
          <p className="text-sm text-muted-foreground">
            {trend.trend === 'up' ? 'Increasing' :
              trend.trend === 'down' ? 'Decreasing' :
                'No significant change'}
          </p>
        </div>
        <div className="p-4 bg-card rounded-lg border">
          <h3 className="text-sm font-medium text-muted-foreground">Thresholds</h3>
          <p className="text-sm">Min: {TEMPERATURE_THRESHOLDS.min}°C</p>
          <p className="text-sm">Max: {TEMPERATURE_THRESHOLDS.max}°C</p>
          <p className="text-sm text-red-600">Critical: {TEMPERATURE_THRESHOLDS.critical}°C</p>
        </div>
      </div>
    );
  };

  const renderChart = () => {
    if (isLoading) return <Skeleton className="h-[300px] sm:h-[400px] w-full" />;
    
    if (error) return (
      <Alert variant="destructive">
        <AlertTitle>Error Loading Data</AlertTitle>
        <AlertDescription>{error}</AlertDescription>
      </Alert>
    );

    const displayData = chartData.map(item => ({
      ...item,
      value: item.value ?? 0,
      threshold: TEMPERATURE_THRESHOLDS
    }));

    if (viewType === 'tabular') {
      return (
        <div className="overflow-x-auto max-h-[300px] sm:max-h-[500px]">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50 sticky top-0">
              <tr>
                <th className="px-3 sm:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  {xKey === 'day' ? 'Day' : xKey === 'week' ? 'Week' : 'Month'}
                </th>
                <th className="px-3 sm:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Temperature (°C)
                </th>
                <th className="px-3 sm:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {displayData.map((item, index) => (
                <tr key={index} className="hover:bg-gray-50">
                  <td className="px-3 sm:px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {renderTableCell(item)}
                  </td>
                  <td className="px-3 sm:px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {item.value ? item.value.toFixed(1) : '0.0'}°C
                  </td>
                  <td className="px-3 sm:px-6 py-4 whitespace-nowrap text-sm">
                    {getStatusBadge(item.value)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      );
    }

    const thresholdLines = [
      <ReferenceLine key="min" y={TEMPERATURE_THRESHOLDS.min} stroke="green" strokeDasharray="3 3" label={{ value: 'Min', position: 'right', fill: 'green' }} />,
      <ReferenceLine key="max" y={TEMPERATURE_THRESHOLDS.max} stroke="orange" strokeDasharray="3 3" label={{ value: 'Max', position: 'right', fill: 'orange' }} />,
      <ReferenceLine key="critical" y={TEMPERATURE_THRESHOLDS.critical} stroke="red" strokeDasharray="3 3" label={{ value: 'Critical', position: 'right', fill: 'red' }} />,
    ];

    if (viewType === 'line') {
      return (
        <div className="h-[300px] sm:h-[400px] lg:h-[500px] p-2 sm:p-4 mb-4">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart
              data={displayData}
              margin={{ top: 20, right: 15, left: 10, bottom: 60 }}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                dataKey={xKey}
                height={80}
                tick={{ fontSize: 10 }}
                angle={window.innerWidth < 640 ? -45 : 0}
                textAnchor={window.innerWidth < 640 ? 'end' : 'middle'}
                dy={10}
                padding={{ left: 20, right: 20 }}
                interval="preserveStartEnd"
              />
              <YAxis
                domain={[0, 50]}
                tick={{ fontSize: 10 }}
                tickFormatter={(value) => `${value}°C`}
                width={50}
                tickMargin={5}
                axisLine={{ stroke: '#666' }}
                tickLine={{ stroke: '#666' }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend verticalAlign="top" height={36} />
              <Line
                type="monotoneX"
                dataKey="value"
                name="Temperature"
                stroke="#F97316"
                strokeWidth={2}
                dot={{ fill: '#fff', strokeWidth: 2, r: 4 }}
                activeDot={{ r: 6, fill: '#fff', stroke: '#F97316', strokeWidth: 2 }}
                connectNulls={false}
                isAnimationActive={true}
                animationDuration={500}
              />
              {thresholdLines}
            </LineChart>
          </ResponsiveContainer>
        </div>
      );
    }

    if (viewType === 'bar') {
      return (
        <div className="h-[300px] sm:h-[400px] lg:h-[500px] p-2 sm:p-4 mb-4">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart
              data={displayData}
              margin={{ top: 20, right: 15, left: 10, bottom: 60 }}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                dataKey={xKey}
                height={80}
                tick={{ fontSize: 10 }}
                angle={window.innerWidth < 640 ? -45 : 0}
                textAnchor={window.innerWidth < 640 ? 'end' : 'middle'}
                dy={10}
                padding={{ left: 20, right: 20 }}
                interval="preserveStartEnd"
              />
              <YAxis
                domain={[0, 50]}
                tick={{ fontSize: 10 }}
                tickFormatter={(value) => `${value}°C`}
                width={50}
                tickMargin={5}
                axisLine={{ stroke: '#666' }}
                tickLine={{ stroke: '#666' }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend verticalAlign="top" height={36} />
              <Bar
                dataKey="value"
                name="Temperature"
                fill="#F97316"
                radius={[4, 4, 0, 0]}
              />
              {thresholdLines}
            </BarChart>
          </ResponsiveContainer>
        </div>
      );
    }
    return null;
  };

  const renderTableCell = (item: DataItem) => {
    const value = item[xKey];
    if (typeof value === 'string' || typeof value === 'number') {
      return value.toString();
    }
    return '';
  };

  return (
    <div className="w-full max-w-7xl mx-auto overflow-x-hidden">
      <Card className="w-full">
        <CardHeader className="px-4 sm:px-6">
          <div className="flex flex-col space-y-4">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
              <div className="flex items-center space-x-3">
                <div className="p-2 bg-orange-100 rounded-lg flex-shrink-0">
                  <Thermometer className="h-6 w-6 sm:h-8 sm:w-8 text-orange-600" />
                </div>
                <div className="min-w-0">
                  <h1 className="text-xl sm:text-2xl font-bold text-gray-900 truncate">Temperature Dashboard</h1>
                  <p className="text-sm text-muted-foreground truncate">{dateRange}</p>
                </div>
              </div>
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3">
                <div className="flex items-center space-x-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={handlePreviousPeriod}
                    className="flex-1 sm:flex-none text-xs sm:text-sm px-2 sm:px-3"
                  >
                    <ChevronLeft className="h-3 w-3 sm:h-4 sm:w-4 mr-1" />
                    <span className="hidden xs:inline">
                      {overview === 'daily' ? 'Prev Week' :
                        overview === 'weekly' ? 'Prev Month' :
                          'Prev Year'}
                    </span>
                    <span className="xs:hidden">Prev</span>
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={handleNextPeriod}
                    className="flex-1 sm:flex-none text-xs sm:text-sm px-2 sm:px-3"
                  >
                    <span className="hidden xs:inline">
                      {overview === 'daily' ? 'Next Week' :
                        overview === 'weekly' ? 'Next Month' :
                          'Next Year'}
                    </span>
                    <span className="xs:hidden">Next</span>
                    <ChevronRight className="h-3 w-3 sm:h-4 sm:w-4 ml-1" />
                  </Button>
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleExport}
                  className="flex items-center justify-center text-xs sm:text-sm px-2 sm:px-3"
                >
                  <Download className="h-3 w-3 sm:h-4 sm:w-4 mr-1" />
                  <span className="hidden sm:inline">Export Data</span>
                  <span className="sm:hidden">Export</span>
                </Button>
              </div>
            </div>
          </div>
        </CardHeader>
        <CardContent className="px-4 sm:px-6">
          <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between mb-3 gap-3">
            <div className="flex flex-col sm:flex-row items-stretch sm:items-center space-y-3 sm:space-y-0 sm:space-x-3">
              <div className="relative">
                <DropdownMenu modal={false}>
                  <DropdownMenuTrigger asChild>
                    <Button variant="outline" className="w-full sm:w-[180px] justify-between">
                      <div className="flex items-center">
                        {periodOptions.find(option => option.value === overview)?.icon || <Calendar className="h-4 w-4 mr-2" />}
                        <span className="hidden sm:inline">
                          {periodOptions.find(option => option.value === overview)?.label || "Select period"}
                        </span>
                        <span className="sm:hidden">
                          {overview ? overview.charAt(0).toUpperCase() + overview.slice(1) : "Period"}
                        </span>
                      </div>
                      <ChevronDown className="h-4 w-4 ml-2" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent
                    align="start"
                    sideOffset={5}
                    className="z-50 min-w-[180px]"
                    avoidCollisions={true}
                  >
                    {periodOptions.map((option) => (
                      <DropdownMenuItem
                        key={option.value}
                        onClick={() => handleOverviewChange(option.value as 'daily' | 'weekly' | 'monthly')}
                      >
                        <div className="flex items-center">
                          {option.icon}
                          <span className="ml-2">{option.label}</span>
                        </div>
                      </DropdownMenuItem>
                    ))}
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>

              <div className="relative">
                <DropdownMenu modal={false}>
                  <DropdownMenuTrigger asChild>
                    <Button variant="outline" className="w-full sm:w-[180px] justify-between">
                      <div className="flex items-center">
                        {viewType === 'line' ? <LineChart className="h-4 w-4 mr-2" /> :
                          viewType === 'bar' ? <BarChart3 className="h-4 w-4 mr-2" /> :
                            <Table className="h-4 w-4 mr-2" />}
                        <span className="hidden sm:inline">
                          {viewType.charAt(0).toUpperCase() + viewType.slice(1)} View
                        </span>
                        <span className="sm:hidden">
                          {viewType.charAt(0).toUpperCase() + viewType.slice(1)}
                        </span>
                      </div>
                      <ChevronDown className="h-4 w-4 ml-2" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent
                    align="start"
                    sideOffset={5}
                    className="z-50 min-w-[180px]"
                    avoidCollisions={true}
                  >
                    {viewTypeOptions.map((option) => (
                      <DropdownMenuItem
                        key={option.value}
                        onClick={() => setViewType(option.value as ViewType)}
                      >
                        <div className="flex items-center">
                          {option.icon}
                          <span className="ml-2">{option.label}</span>
                        </div>
                      </DropdownMenuItem>
                    ))}
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </div>

            <div className="flex justify-center sm:justify-end">
              <RefreshIndicator
                isRefreshing={isRefreshing}
                lastRefreshTime={lastRefreshTime}
                autoRefreshEnabled={autoRefreshEnabled}
                onToggleAutoRefresh={toggleAutoRefresh}
              />
            </div>
          </div>

          <div ref={chartRef} className="h-[300px] sm:h-[400px] lg:h-[450px] mb-2">
            {renderChart()}
          </div>
          {renderSummary()}
        </CardContent>
        <UnifiedExportModal
          isOpen={showExportModal}
          onClose={() => setShowExportModal(false)}
          currentOverview={overview}
          chartData={chartData}
          chartRef={chartRef}
          chartType="temperature"
          dateRange={dateRange}
        />
      </Card>
    </div>
  );
};

export default TemperatureDashboard;