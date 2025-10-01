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
