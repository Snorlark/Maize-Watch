import axios from "axios";
import authService from "./authService";

const API_BASE = import.meta.env.VITE_API_URL || (import.meta.env.DEV ? "http://localhost:8080/api" : "https://maize-watch-backend.onrender.com/api");

export interface Sensor {
  _id: string;
  deviceID: string;
  sensorName: string;
  description: string;
  soilType: string;
  readings: {
    soilMoisture: number;
    temperature: number;
    humidity: number;
    lightIntensity: number;
    soilPh: number;
  };
}

export interface Field {
  _id: string;
  fieldName: string;
  plantingDate: string;
  growthStage: string;
  sensors: Sensor[];
}

// Legacy farm structure (your actual database)
export interface LegacyFarm {
  _id: string;
  userId: string;
  farmName?: string; // Add farmName as optional for compatibility
  fieldName: string;
  location: string;
  soilType: string;
  plantingDate: string;
  growthStage: string;
  fields?: Field[]; // Add fields as optional for compatibility
  createdAt: string;
  updatedAt: string;
  __v?: number;
}

// New farm structure (for future use)
export interface Farm {
  _id: string;
  userId: string;
  farmName: string;
  location: string;
  fields: Field[];
  createdAt: string;
  updatedAt: string;
  __v?: number;
}

// Use legacy structure for now
export type CurrentFarm = LegacyFarm;

export interface FarmAssignmentData {
  fieldName: string;
  location: string;
  soilType: string;
  plantingDate: string;
  growthStage: string;
}

export const farmService = {
  getTotalFarms: async (): Promise<number> => {
    if (!authService.isAuthenticated()) {
      throw new Error("Not authenticated");
    }

    const token = authService.getToken();

    const res = await axios.get(`${API_BASE}/farms/total`, {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json"
      }
    });

    return res.data.total;
  },

  // Get farms by user ID
  getFarmsByUserId: async (userId: string): Promise<Farm[]> => {
    if (!authService.isAuthenticated()) {
      throw new Error("Not authenticated");
    }

    const token = authService.getToken();

    const res = await axios.get(`${API_BASE}/farms?owner=${userId}`, {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json"
      }
    });

    return res.data.data?.farms || [];
  },

  // Get all farms (admin only)
  getAllFarms: async (): Promise<Farm[]> => {
    if (!authService.isAuthenticated()) {
      throw new Error("Not authenticated");
    }

    const token = authService.getToken();

    const res = await axios.get(`${API_BASE}/farms?all=true`, {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json"
      }
    });

    return res.data.data?.farms || [];
  },

  // Assign farm to user
  assignFarmToUser: async (userId: string, farmData: FarmAssignmentData): Promise<Farm> => {
    if (!authService.isAuthenticated()) {
      throw new Error("Not authenticated");
    }

    const token = authService.getToken();

    const res = await axios.post(`${API_BASE}/farms`, {
      userId,
      ...farmData
    }, {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json"
      }
    });

    return res.data.data.farm;
  },

  // Update farm
  updateFarm: async (farmId: string, farmData: Partial<FarmAssignmentData>): Promise<Farm> => {
    if (!authService.isAuthenticated()) {
      throw new Error("Not authenticated");
    }

    const token = authService.getToken();

    const res = await axios.put(`${API_BASE}/farms/${farmId}`, farmData, {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json"
      }
    });

    return res.data.data.farm;
  },

  // Delete farm
  deleteFarm: async (farmId: string): Promise<void> => {
    if (!authService.isAuthenticated()) {
      throw new Error("Not authenticated");
    }

    const token = authService.getToken();

    await axios.delete(`${API_BASE}/farms/${farmId}`, {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json"
      }
    });
  },

  // Reassign farm to different user
  reassignFarm: async (farmId: string, newUserId: string): Promise<Farm> => {
    if (!authService.isAuthenticated()) {
      throw new Error("Not authenticated");
    }

    const token = authService.getToken();

    console.log('Making API call to reassign farm:', {
      url: `${API_BASE}/farms/${farmId}`,
      payload: { userId: newUserId },
      token: token ? 'Present' : 'Missing'
    });

    try {
      const res = await axios.put(`${API_BASE}/farms/${farmId}`, {
        userId: newUserId
      }, {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json"
        },
        timeout: 10000 // 10 second timeout
      });

      console.log('API response:', res.data);
      return res.data.data.farm;
    } catch (error: any) {
      console.error('API call failed:', {
        status: error.response?.status,
        statusText: error.response?.statusText,
        data: error.response?.data,
        message: error.message
      });
      throw error;
    }
  },

  // Get all farms with user details for assignment management
  getAllFarmsWithUsers: async (): Promise<CurrentFarm[]> => {
    if (!authService.isAuthenticated()) {
      throw new Error("Not authenticated");
    }

    const token = authService.getToken();

    const res = await axios.get(`${API_BASE}/farms`, {
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json"
      }
    });

    return res.data.data?.farms || [];
  },

  // Get farm by ID for testing
  getFarmById: async (farmId: string): Promise<Farm> => {
    if (!authService.isAuthenticated()) {
      throw new Error("Not authenticated");
    }

    const token = authService.getToken();

    console.log('Making GET request for farm:', {
      url: `${API_BASE}/farms/${farmId}`,
      token: token ? 'Present' : 'Missing'
    });

    try {
      const res = await axios.get(`${API_BASE}/farms/${farmId}`, {
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json"
        },
        timeout: 10000
      });

      console.log('GET farm response:', res.data);
      return res.data.data.farm;
    } catch (error: any) {
      console.error('GET farm failed:', {
        status: error.response?.status,
        statusText: error.response?.statusText,
        data: error.response?.data,
        message: error.message
      });
      throw error;
    }
  }
};
