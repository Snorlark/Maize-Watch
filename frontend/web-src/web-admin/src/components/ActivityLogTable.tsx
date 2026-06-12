import React from 'react';
import { User, MapPin, Smartphone, ChevronLeft, ChevronRight, Loader2 } from 'lucide-react';

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
    switch (role) {
      case 'farmer':
      case 'user':
        return 'bg-green-100 text-green-800';
      case 'admin':
        return 'bg-blue-100 text-blue-800';
      case 'super_admin':
        return 'bg-purple-100 text-purple-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getBrowserFromUserAgent = (userAgent: string) => {
    if (userAgent.includes('Chrome')) return 'Chrome';
    if (userAgent.includes('Firefox')) return 'Firefox';
    if (userAgent.includes('Safari')) return 'Safari';
    if (userAgent.includes('Edge')) return 'Edge';
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

  // Handle page navigation
  const goToPreviousPage = () => {
    if (currentPage > 1) {
      onPageChange(currentPage - 1);
    }
  };

  const goToNextPage = () => {
    if (currentPage < totalPages) {
      onPageChange(currentPage + 1);
    }
  };

  return (
    <div className="w-full">
      {/* Header Section */}
      <div className="flex justify-between mb-4 items-end">
        <div>
          <h2 className="text-xl font-semibold text-[#1E441E]">Activity Log</h2>
          <p className="text-sm text-[#456C2D] mt-1">
            Recent system activities and user actions ({logs.length} total logs)
          </p>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-lg overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-[#456C2D] text-[#F5F5DC] text-left">
              <tr>
                <th className="px-4 py-3 text-xs font-medium uppercase tracking-wider w-12">#</th>
                <th className="px-4 py-3 text-xs font-medium uppercase tracking-wider min-w-[180px]">User</th>
                <th className="px-4 py-3 text-xs font-medium uppercase tracking-wider w-24">Role</th>
                <th className="px-4 py-3 text-xs font-medium uppercase tracking-wider w-24">Action</th>
                <th className="px-4 py-3 text-xs font-medium uppercase tracking-wider w-28">Resource</th>
                <th className="px-4 py-3 text-xs font-medium uppercase tracking-wider w-36">Timestamp</th>
                <th className="px-4 py-3 text-xs font-medium uppercase tracking-wider min-w-[200px]">Details</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {loading ? (
                <tr>
                  <td colSpan={7} className="px-4 py-8 text-center">
                    <Loader2 className="w-6 h-6 mx-auto animate-spin text-[#456C2D]" />
                    <p className="mt-2 text-[#456C2D]">Loading activity logs...</p>
                  </td>
                </tr>
              ) : logs.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-4 py-8 text-center text-[#456C2D]">No activity logs found</td>
                </tr>
              ) : (
                logs.map((log, index) => (
                  <tr key={log._id} className="hover:bg-[#F5F9E8] transition-colors">
                    <td className="px-4 py-3 text-center font-medium text-[#456C2D] text-sm">
                      {(currentPage - 1) * 20 + index + 1}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center min-w-0">
                        <div className="flex-shrink-0 h-8 w-8">
                          <div className="h-8 w-8 rounded-full bg-[#B8D4A8] flex items-center justify-center">
                            <User className="w-4 h-4 text-[#356B2C]" />
                          </div>
                        </div>
                        <div className="ml-2 min-w-0">
                          <div className="font-medium text-[#356B2C] text-sm truncate">
                            {log.userId?.fullName || log.userId?.username || 'Unknown User'}
                          </div>
                          <div className="text-[#4A7C59] text-xs truncate">
                            {log.userId?.email || log.userEmail || 'No email'}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium whitespace-nowrap ${getRoleColor(log.userRole)}`}>
                        {log.userRole.replace('_', ' ')}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium whitespace-nowrap ${getActionColor(log.action)}`}>
                        {log.action}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      <div className="text-[#356B2C] text-sm truncate">{log.resource}</div>
                    </td>
                    <td className="px-4 py-3">
                      <div className="text-[#356B2C] text-xs whitespace-nowrap">
                        {new Date(log.timestamp).toLocaleDateString()}
                      </div>
                      <div className="text-[#4A7C59] text-xs whitespace-nowrap">
                        {new Date(log.timestamp).toLocaleTimeString()}
                      </div>
                    </td>
                    <td className="px-4 py-3">
                      <div className="space-y-1">
                        <div className="flex items-center text-[#4A7C59] text-xs">
                          <MapPin className="w-3 h-3 mr-1 flex-shrink-0" />
                          <span className="truncate">{log.ipAddress}</span>
                        </div>
                        <div className="flex items-center text-[#4A7C59] text-xs">
                          <Smartphone className="w-3 h-3 mr-1 flex-shrink-0" />
                          <span className="truncate">{getBrowserFromUserAgent(log.userAgent)}</span>
                        </div>
                        {log.details && Object.keys(log.details).length > 0 && (
                          <details className="text-xs">
                            <summary className="cursor-pointer text-[#456C2D] hover:text-[#2D5A24] font-medium">
                              More
                            </summary>
                            <pre className="mt-1 p-2 bg-[#F5F9F1] rounded overflow-x-auto text-[#356B2C] text-xs max-w-xs">
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
      </div>

      {/* Pagination Controls */}
      {totalPages > 1 && !loading && (
        <div className="flex flex-col sm:flex-row items-center justify-between mt-6 p-4 bg-white rounded-lg shadow-sm border border-[#B8D4A8] gap-4">
          <div className="text-sm text-[#456C2D] font-medium">
            Page {currentPage} of {totalPages}
          </div>
          
          <div className="flex items-center gap-2">
            {/* Previous Button */}
            <button
              onClick={goToPreviousPage}
              disabled={currentPage === 1}
              className={`flex items-center px-4 py-2 rounded-lg transition-colors font-medium ${
                currentPage === 1
                  ? 'bg-gray-200 text-gray-400 cursor-not-allowed'
                  : 'bg-[#456C2D] text-[#F5F5DC] hover:bg-[#5A7A3A]'
              }`}
            >
              <ChevronLeft className="w-4 h-4 mr-1" />
              Previous
            </button>
            
            {/* Page Numbers */}
            <div className="flex gap-1">
              {getPageNumbers().map((page) => (
                <button
                  key={page}
                  onClick={() => onPageChange(page)}
                  className={`px-3 py-2 rounded-lg transition-colors font-medium ${
                    currentPage === page
                      ? 'bg-[#8B4513] text-[#F5F5DC]'
                      : 'bg-[#456C2D] text-[#F5F5DC] hover:bg-[#5A7A3A]'
                  }`}
                >
                  {page}
                </button>
              ))}
            </div>
            
            {/* Next Button */}
            <button
              onClick={goToNextPage}
              disabled={currentPage === totalPages}
              className={`flex items-center px-4 py-2 rounded-lg transition-colors font-medium ${
                currentPage === totalPages
                  ? 'bg-gray-200 text-gray-400 cursor-not-allowed'
                  : 'bg-[#456C2D] text-[#F5F5DC] hover:bg-[#5A7A3A]'
              }`}
            >
              Next
              <ChevronRight className="w-4 h-4 ml-1" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default ActivityLogTable;