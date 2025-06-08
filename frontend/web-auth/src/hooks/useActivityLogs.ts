import { useState, useEffect, useCallback } from 'react';
import { activityLogService } from '../api/services/activityLogService';
import { ActivityLog, ActivityLogFilters } from '../api/services/activityLog';

export const useActivityLogs = () => {
  const [logs, setLogs] = useState<ActivityLog[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalItems, setTotalItems] = useState(0);

  const fetchLogs = useCallback(async (
    page: number = 1, 
    filters: ActivityLogFilters = {}
  ) => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await activityLogService.getActivityLogs(page, 20, filters);
      
      setLogs(response.logs);
      setCurrentPage(response.pagination.currentPage);
      setTotalPages(response.pagination.totalPages);
      setTotalItems(response.pagination.totalItems);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to fetch activity logs');
    } finally {
      setLoading(false);
    }
  }, []);

  const refreshLogs = useCallback(() => {
    fetchLogs(currentPage);
  }, [fetchLogs, currentPage]);

  return {
    logs,
    loading,
    error,
    currentPage,
    totalPages,
    totalItems,
    fetchLogs,
    refreshLogs,
    setCurrentPage
  };
};