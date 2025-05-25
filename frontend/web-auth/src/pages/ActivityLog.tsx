import React, { useState, useEffect } from 'react';
import { Search, Filter, Calendar, User, Activity, Clock, MapPin, Smartphone, ChevronDown, ChevronUp } from 'lucide-react';
import Footer from '../components/Footer';
import apiClient from '../api/client';
import authService from '../api/services/authService';

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

interface FilterState {
  userId: string;
  action: string;
  resource: string;
  startDate: string;
  endDate: string;
  search: string;
}

const ActivityLogPage: React.FC = () => {
  const [logs, setLogs] = useState<ActivityLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [filters, setFilters] = useState<FilterState>({
    userId: '',
    action: '',
    resource: '',
    startDate: '',
    endDate: '',
    search: ''
  });
  const [showFilters, setShowFilters] = useState(false);

  useEffect(() => {
    fetchLogs(1);
  }, []);

  useEffect(() => {
    fetchLogs(1);
  }, [filters]);

  const fetchLogs = async (page = 1) => {
    setLoading(true);
    setError(null);
    
    if (!authService.isAuthenticated()) {
      setError('No authentication token found. Please log in again.');
      setLoading(false);
      return;
    }

    try {
      const params = {
        page: page.toString(),
        limit: '20',
        ...Object.fromEntries(Object.entries(filters).filter(([_, v]) => v))
      };

      const response = await apiClient.get('/api/activity-logs', { params });
      
      setLogs(response.data.logs || []);
      setTotalPages(response.data.totalPages || 1);
      setCurrentPage(page);
    } catch (error: any) {
      console.error('Failed to fetch activity logs:', error);
      
      if (error.response?.status === 401) {
        authService.logout();
        setError('Session expired. Please log in again.');
      } else {
        setError(error.response?.data?.message || 'Failed to fetch activity logs');
      }
      setLogs([]);
    } finally {
      setLoading(false);
    }
  };

  const handleFilterChange = (key: keyof FilterState, value: string) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  };

  const clearFilters = () => {
    setFilters({
      userId: '',
      action: '',
      resource: '',
      startDate: '',
      endDate: '',
      search: ''
    });
  };

  const getActionColor = (action: string) => {
    const colors = {
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

  const getRoleColor = (role: string) => {
    const colors = {
      super_admin: 'bg-red-100 text-red-800',
      admin: 'bg-orange-100 text-orange-800',
      user: 'bg-blue-100 text-blue-800'
    };
    return colors[role as keyof typeof colors] || 'bg-gray-100 text-gray-600';
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString();
  };

  const getBrowserFromUserAgent = (userAgent: string) => {
    if (userAgent.includes('Chrome')) return 'Chrome';
    if (userAgent.includes('Firefox')) return 'Firefox';
    if (userAgent.includes('Safari')) return 'Safari';
    if (userAgent.includes('Edge')) return 'Edge';
    return 'Unknown';
  };

  const getOSFromUserAgent = (userAgent: string) => {
    if (userAgent.includes('Windows')) return 'Windows';
    if (userAgent.includes('Mac')) return 'macOS';
    if (userAgent.includes('Linux')) return 'Linux';
    if (userAgent.includes('Android')) return 'Android';
    if (userAgent.includes('iOS')) return 'iOS';
    return 'Unknown';
  };

  // Redirect if not admin - you can implement this check based on your auth system
  // For now, I'll comment this out since we don't have access to UserContext
  // if (authChecked && !isAdmin) {
  //   return <Navigate to="/unauthorized" replace />;
  // }

  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <main className="flex-grow container mx-auto px-4 py-8">
        {/* Header */}
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-2xl font-semibold flex items-center gap-2">
              <Activity className="w-6 h-6 text-[#356B2C]" />
              Activity Log
            </h1>
            <p className="text-[#4A7C59] mt-1 text-sm">Monitor all admin and user activities</p>
          </div>
          <div className="flex items-center gap-3">
            <div className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm">
              Admin Access
            </div>
            <button
              onClick={() => setShowFilters(!showFilters)}
              className="flex items-center gap-2 px-4 py-2 bg-[#356B2C] text-white rounded-lg hover:bg-[#2D5A24] transition-colors"
            >
              <Filter className="w-4 h-4" />
              Filters
              {showFilters ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
            </button>
          </div>
        </div>

        {/* Error Message */}
        {error && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            <div className="flex items-center justify-between">
              <span><strong>Error:</strong> {error}</span>
              <button
                onClick={() => fetchLogs(currentPage)}
                className="px-3 py-1 bg-red-600 text-white text-sm rounded hover:bg-red-700 transition-colors"
              >
                Retry
              </button>
            </div>
          </div>
        )}

        {/* Filters */}
        {showFilters && (
          <div className="bg-white rounded-lg shadow-sm border border-[#B8D4A8] p-6 mb-6">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
              <div>
                <label className="block text-sm font-medium text-[#356B2C] mb-2">Search</label>
                <div className="relative">
                  <Search className="w-4 h-4 absolute left-3 top-3 text-gray-400" />
                  <input
                    type="text"
                    placeholder="Search users, actions..."
                    value={filters.search}
                    onChange={(e) => handleFilterChange('search', e.target.value)}
                    className="w-full pl-10 pr-3 py-2 border border-[#B8D4A8] rounded-lg focus:ring-2 focus:ring-[#356B2C] focus:border-transparent"
                  />
                </div>
              </div>
              
              <div>
                <label className="block text-sm font-medium text-[#356B2C] mb-2">Action</label>
                <select
                  value={filters.action}
                  onChange={(e) => handleFilterChange('action', e.target.value)}
                  className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:ring-2 focus:ring-[#356B2C] focus:border-transparent"
                >
                  <option value="">All Actions</option>
                  <option value="login">Login</option>
                  <option value="create">Create</option>
                  <option value="update">Update</option>
                  <option value="delete">Delete</option>
                  <option value="view">View</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-[#356B2C] mb-2">Resource</label>
                <select
                  value={filters.resource}
                  onChange={(e) => handleFilterChange('resource', e.target.value)}
                  className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:ring-2 focus:ring-[#356B2C] focus:border-transparent"
                >
                  <option value="">All Resources</option>
                  <option value="user">User</option>
                  <option value="post">Post</option>
                  <option value="settings">Settings</option>
                  <option value="auth">Authentication</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-[#356B2C] mb-2">Start Date</label>
                <input
                  type="date"
                  value={filters.startDate}
                  onChange={(e) => handleFilterChange('startDate', e.target.value)}
                  className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:ring-2 focus:ring-[#356B2C] focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-[#356B2C] mb-2">End Date</label>
                <input
                  type="date"
                  value={filters.endDate}
                  onChange={(e) => handleFilterChange('endDate', e.target.value)}
                  className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:ring-2 focus:ring-[#356B2C] focus:border-transparent"
                />
              </div>
            </div>
            
            <div className="mt-4 flex justify-end">
              <button
                onClick={clearFilters}
                className="px-4 py-2 text-[#4A7C59] hover:text-[#356B2C] transition-colors"
              >
                Clear Filters
              </button>
            </div>
          </div>
        )}

        {/* Activity Log Table */}
        <div className="bg-white rounded-lg shadow-sm border border-[#B8D4A8] overflow-hidden">
          {loading ? (
            <div className="flex items-center justify-center py-12">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#356B2C]"></div>
            </div>
          ) : (
            <>
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-[#F5F9F1] border-b border-[#B8D4A8]">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-[#356B2C] uppercase tracking-wider">
                        User
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-[#356B2C] uppercase tracking-wider">
                        Role
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-[#356B2C] uppercase tracking-wider">
                        Action
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-[#356B2C] uppercase tracking-wider">
                        Resource
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-[#356B2C] uppercase tracking-wider">
                        Timestamp
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-[#356B2C] uppercase tracking-wider">
                        Details
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-[#E8F2E0]">
                    {logs.length === 0 ? (
                      <tr>
                        <td colSpan={6} className="px-6 py-12 text-center text-[#4A7C59]">
                          {error ? 'Failed to load activity logs' : 'No activity logs found'}
                        </td>
                      </tr>
                    ) : (
                      logs.map((log) => (
                        <tr key={log._id} className="hover:bg-[#F9FBF7]">
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="flex items-center">
                              <div className="flex-shrink-0 h-8 w-8">
                                <div className="h-8 w-8 rounded-full bg-[#B8D4A8] flex items-center justify-center">
                                  <User className="w-4 h-4 text-[#356B2C]" />
                                </div>
                              </div>
                              <div className="ml-3">
                                <div className="text-sm font-medium text-[#356B2C]">
                                  {log.userId?.name || 'Unknown User'}
                                </div>
                                <div className="text-sm text-[#4A7C59]">
                                  {log.userEmail}
                                </div>
                              </div>
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getRoleColor(log.userRole)}`}>
                              {log.userRole}
                            </span>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getActionColor(log.action)}`}>
                              {log.action}
                            </span>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="text-sm text-[#356B2C]">{log.resource}</div>
                            {log.resourceId && (
                              <div className="text-xs text-[#4A7C59]">ID: {log.resourceId}</div>
                            )}
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="flex items-center text-sm text-[#356B2C]">
                              <Clock className="w-4 h-4 mr-1 text-[#4A7C59]" />
                              {formatDate(log.timestamp)}
                            </div>
                          </td>
                          <td className="px-6 py-4">
                            <div className="space-y-1">
                              <div className="flex items-center text-xs text-[#4A7C59]">
                                <MapPin className="w-3 h-3 mr-1" />
                                {log.ipAddress}
                              </div>
                              <div className="flex items-center text-xs text-[#4A7C59]">
                                <Smartphone className="w-3 h-3 mr-1" />
                                {getBrowserFromUserAgent(log.userAgent)} on {getOSFromUserAgent(log.userAgent)}
                              </div>
                              {log.details && Object.keys(log.details).length > 0 && (
                                <details className="text-xs">
                                  <summary className="cursor-pointer text-[#356B2C] hover:text-[#2D5A24]">
                                    View Details
                                  </summary>
                                  <pre className="mt-1 p-2 bg-[#F5F9F1] rounded text-xs overflow-x-auto text-[#356B2C]">
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

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="bg-[#F5F9F1] px-6 py-3 border-t border-[#B8D4A8] flex items-center justify-between">
                  <div className="text-sm text-[#356B2C]">
                    Page {currentPage} of {totalPages}
                  </div>
                  <div className="flex gap-2">
                    <button
                      onClick={() => fetchLogs(currentPage - 1)}
                      disabled={currentPage === 1}
                      className="px-3 py-1 text-sm border border-[#B8D4A8] rounded hover:bg-[#E8F2E0] disabled:opacity-50 disabled:cursor-not-allowed text-[#356B2C]"
                    >
                      Previous
                    </button>
                    <button
                      onClick={() => fetchLogs(currentPage + 1)}
                      disabled={currentPage === totalPages}
                      className="px-3 py-1 text-sm border border-[#B8D4A8] rounded hover:bg-[#E8F2E0] disabled:opacity-50 disabled:cursor-not-allowed text-[#356B2C]"
                    >
                      Next
                    </button>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </main>

      <Footer />
    </div>
  );
};

export default ActivityLogPage;