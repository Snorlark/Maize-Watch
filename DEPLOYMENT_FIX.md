# 🚨 Deployment Fix Guide

## Problem Identified
- ❌ Backend API returning 404 for all endpoints
- ❌ Images not loading (static files not served)
- ❌ Login failing with 404 error

## Root Cause
**Monorepo deployment misconfiguration** - You're trying to deploy both frontend and backend to the same Render service without proper orchestration.

## ✅ Solution Applied

### 1. Created Root Package.json
- Added build scripts to compile both backend and frontend
- Added start script to run backend server
- Configured to serve frontend static files through backend

### 2. Created Render Configuration
- `render.yaml` file for proper deployment
- Configured build and start commands
- Set environment variables

### 3. Deployment Structure
```
maize-watch-rdcy.onrender.com/
├── /api/              ← Backend API endpoints
├── /web-public/       ← Static files from frontend
├── /                  ← Frontend app (served by backend)
```

## 🚀 Deployment Steps

### Step 1: Commit Changes
```bash
git add .
git commit -m "Add monorepo deployment configuration"
git push origin main
```

### Step 2: Configure Render Service
In your Render dashboard:

**Build Command**: `npm run build`
**Start Command**: `npm start`

**Environment Variables**:
```
NODE_ENV=production
FRONTEND_URL=https://maize-watch-rdcy.onrender.com
MONGODB_URI=<your-mongodb-uri>
JWT_SECRET=<your-jwt-secret>
EMAIL_HOST=<smtp-host>
EMAIL_PORT=<smtp-port>
EMAIL_USER=<smtp-username>
EMAIL_PASS=<smtp-password>
EMAIL_FROM=<from-email>
```

### Step 3: Deploy
- Trigger manual deploy in Render dashboard
- Monitor build logs for errors
- Wait for deployment completion

## 🧪 Expected Results After Fix

### API Endpoints
- ✅ `https://maize-watch-rdcy.onrender.com/api/health` → 200 OK
- ✅ `https://maize-watch-rdcy.onrender.com/api/auth/login` → POST endpoint available
- ✅ `https://maize-watch-rdcy.onrender.com/api/test` → 200 OK

### Static Files
- ✅ `https://maize-watch-rdcy.onrender.com/web-public/images/smiley.png` → Image loads
- ✅ All PNG files accessible via `/web-public/images/`

### Frontend
- ✅ Login works without 404 errors
- ✅ Images display correctly
- ✅ API calls succeed

## 🔍 Testing
After deployment, run:
```bash
node debug-deployment.js
```

Should show all green checkmarks.

## 🚨 Alternative: Separate Services
If monorepo deployment fails, consider:
1. **Backend Service**: Deploy `backend/` folder separately
2. **Frontend Service**: Deploy `frontend/web-src/web-public/` separately
3. Update CORS and API URLs accordingly
