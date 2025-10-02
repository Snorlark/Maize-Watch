# 🚀 Maize-Watch Deployment Checklist

## Current Issues (Still Occurring)
- ❌ CORS: `Access-Control-Allow-Origin` header missing
- ❌ Images: All PNG files returning 404
- ❌ Backend: `net::ERR_FAILED` suggests backend connection issues

## ✅ Fixes Applied (Need Deployment)

### 1. Backend CORS Configuration
**File**: `backend/src/server.ts`
**Changes**: Added production frontend URL to CORS origins
```typescript
const allowedOrigins = [
  "http://localhost:3000",
  "http://localhost:5173", 
  "https://maize-watch-rdcy.onrender.com", // ← ADDED
  process.env.FRONTEND_URL,
];
```

### 2. Static File Serving
**File**: `backend/src/server.ts`
**Changes**: Added middleware to serve frontend assets
```typescript
app.use('/web-public', express.static('frontend/web-src/web-public/public'));
app.use('/web-admin', express.static('frontend/web-src/web-admin/public'));
```

## 🔧 Immediate Actions Required

### Step 1: Verify Backend Deployment
1. **Check if backend is running**: Visit `https://maize-watch.onrender.com/api/health` (if health endpoint exists)
2. **Check deployment logs** on Render dashboard
3. **Verify environment variables** are set correctly

### Step 2: Required Environment Variables
Set these in your Render backend service:
```
FRONTEND_URL=https://maize-watch-rdcy.onrender.com
NODE_ENV=production
MONGODB_URI=<your-mongodb-uri>
JWT_SECRET=<your-jwt-secret>
```

### Step 3: Deploy Backend
1. **Push changes** to your deployment branch
2. **Trigger redeploy** on Render
3. **Wait for build completion**

### Step 4: Verify File Structure
Ensure your backend deployment includes:
```
backend/
├── src/
├── frontend/
│   └── web-src/
│       ├── web-public/
│       │   └── public/
│       │       └── images/ ← All PNG files should be here
│       └── web-admin/
│           └── public/
```

## 🧪 Testing Steps

### Test 1: CORS Fix
Try this in browser console on your frontend:
```javascript
fetch('https://maize-watch.onrender.com/api/auth/login', {
  method: 'OPTIONS'
}).then(r => console.log('CORS headers:', r.headers));
```

### Test 2: Static Files
Try accessing: `https://maize-watch.onrender.com/web-public/images/smiley.png`

### Test 3: API Health
Try accessing: `https://maize-watch.onrender.com/api/` (should return some response)

## 🚨 If Issues Persist

### Backend Not Responding
- Check Render logs for build/runtime errors
- Verify PORT environment variable (should be set by Render)
- Check if backend service is sleeping (free tier limitation)

### CORS Still Failing
- Verify the exact frontend URL matches what's in CORS config
- Check if changes were actually deployed
- Add wildcard temporarily for testing: `origin: "*"`

### Images Still 404
- Verify file paths in deployment
- Check if static middleware is before API routes
- Test direct file access via backend URL

## 📞 Quick Debug Commands

### Check Backend Status
```bash
curl -I https://maize-watch.onrender.com/api/
```

### Check Static Files
```bash
curl -I https://maize-watch.onrender.com/web-public/images/smiley.png
```

### Check CORS Headers
```bash
curl -H "Origin: https://maize-watch-rdcy.onrender.com" \
     -H "Access-Control-Request-Method: POST" \
     -X OPTIONS \
     https://maize-watch.onrender.com/api/auth/login
```

## 🎯 Expected Results After Fix
- ✅ Login should work without CORS errors
- ✅ All images should load correctly
- ✅ API calls should succeed
- ✅ No 404 errors for static assets
