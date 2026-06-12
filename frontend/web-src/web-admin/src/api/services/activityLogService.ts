import apiClient from '../client';
import { ActivityLogResponse, ActivityLogFilters, ActivityStats } from '../services/activityLog';

export const activityLogService = {
  async getActivityLogs(
    page: number = 1, 
    limit: number = 20, 
    filters: ActivityLogFilters = {}
  ): Promise<ActivityLogResponse> {
    const params = new URLSearchParams({
      page: page.toString(),
      limit: limit.toString(),
      ...Object.entries(filters)
        .filter(([_, value]) => value !== undefined && value !== '')
        .reduce((acc, [key, value]) => ({ ...acc, [key]: value }), {})
    });

    const response = await apiClient.get(`/activity-logs?${params}`);
    return response.data;
  },

  async getActivityStats(days: number = 30): Promise<ActivityStats> {
    const response = await apiClient.get(`/activity-logs/stats?days=${days}`);
    return response.data;
  }
};