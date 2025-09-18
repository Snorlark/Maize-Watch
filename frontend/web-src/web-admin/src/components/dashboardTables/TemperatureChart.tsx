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

// Import the updated configuration
import { apiService } from "../../api/config";
import { dataTransformUtils } from "../../api/utils/dataTransformUtils";
import { CHART_CONFIG } from "../../api/utils/chartConfig";
import { dateUtils } from "../../api/utils/dateUtils";


// Updated types to match your backend structure and UnifiedExportModal
interface ChartDataItem {
  label: string;
  timestamp: string;
  temperature: number | null;
  humidity: number | null;
  soilMoisture: number | null;
  soilPh: number | null;
  lightIntensity: number | null;
  dataPoints: number;
  // Chart-specific properties
  value: number | null;
  day?: string;
  week?: string;
  month?: string;
  // Add index signature to make it compatible with ChartDataPoint
  [key: string]: any;
}

interface ApiResponse {
  success: boolean;
  data: ChartDataItem[];
  rawData?: any[];
  error?: string;
  message?: string;
}

// Use temperature configuration from the updated config
const TEMPERATURE_CONFIG = CHART_CONFIG.temperature;
const TEMPERATURE_THRESHOLDS = TEMPERATURE_CONFIG.thresholds;
const TEMPERATURE_COLORS = TEMPERATURE_CONFIG.colors;

// Custom Tooltip
const CustomTooltip = ({ active, payload, label }: any) => {
  if (active && payload && payload.length) {
    const data = payload[0].payload;
    const value = payload[0].value;
    
    let status = "Normal";
    let statusColor = "text-green-600";
    
    if (value === null || value === 0) {
      status = "No Data";
      statusColor = "text-gray-600";
    } else if (value < TEMPERATURE_THRESHOLDS.min) {
      status = "Too Cold";
      statusColor = "text-blue-600";
    } else if (value > TEMPERATURE_THRESHOLDS.critical) {
      status = "Critical";
      statusColor = "text-red-600";
    } else if (value > TEMPERATURE_THRESHOLDS.max) {
      status = "Too Hot";
      statusColor = "text-orange-600";
    }
    
    return (
      <div className="bg-white border border-gray-200 rounded-lg p-3 shadow-lg">
        <div className="flex items-center gap-2 mb-2">
          <div className={`p-2 rounded-full ${TEMPERATURE_COLORS.background}`}>
            <Thermometer className={`w-4 h-4 ${TEMPERATURE_COLORS.text}`} />
          </div>
          <p className="font-semibold text-gray-800">{label}</p>
        </div>
        <p className="text-orange-500">{`Temperature: ${value ? value.toFixed(1) : '0.0'}°C`}</p>
        <p className={`${statusColor} text-sm flex items-center gap-1`}>
          <Thermometer className="w-3 h-3" />
          {`Status: ${status}`}
        </p>
        {data.dataPoints !== undefined && (
          <p className="text-gray-500 text-sm">{`Data Points: ${data.dataPoints}`}</p>
        )}
        <div className="mt-2 text-xs text-gray-500">
          <p>Thresholds:</p>
          <p className="text-green-600">Min: {TEMPERATURE_THRESHOLDS.min}°C</p>
          <p className="text-orange-600">Max: {TEMPERATURE_THRESHOLDS.max}°C</p>
          <p className="text-red-600">Critical: {TEMPERATURE_THRESHOLDS.critical}°C</p>
        </div>
      </div>
    );
  }
  return null;
};

const calculateTrend = (data: ChartDataItem[]): { trend: 'up' | 'down' | 'neutral'; percentage: number } => {
  const validData = data.filter((item: ChartDataItem) => item.value !== null && item.value !== 0);
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

type ViewType = 'line' | 'bar' | 'tabular';

const periodOptions = [
  { label: 'Daily', value: 'daily', icon: <Calendar className="h-4 w-4 mr-1" /> },
  { label: 'Weekly', value: 'weekly', icon: <Calendar className="h-4 w-4 mr-1" /> },
  { label: 'Monthly', value: 'monthly', icon: <Calendar className="h-4 w-4 mr-1" /> },
];

const viewTypeOptions = [
  { label: 'Line Chart', value: 'line', icon: <LineChart className="h-4 w-4 mr-1" /> },
  { label: 'Bar Chart', value: 'bar', icon: <BarChart3 className="h-4 w-4 mr-1" /> },
  { label: 'Table View', value: 'tabular', icon: <Table className="h-4 w-4 mr-1" /> },
];

// Main Component
const TemperatureDashboard = () => {
  const [chartData, setChartData] = useState<ChartDataItem[]>([]);
  const [overview, setOverview] = useState<'daily' | 'weekly' | 'monthly'>('daily');
  const [selectedDate, setSelectedDate] = useState<Date>(new Date());
  const [dateRange, setDateRange] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);
  const [viewType, setViewType] = useState<ViewType>('line');
  const [showExportModal, setShowExportModal] = useState<boolean>(false);
  const [xKey, setXKey] = useState<string>('label');
  const chartRef = useRef<HTMLDivElement>(null);

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

  // Updated fetchData function to properly use your MongoDB API
  const fetchData = async (
  period: 'daily' | 'weekly' | 'monthly',
  baseDate: Date = new Date(),
  silent: boolean = false
) => {
  if (!silent) {
    setIsLoading(true);
  }
  setError(null);

  try {
    console.log(`[TemperatureDashboard] Fetching ${period} data`);

    // Determine the appropriate limit based on period
    let limit = 7; // Default for daily (7 days)
    switch (period) {
      case 'weekly':
        limit = 4; // 4 weeks in a month
        break;
      case 'monthly':
        limit = 12; // 12 months in a year
        break;
    }

      // Use your apiService to fetch historical data, passing baseDate to align ranges
      const result = await apiService.fetchHistoricalData(period, limit, baseDate);

    if (!result.success || !result.data) {
      throw new Error(result.message || 'Failed to fetch temperature data');
    }

    // ✅ Now safe to log + properly type 'item'
    console.log(`[TemperatureDashboard] Received data:`, {
      period,
      dataLength: result.data.length,
      hasTemperatureData: result.data.some((item: ChartDataItem) => item.temperature !== null)
    });

    // ✅ Map with explicit type
    const processedData: ChartDataItem[] = result.data.map((item: ChartDataItem) => ({
      ...item,
      value: item.temperature,
      day: period === 'daily' ? item.label : undefined,
      week: period === 'weekly' ? item.label : undefined,
      month: period === 'monthly' ? item.label : undefined,
    }));


      // Calculate date range for display
      let displayRange = '';
      if (result.data.length > 0) {
        const firstItem = result.rawData?.[0];
        const lastItem = result.rawData?.[result.rawData.length - 1];
        
        if (firstItem && lastItem) {
          switch (period) {
            case 'daily':
              if (firstItem.date && lastItem.date) {
                displayRange = `${new Date(firstItem.date).toLocaleDateString()} - ${new Date(lastItem.date).toLocaleDateString()}`;
              }
              break;
            case 'weekly':
              if (firstItem.weekStart && lastItem.weekEnd) {
                displayRange = `${new Date(firstItem.weekStart).toLocaleDateString()} - ${new Date(lastItem.weekEnd).toLocaleDateString()}`;
              }
              break;
            case 'monthly':
              if (firstItem.monthStart && lastItem.monthEnd) {
                displayRange = `${new Date(firstItem.monthStart).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })} - ${new Date(lastItem.monthEnd).toLocaleDateString('en-US', { month: 'long', year: 'numeric' })}`;
              }
              break;
          }
        }
      }

      // Fallback to calculated range if not available from data
      if (!displayRange) {
        let startDate: Date, endDate: Date;
        switch (period) {
          case 'daily':
            startDate = dateUtils.getStartOfWeek(baseDate);
            endDate = dateUtils.getEndOfWeek(startDate);
            break;
          case 'weekly':
            startDate = dateUtils.getStartOfMonth(baseDate);
            endDate = dateUtils.getEndOfMonth(baseDate);
            break;
          case 'monthly':
            startDate = new Date(baseDate.getFullYear(), 0, 1);
            endDate = new Date(baseDate.getFullYear(), 11, 31);
            break;
          default:
            startDate = baseDate;
            endDate = baseDate;
        }
        displayRange = dateUtils.formatDateRange(startDate, endDate);
      }

      // Set the appropriate xKey for chart rendering
      let chartXKey = 'label';
      switch (period) {
        case 'daily':
          chartXKey = 'day';
          break;
        case 'weekly':
          chartXKey = 'week';
          break;
        case 'monthly':
          chartXKey = 'month';
          break;
      }

      setChartData(processedData);
      setXKey(chartXKey);
      setDateRange(displayRange);
      setError(null);

      console.log(`[TemperatureDashboard] Data processed successfully:`, {
        chartDataLength: processedData.length,
        xKey: chartXKey,
        dateRange: displayRange,
        temperatureValues: processedData.map(item => item.temperature)
      });

    } catch (error) {
      console.error(`[TemperatureDashboard] Error fetching ${period} data:`, error);
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      setError(`Failed to fetch temperature data: ${errorMessage}`);
      
      // Set empty data on error
      setChartData([]);
      setXKey('label');
      setDateRange('No data available');
    } finally {
      setIsLoading(false);
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
        newDate = new Date(selectedDate.getTime() - 7 * 24 * 60 * 60 * 1000); // Previous week
        break;
      case 'weekly':
        newDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth() - 1, 1); // Previous month
        break;
      case 'monthly':
        newDate = new Date(selectedDate.getFullYear() - 1, selectedDate.getMonth(), 1); // Previous year
        break;
      default:
        newDate = new Date(selectedDate.getTime() - 24 * 60 * 60 * 1000);
    }
    setSelectedDate(newDate);
  };

  const handleNextPeriod = () => {
    const now = new Date();
    
    let newDate: Date;
    switch (overview) {
      case 'daily':
        newDate = new Date(selectedDate.getTime() + 7 * 24 * 60 * 60 * 1000); // Next week
        break;
      case 'weekly':
        newDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, 1); // Next month
        break;
      case 'monthly':
        newDate = new Date(selectedDate.getFullYear() + 1, selectedDate.getMonth(), 1); // Next year
        break;
      default:
        newDate = new Date(selectedDate.getTime() + 24 * 60 * 60 * 1000);
    }

    // Don't navigate to future dates beyond current time
    if (newDate > now) {
      newDate = now;
    }
    setSelectedDate(newDate);
  };

  const handleExport = () => {
    setShowExportModal(true);
  };

  const renderSummary = () => {
    // const validData = chartData.filter((item: ChartDataItem) => item.temperature !== null && item.temperature !== 0);
    const validData = chartData.filter(
  (item: ChartDataItem) =>
    item.temperature !== null &&
    item.temperature !== undefined &&
    item.temperature !== 0
);
    
    if (validData.length === 0) {
      return (
        <div className="mt-4 p-4 bg-gray-50 rounded-lg">
          <p className="text-sm text-gray-600">No temperature data available for the selected period</p>
          <p className="text-xs text-gray-500 mt-2">
            Try selecting a different time period or check if sensors are collecting data.
          </p>
        </div>
      );
    }

    const currentValue = validData[validData.length - 1].temperature as number;
    const averageValue = validData.reduce(
  (sum, item: ChartDataItem) => sum + (item.temperature as number),
  0
) / validData.length;
    const maxValue = Math.max(...validData.map(item => item.temperature as number));
    const minValue = Math.min(...validData.map(item => item.temperature as number));
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
        <div className="p-4 bg-white rounded-lg border">
          <h3 className="text-sm font-medium text-gray-500">Current Status</h3>
          <p className={`text-xl lg:text-2xl font-bold ${statusColor}`}>{status}</p>
          <p className="text-sm text-gray-500">Current: {currentValue.toFixed(1)}°C</p>
        </div>
        <div className="p-4 bg-white rounded-lg border">
          <h3 className="text-sm font-medium text-gray-500">Statistics</h3>
          <p className="text-lg font-semibold">Avg: {averageValue.toFixed(1)}°C</p>
          <p className="text-sm text-gray-500">Min: {minValue.toFixed(1)}°C | Max: {maxValue.toFixed(1)}°C</p>
        </div>
        <div className="p-4 bg-white rounded-lg border">
          <h3 className="text-sm font-medium text-gray-500">Trend</h3>
          <div className="flex items-center gap-2">
            <span className={`text-xl font-bold ${
              trend.trend === 'up' ? 'text-green-600' :
              trend.trend === 'down' ? 'text-red-600' :
              'text-gray-600'
            }`}>
              {trend.trend === 'up' ? '↑' : trend.trend === 'down' ? '↓' : '→'}
            </span>
            <p className="text-lg font-semibold">
              {trend.percentage > 0 ? `${trend.percentage}%` : 'Stable'}
            </p>
          </div>
          <p className="text-sm text-gray-500">
            {trend.trend === 'up' ? 'Increasing' :
              trend.trend === 'down' ? 'Decreasing' :
                'No significant change'}
          </p>
        </div>
        <div className="p-4 bg-white rounded-lg border">
          <h3 className="text-sm font-medium text-gray-500">Data Quality</h3>
          <p className="text-lg font-semibold">{validData.length} readings</p>
          <p className="text-sm text-gray-500">
            {Math.round((validData.length / chartData.length) * 100)}% coverage
          </p>
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

    if (chartData.length === 0) {
      return (
        <div className="h-[300px] sm:h-[400px] flex items-center justify-center">
          <div className="text-center">
            <Thermometer className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-lg font-medium text-gray-600">No data available</p>
            <p className="text-sm text-gray-500">Try selecting a different time period</p>
          </div>
        </div>
      );
    }

    const displayData = chartData.map((item: ChartDataItem) => ({
  ...item,
  [xKey]: item[xKey as keyof ChartDataItem] || item.label,
}));


    if (viewType === 'tabular') {
      return (
        <div className="overflow-x-auto max-h-[400px] overflow-y-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50 sticky top-0">
              <tr>
                <th className="px-3 sm:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  {overview.charAt(0).toUpperCase() + overview.slice(1)}
                </th>
                <th className="px-3 sm:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Temperature (°C)
                </th>
                <th className="px-3 sm:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-3 sm:px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Data Points
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {displayData.map((item: ChartDataItem, index: number) => (
                <tr key={index} className="hover:bg-gray-50">
                  <td className="px-3 sm:px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {item.label}
                  </td>
                  <td className="px-3 sm:px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {item.temperature ? item.temperature.toFixed(1) : 'N/A'}°C
                  </td>
                  <td className="px-3 sm:px-6 py-4 whitespace-nowrap text-sm">
                    {getStatusBadge(item.temperature)}
                  </td>
                  <td className="px-3 sm:px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {item.dataPoints}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      );
    }

    const thresholdLines = [
      <ReferenceLine key="min" y={TEMPERATURE_THRESHOLDS.min} stroke="#22C55E" strokeDasharray="3 3" label={{ value: `Min ${TEMPERATURE_THRESHOLDS.min}°C`, position: 'right', fill: '#22C55E' }} />,
      <ReferenceLine key="max" y={TEMPERATURE_THRESHOLDS.max} stroke="#F59E0B" strokeDasharray="3 3" label={{ value: `Max ${TEMPERATURE_THRESHOLDS.max}°C`, position: 'right', fill: '#F59E0B' }} />,
      <ReferenceLine key="critical" y={TEMPERATURE_THRESHOLDS.critical} stroke="#EF4444" strokeDasharray="3 3" label={{ value: `Critical ${TEMPERATURE_THRESHOLDS.critical}°C`, position: 'right', fill: '#EF4444' }} />,
    ];

    const commonProps = {
      data: displayData,
      margin: { top: 20, right: 30, left: 20, bottom: 60 }
    };

    const commonAxisProps = {
      xAxis: {
        dataKey: xKey,
        height: 80,
        tick: { fontSize: 12 },
        angle: -45,
        textAnchor: 'end' as const,
        interval: 0
      },
      yAxis: {
        domain: [0, 50] as const,
        tick: { fontSize: 12 },
        tickFormatter: (value: number) => `${value}°C`,
        width: 60
      }
    };

    if (viewType === 'line') {
      return (
        <div className="h-[300px] sm:h-[400px] lg:h-[450px] w-full">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart {...commonProps}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis {...commonAxisProps.xAxis} />
              <YAxis 
                domain={[0, 50]}
                tick={{ fontSize: 12 }}
                tickFormatter={(value: number) => `${value}°C`}
                width={60}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend />
              <Line
                type="monotoneX"
                dataKey="value"
                name="Temperature (°C)"
                stroke={TEMPERATURE_COLORS.primary}
                strokeWidth={3}
                dot={{ fill: TEMPERATURE_COLORS.primary, strokeWidth: 2, r: 5 }}
                activeDot={{ r: 7, fill: TEMPERATURE_COLORS.primary, stroke: '#fff', strokeWidth: 2 }}
                connectNulls={false}
              />
              {thresholdLines}
            </LineChart>
          </ResponsiveContainer>
        </div>
      );
    }

    if (viewType === 'bar') {
      return (
        <div className="h-[300px] sm:h-[400px] lg:h-[450px] w-full">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart {...commonProps}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis {...commonAxisProps.xAxis} />
              <YAxis 
                domain={[0, 50]}
                tick={{ fontSize: 12 }}
                tickFormatter={(value: number) => `${value}°C`}
                width={60}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend />
              <Bar
                dataKey="value"
                name="Temperature (°C)"
                fill={TEMPERATURE_COLORS.primary}
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
                  <p className="text-sm text-gray-500 truncate">{dateRange}</p>
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
                    Previous
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={handleNextPeriod}
                    className="flex-1 sm:flex-none text-xs sm:text-sm px-2 sm:px-3"
                  >
                    Next
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
                  Export
                </Button>
              </div>
            </div>
          </div>
        </CardHeader>
        
        <CardContent className="px-4 sm:px-6">
          <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between mb-4 gap-3">
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
                        {viewTypeOptions.find(option => option.value === viewType)?.icon || <LineChart className="h-4 w-4 mr-2" />}
                        <span className="hidden sm:inline">
                          {viewTypeOptions.find(option => option.value === viewType)?.label || "Select view"}
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

          <div ref={chartRef} className="mb-4">
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