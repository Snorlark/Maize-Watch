import { defineConfig } from 'vite'
import tailwindcss from '@tailwindcss/vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    tailwindcss(),
  ],
  base: '/', // Ensure base path is set correctly for static hosting
  publicDir: 'public', // Explicitly set public directory
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
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
              entryFileNames: 'assets/[name]-[hash].js',
              // Split large chunks
              manualChunks: {
                vendor: ['react', 'react-dom'],
                router: ['react-router-dom'],
                icons: ['lucide-react', 'react-icons'],
                charts: ['recharts'],
                utils: ['axios', 'date-fns']
              }
            }
          },
          // Increase chunk size warning limit
          chunkSizeWarningLimit: 1000
        },
  // Add this to ensure public assets are served correctly in development
  optimizeDeps: {
    exclude: ['lucide-react']
  },
  // Ensure static assets are properly handled
  assetsInclude: ['**/*.png', '**/*.jpg', '**/*.jpeg', '**/*.gif', '**/*.svg', '**/*.webp'],
  // Suppress "use client" warnings
  esbuild: {
    logOverride: { 'this-is-undefined-in-esm': 'silent' }
  }
})