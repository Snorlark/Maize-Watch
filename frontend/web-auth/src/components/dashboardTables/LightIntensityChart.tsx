import { useState, useRef, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, ReferenceLine, Legend } from 'recharts';
import { Card, CardContent, CardHeader } from '../ui/card';
import { Button } from '../ui/button';
import { Calendar, Download, Clock, BarChart3, Table, Sun, ChevronLeft, ChevronRight, ChevronDown } from 'lucide-react';
import UnifiedExportModal from '../UnifiedExportModal';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "../ui/select";
import { Skeleton } from '../ui/skeleton';
import { Alert, AlertDescription, AlertTitle } from '../ui/alert';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "../ui/dropdown-menu";
import { RefreshIndicator } from '../ui/refresh-indicator';
import { useIntelligentRefresh } from '../../hooks/useIntelligentRefresh';

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
  hour?: string;
  day?: string;
  week?: string;
  month?: string;
  timestamp?: string;
}

// Add light intensity thresholds
const LIGHT_INTENSITY_THRESHOLDS = {
  min: 5000, // Minimum optimal light intensity (lux)
  max: 10000, // Maximum optimal light intensity (lux)
  critical: 12000, // Critical light intensity (lux)
};

// Update the color constants
const LIGHT_INTENSITY_COLORS = {
  primary: "#F59E0B", // Amber-500
  min: "#FCD34D", // Amber-300
  max: "#B45309", // Amber-700
  critical: "#92400E", // Amber-800
  background: "#FFFBEB", // Amber-50
  text: "#92400E", // Amber-800
  trend: {
    up: "#22C55E", // Green-500
    down: "#EF4444", // Red-500
    neutral: "#6B7280", // Gray-500
  }
};

// Utility Functions
const formatDateRange = (start: Date, end: Date): string => {
  const options: Intl.DateTimeFormatOptions = { 
    month: 'short', 
    day: 'numeric', 
    year: 'numeric',
    timeZone: 'Asia/Manila'
  };
  return `${start.toLocaleDateString('en-PH', options)} - ${end.toLocaleDateString('en-PH', options)}`;
};

const getDefaultData = (period: string, baseDate?: Date): { chartData: DataItem[]; xKey: string; dateRange: string } => {
  const today = baseDate ? new Date(baseDate) : new Date();
      const defaultThreshold = {
        min: LIGHT_INTENSITY_THRESHOLDS.min,
        max: LIGHT_INTENSITY_THRESHOLDS.max,
        critical: LIGHT_INTENSITY_THRESHOLDS.critical,
      };

  switch (period) {
    case 'hourly': {
      const currentDate = new Date(today);
      const chartData: DataItem[] = [];
      for (let i = 0; i < 24; i++) {
        chartData.push({
          hour: `${i.toString().padStart(2, '0')}:00`,
          value: null,
          dataPoints: 0,
          threshold: defaultThreshold
        });
      }
      return {
        chartData,
        xKey: 'hour',
        dateRange: formatDateRange(currentDate, currentDate)
      };
    }
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
    let statusIcon = <Sun className="w-4 h-4" />;
    if (value < threshold.min) {
      status = "Too Low";
      statusColor = "text-yellow-600";
    } else if (value > threshold.critical) {
      status = "Critical";
      statusColor = "text-purple-600";
    } else if (value > threshold.max) {
      status = "Too High";
      statusColor = "text-orange-600";
    }
    return (
      <div className="bg-white border border-gray-200 rounded-lg p-3 shadow-lg">
        <div className="flex items-center gap-2 mb-2">
          <div className={`p-2 rounded-full ${LIGHT_INTENSITY_COLORS.background}`}>
            <Sun className={`w-4 h-4 ${LIGHT_INTENSITY_COLORS.text}`} />
          </div>
          <p className="font-semibold text-gray-800">{label}</p>
        </div>
        <p className={`text-[${LIGHT_INTENSITY_COLORS.primary}]`}>{`Light Intensity: ${value} lux`}</p>
        <p className={`${statusColor} text-sm flex items-center gap-1`}>
          {statusIcon}
          {`Status: ${status}`}
        </p>
        {data.dataPoints !== undefined && (
          <p className="text-gray-500 text-sm">{`Data Points: ${data.dataPoints}`}</p>
        )}
        <div className="mt-2 text-xs text-gray-500">
          <p>Thresholds:</p>
          <p className="text-[#FCD34D]">Min: {threshold.min} lux</p>
          <p className="text-[#B45309]">Max: {threshold.max} lux</p>
          <p className="text-[#92400E]">Critical: {threshold.critical} lux</p>
        </div>
      </div>
    );
  }
  return null;
};

// Update the calculateTrend function to handle null values
const calculateTrend = (data: DataItem[]): { trend: 'up' | 'down' | 'neutral'; percentage: number } => {
  const validData = data.filter(item => item.value !== null);
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

// Add the same utility functions as HumidityChart
const getStartOfWeek = (date: Date): Date => {
  const daysFromSunday = date.getDay();
  return new Date(date.getFullYear(), date.getMonth(), date.getDate() - daysFromSunday);
};

const getEndOfWeek = (date: Date): Date => {
  const startOfWeek = getStartOfWeek(date);
  return new Date(startOfWeek.getFullYear(), startOfWeek.getMonth(), startOfWeek.getDate() + 6, 23, 59, 59, 999);
};

const getStartOfMonth = (date: Date): Date => {
  return new Date(date.getFullYear(), date.getMonth(), 1);
};

const getEndOfMonth = (date: Date): Date => {
  return new Date(date.getFullYear(), date.getMonth() + 1, 0, 23, 59, 59, 999);
};

// Update ViewType to include all options
type ViewType = 'line' | 'bar' | 'list' | 'tabular';

// Add at the top of LightIntensityDashboard
const periodOptions = [
  { label: 'Hourly', value: 'hourly', icon: <Clock className="h-4 w-4 mr-1" /> },
  { label: 'Daily', value: 'daily', icon: <Calendar className="h-4 w-4 mr-1" /> },
  { label: 'Weekly', value: 'weekly', icon: <Calendar className="h-4 w-4 mr-1" /> },
  { label: 'Monthly', value: 'monthly', icon: <Calendar className="h-4 w-4 mr-1" /> },
];
const viewTypeOptions = [
  { label: 'Line', value: 'line', icon: <LineChart className="h-4 w-4 mr-1" /> },
  { label: 'Bar', value: 'bar', icon: <BarChart3 className="h-4 w-4 mr-1" /> },
  { label: 'Table', value: 'tabular', icon: <Table className="h-4 w-4 mr-1" /> },
];

// Add the getStatusBadge function before the LightIntensityDashboard component
const getStatusBadge = (value: number) => {
  if (value >= LIGHT_INTENSITY_THRESHOLDS.critical) {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">Critical</span>;
  } else if (value >= LIGHT_INTENSITY_THRESHOLDS.max) {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-orange-100 text-orange-800">High</span>;
  } else if (value >= LIGHT_INTENSITY_THRESHOLDS.min) {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">Optimal</span>;
  } else {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800">Low</span>;
  }
};

// Add helper functions for week calculations before the fetchData function
const getWeeksInMonth = (date: Date): number => {
  const firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
  const lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
  const firstWeekday = firstDay.getDay();
  const lastWeekday = lastDay.getDay();
  const daysInMonth = lastDay.getDate();
  
  // Calculate number of weeks
  let weeks = Math.ceil((daysInMonth + firstWeekday) / 7);
  if (lastWeekday < firstWeekday) weeks++;
  
  return weeks;
};

const getWeekNumberInMonth = (date: Date): number => {
  const firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
  const firstWeekday = firstDay.getDay();
  const dayOfMonth = date.getDate();
  
  // Calculate week number (1-based)
  return Math.ceil((dayOfMonth + firstWeekday) / 7);
};

// Update the main component
const LightIntensityDashboard = () => {
  const [viewType, setViewType] = useState<ViewType>('line');
  const [overview, setOverview] = useState<'hourly' | 'daily' | 'weekly' | 'monthly'>('weekly');
  const [chartData, setChartData] = useState<DataItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [dateRange, setDateRange] = useState<string>('');
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [showExportModal, setShowExportModal] = useState<boolean>(false);
  const chartRef = useRef<HTMLDivElement>(null);
  const [xKey, setXKey] = useState<string>('day');

  // Use intelligent refresh hook
  const {
    isRefreshing,
    lastRefreshTime,
    autoRefreshEnabled,
    toggleAutoRefresh: toggleRefresh
  } = useIntelligentRefresh({
    refreshInterval: 15000,
    enabled: true,
    onRefresh: () => fetchData(overview, selectedDate, true)
  });

  // API Configuration
  const API_CONFIG = {
    baseUrl: import.meta.env.VITE_API_URL || 'https://maize-watch.onrender.com',
    endpoints: {
      historical: '/api/sensors/historical',
      weekly: '/api/sensors/weekly-overview',
      latest: '/api/sensors/latest'
    }
  };

  // Update the fetchData function
  const fetchData = async (period: string, baseDate: Date = new Date(), silent: boolean = false) => {
    if (!silent) {
    setIsLoading(true);
    }
    setError(null);

    try {
      // Convert baseDate to Philippine time
      const phDate = new Date(baseDate.getTime() + (8 * 60 * 60 * 1000));
      let startDate: Date;
      let endDate: Date;
      let endpoint: string;
      let params: Record<string, string> = {};

      switch (period) {
        case 'hourly': {
          // For hourly view, get data for the selected day
          startDate = new Date(phDate);
          startDate.setHours(0, 0, 0, 0);
          endDate = new Date(phDate);
          endDate.setHours(23, 59, 59, 999);
          endpoint = API_CONFIG.endpoints.historical;
          params.startDate = startDate.toISOString();
          params.endDate = endDate.toISOString();
          console.log('Hourly view - Date range:', {
            startDate: startDate.toISOString(),
            endDate: endDate.toISOString(),
            phDate: phDate.toISOString()
          });
          break;
        }
        case 'daily': {
          // For daily view, get data for the week containing the selected date
          startDate = getStartOfWeek(phDate);
          endDate = getEndOfWeek(startDate);
          endpoint = API_CONFIG.endpoints.historical;
          params.startDate = startDate.toISOString();
          params.endDate = endDate.toISOString();
          console.log('Daily view - Week range:', {
            startDate: startDate.toISOString(),
            endDate: endDate.toISOString(),
            phDate: phDate.toISOString()
          });
          break;
        }
        case 'weekly': {
          // For weekly view, get data for the month containing the selected date
          startDate = getStartOfMonth(phDate);
          endDate = getEndOfMonth(phDate);
          endpoint = API_CONFIG.endpoints.historical;
          params.startDate = startDate.toISOString();
          params.endDate = endDate.toISOString();
          break;
        }
        case 'monthly': {
          // For monthly view, get data for the entire year
          startDate = new Date(phDate.getFullYear(), 0, 1); // January 1st
          endDate = new Date(phDate.getFullYear(), 11, 31, 23, 59, 59, 999); // December 31st
          endpoint = API_CONFIG.endpoints.historical;
          params.startDate = startDate.toISOString();
          params.endDate = endDate.toISOString();
          break;
        }
        default:
          throw new Error('Invalid period specified');
      }

      const url = `${API_CONFIG.baseUrl}${endpoint}?${new URLSearchParams(params)}`;
      console.log(`Making API request to ${url} for ${period} view`);
      
      const response = await fetch(url, {
        headers: {
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('API error response:', errorText);
        throw new Error(`HTTP error! status: ${response.status}, message: ${errorText}`);
      }

      const result = await response.json();
      console.log(`API response for ${period} view:`, {
        success: result.success,
        dataLength: result.data?.length,
        firstItem: result.data?.[0],
        lastItem: result.data?.[result.data?.length - 1]
      });
      
      if (!result.success) {
        throw new Error(result.error || 'Failed to fetch data');
      }

      let processedData: DataItem[] = [];
      const rawData = result.data;

      // Handle empty or invalid data
      if (!rawData || !Array.isArray(rawData) || rawData.length === 0) {
        console.warn(`No data available for ${period} view`);
        processedData = getDefaultData(period, phDate).chartData;
      } else {
        // Filter data to only include entries within our date range
        const filteredData = rawData.filter((item: any) => {
          const itemDate = new Date(item.timestamp);
          const isInRange = itemDate >= startDate && itemDate <= endDate;
          if (!isInRange) {
            console.log('Filtered out item:', {
              timestamp: item.timestamp,
              itemDate: itemDate.toISOString(),
              startDate: startDate.toISOString(),
              endDate: endDate.toISOString()
            });
          }
          return isInRange;
        });

        console.log(`Filtered data for ${period} view:`, {
          totalItems: rawData.length,
          filteredItems: filteredData.length,
          firstFilteredItem: filteredData[0],
          lastFilteredItem: filteredData[filteredData.length - 1]
        });

        switch (period) {
          case 'hourly': {
            // Process hourly data for the selected day
            const hourlyData = new Map<string, { sum: number; count: number; dates: string[] }>();
            
            // Initialize all hours for the day
            for (let i = 0; i < 24; i++) {
              const hourKey = `${i.toString().padStart(2, '0')}:00`;
              hourlyData.set(hourKey, { sum: 0, count: 0, dates: [] });
            }
            
            filteredData.forEach((item: any) => {
              if (!item || typeof item !== 'object') return;
              
              const date = new Date(item.timestamp);
              const hourKey = `${date.getHours().toString().padStart(2, '0')}:00`;
              if (hourlyData.has(hourKey)) {
                const current = hourlyData.get(hourKey)!;
                if (typeof item.lightIntensity === 'number' && !isNaN(item.lightIntensity)) {
                  current.sum += item.lightIntensity;
                  current.count++;
                  current.dates.push(date.toISOString());
                }
              }
            });

            console.log('Hourly data processing:', {
              totalHours: hourlyData.size,
              hoursWithData: Array.from(hourlyData.entries())
                .filter(([_, data]) => data.count > 0)
                .map(([hour, data]) => ({
                  hour,
                  count: data.count,
                  average: data.sum / data.count
                }))
            });

            processedData = Array.from(hourlyData.entries()).map(([hour, data]) => ({
              hour,
              value: data.count > 0 ? parseFloat((data.sum / data.count).toFixed(2)) : null,
              dataPoints: data.count,
              threshold: LIGHT_INTENSITY_THRESHOLDS
            }));
            setXKey('hour');
            break;
          }
          case 'daily': {
            // Process daily data for the week
            const dailyData = new Map<string, { sum: number; count: number; dates: string[] }>();
            const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
            
            // Initialize all days
            days.forEach(day => dailyData.set(day, { sum: 0, count: 0, dates: [] }));
            
            filteredData.forEach((item: any) => {
              if (!item || typeof item !== 'object') return;
              
              const date = new Date(item.timestamp);
              const dayKey = days[date.getDay()];
              const current = dailyData.get(dayKey)!;
              if (typeof item.lightIntensity === 'number' && !isNaN(item.lightIntensity)) {
                current.sum += item.lightIntensity;
                current.count++;
                current.dates.push(date.toISOString());
              }
            });

            console.log('Daily data processing:', {
              totalDays: dailyData.size,
              daysWithData: Array.from(dailyData.entries())
                .filter(([_, data]) => data.count > 0)
                .map(([day, data]) => ({
                  day,
                  count: data.count,
                  average: data.sum / data.count
                }))
            });

            processedData = days.map(day => {
              const data = dailyData.get(day)!;
              return {
                day,
                value: data.count > 0 ? parseFloat((data.sum / data.count).toFixed(2)) : null,
                dataPoints: data.count,
                threshold: LIGHT_INTENSITY_THRESHOLDS
              };
            });
            setXKey('day');
            break;
          }
          case 'weekly': {
            // Process weekly data for the month
            const weeksInMonth = getWeeksInMonth(phDate);
            const weeklyData = new Map<string, { sum: number; count: number; dates: string[] }>();
            
            // Initialize all weeks
            for (let i = 1; i <= weeksInMonth; i++) {
              weeklyData.set(`Week ${i}`, { sum: 0, count: 0, dates: [] });
            }
            
            filteredData.forEach((item: any) => {
              if (!item || typeof item !== 'object') return;
              
              const date = new Date(item.timestamp);
              const weekNumber = getWeekNumberInMonth(date);
              const weekKey = `Week ${weekNumber}`;
              
              if (weeklyData.has(weekKey)) {
                const current = weeklyData.get(weekKey)!;
                if (typeof item.lightIntensity === 'number' && !isNaN(item.lightIntensity)) {
                  current.sum += item.lightIntensity;
                  current.count++;
                  current.dates.push(date.toISOString());
                }
              }
            });

            processedData = Array.from(weeklyData.entries()).map(([week, data]) => ({
              week,
              value: data.count > 0 ? parseFloat((data.sum / data.count).toFixed(2)) : null,
              dataPoints: data.count,
              threshold: LIGHT_INTENSITY_THRESHOLDS
            }));
            setXKey('week');
            break;
          }
          case 'monthly': {
            // Process monthly data for the year
            const monthlyData = new Map<string, { sum: number; count: number; dates: string[] }>();
            const monthNames = [
              "January", "February", "March", "April", "May", "June",
              "July", "August", "September", "October", "November", "December"
            ];
            
            // Initialize all months
            monthNames.forEach(month => monthlyData.set(month, { sum: 0, count: 0, dates: [] }));
            
            filteredData.forEach((item: any) => {
              if (!item || typeof item !== 'object') return;
              
              const date = new Date(item.timestamp);
              const monthKey = monthNames[date.getMonth()];
              const current = monthlyData.get(monthKey)!;
              if (typeof item.lightIntensity === 'number' && !isNaN(item.lightIntensity)) {
                current.sum += item.lightIntensity;
                current.count++;
                current.dates.push(date.toISOString());
              }
            });

            processedData = monthNames.map(month => {
              const data = monthlyData.get(month)!;
              return {
                month,
                value: data.count > 0 ? parseFloat((data.sum / data.count).toFixed(2)) : null,
                dataPoints: data.count,
                threshold: LIGHT_INTENSITY_THRESHOLDS
              };
            });
            setXKey('month');
            break;
          }
        }
      }

      console.log(`Final processed data for ${period} view:`, {
        dataLength: processedData.length,
        dataWithValues: processedData.filter(item => item.value !== null).length,
        firstItem: processedData[0],
        lastItem: processedData[processedData.length - 1]
      });

      setChartData(processedData);
      setDateRange(formatDateRange(startDate, endDate));
    } catch (error) {
      console.error(`Error fetching ${period} data:`, error);
      setError("Failed to fetch data. Please try again later.");
      const defaultData = getDefaultData(period, baseDate);
      setChartData(defaultData.chartData);
      setXKey(defaultData.xKey);
      setDateRange(defaultData.dateRange);
    } finally {
      setIsLoading(false);
    }
  };

  // Fetch data when overview or selectedDate changes
  useEffect(() => {
    fetchData(overview, selectedDate);
  }, [overview, selectedDate]);

  // Use intelligent refresh for auto-refresh
  useEffect(() => {
    if (autoRefreshEnabled) {
    const interval = setInterval(() => {
        fetchData(overview, selectedDate, true); // Silent refresh
    }, 15000);

    return () => clearInterval(interval);
    }
  }, [autoRefreshEnabled, overview, selectedDate]);

  const handleOverviewChange = (newOverview: 'hourly' | 'daily' | 'weekly' | 'monthly') => {
    setOverview(newOverview);
    fetchData(newOverview, selectedDate);
  };

  const handlePreviousPeriod = () => {
    let newDate: Date;
    switch (overview) {
      case 'hourly':
        newDate = new Date(selectedDate.getTime() - 24 * 60 * 60 * 1000);
        break;
      case 'daily':
        newDate = new Date(selectedDate.getTime() - 7 * 24 * 60 * 60 * 1000);
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
    setSelectedDate(newDate);
  };

  const handleNextPeriod = () => {
    // Don't allow navigation to future dates
    const now = new Date();
    if (selectedDate >= now) {
      return;
    }

    let newDate: Date;
    switch (overview) {
      case 'hourly':
        newDate = new Date(selectedDate.getTime() + 24 * 60 * 60 * 1000);
        break;
      case 'daily':
        newDate = new Date(selectedDate.getTime() + 7 * 24 * 60 * 60 * 1000);
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

    // Ensure we don't go beyond current date
    if (newDate > now) {
      newDate = now;
    }
    setSelectedDate(newDate);
  };

  const handleExport = () => {
    setShowExportModal(true);
  };

  // Update the renderSummary function to handle null values
  const renderSummary = () => {
    const validData = chartData.filter(item => item.value !== null);
    if (validData.length === 0) {
      return (
        <div className="mt-4 p-4 bg-muted rounded-lg">
          <p className="text-sm text-muted-foreground">No data available for the selected period</p>
        </div>
      );
    }

    const currentValue = validData[validData.length - 1].value as number;
    const averageValue = validData.reduce((sum, item) => sum + (item.value as number), 0) / validData.length;
    const trend = calculateTrend(validData);

    let status = 'Normal';
    let statusColor = 'text-green-600';
    if (currentValue < LIGHT_INTENSITY_THRESHOLDS.min) {
      status = 'Too Low';
      statusColor = 'text-yellow-600';
    } else if (currentValue > LIGHT_INTENSITY_THRESHOLDS.critical) {
      status = 'Critical';
      statusColor = 'text-red-600';
    } else if (currentValue > LIGHT_INTENSITY_THRESHOLDS.max) {
      status = 'Too High';
      statusColor = 'text-orange-600';
    }

      return (
      <div className="mt-4 grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="p-4 bg-card rounded-lg border">
          <h3 className="text-sm font-medium text-muted-foreground">Current Status</h3>
          <p className={`text-2xl font-bold ${statusColor}`}>{status}</p>
          <p className="text-sm text-muted-foreground">Current: {currentValue.toFixed(1)} lux</p>
        </div>
        <div className="p-4 bg-card rounded-lg border">
          <h3 className="text-sm font-medium text-muted-foreground">Average</h3>
          <p className="text-2xl font-bold">{averageValue.toFixed(1)} lux</p>
          <p className="text-sm text-muted-foreground">Based on {validData.length} data points</p>
        </div>
        <div className="p-4 bg-card rounded-lg border">
          <h3 className="text-sm font-medium text-muted-foreground">Trend</h3>
          <div className="flex items-center gap-2">
            <span className={`text-2xl font-bold ${
              trend.trend === 'up' ? 'text-green-600' :
              trend.trend === 'down' ? 'text-red-600' :
              'text-gray-600'
            }`}>
              {trend.trend === 'up' ? '↑' : trend.trend === 'down' ? '↓' : '→'}
            </span>
            <p className="text-2xl font-bold">
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
          <p className="text-sm">Min: {LIGHT_INTENSITY_THRESHOLDS.min} lux</p>
          <p className="text-sm">Max: {LIGHT_INTENSITY_THRESHOLDS.max} lux</p>
          <p className="text-sm text-red-600">Critical: {LIGHT_INTENSITY_THRESHOLDS.critical} lux</p>
        </div>
        </div>
      );
  };

  // Update the renderChart function to ensure value is always a number
  const renderChart = () => {
    if (isLoading) return <Skeleton className="h-[400px] w-full" />;
    if (error) return <Alert variant="destructive"><AlertTitle>Error</AlertTitle><AlertDescription>{error}</AlertDescription></Alert>;
    
    // Always show chart even with empty data
    const displayData = (chartData.length === 0 ? 
      getDefaultData(overview, selectedDate).chartData : 
      chartData.map(item => ({
        ...item,
        value: item.value ?? 0, // Use nullish coalescing to handle null values
        threshold: LIGHT_INTENSITY_THRESHOLDS
      }))).map(item => ({
        ...item,
        value: Number(item.value) // Ensure value is always a number
      }));

    if (viewType === 'tabular') {
      return (
        <div className="overflow-x-auto max-h-[500px]">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50 sticky top-0">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  {xKey === 'hour' ? 'Hour' : xKey === 'day' ? 'Day' : xKey === 'week' ? 'Week' : 'Month'}
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Light Intensity (lux)
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {displayData.map((item, index) => (
                <tr key={index} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {renderTableCell(item)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {item.value?.toFixed(1) ?? '0.0'} lux
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
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
      <ReferenceLine key="min" y={LIGHT_INTENSITY_THRESHOLDS.min} stroke="green" strokeDasharray="3 3" label={{ value: 'Min', position: 'right', fill: 'green' }} />,
      <ReferenceLine key="max" y={LIGHT_INTENSITY_THRESHOLDS.max} stroke="orange" strokeDasharray="3 3" label={{ value: 'Max', position: 'right', fill: 'orange' }} />,
      <ReferenceLine key="critical" y={LIGHT_INTENSITY_THRESHOLDS.critical} stroke="red" strokeDasharray="3 3" label={{ value: 'Critical', position: 'right', fill: 'red' }} />,
    ];

    // Customize X-axis labels based on view type
    const getXAxisLabel = (value: string) => {
      switch (overview) {
        case 'hourly':
          return `${value}:00`; // Add :00 to hour labels
        case 'daily':
          return value; // Already formatted as day names
        case 'weekly':
          return value; // Already formatted as Week 1, Week 2, etc.
        case 'monthly':
          return value; // Already formatted as month names
        default:
          return value;
      }
    };

    if (viewType === 'line') {
    return (
        <div className="h-[500px] p-4 mb-4">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart
              data={displayData}
              margin={{ top: 20, right: 30, left: 20, bottom: 60 }}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                dataKey={xKey}
                height={80}
                tick={{ fontSize: 12 }}
                angle={0}
                textAnchor="middle"
                dy={10}
                padding={{ left: 20, right: 20 }}
                tickFormatter={getXAxisLabel}
              />
              <YAxis
                domain={[0, 15000]}
                tick={{ fontSize: 12 }}
                tickFormatter={(value) => `${value} lux`}
                width={60}
                tickMargin={10}
                axisLine={{ stroke: '#666' }}
                tickLine={{ stroke: '#666' }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend verticalAlign="top" height={36} />
              <Line
                type="monotoneX"
                dataKey="value"
                name="Light Intensity"
                stroke="#F59E0B"
                strokeWidth={2}
                dot={{ fill: '#fff', strokeWidth: 2, r: 4 }}
                activeDot={{ r: 6, fill: '#fff', stroke: '#F59E0B', strokeWidth: 2 }}
                connectNulls={true}
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
        <div className="h-[500px] p-4 mb-4">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart
              data={displayData}
              margin={{ top: 20, right: 30, left: 20, bottom: 60 }}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                dataKey={xKey}
                height={80}
                tick={{ fontSize: 12 }}
                angle={0}
                textAnchor="middle"
                dy={10}
                padding={{ left: 20, right: 20 }}
                tickFormatter={getXAxisLabel}
              />
              <YAxis
                domain={[0, 15000]}
                tick={{ fontSize: 12 }}
                tickFormatter={(value) => `${value} lux`}
                width={60}
                tickMargin={10}
                axisLine={{ stroke: '#666' }}
                tickLine={{ stroke: '#666' }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend verticalAlign="top" height={36} />
              <Bar
                dataKey="value"
                name="Light Intensity"
                fill="#F59E0B"
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

  // Update table cell rendering
  const renderTableCell = (item: DataItem) => {
    const value = item[xKey];
    if (typeof value === 'string' || typeof value === 'number') {
      return value.toString();
    }
    return '';
  };

  return (
    <Card className="w-full">
      <CardHeader>
        <div className="flex flex-col space-y-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-amber-100 rounded-lg">
                <Sun className="h-8 w-8 text-amber-600" />
            </div>
            <div>
                <h1 className="text-2xl font-bold text-gray-900">Light Intensity Dashboard</h1>
                <p className="text-sm text-muted-foreground">{dateRange}</p>
                  </div>
              </div>
            <div className="flex flex-col items-end gap-2">
              <div className="flex items-center space-x-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handlePreviousPeriod}
                >
                  <ChevronLeft className="h-4 w-4 mr-1" />
                  {overview === 'hourly' ? 'Previous Day' :
                   overview === 'daily' ? 'Previous Week' :
                   overview === 'weekly' ? 'Previous Week' :
                   'Previous Month'}
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleNextPeriod}
                >
                  {overview === 'hourly' ? 'Next Day' :
                   overview === 'daily' ? 'Next Week' :
                   overview === 'weekly' ? 'Next Week' :
                   'Next Month'}
                  <ChevronRight className="h-4 w-4 ml-1" />
                </Button>
          </div>
              <Button
                variant="outline"
                size="sm"
                onClick={handleExport}
                className="w-full flex items-center justify-center"
              >
                <Download className="h-4 w-4 mr-1" />
                Export Data
              </Button>
        </div>
      </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center space-x-3">
            <Select
                value={overview}
              onValueChange={(value) => handleOverviewChange(value as 'hourly' | 'daily' | 'weekly' | 'monthly')}
            >
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Select period" />
              </SelectTrigger>
              <SelectContent>
                {periodOptions.map((option) => (
                  <SelectItem key={option.value} value={option.value}>
                    <div className="flex items-center">
                      {option.icon}
                      <span className="ml-2">{option.label}</span>
            </div>
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" className="w-[180px] justify-between">
                  <div className="flex items-center">
                    {viewType === 'line' ? <LineChart className="h-4 w-4 mr-2" /> :
                     viewType === 'bar' ? <BarChart3 className="h-4 w-4 mr-2" /> :
                     <Table className="h-4 w-4 mr-2" />}
                    {viewType.charAt(0).toUpperCase() + viewType.slice(1)} View
        </div>
                  <ChevronDown className="h-4 w-4 ml-2" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent>
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
        
        {/* Refresh indicator */}
        <RefreshIndicator
          isRefreshing={isRefreshing}
          lastRefreshTime={lastRefreshTime}
          autoRefreshEnabled={autoRefreshEnabled}
          onToggleAutoRefresh={toggleRefresh}
        />
        </div>

        <div ref={chartRef} className="h-[450px] p-4 mb-2">
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
        chartType="lightIntensity"
        dateRange={dateRange}
        />
    </Card>
  );
};

export default LightIntensityDashboard;