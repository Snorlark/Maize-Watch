import { useState, useEffect, useRef, useCallback } from 'react';

interface UseIntelligentRefreshOptions {
  refreshInterval?: number; // in milliseconds
  enabled?: boolean;
  onRefresh?: () => Promise<any>;
}

interface UseIntelligentRefreshReturn {
  isRefreshing: boolean;
  lastRefreshTime: Date | null;
  refreshData: () => Promise<void>;
  toggleAutoRefresh: () => void;
  autoRefreshEnabled: boolean;
  refreshIndicator: boolean;
}

export const useIntelligentRefresh = ({
  refreshInterval = 15000,
  enabled = true,
  onRefresh
}: UseIntelligentRefreshOptions): UseIntelligentRefreshReturn => {
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [lastRefreshTime, setLastRefreshTime] = useState<Date | null>(null);
  const [autoRefreshEnabled, setAutoRefreshEnabled] = useState(enabled);
  const [refreshIndicator, setRefreshIndicator] = useState(false);
  
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  const refreshData = useCallback(async () => {
    if (!onRefresh) return;
    
    try {
      setIsRefreshing(true);
      setRefreshIndicator(true);
      
      await onRefresh();
      
      setLastRefreshTime(new Date());
      
      // Show refresh indicator briefly
      setTimeout(() => {
        setRefreshIndicator(false);
      }, 1000);
      
    } catch (error) {
      console.error('Error during intelligent refresh:', error);
    } finally {
      setIsRefreshing(false);
    }
  }, [onRefresh]);

  const toggleAutoRefresh = useCallback(() => {
    setAutoRefreshEnabled(prev => !prev);
  }, []);

  // Start/stop auto-refresh based on enabled state
  useEffect(() => {
    if (autoRefreshEnabled && enabled) {
      intervalRef.current = setInterval(() => {
        refreshData();
      }, refreshInterval);
    } else {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
    }

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
    };
  }, [autoRefreshEnabled, enabled, refreshInterval, refreshData]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, []);

  return {
    isRefreshing,
    lastRefreshTime,
    refreshData,
    toggleAutoRefresh,
    autoRefreshEnabled,
    refreshIndicator
  };
}; 