import { useState, useRef, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, ReferenceLine, Legend } from 'recharts';
import { Card, CardContent, CardHeader } from '../ui/card';
import { Button } from '../ui/button';
import { Calendar, Download, Clock, BarChart3, Table, Droplets, ChevronLeft, ChevronRight, ChevronDown, Menu } from 'lucide-react';
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
import { apiService } from '../../api/config';

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
const formatDateRange = (start: Date, end: Date): string => {
  const options: Intl.DateTimeFormatOptions = {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    timeZone: 'Asia/Manila'
  };
  return `${start.toLocaleDateString('en-PH', options)} - ${end.toLocaleDateString('en-PH', options)}`;
};

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

// Add at the top of HumidityDashboard
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

// Add the getStatusBadge function before the HumidityDashboard component
const getStatusBadge = (value: number) => {
  if (value >= HUMIDITY_THRESHOLDS.critical) {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">Critical</span>;
  } else if (value >= HUMIDITY_THRESHOLDS.max) {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-orange-100 text-orange-800">High</span>;
  } else if (value >= HUMIDITY_THRESHOLDS.min) {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">Optimal</span>;
  } else {
    return <span className="px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">Low</span>;
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

const getDefaultData = (period: string, baseDate?: Date): { chartData: DataItem[]; xKey: string; dateRange: string } => {
  const today = baseDate ? new Date(baseDate) : new Date();
  const defaultThreshold = {
    min: HUMIDITY_THRESHOLDS.min,
    max: HUMIDITY_THRESHOLDS.max,
    critical: HUMIDITY_THRESHOLDS.critical,
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
    let statusIcon = <Droplets className="w-4 h-4" />;
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
      <div className="bg-white border border-gray-200 rounded-lg p-3 shadow-lg max-w-xs">
        <div className="flex items-center gap-2 mb-2">
          <div className={`p-2 rounded-full ${HUMIDITY_COLORS.background}`}>
            <Droplets className={`w-4 h-4 ${HUMIDITY_COLORS.text}`} />
          </div>
          <p className="font-semibold text-gray-800 text-sm">{label}</p>
        </div>
        <p className={`text-[${HUMIDITY_COLORS.primary}] text-sm`}>{`Humidity: ${value}%`}</p>
        <p className={`${statusColor} text-sm flex items-center gap-1`}>
          {statusIcon}
          {`Status: ${status}`}
        </p>
        {data.dataPoints !== undefined && (
          <p className="text-gray-500 text-xs">{`Data Points: ${data.dataPoints}`}</p>
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

// Update the component state
const HumidityDashboard = () => {
  const [chartData, setChartData] = useState<DataItem[]>([]);
  const [overview, setOverview] = useState<'daily' | 'weekly' | 'monthly'>('daily');
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [dateRange, setDateRange] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [viewType, setViewType] = useState<ViewType>('line');
  const [showExportModal, setShowExportModal] = useState<boolean>(false);
  const [xKey, setXKey] = useState<string>('hour');
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState<boolean>(false);
  const chartRef = useRef<HTMLDivElement>(null);

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

  // Using unified apiService for MongoDB-backed historical data

  // Update the fetchData function to use MongoDB-backed apiService
  const fetchData = async (period: string, baseDate: Date = new Date(), silent: boolean = false) => {
    if (!silent) {
      setIsLoading(true);
    }
    setError(null);

    try {
      // Determine limit based on period
      let limit = 7;
      switch (period) {
        case 'weekly':
          limit = 4;
          break;
        case 'monthly':
          limit = 12;
          break;
      }

      const result = await apiService.fetchHistoricalData(period as 'daily' | 'weekly' | 'monthly', limit, baseDate);
      if (!result.success || !result.data) {
        throw new Error(result.message || 'Failed to fetch humidity data');
      }

      const processedData: DataItem[] = result.data.map((item: any) => ({
        ...item,
        value: item.humidity ?? null,
        day: period === 'daily' ? item.label : undefined,
        week: period === 'weekly' ? item.label : undefined,
        month: period === 'monthly' ? item.label : undefined,
        threshold: HUMIDITY_THRESHOLDS,
      }));

      // Determine date range display
      let displayRange = '';
      if (result.data.length > 0) {
        const firstItem = result.data[0];
        const lastItem = result.data[result.data.length - 1];
        switch (period) {
          case 'daily':
            if (firstItem.date && lastItem.date) displayRange = formatDateRange(new Date(firstItem.date), new Date(lastItem.date));
            break;
          case 'weekly':
            if (firstItem.weekStart && lastItem.weekEnd) displayRange = formatDateRange(new Date(firstItem.weekStart), new Date(lastItem.weekEnd));
            break;
          case 'monthly':
            if (firstItem.monthStart && lastItem.monthEnd) displayRange = formatDateRange(new Date(firstItem.monthStart), new Date(lastItem.monthEnd));
            break;
        }
      }
      if (!displayRange) {
        let startDate: Date, endDate: Date;
        switch (period) {
          case 'daily':
            startDate = getStartOfWeek(baseDate);
            endDate = getEndOfWeek(startDate);
            break;
          case 'weekly':
            startDate = getStartOfMonth(baseDate);
            endDate = getEndOfMonth(baseDate);
            break;
          case 'monthly':
            startDate = new Date(baseDate.getFullYear(), 0, 1);
            endDate = new Date(baseDate.getFullYear(), 11, 31);
            break;
          default:
            startDate = baseDate; endDate = baseDate;
        }
        displayRange = formatDateRange(startDate, endDate);
      }

      // xKey by period
      let chartXKey = 'day';
      if (period === 'weekly') chartXKey = 'week';
      if (period === 'monthly') chartXKey = 'month';

      setChartData(processedData);
      setXKey(chartXKey);
      setDateRange(displayRange);
      setError(null);
    } catch (error) {
      console.error(`Error fetching ${period} data:`, error);
      setError("Failed to fetch data. Please try again later.");
      const defaultData = getDefaultData(period, new Date());
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

  const handleOverviewChange = (newOverview: 'daily' | 'weekly' | 'monthly') => {
    setOverview(newOverview);
    fetchData(newOverview, selectedDate);
  };

  const handlePreviousPeriod = () => {
    let newDate: Date;
    switch (overview) {
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

  // Update the renderSummary function to handle null values and be responsive
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
    if (currentValue < HUMIDITY_THRESHOLDS.min) {
      status = 'Too Dry';
      statusColor = 'text-yellow-600';
    } else if (currentValue > HUMIDITY_THRESHOLDS.critical) {
      status = 'Critical';
      statusColor = 'text-red-600';
    } else if (currentValue > HUMIDITY_THRESHOLDS.max) {
      status = 'Too Humid';
      statusColor = 'text-orange-600';
    }

    return (
      <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-3 md:gap-4">
        <div className="p-3 md:p-4 bg-card rounded-lg border">
          <h3 className="text-xs md:text-sm font-medium text-muted-foreground">Current Status</h3>
          <p className={`text-lg md:text-2xl font-bold ${statusColor}`}>{status}</p>
          <p className="text-xs md:text-sm text-muted-foreground">Current: {currentValue.toFixed(1)}%</p>
        </div>
        <div className="p-3 md:p-4 bg-card rounded-lg border">
          <h3 className="text-xs md:text-sm font-medium text-muted-foreground">Average</h3>
          <p className="text-lg md:text-2xl font-bold">{averageValue.toFixed(1)}%</p>
          <p className="text-xs md:text-sm text-muted-foreground">Based on {validData.length} data points</p>
        </div>
        <div className="p-3 md:p-4 bg-card rounded-lg border">
          <h3 className="text-xs md:text-sm font-medium text-muted-foreground">Trend</h3>
          <div className="flex items-center gap-2">
            <span className={`text-lg md:text-2xl font-bold ${trend.trend === 'up' ? 'text-green-600' :
                trend.trend === 'down' ? 'text-red-600' :
                  'text-gray-600'
              }`}>
              {trend.trend === 'up' ? '↑' : trend.trend === 'down' ? '↓' : '→'}
            </span>
            <p className="text-lg md:text-2xl font-bold">
              {trend.percentage > 0 ? `${trend.percentage}%` : 'Stable'}
            </p>
          </div>
          <p className="text-xs md:text-sm text-muted-foreground">
            {trend.trend === 'up' ? 'Increasing' :
              trend.trend === 'down' ? 'Decreasing' :
                'No significant change'}
          </p>
        </div>
        <div className="p-4 bg-card rounded-lg border">
          <h3 className="text-sm font-medium text-muted-foreground">Thresholds</h3>
          <p className="text-sm">Min: {HUMIDITY_THRESHOLDS.min}%</p>
          <p className="text-sm">Max: {HUMIDITY_THRESHOLDS.max}%</p>
          <p className="text-sm text-red-600">Critical: {HUMIDITY_THRESHOLDS.critical}%</p>
        </div>
      </div>
    );
  };

  // Update the renderChart function to ensure value is always a number
  const renderChart = () => {
    if (isLoading) return <Skeleton className="h-[300px] sm:h-[400px] w-full" />;
    if (error) return <Alert variant="destructive"><AlertTitle>Error</AlertTitle><AlertDescription>{error}</AlertDescription></Alert>;

    // Always show chart even with empty data
    const displayData = (chartData.length === 0 ?
      getDefaultData(overview, selectedDate).chartData :
      chartData.map(item => ({
        ...item,
        value: item.value ?? 0, // Use nullish coalescing to handle null values
        threshold: HUMIDITY_THRESHOLDS
      }))).map(item => ({
        ...item,
        value: Number(item.value) // Ensure value is always a number
      }));

    if (viewType === 'tabular') {
      return (
        <div className="overflow-x-auto max-h-[300px] sm:max-h-[500px] border rounded-lg">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50 sticky top-0">
              <tr>
                <th className="px-3 sm:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  {xKey === 'hour' ? 'Hour' : xKey === 'day' ? 'Day' : xKey === 'week' ? 'Week' : 'Month'}
                </th>
                <th className="px-3 sm:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Humidity
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
                    {item.value?.toFixed(1) ?? '0.0'}
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
      <ReferenceLine key="min" y={HUMIDITY_THRESHOLDS.min} stroke="green" strokeDasharray="3 3" label={{ value: 'Min', position: 'right', fill: 'green' }} />,
      <ReferenceLine key="max" y={HUMIDITY_THRESHOLDS.max} stroke="orange" strokeDasharray="3 3" label={{ value: 'Max', position: 'right', fill: 'orange' }} />,
      <ReferenceLine key="critical" y={HUMIDITY_THRESHOLDS.critical} stroke="red" strokeDasharray="3 3" label={{ value: 'Critical', position: 'right', fill: 'red' }} />,
    ];

    // Customize X-axis labels based on view type
    const getXAxisLabel = (value: string) => {
      switch (overview) {
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

    // Responsive chart margins and settings
    const chartMargins = {
      top: 20,
      right: window.innerWidth < 640 ? 15 : 30,
      left: window.innerWidth < 640 ? 15 : 20,
      bottom: window.innerWidth < 640 ? 40 : 60
    };

    if (viewType === 'line') {
      return (
        <div className="h-[300px] sm:h-[400px] lg:h-[500px] p-2 sm:p-4 mb-4">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart
              data={displayData}
              margin={chartMargins}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                dataKey={xKey}
                height={window.innerWidth < 640 ? 50 : 80}
                tick={{ fontSize: window.innerWidth < 640 ? 10 : 12 }}
                angle={window.innerWidth < 640 ? -45 : 0}
                textAnchor={window.innerWidth < 640 ? "end" : "middle"}
                dy={window.innerWidth < 640 ? 5 : 10}
                padding={{ left: 20, right: 20 }}
                tickFormatter={getXAxisLabel}
                interval={window.innerWidth < 640 ? 1 : 0}
              />
              <YAxis
                domain={[0, 14]}
                tick={{ fontSize: window.innerWidth < 640 ? 10 : 12 }}
                tickFormatter={(value) => `${value}`}
                width={window.innerWidth < 640 ? 40 : 60}
                tickMargin={5}
                axisLine={{ stroke: '#666' }}
                tickLine={{ stroke: '#666' }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend
                verticalAlign="top"
                height={window.innerWidth < 640 ? 24 : 36}
                wrapperStyle={{ fontSize: window.innerWidth < 640 ? '12px' : '14px' }}
              />
              <Line
                type="monotoneX"
                dataKey="value"
                name="Humidity"
                stroke="#0EA5E9"
                strokeWidth={window.innerWidth < 640 ? 1.5 : 2}
                dot={{ fill: '#fff', strokeWidth: window.innerWidth < 640 ? 1.5 : 2, r: window.innerWidth < 640 ? 3 : 4 }}
                activeDot={{ r: window.innerWidth < 640 ? 5 : 6, fill: '#fff', stroke: '#0EA5E9', strokeWidth: 2 }}
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
        <div className="h-[300px] sm:h-[400px] lg:h-[500px] p-2 sm:p-4 mb-4">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart
              data={displayData}
              margin={chartMargins}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                dataKey={xKey}
                height={window.innerWidth < 640 ? 50 : 80}
                tick={{ fontSize: window.innerWidth < 640 ? 10 : 12 }}
                angle={window.innerWidth < 640 ? -45 : 0}
                textAnchor={window.innerWidth < 640 ? "end" : "middle"}
                dy={window.innerWidth < 640 ? 5 : 10}
                padding={{ left: 20, right: 20 }}
                tickFormatter={getXAxisLabel}
                interval={window.innerWidth < 640 ? 1 : 0}
              />
              <YAxis
                domain={[0, 14]}
                tick={{ fontSize: window.innerWidth < 640 ? 10 : 12 }}
                tickFormatter={(value) => `${value}`}
                width={window.innerWidth < 640 ? 40 : 60}
                tickMargin={5}
                axisLine={{ stroke: '#666' }}
                tickLine={{ stroke: '#666' }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend
                verticalAlign="top"
                height={window.innerWidth < 640 ? 24 : 36}
                wrapperStyle={{ fontSize: window.innerWidth < 640 ? '12px' : '14px' }}
              />
              <Bar
                dataKey="value"
                name="Humidity"
                fill="#0EA5E9"
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
    <Card className="w-full mx-auto max-w-7xl">
      <CardHeader className="px-4 sm:px-6">
        <div className="flex flex-col space-y-4">
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-sky-100 rounded-lg flex-shrink-0">
                <Droplets className="h-6 w-6 sm:h-8 sm:w-8 text-sky-600" />
              </div>
              <div className="min-w-0">
                <h1 className="text-xl sm:text-2xl font-bold text-gray-900 truncate">Humidity Dashboard</h1>
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

          {/* Refresh indicator */}
          <div className="flex justify-end">
            <RefreshIndicator
              isRefreshing={isRefreshing}
              lastRefreshTime={lastRefreshTime}
              autoRefreshEnabled={autoRefreshEnabled}
              onToggleAutoRefresh={toggleRefresh}
            />
          </div>
        </div>

        <div ref={chartRef} className="mb-2">
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
        chartType="humidity"
        dateRange={dateRange}
      />
    </Card>
  );
};

export default HumidityDashboard;