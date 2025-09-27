import React, { useState, useEffect } from 'react';
import { Activity, RefreshCw, AlertCircle } from 'lucide-react';
import apiClient from '../../api/client';
import authService from '../../api/services/authService';

interface RecentActivityWidgetProps {
  maxItems?: number;
  refreshInterval?: number;
}

const RecentActivityWidget: React.FC<RecentActivityWidgetProps> = ({ 
  maxItems = 5, 
  refreshInterval = 15000 
}) => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [logs, setLogs] = useState<any[]>([]);

  const fetchLogs = async () => {
    console.log('🔍 RecentActivityWidget: Starting fetch...');
    setLoading(true);
    setError(null);

    try {
      const currentUser = authService.getCurrentUser();
      console.log('🔍 Activity logs endpoint selection:', {
        userRole: currentUser?.role,
        endpoint: '/api/activity-logs'
      });
      
      const response = await apiClient.get('/api/activity-logs', {
        params: { page: 1, limit: maxItems }
      });
      
      console.log('🔍 Activity logs response:', response.data);
      
      if (response.data && response.data.logs) {
        setLogs(response.data.logs);
      } else {
        setLogs([]);
      }
    } catch (err: any) {
      console.error('Error fetching activity logs:', err);
      setError(err.message || 'Failed to fetch activity logs');
      setLogs([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchLogs();
    
    if (refreshInterval > 0) {
      const interval = setInterval(fetchLogs, refreshInterval);
      return () => clearInterval(interval);
    }
  }, [maxItems, refreshInterval]);

  return (
    <div className="bg-white rounded-xl shadow-lg overflow-hidden">
      <div className="p-6 border-b border-[#E8F2E0]">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-green-50 rounded-lg">
              <Activity className="w-6 h-6 text-green-600" />
            </div>
            <div>
              <h3 className="text-lg font-semibold text-[#1E441E]">Recent Activity</h3>
              <p className="text-sm text-[#4A7C59]">Latest system activity</p>
            </div>
          </div>
          <button 
            onClick={fetchLogs}
            disabled={loading}
            className="flex items-center gap-2 px-3 py-1 text-[#4A7C59] hover:text-[#356B2C] transition-colors disabled:opacity-50 text-sm"
          >
            <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
        </div>
      </div>
      
      <div className="p-6">
        {loading ? (
          <div className="flex items-center justify-center py-8">
            <RefreshCw className="w-6 h-6 animate-spin text-[#4A7C59]" />
            <span className="ml-2 text-[#4A7C59]">Loading activity...</span>
          </div>
        ) : error ? (
          <div className="flex items-center justify-center py-8">
            <AlertCircle className="w-6 h-6 text-red-500" />
            <span className="ml-2 text-red-600">{error}</span>
          </div>
        ) : logs.length === 0 ? (
          <div className="text-center py-8 text-[#4A7C59]">
            No recent activity found
          </div>
        ) : (
          <div className="space-y-4">
            {logs.map((log, index) => (
              <div key={log._id || index} className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                <div className="w-2 h-2 bg-green-500 rounded-full mt-2"></div>
                <div className="flex-1">
                  <p className="text-sm text-[#1E441E]">
                    {log.userId?.fullName || log.userId?.username || 'Unknown User'} performed {log.action} on {log.resource}
                  </p>
                  <p className="text-xs text-[#4A7C59] mt-1">
                    {new Date(log.timestamp).toLocaleString()}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default RecentActivityWidget;