import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    tailwindcss(),
  ],
  server: {
    proxy: {
      // Proxy all /auth requests to your backend (for authentication)
      '/auth': {
        target: 'https://maize-watch.onrender.com',
        changeOrigin: true,
        secure: false,
      },
      // Proxy all /api requests to your backend (for data)
      '/api': {
        target: 'https://maize-watch.onrender.com',
        changeOrigin: true,
        secure: false,
      }
    }
  }
})