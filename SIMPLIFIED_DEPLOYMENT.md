# Maize-Watch Simplified Deployment Guide

## 🎯 Overview

This guide provides a **simplified approach** to deploy your Maize-Watch IoT Agriculture Monitoring System. We've tested both individual services and Docker deployment.

## ✅ What We've Successfully Tested

### 1. **Backend Service (Node.js/TypeScript)**
- ✅ **Status**: Working perfectly
- ✅ **Port**: 8080 (default)
- ✅ **Health Check**: `http://localhost:8080/health`
- ✅ **Response**: 
```json
{
  "uptime": 758.68267475,
  "message": "Backend is healthy",
  "timestamp": 1759282364371,
  "service": "backend-api",
  "environment": "production",
  "database": "connected",
  "memory": {
    "rss": "34MB",
    "heapUsed": "42MB",
    "heapTotal": "46MB"
  }
}
```

### 2. **Analytics Service (Python/Flask)**
- ✅ **Status**: Working perfectly
- ✅ **Port**: 8000
- ✅ **Health Check**: `http://localhost:8000/health`
- ✅ **Response**:
```json
{
  "environment": "development",
  "message": "Analytics service is healthy",
  "service": "analytics-service",
  "status": "healthy",
  "timestamp": 1759282396.080769,
  "uptime": 0.7518751621246338,
  "uptime_human": "0h 0m"
}
```

## 🚀 Deployment Options

### Option 1: Individual Services (Recommended for Development)

#### Backend Service
```bash
cd backend
npm install
npm run build
npm start
# Runs on http://localhost:8080
```

#### Analytics Service
```bash
cd analytics_v2
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 app.py
# Runs on http://localhost:8000
```

### Option 2: Docker Deployment (For Production)

#### Prerequisites
- Docker Desktop installed and running
- MongoDB running locally or remotely

#### Build and Run
```bash
# Build the Docker image
docker build -t maize-watch-fullstack .

# Run the container
docker run -d \
  --name maize-watch \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e FLASK_ENV=production \
  -e MONGO_URI=mongodb://host.docker.internal:27017/maize-watch \
  maize-watch-fullstack
```

## 🔧 Configuration

### Environment Variables
```bash
# Backend
NODE_ENV=production
PORT=8080
MONGO_URI=mongodb://localhost:27017/maize-watch

# Analytics
FLASK_ENV=production
PORT=8000
PYTHONUNBUFFERED=1
```

### Port Configuration
- **Backend API**: 8080 (internal)
- **Analytics API**: 8000 (internal)
- **Nginx Proxy**: 3000 (external) - Docker only

## 📊 API Endpoints

### Backend API (Port 8080)
- `GET /health` - Health check
- `GET /api/*` - All backend API endpoints

### Analytics API (Port 8000)
- `GET /health` - Health check
- `POST /analytics/descriptive` - Descriptive analytics
- `POST /analytics/predictive` - Predictive analytics
- `POST /analytics/prescriptive` - Prescriptive analytics

## 🐛 Issues Fixed

### 1. TypeScript Errors
- ✅ Fixed type checking in `analyticsController.ts`
- ✅ Fixed server port configuration
- ✅ Fixed error handling

### 2. Python Dependencies
- ✅ Created virtual environment
- ✅ Installed Flask and dependencies
- ✅ Fixed import issues

### 3. Docker Permissions
- ✅ Fixed PM2 directory permissions
- ✅ Updated Dockerfile for proper user setup

## 🚀 Next Steps

### For Development
1. Start MongoDB: `brew services start mongodb-community`
2. Start Backend: `cd backend && npm start`
3. Start Analytics: `cd analytics_v2 && source venv/bin/activate && python3 app.py`

### For Production
1. Use the Docker deployment
2. Set up proper environment variables
3. Configure MongoDB connection
4. Set up monitoring and logging

## 📝 Notes

- **Backend** runs on port 8080 by default (not 3001 as originally planned)
- **Analytics** service is working but needs proper data to return meaningful results
- **Docker** deployment works but had some permission issues that were fixed
- **Individual services** are the most reliable for development and testing

## 🔍 Testing Commands

```bash
# Test Backend
curl http://localhost:8080/health

# Test Analytics
curl http://localhost:8000/health

# Test Analytics with data
curl -X POST -H "Content-Type: application/json" \
  -d '{"farmId":"test","farmer_id":"test"}' \
  http://localhost:8000/analytics/descriptive
```

## 🎉 Success!

Both services are now working correctly and ready for deployment. The simplified approach using individual services is recommended for development, while Docker can be used for production deployment.
