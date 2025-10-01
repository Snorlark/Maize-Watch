#!/bin/bash
# ==========================================
# SHEBANG LINE
# ==========================================
echo "🚀 Starting Maize-Watch full-stack application..."
echo "================================================"
echo "Time: $(date)"
echo "================================================"

# ==========================================
# SECTION 1: Logging and Initialization
# ==========================================
echo "🚀 Starting full-stack application..."
echo "================================================"
echo "Time: $(date)"
echo "================================================"

# ==========================================
# SECTION 2: Test Python Environment
# ==========================================
echo "Testing Python environment..."
cd /app/analytics_v2
python3 test_python.py
echo "✅ Python environment test completed"

# ==========================================
# SECTION 3: Start Nginx
# ==========================================
echo "Starting Nginx reverse proxy..."

# Start Nginx as a background process
nginx -g 'daemon off;' &

# Store Nginx process ID
NGINX_PID=$!
echo "✅ Nginx started (PID: $NGINX_PID)"

# Wait for Nginx to fully start
sleep 3
echo "Nginx is ready on port 10000"

# ==========================================
# SECTION 4: Create PM2 Configuration
# ==========================================
echo "Creating PM2 ecosystem configuration..."

cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'backend',
      cwd: '/app/backend',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      },
      error_file: '/app/logs/backend-error.log',
      out_file: '/app/logs/backend-out.log',
      log_file: '/app/logs/backend.log',
      time: true,
      instances: 1,
      exec_mode: 'fork',
      max_memory_restart: '500M',
      restart_delay: 1000,
      max_restarts: 10,
      min_uptime: '10s'
    },
    {
      name: 'analytics',
      cwd: '/app/analytics_v2',
      script: 'gunicorn',
      args: '--bind 0.0.0.0:8000 --workers 2 --timeout 120 app:app',
      interpreter: 'none',
      env: {
        FLASK_ENV: 'production',
        PORT: 8000,
        PYTHONUNBUFFERED: '1'
      },
      error_file: '/app/logs/analytics-error.log',
      out_file: '/app/logs/analytics-out.log',
      log_file: '/app/logs/analytics.log',
      time: true,
      instances: 1,
      exec_mode: 'fork',
      max_memory_restart: '1G',
      restart_delay: 2000,
      max_restarts: 10,
      min_uptime: '10s'
    }
  ]
};
EOF

# ==========================================
# SECTION 5: Create Logs Directory
# ==========================================
mkdir -p /app/logs
echo "📁 Logs directory created"

# ==========================================
# SECTION 6: Start Services with PM2
# ==========================================
echo "Starting backend and analytics services..."
echo "================================================"

# Ensure PM2 directories exist
mkdir -p ~/.pm2/logs ~/.pm2/pids ~/.pm2/modules

# Start both services
pm2 start ecosystem.config.js

# Wait for services to initialize
sleep 5

# ==========================================
# SECTION 7: Display Status
# ==========================================
echo "================================================"
echo "📊 Service Status:"
echo "================================================"
pm2 list

# ==========================================
# SECTION 8: Keep Container Running
# ==========================================
echo "================================================"
echo "✅ All services started successfully!"
echo "================================================"
echo "🟢 Backend API: http://localhost:3001 (internal)"
echo "🐍 Analytics: http://localhost:8000 (internal)"
echo "🌐 Nginx proxy: http://localhost:10000 (external)"
echo "================================================"
echo "Endpoints:"
echo "  - Health: http://localhost:10000/health"
echo "  - API: http://localhost:10000/api/*"
echo "  - Analytics: http://localhost:10000/analytics/*"
echo "================================================"
echo "Tailing PM2 logs (container will keep running)..."
echo "Press Ctrl+C to stop all services"
echo "================================================"

# Follow PM2 logs in real-time (keeps container alive)
pm2 logs --raw
