import React, { useState, useEffect } from 'react';
import { 
  Activity, 
  RefreshCw, 
  AlertCircle, 
  User, 
  Clock, 
  MapPin, 
  Smartphone, 
  ChevronRight 
} from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { activityLogService } from '../../api/services/activityLogService';
import { ActivityLog } from '../../api/services/activityLog';


interface RecentActivityWidgetProps {
  maxItems?: number;
  refreshInterval?: number;
}

const RecentActivityWidget: React.FC<RecentActivityWidgetProps> = ({ 
  maxItems = 5, 
  refreshInterval = 15000 
}) => {
  const [recentActivity, setRecentActivity] = useState<ActivityLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [lastActivityCheck, setLastActivityCheck] = useState<string | null>(null);
  const [hasNewActivity, setHasNewActivity] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    // Initial load
    fetchRecentActivity(true);
  }, [maxItems]);

  // Smart polling - check for new activity
  useEffect(() => {
    if (!refreshInterval) return;

    const interval = setInterval(() => {
      checkForNewActivity();
    }, refreshInterval);

    return () => clearInterval(interval);
  }, [lastActivityCheck, refreshInterval]);

  const checkForNewActivity = async () => {
    if (!lastActivityCheck) return;

    try {
      // Only fetch the most recent log to check if there's new activity
      const result = await activityLogService.getActivityLogs(1, 1);
      
      if (result.logs && result.logs.length > 0) {
        const mostRecentLog = result.logs[0];
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
      setLoading(true);
    }
    setError(null);
    setHasNewActivity(false);

    try {
      // Fetch only the most recent logs for widget
      const result = await activityLogService.getActivityLogs(1, maxItems);
      
      if (result.logs) {
        const logs = result.logs;
        setRecentActivity(logs);
        
        // Store the timestamp of the most recent activity for comparison
        if (logs.length > 0) {
          setLastActivityCheck(logs[0].timestamp);
        }
      } else {
        setError('Failed to fetch activity logs');
        setRecentActivity([]);
      }
    } catch (error: any) {
      console.error('Error fetching recent activity:', error);
      setError(error.message || 'Failed to fetch activity logs');
      setRecentActivity([]);
    } finally {
      setLoading(false);
    }
  };

  // Manual refresh function
  const handleManualRefresh = () => {
    fetchRecentActivity(false);
  };

  // Helper functions
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

  const getActivityDescription = (log: ActivityLog): string => {
    const userName = log.userId?.name || log.userId?.email || 'Unknown User';
    const action = log.action.toLowerCase();
    const resource = log.resource.toLowerCase();
    
    // Create contextual descriptions based on action and resource
    if (action.includes('login')) {
      return `${userName} signed into the system`;
    }
    
    if (action.includes('logout')) {
      return `${userName} signed out of the system`;
    }
    
    if (action.includes('create')) {
      if (resource.includes('user')) {
        return `${userName} created a new user account`;
      }
      if (resource.includes('farm')) {
        return `${userName} created a new farm prototype`;
      }
      if (resource.includes('post')) {
        return `${userName} created a new post`;
      }
      return `${userName} created a new ${resource}`;
    }
    
    if (action.includes('update')) {
      if (resource.includes('user')) {
        return `${userName} updated user information`;
      }
      if (resource.includes('farm')) {
        return `${userName} updated farm prototype data`;
      }
      if (resource.includes('profile')) {
        return `${userName} updated their profile`;
      }
      return `${userName} updated ${resource} information`;
    }
    
    if (action.includes('delete')) {
      if (resource.includes('user')) {
        return `${userName} deleted a user account`;
      }
      if (resource.includes('farm')) {
        return `${userName} deleted a farm prototype`;
      }
      return `${userName} deleted a ${resource}`;
    }
    
    if (action.includes('view')) {
      if (resource.includes('dashboard')) {
        return `${userName} accessed the dashboard`;
      }
      if (resource.includes('user')) {
        return `${userName} viewed user information`;
      }
      if (resource.includes('farm')) {
        return `${userName} viewed farm prototype data`;
      }
      if (resource.includes('activity')) {
        return `${userName} viewed activity logs`;
      }
      return `${userName} viewed ${resource} information`;
    }
    
    // Default fallback
    return `${userName} performed ${action} action on ${resource}`;
  };

  const getRoleColor = (role: string): string => {
    const colors: { [key: string]: string } = {
      super_admin: 'bg-red-100 text-red-800',
      admin: 'bg-orange-100 text-orange-800',
      user: 'bg-blue-100 text-blue-800',
      farmer: 'bg-green-100 text-green-800'
    };
    return colors[role] || 'bg-gray-100 text-gray-600';
  };

  const formatDate = (dateString: string): string => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInMinutes = Math.floor((now.getTime() - date.getTime()) / (1000 * 60));
    
    if (diffInMinutes < 1) return 'Just now';
    if (diffInMinutes < 60) return `${diffInMinutes}m ago`;
    if (diffInMinutes < 1440) return `${Math.floor(diffInMinutes / 60)}h ago`;
    return date.toLocaleDateString();
  };

  const getBrowserFromUserAgent = (userAgent: string): string => {
    if (userAgent.includes('Chrome')) return 'Chrome';
    if (userAgent.includes('Firefox')) return 'Firefox';
    if (userAgent.includes('Safari')) return 'Safari';
    if (userAgent.includes('Edge')) return 'Edge';
    if (userAgent.includes('Brave')) return 'Brave';
    return 'Unknown';
  };


  return (
    <div className="bg-white rounded-xl shadow-lg overflow-hidden">
      {/* Widget Header */}
      <div className="p-6 border-b border-[#E8F2E0]">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="p-2 bg-green-50 rounded-lg">
              <Activity className="w-6 h-6 text-green-600" />
            </div>
            <div>
              <h3 className="text-lg font-semibold text-[#1E441E]">Recent Activity</h3>
              <div className="flex items-center gap-4 text-xs text-[#4A7C59]">
                <div className="flex items-center gap-1">
                  <RefreshCw className="w-3 h-3" />
                  <span>Auto-refresh enabled</span>
                </div>
                {hasNewActivity && (
                  <div className="flex items-center gap-1 text-green-600">
                    <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                    <span>New activity</span>
                  </div>
                )}
              </div>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <button 
              onClick={handleManualRefresh}
              disabled={loading}
              className="flex items-center gap-2 px-3 py-1 text-[#4A7C59] hover:text-[#356B2C] transition-colors disabled:opacity-50 text-sm cursor-pointer disabled:cursor-not-allowed"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
              Refresh
            </button>
            <button 
              onClick={() => navigate('/admin-portal-xyz123/activity-logs')}
              className="flex items-center gap-2 px-4 py-2 bg-[#8B4513] text-[#F5F5DC] rounded-lg hover:bg-[#A0522D] transition-colors font-medium text-sm cursor-pointer"
            >
              View All
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Error State */}
      {error && (
        <div className="p-6 border-b border-[#E8F2E0]">
          <div className="flex items-center justify-between bg-red-50 border border-red-200 rounded-lg p-4">
            <div className="flex items-center gap-2">
              <AlertCircle className="w-4 h-4 text-red-600" />
              <span className="text-red-700 font-medium text-sm">
                Error: {error}
              </span>
            </div>
            <button
              onClick={handleManualRefresh}
              className="px-3 py-1 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors text-sm cursor-pointer"
            >
              Retry
            </button>
          </div>
        </div>
      )}

      {/* Activity List */}
      <div className="p-6">
        {loading && recentActivity.length === 0 ? (
          <div className="flex items-center justify-center py-8">
            <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-[#356B2C]"></div>
            <span className="ml-3 text-[#4A7C59] text-sm">Loading recent activity...</span>
          </div>
        ) : recentActivity.length === 0 ? (
          <div className="text-center py-8 text-[#4A7C59]">
            {error ? 'Failed to load recent activity' : 'No recent activity found'}
          </div>
        ) : (
          <div className="space-y-4">
            {recentActivity.map((log) => (
              <div key={log._id} className="flex items-start gap-3 p-3 rounded-lg hover:bg-[#F9FBF7] transition-colors">
                {/* User Avatar */}
                <div className="flex-shrink-0">
                  <div className="h-8 w-8 rounded-full bg-[#B8D4A8] flex items-center justify-center">
                    <User className="w-4 h-4 text-[#356B2C]" />
                  </div>
                </div>

                {/* Activity Details */}
                <div className="flex-1 min-w-0">
                  {/* Main activity description */}
                  <div className="mb-2">
                    <p className="text-[#356B2C] text-sm font-medium leading-relaxed">
                      {getActivityDescription(log)}
                    </p>
                  </div>
                  
                  {/* Role and action badges */}
                  <div className="flex items-center gap-2 mb-2">
                    <span className={`inline-flex px-2 py-0.5 rounded-full text-xs font-medium ${getRoleColor(log.userRole)}`}>
                      {log.userRole}
                    </span>
                    <span className={`inline-flex px-2 py-0.5 rounded-full text-xs font-medium ${getActionColor(log.action)}`}>
                      {log.action}
                    </span>
                    {log.resourceId && (
                      <span className="text-xs text-[#4A7C59] bg-gray-100 px-2 py-0.5 rounded">
                        ID: {log.resourceId.substring(0, 8)}...
                      </span>
                    )}
                  </div>

                  {/* Metadata */}
                  <div className="flex items-center gap-4 text-xs text-[#4A7C59]">
                    <div className="flex items-center gap-1">
                      <Clock className="w-3 h-3" />
                      {formatDate(log.timestamp)}
                    </div>
                    <div className="flex items-center gap-1">
                      <MapPin className="w-3 h-3" />
                      {log.ipAddress}
                    </div>
                    <div className="flex items-center gap-1">
                      <Smartphone className="w-3 h-3" />
                      {getBrowserFromUserAgent(log.userAgent)}
                    </div>
                  </div>
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