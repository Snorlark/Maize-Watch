// // src/api/client.ts
// import axios from 'axios';

// const apiBaseUrl = 'http://localhost:8080';
// console.log('API Base URL being used:', apiBaseUrl); // Verify URL in console

// const apiClient = axios.create({
//   baseURL: apiBaseUrl,
//   headers: {
//     'Content-Type': 'application/json',
//   },
//   timeout: 10000, // 10 seconds timeout
// });

// // Add auth token to requests if available
// apiClient.interceptors.request.use(
//   (config) => {
//     const token = localStorage.getItem('token');
//     if (token) {
//       config.headers.Authorization = `Bearer ${token}`;
//     }
//     return config;
//   },
//   (error) => {
//     return Promise.reject(error);
//   }
// );

// export default apiClient;

// src/api/client.ts
import axios from 'axios';
import https from 'https';

// const apiBaseUrl = 'https://maize-watch.onrender.com';
const apiBaseUrl = 'http://localhost:8080';
console.log('API Base URL being used:', apiBaseUrl); // Verify URL in console

// Create an HTTPS agent that ignores SSL errors
// const httpsAgent = new https.Agent({
//   rejectUnauthorized: false, // <-- Accept invalid SSL certs
// });

// Create the Axios instance
const apiClient = axios.create({
  baseURL: apiBaseUrl,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 seconds timeout
  // httpsAgent, // <-- Attach the custom HTTPS agent here
});

// Add auth token to requests if available
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export default apiClient;
