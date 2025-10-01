# Maize-Watch Full-Stack Docker Deployment Guide

## 🎯 Overview

This guide deploys your Maize-Watch IoT Agriculture Monitoring System as a single Docker container containing:
- 🟢 **Node.js Backend** (TypeScript/Express) - Port 3001
- 🐍 **Python Analytics** (Flask/Gunicorn) - Port 8000  
- 🌐 **Nginx Reverse Proxy** - Port 3000 (external)
- 🔄 **PM2 Process Manager** - Keeps services running

**Total Cost: $7/month** (vs $21+ for separate services)

## 📁 Project Structure

```
Maize-Watch/
├── backend/                 # Node.js TypeScript API
│   ├── src/
│   ├── package.json
│   └── dist/               # Built JavaScript
├── analytics_v2/           # Python Analytics Service
│   ├── src/
│   ├── app.py             # NEW: Flask web server
│   └── requirements.txt
├── nginx/                  # Traffic routing
│   └── nginx.conf
├── scripts/                # Container orchestration
│   ├── start.sh
│   └── ecosystem.config.js
├── Dockerfile             # Multi-service container
├── package.json           # Root PM2 configuration
├── .dockerignore
└── DEPLOYMENT_GUIDE.md
```

## 🚀 Quick Start

### 1. Local Testing (5 minutes)

```bash
# Build the Docker image
docker build -t maize-watch-fullstack .

# Run the container
docker run -p 3000:3000 \
  -e NODE_ENV=production \
  -e FLASK_ENV=production \
  -e MONGO_URI=your_mongodb_connection_string \
  --name maize-watch-test \
  maize-watch-fullstack
```

### 2. Test Endpoints

```bash
# Health check
curl http://localhost:3000/health

# Backend API
curl http://localhost:3000/api/health

# Analytics service
curl http://localhost:3000/analytics/health

# Your actual endpoints
curl http://localhost:3000/api/users
curl http://localhost:3000/analytics/status
```

### 3. Deploy to Render

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Add Docker multi-service deployment"
   git push origin main
   ```

2. **Create Render Service:**
   - Go to [render.com](https://render.com)
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Configure:
     ```
     Name: maize-watch-fullstack
     Runtime: Docker
     Region: Choose closest to you
     Branch: main
     Build Command: (leave empty)
     Start Command: (leave empty)
     ```

3. **Set Environment Variables:**
   ```
   NODE_ENV=production
   FLASK_ENV=production
   MONGO_URI=your_mongodb_connection_string
   JWT_SECRET=your_jwt_secret_here
   # Add any other variables your apps need
   ```

4. **Deploy:**
   - Click "Create Web Service"
   - Wait for build to complete (~5-10 minutes)
   - Your app will be live at `https://maize-watch-fullstack.onrender.com`

## 🔧 Configuration Details

### Port Configuration

| Service | Internal Port | External Access |
|---------|---------------|-----------------|
| Nginx   | 3000         | `https://your-app.onrender.com` |
| Backend | 3001         | `https://your-app.onrender.com/api/*` |
| Analytics | 8000       | `https://your-app.onrender.com/analytics/*` |

### URL Routing

```
https://your-app.onrender.com/
├── /health                    → Nginx health check
├── /api/*                     → Node.js Backend (port 3001)
│   ├── /api/health           → Backend health check
│   ├── /api/users            → Your API endpoints
│   └── /api/...              → All other API routes
└── /analytics/*               → Python Analytics (port 8000)
    ├── /analytics/health     → Analytics health check
    ├── /analytics/descriptive → Analytics endpoints
    ├── /analytics/predictive
    ├── /analytics/prescriptive
    └── /analytics/complete
```

### Environment Variables

**Required:**
- `MONGO_URI` - MongoDB connection string
- `NODE_ENV=production` - Backend environment
- `FLASK_ENV=production` - Analytics environment

**Optional:**
- `JWT_SECRET` - For authentication
- `REDIS_URL` - For caching (if you add Redis)
- `API_KEY` - For external services
- Any other variables your apps use

## 🐳 Docker Configuration

### Dockerfile Breakdown

1. **Base Image:** Ubuntu 22.04 (supports both Node.js and Python)
2. **System Dependencies:** curl, wget, python3, nginx, build tools
3. **Node.js 18:** Latest LTS version
4. **PM2:** Process manager for both services
5. **Dependencies:** Install Node.js and Python packages
6. **Code Copy:** Copy application code
7. **Nginx Config:** Set up reverse proxy
8. **Security:** Run as non-root user
9. **Health Check:** Monitor service health
10. **Startup:** Run orchestration script

### Container Architecture

```
Docker Container
├── Nginx (Port 3000) - Traffic Director
│   ├── Routes /api/* → Backend
│   ├── Routes /analytics/* → Analytics
│   └── Health check endpoint
├── Node.js Backend (Port 3001)
│   ├── Express.js API
│   ├── TypeScript compiled to JavaScript
│   └── MongoDB connection
├── Python Analytics (Port 8000)
│   ├── Flask web server
│   ├── Gunicorn WSGI server
│   └── Analytics processing
└── PM2 Process Manager
    ├── Keeps all services running
    ├── Auto-restart on crashes
    └── Log management
```

## 🔍 Monitoring & Debugging

### Health Checks

**Main Health Check:**
```bash
curl https://your-app.onrender.com/health
# Returns: "All services healthy"
```

**Individual Service Health:**
```bash
# Backend health
curl https://your-app.onrender.com/api/health
# Returns: JSON with uptime, memory, database status

# Analytics health  
curl https://your-app.onrender.com/analytics/health
# Returns: JSON with uptime, service status
```

### Logs

**In Render Dashboard:**
1. Go to your service
2. Click "Logs" tab
3. View real-time logs from all services

**Log Format:**
```
2024-01-15T10:30:00Z backend | 🟢 Backend API listening on port 3001
2024-01-15T10:30:01Z analytics | 🐍 Analytics service starting on port 8000
2024-01-15T10:30:05Z backend | GET /api/users 200 45ms
```

### Common Issues

**1. Service Unhealthy:**
- Check logs for error messages
- Verify environment variables are set
- Ensure MongoDB connection string is correct

**2. 502 Bad Gateway:**
- Backend or Analytics service not running
- Check PM2 status in logs
- Verify port configuration

**3. 404 Not Found:**
- Check Nginx routing configuration
- Verify URL paths match your API routes
- Ensure services are listening on correct ports

## 🚀 Advanced Features

### Adding Redis Cache (Optional)

1. **Create Redis service in Render:**
   - Click "New +" → "Redis"
   - Choose free tier
   - Copy Redis URL

2. **Add to environment variables:**
   ```
   REDIS_URL=redis://red-xxxxx:6379
   ```

3. **Update your code to use Redis:**
   - Backend: Add Redis client
   - Analytics: Add Redis client
   - Implement caching strategies

### Custom Domain

1. **In Render Dashboard:**
   - Go to your service
   - Click "Settings"
   - Add your custom domain
   - Update DNS records

2. **Update CORS settings:**
   - Update `FRONTEND_URL` environment variable
   - Update CORS configuration in backend

### Scaling

**Current Setup:**
- 1 container with 2 services
- 512MB RAM (Starter plan)
- Good for moderate traffic

**To Scale:**
- Upgrade to higher Render plan
- Add more memory/CPU
- Consider separate services for high traffic
- Add load balancing

## 📊 Performance Optimization

### Docker Build Optimization

**Current Dockerfile is optimized for:**
- Layer caching (dependencies installed before code copy)
- Minimal image size (removes package caches)
- Security (non-root user)
- Health monitoring

### Service Optimization

**Backend (Node.js):**
- Uses PM2 for process management
- Memory limit: 500MB (auto-restart if exceeded)
- Graceful shutdown handling

**Analytics (Python):**
- Uses Gunicorn with 2 workers
- Memory limit: 1GB (auto-restart if exceeded)
- Unbuffered output for better logging

**Nginx:**
- Reverse proxy with connection pooling
- Gzip compression (if enabled)
- Timeout handling

## 🔒 Security Features

### Built-in Security

1. **Non-root user:** Container runs as `appuser`
2. **Helmet.js:** Security headers in backend
3. **CORS:** Configured for your frontend
4. **Rate limiting:** Express rate limiter
5. **Input validation:** Express validator
6. **Environment variables:** Secrets not in code

### Production Checklist

- [ ] All secrets in environment variables
- [ ] CORS configured for your domain
- [ ] Rate limiting enabled
- [ ] Input validation on all endpoints
- [ ] Health checks working
- [ ] Logs being captured
- [ ] Database connection secure
- [ ] HTTPS enabled (automatic on Render)

## 🎉 Success!

Your Maize-Watch application is now deployed as a professional, production-ready full-stack service!

**What you've accomplished:**
- ✅ Multi-service Docker container
- ✅ Professional traffic routing with Nginx
- ✅ Process management with PM2
- ✅ Health monitoring and auto-restart
- ✅ Production deployment on Render
- ✅ Cost-effective solution ($7/month)

**Next steps:**
- Monitor your application in Render dashboard
- Set up custom domain (optional)
- Add Redis caching (optional)
- Scale as your user base grows

**Support:**
- Check Render logs for debugging
- Review this guide for configuration
- Monitor health endpoints for status

---

*Built with ❤️ for the Maize-Watch IoT Agriculture Monitoring System*
