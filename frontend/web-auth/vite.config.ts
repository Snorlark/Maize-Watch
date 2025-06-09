import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
// Updated to use live backend URL
//http://localhost:8080
//https://maize-watch.onrender.com
export default defineConfig({
  plugins: [
    tailwindcss(),
  ],
  server: {
    proxy: {
      // Proxy all /api requests to your live backend
      '/api': {
        target: 'https://maize-watch.onrender.com',
        changeOrigin: true,
        secure: true,
      }
    }
  }
})