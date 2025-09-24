import React from 'react';
import { User, Activity, Clock, MapPin, Smartphone } from 'lucide-react';

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

interface ActivityLogTableProps {
  logs: ActivityLog[];
  loading: boolean;
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}

const ActivityLogTable: React.FC<ActivityLogTableProps> = ({
  logs,
  loading,
  currentPage,
  totalPages,
  onPageChange
}) => {
  const getActionColor = (action: string) => {
    const colors = {
      login: 'bg-green-100 text-green-800',
      logout: 'bg-gray-100 text-gray-600',
      create: 'bg-blue-100 text-blue-800',
      update: 'bg-yellow-100 text-yellow-800',
      delete: 'bg-red-100 text-red-800'
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

  // Generate page numbers for pagination
  const getPageNumbers = () => {
    const pages = [];
    const maxVisiblePages = 5;
    
    if (totalPages <= maxVisiblePages) {
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i);
      }
    } else {
      let start = Math.max(1, currentPage - 2);
      let end = Math.min(totalPages, start + maxVisiblePages - 1);
      
      if (end - start < maxVisiblePages - 1) {
        start = Math.max(1, end - maxVisiblePages + 1);
      }
      
      for (let i = start; i <= end; i++) {
        pages.push(i);
      }
    }
    
    return pages;
  };

  return (
    <div className="bg-white rounded-lg shadow-sm border border-[#B8D4A8]">
      {/* Table Header */}
      <div className="p-4 border-b border-[#E8F2E0]">
        <h3 className="text-lg font-semibold text-[#1E441E]">Activity Log</h3>
        <p className="text-sm text-[#456C2D] mt-1">
          Recent system activities and user actions
        </p>
      </div>

      {/* Table Content */}
      <div className="overflow-x-auto">
        {loading ? (
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-[#356B2C]"></div>
          </div>
        ) : (
          <table className="w-full">
            <thead className="bg-[#456C2D] text-[#F5F5DC] text-left">
              <tr>
                <th className="px-6 py-3 text-left font-medium uppercase tracking-wider text-xs">
                  User
                </th>
                <th className="px-6 py-3 text-left font-medium uppercase tracking-wider text-xs">
                  Role
                </th>
                <th className="px-6 py-3 text-left font-medium uppercase tracking-wider text-xs">
                  Action
                </th>
                <th className="px-6 py-3 text-left font-medium uppercase tracking-wider text-xs">
                  Resource
                </th>
                <th className="px-6 py-3 text-left font-medium uppercase tracking-wider text-xs">
                  Timestamp
                </th>
                <th className="px-6 py-3 text-left font-medium uppercase tracking-wider text-xs">
                  Details
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-[#E8F2E0]">
              {logs.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center text-[#4A7C59] text-base">
                    No activity logs found
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
                          <div className="font-medium text-[#356B2C] text-sm">
                            {log.userId?.fullName || log.userId?.username || 'Unknown User'}
                          </div>
                          <div className="text-[#4A7C59] text-sm">
                            {log.userId?.email || log.userEmail || 'No email available'}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 font-semibold rounded-full text-xs ${getRoleColor(log.userRole)}`}>
                        {log.userRole}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 font-semibold rounded-full text-xs ${getActionColor(log.action)}`}>
                        {log.action}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="text-[#356B2C] text-sm">{log.resource}</div>
                      {log.resourceId && (
                        <div className="text-[#4A7C59] text-xs">ID: {log.resourceId}</div>
                      )}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center text-[#356B2C] text-sm">
                        <Clock className="w-4 h-4 mr-1 text-[#4A7C59]" />
                        {formatDate(log.timestamp)}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="space-y-1">
                        <div className="flex items-center text-[#4A7C59] text-xs">
                          <MapPin className="w-3 h-3 mr-1" />
                          {log.ipAddress}
                        </div>
                        <div className="flex items-center text-[#4A7C59] text-xs">
                          <Smartphone className="w-3 h-3 mr-1" />
                          {getBrowserFromUserAgent(log.userAgent)} on {getOSFromUserAgent(log.userAgent)}
                        </div>
                        {log.details && Object.keys(log.details).length > 0 && (
                          <details className="text-xs">
                            <summary className="cursor-pointer text-[#356B2C] hover:text-[#2D5A24]">
                              View Details
                            </summary>
                            <pre className="mt-1 p-2 bg-[#F5F9F1] rounded overflow-x-auto text-[#356B2C] text-xs">
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
        )}
      </div>

      {/* Pagination - Outside the table container */}
      {totalPages > 1 && !loading && (
        <div className="flex items-center justify-between p-4 bg-gray-50 border-t border-[#E8F2E0]">
          <div className="text-sm text-[#456C2D] font-medium">
            Page {currentPage} of {totalPages}
          </div>
          <div className="flex items-center gap-2">
            {/* Previous Button */}
            <button
              onClick={() => onPageChange(currentPage - 1)}
              disabled={currentPage === 1}
              className={`flex items-center px-4 py-2 rounded-lg transition-colors font-medium ${
                currentPage === 1
                  ? 'bg-gray-200 text-gray-400 cursor-not-allowed'
                  : 'bg-[#456C2D] text-[#F5F5DC] hover:bg-[#5A7A3A]'
              }`}
            >
              Previous
            </button>
            
            {/* Page Numbers */}
            <div className="flex gap-1">
              {getPageNumbers().map((pageNum) => (
                <button
                  key={pageNum}
                  onClick={() => onPageChange(pageNum)}
                  className={`px-3 py-2 rounded-lg transition-colors font-medium ${
                    currentPage === pageNum
                      ? 'bg-[#8B4513] text-[#F5F5DC]'
                      : 'bg-[#456C2D] text-[#F5F5DC] hover:bg-[#5A7A3A]'
                  }`}
                >
                  {pageNum}
                </button>
              ))}
            </div>
            
            {/* Next Button */}
            <button
              onClick={() => onPageChange(currentPage + 1)}
              disabled={currentPage === totalPages}
              className={`flex items-center px-4 py-2 rounded-lg transition-colors font-medium ${
                currentPage === totalPages
                  ? 'bg-gray-200 text-gray-400 cursor-not-allowed'
                  : 'bg-[#456C2D] text-[#F5F5DC] hover:bg-[#5A7A3A]'
              }`}
            >
              Next
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default ActivityLogTable;