import React from 'react';
import { RefreshCw } from 'lucide-react';

interface RefreshIndicatorProps {
  isRefreshing: boolean;
  lastRefreshTime: Date | null;
  autoRefreshEnabled: boolean;
  onToggleAutoRefresh?: () => void;
  className?: string;
}

export const RefreshIndicator: React.FC<RefreshIndicatorProps> = ({
  isRefreshing,
  lastRefreshTime,
  autoRefreshEnabled,
  onToggleAutoRefresh,
  className = ''
}) => {
  const formatLastRefresh = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    
    if (seconds < 60) {
      return `${seconds}s ago`;
    } else if (minutes < 60) {
      return `${minutes}m ago`;
    } else {
      return date.toLocaleTimeString();
    }
  };

  return (
    <div className={`flex items-center gap-2 text-sm text-gray-500 ${className}`}>
      {/* Auto-refresh toggle button */}
      {onToggleAutoRefresh && (
        <button
          onClick={onToggleAutoRefresh}
          className={`flex items-center gap-1 px-2 py-1 rounded-md transition-colors ${
            autoRefreshEnabled 
              ? 'bg-green-100 text-green-700 hover:bg-green-200' 
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
          }`}
          title={autoRefreshEnabled ? 'Disable auto-refresh' : 'Enable auto-refresh'}
        >
          <div className={`w-2 h-2 rounded-full ${
            autoRefreshEnabled ? 'bg-green-500' : 'bg-gray-400'
          }`} />
          <span className="text-xs">
            {autoRefreshEnabled ? 'Auto' : 'Manual'}
          </span>
        </button>
      )}
      
      {/* Refresh indicator */}
      <div className="flex items-center gap-1">
        <RefreshCw 
          className={`w-3 h-3 transition-all duration-300 ${
            isRefreshing ? 'animate-spin text-blue-500' : 'text-gray-400'
          }`} 
        />
        <span className="text-xs">
          {isRefreshing ? 'Updating...' : lastRefreshTime ? formatLastRefresh(lastRefreshTime) : 'Never'}
        </span>
      </div>
    </div>
  );
}; 