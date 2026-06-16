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
  base: '/', // Ensure base path is set correctly for static hosting
  publicDir: 'public', // Explicitly set public directory
  server: {
    proxy: {
      '/api': {
        target: process.env.VITE_API_URL || 'http://localhost:3001',
        changeOrigin: true,
        secure: false,
      }
    },
    // Ensure static files are served correctly
    fs: {
      strict: false
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    // Copy public assets to dist root (includes _headers and _redirects)
    copyPublicDir: true,
    rollupOptions: {
      output: {
        assetFileNames: 'assets/[name]-[hash][extname]',
        chunkFileNames: 'assets/[name]-[hash].js',
        entryFileNames: 'assets/[name]-[hash].js'
      }
    }
  }
})