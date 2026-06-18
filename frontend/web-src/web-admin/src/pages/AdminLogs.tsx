import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import { FileText, Clock, User, Smartphone } from 'lucide-react';
import Footer from '../components/Footer';

interface ActivityLog {
  _id: string;
  userId: string;
  username: string;
  action: string;
  timestamp: string;
  deviceType: string;
  details: string;
}

const AdminLogs: React.FC = () => {
  const [logs, setLogs] = useState<ActivityLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState({
    dateRange: 'all',
    userFilter: '',
    actionFilter: ''
  });
  const navigate = useNavigate();

  useEffect(() => {
    const checkAdminAccess = async () => {
      try {
        const response = await axios.get('https://maize-watch-rdcy.onrender.com/api/auth/check-admin', {
          withCredentials: true
        });
        
        if (!response.data.isAdmin) {
          navigate('/admin-portal-xyz123/dashboard');
        }
      } catch (err) {
        console.error('Admin access check failed:', err);
        navigate('/admin-portal-xyz123/dashboard');
      }
    };

    checkAdminAccess();
  }, [navigate]);

  useEffect(() => {
    const fetchLogs = async () => {
      try {
        setLoading(true);
        const response = await axios.get('https://maize-watch-rdcy.onrender.com/api/logs', {
          params: filter,
          withCredentials: true
        });
        setLogs(response.data);
        setError(null);
      } catch (err) {
        console.error('Error fetching logs:', err);
        setError('Failed to fetch activity logs');
      } finally {
        setLoading(false);
      }
    };

    fetchLogs();
  }, [filter]);

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('en-PH', {
      timeZone: 'Asia/Manila',
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getActionIcon = (action: string) => {
    switch (action.toLowerCase()) {
      case 'login':
        return <User className="w-4 h-4" />;
      case 'logout':
        return <User className="w-4 h-4" />;
      case 'mobile_login':
        return <Smartphone className="w-4 h-4" />;
      default:
        return <FileText className="w-4 h-4" />;
    }
  };

  const getActionColor = (action: string) => {
    switch (action.toLowerCase()) {
      case 'login':
        return 'text-green-600 bg-green-50';
      case 'logout':
        return 'text-red-600 bg-red-50';
      case 'mobile_login':
        return 'text-blue-600 bg-blue-50';
      default:
        return 'text-gray-600 bg-gray-50';
    }
  };

  return (
    <div className="bg-[#E6F0D3] min-h-screen font-sans text-[#356B2C] px-6 sm:px-20 md:px-32 lg:px-50 pt-6">
      <main className="py-10">
        <div className="max-w-7xl mx-auto">
          {/* Header */}
          <div className="bg-white rounded-lg shadow-md p-6 mb-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <FileText className="w-8 h-8 text-[#356B2C]" />
                <h1 className="text-2xl font-bold text-gray-900">Activity Logs</h1>
              </div>
              <div className="flex items-center gap-4">
                <select
                  value={filter.dateRange}
                  onChange={(e) => setFilter(prev => ({ ...prev, dateRange: e.target.value }))}
                  className="rounded-md border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#356B2C]"
                >
                  <option value="all">All Time</option>
                  <option value="today">Today</option>
                  <option value="week">This Week</option>
                  <option value="month">This Month</option>
                </select>
                <input
                  type="text"
                  placeholder="Filter by user..."
                  value={filter.userFilter}
                  onChange={(e) => setFilter(prev => ({ ...prev, userFilter: e.target.value }))}
                  className="rounded-md border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#356B2C]"
                />
                <select
                  value={filter.actionFilter}
                  onChange={(e) => setFilter(prev => ({ ...prev, actionFilter: e.target.value }))}
                  className="rounded-md border border-gray-300 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#356B2C]"
                >
                  <option value="">All Actions</option>
                  <option value="login">Login</option>
                  <option value="logout">Logout</option>
                  <option value="mobile_login">Mobile Login</option>
                </select>
              </div>
            </div>
          </div>

          {/* Logs Table */}
          <div className="bg-white rounded-lg shadow-md overflow-hidden">
            {loading ? (
              <div className="p-8 text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#356B2C] mx-auto"></div>
                <p className="mt-2 text-gray-600">Loading activity logs...</p>
              </div>
            ) : error ? (
              <div className="p-8 text-center text-red-600">
                <p>{error}</p>
              </div>
            ) : logs.length === 0 ? (
              <div className="p-8 text-center text-gray-600">
                <p>No activity logs found</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Timestamp
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        User
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Action
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Device
                      </th>
                      <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Details
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {logs.map((log) => (
                      <tr key={log._id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          <div className="flex items-center gap-2">
                            <Clock className="w-4 h-4 text-gray-400" />
                            {formatDate(log.timestamp)}
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center gap-2">
                            <User className="w-4 h-4 text-gray-400" />
                            <span className="text-sm font-medium text-gray-900">
                              {log.username}
                            </span>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium ${getActionColor(log.action)}`}>
                            {getActionIcon(log.action)}
                            {log.action}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          <div className="flex items-center gap-2">
                            <Smartphone className="w-4 h-4 text-gray-400" />
                            {log.deviceType}
                          </div>
                        </td>
                        <td className="px-6 py-4 text-sm text-gray-500">
                          {log.details}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      </main>
      <Footer />
    </div>
  );
};

export default AdminLogs; 