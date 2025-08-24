import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Users, 
  Activity, 
  Thermometer, 
  BarChart3, 
  Eye, 
  TrendingUp,
  Clock,
  User,
  MapPin,
  Smartphone,
  ChevronRight,
  RefreshCw,
  AlertCircle,
  CheckCircle
} from 'lucide-react';
import apiClient from '../api/client';
import authService from '../api/services/authService';

// Activity logs API service
const activityLogAPI = {
  getLogs: async (filters: Record<string, any> = {}, page = 1, limit = 50) => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      const params: Record<string, string> = {
        page: page.toString(),
        limit: limit.toString()
      };

      // Add filters to params
      Object.entries(filters).forEach(([key, value]) => {
        if (value !== '' && value !== false && value !== null && value !== undefined) {
          params[key] = value.toString();
        }
      });

      const response = await apiClient.get('/api/activity-logs', { params });
      return {
        success: true,
        data: response.data,
        status: response.status
      };
    } catch (error: any) {
      console.error('Error getting activity logs:', error);
      return {
        success: false,
        error: error.response?.data?.message || error.message,
        status: error.response?.status || 0
      };
    }
  },

  getSummary: async (dateRange: { startDate?: string; endDate?: string } = {}) => {
    try {
      if (!authService.isAuthenticated()) {
        throw new Error('Authentication required');
      }
      
      const params: Record<string, string> = {};
      if (dateRange.startDate) params.startDate = dateRange.startDate;
      if (dateRange.endDate) params.endDate = dateRange.endDate;

      const response = await apiClient.get('/api/activity-logs', { params });
      return {
        success: true,
        data: response.data,
        status: response.status
      };
    } catch (error: any) {
      console.error('Error getting activity summary:', error);
      return {
        success: false,
        error: error.response?.data?.message || error.message,
        status: error.response?.status || 0
      };
    }
  }
};

// Activity Log interface
interface ActivityLog {
  _id: string;
  userId: {
    _id: string;
    name: string;
    email: string;
  };
  userEmail: string;
  userRole: string;
  action: string;
  resource: string;
  resourceId?: string;
  details: any;
  ipAddress: string;
  userAgent: string;
  timestamp: string;
}

// Mock data for other dashboard elements (keeping non-activity data)
const mockData = {
  admin: {
    name: "John Smith"
  },
  stats: {
    totalUsers: 1247,
    activeUsers: 89,
    totalDevices: 156,
    activeDevices: 142
  },
  currentTemperature: {
    value: 28.5,
    status: "Normal",
    timestamp: new Date().toISOString()
  },
  temperatureChart: [
    { time: '00:00', temp: 25.2 },
    { time: '04:00', temp: 23.8 },
    { time: '08:00', temp: 26.4 },
    { time: '12:00', temp: 29.1 },
    { time: '16:00', temp: 31.2 },
    { time: '20:00', temp: 28.5 }
  ]
};

const AdminDashboard = () => {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState(mockData);
  const [recentActivity, setRecentActivity] = useState<ActivityLog[]>([]);
  const [activityLoading, setActivityLoading] = useState(true);
  const [activityError, setActivityError] = useState<string | null>(null);
  const [currentTime, setCurrentTime] = useState(new Date());
  const [lastActivityCheck, setLastActivityCheck] = useState<string | null>(null);
  const [hasNewActivity, setHasNewActivity] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    // Load dashboard data
    const loadDashboard = async () => {
      setLoading(true);
      
      // Simulate loading other dashboard data
      setTimeout(() => {
        setLoading(false);
      }, 1000);
      
      // Load recent activity logs
      await fetchRecentActivity(true);
    };

    loadDashboard();
  }, []);

  useEffect(() => {
    // Update current time every second
    const interval = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  // Smart polling - check for new activity every 15 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      checkForNewActivity();
    }, 15000); // 15 seconds - more frequent checks but lighter requests

    return () => clearInterval(interval);
  }, [lastActivityCheck]);

  // Check if there's new activity without fetching full data
  const checkForNewActivity = async () => {
    if (!lastActivityCheck) return;

    try {
      // Only fetch the most recent log to check if there's new activity
      const result = await activityLogAPI.getLogs({}, 1, 1);
      
      if (result.success && result.data.logs && result.data.logs.length > 0) {
        const mostRecentLog = result.data.logs[0];
        const mostRecentTimestamp = mostRecentLog.timestamp;
        
        // Compare with our last known timestamp
        if (mostRecentTimestamp !== lastActivityCheck) {
          setHasNewActivity(true);
          // Auto-fetch new data after detecting changes
          await fetchRecentActivity(false);
        }
      }
    } catch (error) {
      // Silently handle check errors - don't disrupt user experience
      console.log('Activity check failed:', error);
    }
  };

  const fetchRecentActivity = async (initialLoad: boolean = false) => {
    if (!initialLoad) {
      setActivityLoading(true);
    }
    setActivityError(null);
    setHasNewActivity(false);

    try {
      // Fetch only the 5 most recent logs for dashboard
      const result = await activityLogAPI.getLogs({}, 1, 5);
      
      if (result.success && result.data.logs) {
        const logs = result.data.logs;
        setRecentActivity(logs);
        
        // Store the timestamp of the most recent activity for comparison
        if (logs.length > 0) {
          setLastActivityCheck(logs[0].timestamp);
        }
      } else {
        setActivityError(result.error || 'Failed to fetch activity logs');
        setRecentActivity([]);
      }
    } catch (error: any) {
      console.error('Error fetching recent activity:', error);
      setActivityError(error.message || 'Failed to fetch activity logs');
      setRecentActivity([]);
    } finally {
      setActivityLoading(false);
    }
  };

  // Manual refresh function
  const handleManualRefresh = () => {
    fetchRecentActivity(false);
  };

  // Enhanced functions from ActivityLogPage
  const getActionColor = (action: string): string => {
    const colors: { [key: string]: string } = {
      login: 'bg-green-100 text-green-800',
      logout: 'bg-gray-100 text-gray-600',
      create: 'bg-blue-100 text-blue-800',
      update: 'bg-yellow-100 text-yellow-800',
      delete: 'bg-red-100 text-red-800',
      view: 'bg-purple-100 text-purple-800'
    };
    
    for (const [key, color] of Object.entries(colors)) {
      if (action.toLowerCase().includes(key)) return color;
    }
    return 'bg-gray-100 text-gray-600';
  };

  const getRoleColor = (role: string): string => {
    const colors: { [key: string]: string } = {
      super_admin: 'bg-red-100 text-red-800',
      admin: 'bg-orange-100 text-orange-800',
      user: 'bg-blue-100 text-blue-800'
    };
    return colors[role] || 'bg-gray-100 text-gray-600';
  };

  const formatDate = (dateString: string): string => {
    return new Date(dateString).toLocaleString();
  };

  const getBrowserFromUserAgent = (userAgent: string): string => {
    if (userAgent.includes('Chrome')) return 'Chrome';
    if (userAgent.includes('Firefox')) return 'Firefox';
    if (userAgent.includes('Safari')) return 'Safari';
    if (userAgent.includes('Edge')) return 'Edge';
    return 'Unknown';
  };

  const getOSFromUserAgent = (userAgent: string): string => {
    if (userAgent.includes('Windows')) return 'Windows';
    if (userAgent.includes('Mac')) return 'macOS';
    if (userAgent.includes('Linux')) return 'Linux';
    if (userAgent.includes('Android')) return 'Android';
    if (userAgent.includes('iOS')) return 'iOS';
    return 'Unknown';
  };

  const getTemperatureStatus = (temp: number): { status: string; color: string } => {
    if (temp < 20) return { status: 'Too Cold', color: 'text-blue-600' };
    if (temp > 35) return { status: 'Critical', color: 'text-red-600' };
    if (temp > 30) return { status: 'Too Hot', color: 'text-orange-600' };
    return { status: 'Normal', color: 'text-green-600' };
  };

  const tempStatus = getTemperatureStatus(data.currentTemperature.value);

  if (loading) {
    return (
      <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#356B2C]"></div>
            <span className="ml-3" style={{ fontSize: 'var(--text-lg)' }}>Loading dashboard...</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div 
      className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-4 sm:px-6 lg:px-8 pt-6 pb-8" 
      style={{ 
        '--text-xs': '12px', 
        '--text-sm': '14px', 
        '--text-base': '16px', 
        '--text-lg': '18px', 
        '--text-xl': '20px' 
      } as React.CSSProperties}
    >
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="font-bold text-[#1E441E] mb-2" style={{ fontSize: 'var(--text-xl)' }}>
            Welcome Admin, {data.admin.name}
          </h1>
          <p className="text-[#456C2D]" style={{ fontSize: 'var(--text-base)' }}>
            System overview and monitoring dashboard - {currentTime.toLocaleString()}
          </p>
          <div className="mt-3 flex items-center gap-3">
            <span 
              className="inline-flex items-center px-3 py-1 rounded-full font-medium bg-[#456C2D] text-[#F5F5DC]" 
              style={{ fontSize: 'var(--text-sm)' }}
            >
              Admin Dashboard
            </span>
            <div className="flex items-center gap-2 text-[#4A7C59]" style={{ fontSize: 'var(--text-sm)' }}>
              <RefreshCw className="w-4 h-4" />
              <span>Real-time monitoring</span>
            </div>
          </div>
        </div>

        {/* Stats Overview */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {[
            { label: "Total Users", value: data.stats.totalUsers.toLocaleString(), icon: <Users className="w-6 h-6 text-blue-600" />, bg: "bg-blue-50" },
            { label: "Active Users", value: data.stats.activeUsers, icon: <Activity className="w-6 h-6 text-green-600" />, bg: "bg-green-50", live: true },
            { label: "Total Devices", value: data.stats.totalDevices, icon: <Thermometer className="w-6 h-6 text-purple-600" />, bg: "bg-purple-50" },
            { label: "Active Devices", value: data.stats.activeDevices, icon: <AlertCircle className="w-6 h-6 text-orange-600" />, bg: "bg-orange-50", activePercent: Math.round((data.stats.activeDevices / data.stats.totalDevices) * 100) }
          ].map((stat, i) => (
            <div key={i} className="bg-white rounded-xl shadow-lg p-6">
              <div className="flex items-center justify-between mb-4">
                <div className={`p-3 ${stat.bg} rounded-lg`}>
                  {stat.icon}
                </div>
                {stat.live && (
                  <div className="flex items-center gap-1">
                    <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                    <span style={{ fontSize: 'var(--text-xs)' }} className="text-green-600">Live</span>
                  </div>
                )}
                {stat.activePercent && (
                  <span style={{ fontSize: 'var(--text-xs)' }} className="px-2 py-1 bg-green-100 text-green-800 rounded-full">
                    {stat.activePercent}% Active
                  </span>
                )}
              </div>
              <div className="font-bold text-[#356B2C] mb-1" style={{ fontSize: 'var(--text-lg)' }}>{stat.value}</div>
              <p style={{ fontSize: 'var(--text-sm)' }} className="text-[#4A7C59]">{stat.label}</p>
            </div>
          ))}
        </div>

        {/* Temperature Widgets */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Current Temperature */}
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-orange-50 rounded-lg">
                  <Thermometer className="w-6 h-6 text-orange-600" />
                </div>
                <h2 style={{ fontSize: 'var(--text-xl)' }} className="font-semibold text-[#1E441E]">Current Temperature</h2>
              </div>
              <button 
                onClick={() => navigate('/livedata')}
                className="flex items-center gap-2 px-4 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors font-medium"
                style={{ fontSize: 'var(--text-sm)' }}
              >
                <Eye className="w-4 h-4" />
                View Live Data
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
            <div className="text-center">
              <div className="font-bold text-[#356B2C] mb-2" style={{ fontSize: '48px' }}>
                {data.currentTemperature.value}°C
              </div>
              <p className={`font-medium ${tempStatus.color} mb-4`} style={{ fontSize: 'var(--text-lg)' }}>
                Status: {tempStatus.status}
              </p>
              <div className="flex justify-center items-center gap-2 text-[#4A7C59]" style={{ fontSize: 'var(--text-sm)' }}>
                <Clock className="w-4 h-4" />
                Last updated: {formatDate(data.currentTemperature.timestamp)}
              </div>
            </div>
          </div>

          {/* Temperature Trends */}
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-blue-50 rounded-lg">
                  <BarChart3 className="w-6 h-6 text-blue-600" />
                </div>
                <h2 style={{ fontSize: 'var(--text-xl)' }} className="font-semibold text-[#1E441E]">Temperature Trends</h2>
              </div>
              <button 
                onClick={() => navigate('/datahistory')}
                className="flex items-center gap-2 px-4 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors font-medium"
                style={{ fontSize: 'var(--text-sm)' }}
              >
                <BarChart3 className="w-4 h-4" />
                View History
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
            <div className="h-40">
              <svg viewBox="0 0 400 160" className="w-full h-full">
                <defs>
                  <pattern id="grid" width="40" height="20" patternUnits="userSpaceOnUse">
                    <path d="M 40 0 L 0 0 0 20" fill="none" stroke="#E5E7EB" strokeWidth="1"/>
                  </pattern>
                </defs>
                <rect width="400" height="160" fill="url(#grid)" />
                <polyline
                  fill="none"
                  stroke="#F97316"
                  strokeWidth="3"
                  points={data.temperatureChart.map((point, index) => 
                    `${(index * 80) + 20},${160 - ((point.temp - 20) * 4)}`
                  ).join(' ')}
                />
                {data.temperatureChart.map((point, index) => (
                  <circle
                    key={index}
                    cx={(index * 80) + 20}
                    cy={160 - ((point.temp - 20) * 4)}
                    r="4"
                    fill="#F97316"
                    stroke="white"
                    strokeWidth="2"
                  />
                ))}
                {data.temperatureChart.map((point, index) => (
                  <text
                    key={index}
                    x={(index * 80) + 20}
                    y="155"
                    textAnchor="middle"
                    fontSize="10"
                    fill="#4A7C59"
                  >
                    {point.time}
                  </text>
                ))}
              </svg>
            </div>
            <div className="text-center" style={{ fontSize: 'var(--text-sm)' }}>
              24-hour temperature overview
            </div>
          </div>
        </div>

        {/* Enhanced Recent Activity - Now using real API data */}
        <div className="bg-white rounded-xl shadow-lg overflow-hidden">
          <div className="p-6 border-b border-[#E8F2E0]">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-green-50 rounded-lg">
                  <Activity className="w-6 h-6 text-green-600" />
                </div>
                <div>
                  <h2 style={{ fontSize: 'var(--text-xl)' }} className="font-semibold text-[#1E441E]">Recent Activity</h2>
                  <div className="flex items-center gap-4 text-[#4A7C59]" style={{ fontSize: 'var(--text-xs)' }}>
                    <div className="flex items-center gap-1">
                      <RefreshCw className="w-3 h-3" />
                      <span>Smart polling every 15s</span>
                    </div>
                    {hasNewActivity && (
                      <div className="flex items-center gap-1 text-green-600">
                        <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                        <span>New activity detected</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <button 
                  onClick={handleManualRefresh}
                  disabled={activityLoading}
                  className="flex items-center gap-2 px-3 py-1 text-[#4A7C59] hover:text-[#356B2C] transition-colors disabled:opacity-50"
                  style={{ fontSize: 'var(--text-sm)' }}
                >
                  <RefreshCw className={`w-4 h-4 ${activityLoading ? 'animate-spin' : ''}`} />
                  Refresh
                </button>
                <button 
                  onClick={() => navigate('/admin/activity-logs')}
                  className="flex items-center gap-2 px-4 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors font-medium"
                  style={{ fontSize: 'var(--text-sm)' }}
                >
                  View All Logs
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>

          {/* Error Message */}
          {activityError && (
            <div className="p-4 bg-red-50 border-b border-red-200">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <AlertCircle className="w-4 h-4 text-red-600" />
                  <span className="text-red-700 font-medium" style={{ fontSize: 'var(--text-sm)' }}>
                    Error loading activity: {activityError}
                  </span>
                </div>
                <button
                  onClick={handleManualRefresh}
                  className="px-3 py-1 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors"
                  style={{ fontSize: 'var(--text-sm)' }}
                >
                  Retry
                </button>
              </div>
            </div>
          )}

          {/* Loading State */}
          {activityLoading && !activityError ? (
            <div className="flex items-center justify-center py-12">
              <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-[#356B2C]"></div>
              <span className="ml-3 text-[#4A7C59]" style={{ fontSize: 'var(--text-sm)' }}>Loading recent activity...</span>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-[#F5F9F1] border-b border-[#B8D4A8]">
                  <tr>
                    <th className="px-6 py-3 text-left font-medium text-[#356B2C] uppercase tracking-wider" style={{ fontSize: 'var(--text-xs)' }}>
                      User
                    </th>
                    <th className="px-6 py-3 text-left font-medium text-[#356B2C] uppercase tracking-wider" style={{ fontSize: 'var(--text-xs)' }}>
                      Role
                    </th>
                    <th className="px-6 py-3 text-left font-medium text-[#356B2C] uppercase tracking-wider" style={{ fontSize: 'var(--text-xs)' }}>
                      Action
                    </th>
                    <th className="px-6 py-3 text-left font-medium text-[#356B2C] uppercase tracking-wider" style={{ fontSize: 'var(--text-xs)' }}>
                      Resource
                    </th>
                    <th className="px-6 py-3 text-left font-medium text-[#356B2C] uppercase tracking-wider" style={{ fontSize: 'var(--text-xs)' }}>
                      Timestamp
                    </th>
                    <th className="px-6 py-3 text-left font-medium text-[#356B2C] uppercase tracking-wider" style={{ fontSize: 'var(--text-xs)' }}>
                      Details
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-[#E8F2E0]">
                  {recentActivity.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="px-6 py-12 text-center text-[#4A7C59]" style={{ fontSize: 'var(--text-base)' }}>
                        {activityError ? 'Failed to load recent activity' : 'No recent activity found'}
                      </td>
                    </tr>
                  ) : (
                    recentActivity.map((log) => (
                      <tr key={log._id} className="hover:bg-[#F9FBF7]">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center">
                            <div className="flex-shrink-0 h-8 w-8">
                              <div className="h-8 w-8 rounded-full bg-[#B8D4A8] flex items-center justify-center">
                                <User className="w-4 h-4 text-[#356B2C]" />
                              </div>
                            </div>
                            <div className="ml-3">
                              <div className="font-medium text-[#356B2C]" style={{ fontSize: 'var(--text-sm)' }}>
                                {log.userId?.name || 'Unknown User'}
                              </div>
                              <div className="text-[#4A7C59]" style={{ fontSize: 'var(--text-xs)' }}>
                                {log.userEmail}
                              </div>
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`inline-flex px-2 py-1 font-semibold rounded-full ${getRoleColor(log.userRole)}`} style={{ fontSize: 'var(--text-xs)' }}>
                            {log.userRole}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`inline-flex px-2 py-1 font-semibold rounded-full ${getActionColor(log.action)}`} style={{ fontSize: 'var(--text-xs)' }}>
                            {log.action}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="text-[#356B2C]" style={{ fontSize: 'var(--text-sm)' }}>{log.resource}</div>
                          {log.resourceId && (
                            <div className="text-[#4A7C59]" style={{ fontSize: 'var(--text-xs)' }}>ID: {log.resourceId}</div>
                          )}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center text-[#356B2C]" style={{ fontSize: 'var(--text-sm)' }}>
                            <Clock className="w-4 h-4 mr-1 text-[#4A7C59]" />
                            {formatDate(log.timestamp)}
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <div className="space-y-1">
                            <div className="flex items-center text-[#4A7C59]" style={{ fontSize: 'var(--text-xs)' }}>
                              <MapPin className="w-3 h-3 mr-1" />
                              {log.ipAddress}
                            </div>
                            <div className="flex items-center text-[#4A7C59]" style={{ fontSize: 'var(--text-xs)' }}>
                              <Smartphone className="w-3 h-3 mr-1" />
                              {getBrowserFromUserAgent(log.userAgent)} on {getOSFromUserAgent(log.userAgent)}
                            </div>
                            {log.details && Object.keys(log.details).length > 0 && (
                              <details style={{ fontSize: 'var(--text-xs)' }}>
                                <summary className="cursor-pointer text-[#356B2C] hover:text-[#2D5A24]">
                                  View Details
                                </summary>
                                <pre className="mt-1 p-2 bg-[#F5F9F1] rounded overflow-x-auto text-[#356B2C]" style={{ fontSize: 'var(--text-xs)' }}>
                                  {JSON.stringify(log.details, null, 2)}
                                </pre>
                              </details>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          )}
        </div></div>
        </div>
  );
};

export default AdminDashboard;