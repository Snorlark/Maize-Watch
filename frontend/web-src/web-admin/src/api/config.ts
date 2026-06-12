// API Configuration
export const API_CONFIG = {
  baseUrl: 'https://maize-watch.onrender.com',
  endpoints: {
    historical: '/api/sensors/historical',
    weekly: '/api/sensors/weekly-overview',
    latest: '/api/sensors/latest'
  }
};

// Chart thresholds and colors
export const CHART_CONFIG = {
  temperature: {
    thresholds: {
      min: 20,
      max: 30,
      critical: 35
    },
    colors: {
      primary: "#F97316", // Orange-500
      min: "#FDBA74", // Orange-300
      max: "#EA580C", // Orange-600
      critical: "#C2410C", // Orange-700
      background: "#FFF7ED", // Orange-50
      text: "#C2410C", // Orange-700
      trend: {
        up: "#22C55E", // Green-500
        down: "#EF4444", // Red-500
        neutral: "#6B7280", // Gray-500
      }
    }
  },
  humidity: {
    thresholds: {
      min: 60,
      max: 80,
      critical: 90
    },
    colors: {
      primary: "#2196F3", // Blue-500
      min: "#60A5FA", // Blue-400
      max: "#1D4ED8", // Blue-700
      critical: "#1E40AF", // Blue-800
      background: "#EFF6FF", // Blue-50
      text: "#1E40AF", // Blue-800
      trend: {
        up: "#22C55E", // Green-500
        down: "#EF4444", // Red-500
        neutral: "#6B7280", // Gray-500
      }
    }
  },
  soilMoisture: {
    thresholds: {
      min: 40,
      max: 70,
      critical: 85
    },
    colors: {
      primary: "#10B981", // Emerald-500
      min: "#34D399", // Emerald-400
      max: "#047857", // Emerald-700
      critical: "#064E3B", // Emerald-800
      background: "#ECFDF5", // Emerald-50
      text: "#064E3B", // Emerald-800
      trend: {
        up: "#22C55E", // Green-500
        down: "#EF4444", // Red-500
        neutral: "#6B7280", // Gray-500
      }
    }
  },
  soilPh: {
    thresholds: {
      min: 6.0,
      max: 7.0,
      critical: 7.5
    },
    colors: {
      primary: "#8B5CF6", // Violet-500
      min: "#A78BFA", // Violet-400
      max: "#6D28D9", // Violet-700
      critical: "#5B21B6", // Violet-800
      background: "#F5F3FF", // Violet-50
      text: "#5B21B6", // Violet-800
      trend: {
        up: "#22C55E", // Green-500
        down: "#EF4444", // Red-500
        neutral: "#6B7280", // Gray-500
      }
    }
  },
  lightIntensity: {
    thresholds: {
      min: 5000,
      max: 10000,
      critical: 12000
    },
    colors: {
      primary: "#F59E0B", // Amber-500
      min: "#FCD34D", // Amber-300
      max: "#B45309", // Amber-700
      critical: "#92400E", // Amber-800
      background: "#FFFBEB", // Amber-50
      text: "#92400E", // Amber-800
      trend: {
        up: "#22C55E", // Green-500
        down: "#EF4444", // Red-500
        neutral: "#6B7280", // Gray-500
      }
    }
  }
};

// Utility functions for date handling
export const dateUtils = {
  getStartOfWeek: (date: Date): Date => {
    const result = new Date(date);
    result.setDate(date.getDate() - date.getDay()); // Set to Sunday
    result.setHours(0, 0, 0, 0);
    return result;
  },

  getEndOfWeek: (date: Date): Date => {
    const result = new Date(date);
    result.setDate(date.getDate() + (6 - date.getDay())); // Set to Saturday
    result.setHours(23, 59, 59, 999);
    return result;
  },

  formatDateRange: (start: Date, end: Date): string => {
    return `${start.toLocaleDateString()} - ${end.toLocaleDateString()}`;
  },

  isValidWeekRange: (start: Date, end: Date): boolean => {
    return start.getDay() === 0 && end.getDay() === 6 && 
           end.getTime() - start.getTime() === 6 * 24 * 60 * 60 * 1000;
  }
};