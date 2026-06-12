# 🚀 Deployment Solution - Separate Services

## 🚨 Current Problem
- **Images not loading**: Backend not serving static files
- **Admin login failing**: Backend API endpoints returning 404
- **Root cause**: Trying to deploy monorepo to single service incorrectly

## ✅ Recommended Solution: Two Separate Services

### **Service 1: Backend API**
**Deploy**: `backend/` folder to new Render service

**Settings**:
- **Name**: `maize-watch-backend`
- **Root Directory**: `backend`
- **Build Command**: `npm install && npm run build`
- **Start Command**: `npm start`
- **Environment Variables**:
  ```
  NODE_ENV=production
  FRONTEND_URL=https://maize-watch-frontend.onrender.com
  MONGODB_URI=<your-mongodb-uri>
  JWT_SECRET=<your-jwt-secret>
  EMAIL_HOST=<smtp-host>
  EMAIL_PORT=<smtp-port>
  EMAIL_USER=<smtp-username>
  EMAIL_PASS=<smtp-password>
  EMAIL_FROM=<from-email>
  ```

### **Service 2: Frontend (Web-Public)**
**Deploy**: `frontend/web-src/web-public/` folder to new Render service

**Settings**:
- **Name**: `maize-watch-frontend`
- **Root Directory**: `frontend/web-src/web-public`
- **Build Command**: `npm install && npm run build`
- **Publish Directory**: `dist`
- **Environment Variables**:
  ```
  VITE_API_BASE_URL=https://maize-watch-backend.onrender.com
  VITE_APP_ENV=production
  ```

### **Service 3: Admin Panel (Optional)**
**Deploy**: `frontend/web-src/web-admin/` folder to new Render service

**Settings**:
- **Name**: `maize-watch-admin`
- **Root Directory**: `frontend/web-src/web-admin`
- **Build Command**: `npm install && npm run build`
- **Publish Directory**: `dist`
- **Environment Variables**:
  ```
  VITE_API_BASE_URL=https://maize-watch-backend.onrender.com
  VITE_APP_ENV=production
  ```

## 🔧 Configuration Updates Needed

### 1. Update Backend CORS
```typescript
// backend/src/server.ts
const allowedOrigins = [
  "http://localhost:3000",
  "http://localhost:5173", 
  "https://maize-watch-frontend.onrender.com", // Frontend
  "https://maize-watch-admin.onrender.com",    // Admin
  process.env.FRONTEND_URL,
];
```

### 2. Update Frontend API URLs
```typescript
// frontend/web-src/web-public/src/api/client.ts
const API_BASE_URL = isDevelopment 
  ? 'http://localhost:8080' 
  : 'https://maize-watch-backend.onrender.com';
```

```typescript
// frontend/web-src/web-admin/src/api/client.ts
const API_BASE_URL = isDevelopment 
  ? 'http://localhost:8080' 
  : 'https://maize-watch-backend.onrender.com';
```

### 3. Remove Static File Serving from Backend
Since images will be served by frontend service:
```typescript
// backend/src/server.ts - REMOVE these lines:
// app.use('/web-public', express.static('frontend/web-src/web-public/public'));
// app.use('/web-admin', express.static('frontend/web-src/web-admin/public'));
```

## 🎯 Expected Results

### After Deployment:
- **Backend**: `https://maize-watch-backend.onrender.com/api/health` → 200 OK
- **Frontend**: `https://maize-watch-frontend.onrender.com/` → Website loads
- **Admin**: `https://maize-watch-admin.onrender.com/` → Admin panel loads
- **Images**: Served directly by frontend services
- **Login**: Works through backend API

## 📋 Step-by-Step Deployment

### Step 1: Create Backend Service
1. Go to Render Dashboard
2. New → Web Service
3. Connect GitHub repo
4. Root Directory: `backend`
5. Configure as above

### Step 2: Create Frontend Service
1. New → Static Site
2. Connect same GitHub repo
3. Root Directory: `frontend/web-src/web-public`
4. Configure as above

### Step 3: Create Admin Service (Optional)
1. New → Static Site
2. Connect same GitHub repo
3. Root Directory: `frontend/web-src/web-admin`
4. Configure as above

### Step 4: Update Code
1. Update API URLs in frontend code
2. Update CORS in backend
3. Commit and push changes
4. Services will auto-redeploy

## 🧪 Testing
After deployment:
1. Test backend: `curl https://maize-watch-backend.onrender.com/api/health`
2. Test frontend: Visit frontend URL
3. Test admin login: Visit admin URL and try login
4. Verify images load correctly

This approach separates concerns and makes deployment much more reliable!
