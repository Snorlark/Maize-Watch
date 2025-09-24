import React, { useState, useEffect } from 'react';
import { Search, Activity } from 'lucide-react';
import Footer from '../components/Footer';
import ActivityLogTable from '../components/ActivityLogTable';
import apiClient from '../api/client';
import authService from '../api/services/authService';

interface ActivityLog {
  _id: string;
  userId: {
    _id: string;
    username: string;
    fullName: string;
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
      
      // The backend wraps the response in a success/data structure
      const responseData = response.data.data || response.data;
      
      setLogs(responseData.logs || []);
      setTotalPages(responseData.pagination?.totalPages || 1);
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

  const handlePageChange = (page: number) => {
    fetchLogs(page);
  };

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
      <main className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="font-bold text-[#1E441E] mb-2 flex items-center gap-3" style={{ fontSize: 'var(--text-xl)' }}>
            <Activity className="w-8 h-8 sm:w-10 sm:h-10 text-[#456C2D]" />
            Activity Log
          </h1>
          <p className="text-[#456C2D]" style={{ fontSize: 'var(--text-base)' }}>
            Monitor all admin and user activities across the system
          </p>
          <div className="mt-3">
            <span className="inline-flex items-center px-3 py-1 rounded-full font-medium bg-[#456C2D] text-[#F5F5DC]" style={{ fontSize: 'var(--text-sm)' }}>
              Admin Access
            </span>
          </div>
        </div>

        {/* Error Message */}
        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6">
            <div className="flex items-center justify-between">
              <span className="font-medium">Error: {error}</span>
              <button
                onClick={() => fetchLogs(currentPage)}
                className="px-3 py-1 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors"
                style={{ fontSize: 'var(--text-sm)' }}
              >
                Retry
              </button>
            </div>
          </div>
        )}

        {/* Filters */}
        <div className="bg-white rounded-lg shadow-sm border border-[#B8D4A8] p-6 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
            <div>
              <label className="block font-medium text-[#356B2C] mb-2" style={{ fontSize: 'var(--text-sm)' }}>Search</label>
              <div className="relative">
                <Search className="w-4 h-4 absolute left-3 top-3 text-gray-400" />
                <input
                  type="text"
                  placeholder="Search users, actions..."
                  value={filters.search}
                  onChange={(e) => handleFilterChange('search', e.target.value)}
                  className="w-full pl-10 pr-3 py-2 border border-[#B8D4A8] rounded-lg focus:ring-2 focus:ring-[#356B2C] focus:border-transparent"
                  style={{ fontSize: 'var(--text-sm)' }}
                />
              </div>
            </div>
            
            <div>
              <label className="block font-medium text-[#356B2C] mb-2" style={{ fontSize: 'var(--text-sm)' }}>Action</label>
              <select
                value={filters.action}
                onChange={(e) => handleFilterChange('action', e.target.value)}
                className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:ring-2 focus:ring-[#356B2C] focus:border-transparent"
                style={{ fontSize: 'var(--text-sm)' }}
              >
                <option value="">All Actions</option>
                <option value="login">Login</option>
                <option value="create">Create</option>
                <option value="update">Update</option>
                <option value="delete">Delete</option>
              </select>
            </div>

            <div>
              <label className="block font-medium text-[#356B2C] mb-2" style={{ fontSize: 'var(--text-sm)' }}>Resource</label>
              <select
                value={filters.resource}
                onChange={(e) => handleFilterChange('resource', e.target.value)}
                className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:ring-2 focus:ring-[#356B2C] focus:border-transparent"
                style={{ fontSize: 'var(--text-sm)' }}
              >
                <option value="">All Resources</option>
                <option value="user">User</option>
                <option value="post">Post</option>
                <option value="settings">Settings</option>
                <option value="auth">Authentication</option>
              </select>
            </div>

            <div>
              <label className="block font-medium text-[#356B2C] mb-2" style={{ fontSize: 'var(--text-sm)' }}>Start Date</label>
              <input
                type="date"
                value={filters.startDate}
                onChange={(e) => handleFilterChange('startDate', e.target.value)}
                className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:ring-2 focus:ring-[#356B2C] focus:border-transparent"
                style={{ fontSize: 'var(--text-sm)' }}
              />
            </div>

            <div>
              <label className="block font-medium text-[#356B2C] mb-2" style={{ fontSize: 'var(--text-sm)' }}>End Date</label>
              <input
                type="date"
                value={filters.endDate}
                onChange={(e) => handleFilterChange('endDate', e.target.value)}
                className="w-full px-3 py-2 border border-[#B8D4A8] rounded-lg focus:ring-2 focus:ring-[#356B2C] focus:border-transparent"
                style={{ fontSize: 'var(--text-sm)' }}
              />
            </div>
          </div>
          
          <div className="mt-4 flex justify-end">
            <button
              onClick={clearFilters}
              className="px-4 py-2 text-[#4A7C59] hover:text-[#356B2C] transition-colors"
              style={{ fontSize: 'var(--text-sm)' }}
            >
              Clear Filters
            </button>
          </div>
        </div>

        {/* Activity Log Table Component */}
        <ActivityLogTable
          logs={logs}
          loading={loading}
          currentPage={currentPage}
          totalPages={totalPages}
          onPageChange={handlePageChange}
        />
      </main>

      <Footer />
    </div>
  );
};

export default ActivityLogPage;