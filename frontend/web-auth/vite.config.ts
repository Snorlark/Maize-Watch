import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    tailwindcss(),
  ],
  server: {
    proxy: {
      // Proxy all /auth requests to your backend
      '/auth': {
        target: 'https://maize-watch.onrender.com',
        changeOrigin: true,
        secure: false,
      },
      // Keep existing /api proxy
      '/api': {
        target: 'https://maize-watch.onrender.com',
        changeOrigin: true,
        secure: false,
      }
    }
  }
})