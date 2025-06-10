import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
// Updated to use localhost:8080 for development
// http://localhost:8080
// https://maize-watch.onrender.com
export default defineConfig({
  plugins: [
    tailwindcss(),
  ],
  server: {
    // Removed proxy configuration since we're using direct localhost:8080
    // The API client will handle the base URL based on environment
  }
})