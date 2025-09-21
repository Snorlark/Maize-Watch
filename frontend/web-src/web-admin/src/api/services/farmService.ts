import apiClient from "../client";  // your axios instance
import axios from "axios";
import authService from "./authService";
const API_BASE = import.meta.env.VITE_API_URL || "http://localhost:8080/api";


// ITOOOOOO AY FOR RENDER BASED HHEHEHE export const farmService = {
//   getTotalFarms: async (): Promise<number> => {
//     if (!authService.isAuthenticated()) {
//       throw new Error("Not authenticated");
//     }

//     const token = authService.getToken();
//     const res = await apiClient.get("/api/farms/total", {
//       headers: {
//         Authorization: `Bearer ${token}`
//       }
//     });

//     return res.data.total; 
//   }
// };


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
  }
};










// mga patapon
// export const farmService = {
//   getTotalFarms: async (): Promise<number> => {
//     if (!authService.isAuthenticated()) {
//       throw new Error("Authentication required");
//     }

//     const response = await apiClient.get("/api/farms/total");
//     return response.data.total;  // matches backend response
//   },
// };

// export const farmService = {
//   getTotalFarms: async (): Promise<number> => {
//     const token = authService.getToken(); // get token from storage/context
//     const res = await apiClient.get("api/farms/total", {
//       headers: {
//         Authorization: `Bearer ${token}`
//       }
//     });
//     return res.data.total;
//   }
// };

// frontend/src/api/services/farmService.ts

// export const farmService = {
//   getTotalFarms: async (): Promise<number> => {
//     const res = await apiClient.get("/api/farms/total");
//     // Make sure backend sends { total: number }
//     return res.data.total; 
//   }
// };


// export const farmService = {
//   getTotalFarms: async (): Promise<number> => {
//     const token = authService.getToken(); // make sure this exists
//     const res = await apiClient.get("/api/farms/total", {
//       headers: {
//         Authorization: `Bearer ${token}`
//       }
//     });
//     return res.data.total;
//   }
// };
