export interface ActivityLog {
  _id: string;
  userId: {
    _id: string;
    name: string;
    email: string;
    role: string;
  } | null;
  userEmail: string;
  userRole: 'user' | 'admin' | 'super_admin';
  action: string;
  resource: string;
  resourceId?: string;
  details: Record<string, any>;
  ipAddress: string;
  userAgent: string;
  timestamp: string;
  metadata?: Record<string, any>;
}

export interface ActivityLogFilters {
  userId?: string;
  action?: string;
  resource?: string;
  startDate?: string;
  endDate?: string;
  search?: string;
}

export interface ActivityLogResponse {
  logs: ActivityLog[];
  pagination: {
    currentPage: number;
    totalPages: number;
    totalItems: number;
    itemsPerPage: number;
    hasNextPage: boolean;
    hasPrevPage: boolean;
  };
}

export interface ActivityStats {
  dailyStats: Array<{
    _id: { action: string; date: string };
    count: number;
  }>;
  actionStats: Array<{
    _id: string;
    count: number;
  }>;
  resourceStats: Array<{
    _id: string;
    count: number;
  }>;
}