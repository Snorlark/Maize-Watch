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
      // Proxy all /api requests to your live backend
      '/api': {
        target: 'https://maize-watch-rdcy.onrender.com',
        changeOrigin: true,
        secure: true,
      }
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    // Copy public assets to dist root
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