# Maize-Watch Deployment Guide

## Issues Fixed

### 1. ✅ CORS Configuration
- **Problem**: Frontend (`https://maize-watch-rdcy.onrender.com`) couldn't access backend (`https://maize-watch.onrender.com`)
- **Solution**: Updated `backend/src/server.ts` to include production frontend URL in CORS origins
- **Code**: Added `"https://maize-watch-rdcy.onrender.com"` to allowed origins

### 2. ✅ Static File Serving
- **Problem**: Images returning 404 errors
- **Solution**: Added static file serving middleware in backend
- **Code**: 
  ```typescript
  app.use('/web-public', express.static('frontend/web-src/web-public/public'));
  app.use('/web-admin', express.static('frontend/web-src/web-admin/public'));
  ```

### 3. ✅ API Configuration
- **Problem**: Frontend API calls not configured for production
- **Solution**: API client already correctly configured with production URL
- **Code**: Uses `https://maize-watch.onrender.com` for production

### 4. ✅ Vite Configuration
- **Problem**: Proxy configuration was rewriting API paths
- **Solution**: Removed path rewriting to maintain `/api` prefix

## Deployment Steps

### Backend Deployment
1. **Environment Variables Required**:
   ```
   FRONTEND_URL=https://maize-watch-rdcy.onrender.com
   NODE_ENV=production
   MONGODB_URI=<your-mongodb-connection-string>
   JWT_SECRET=<your-jwt-secret>
   EMAIL_HOST=<smtp-host>
   EMAIL_PORT=<smtp-port>
   EMAIL_USER=<smtp-username>
   EMAIL_PASS=<smtp-password>
   EMAIL_FROM=<from-email-address>
   ```

2. **Build Command**: `npm run build`
3. **Start Command**: `npm start`

### Frontend Deployment
1. **Build Command**: `npm run build`
2. **Static Files**: Ensure `public/images/` directory is included in deployment

## File Structure for Static Assets
```
backend/
├── frontend/
│   └── web-src/
│       ├── web-public/
│       │   └── public/
│       │       └── images/ (all image assets)
│       └── web-admin/
│           └── public/ (admin assets)
```

## Testing Checklist
- [ ] Backend CORS allows frontend domain
- [ ] Static images load from `/web-public/public/images/`
- [ ] API calls work from frontend to backend
- [ ] Authentication flow works
- [ ] All environment variables set correctly

## URLs
- **Frontend**: https://maize-watch-rdcy.onrender.com
- **Backend**: https://maize-watch.onrender.com
- **API Base**: https://maize-watch.onrender.com/api

## Next Steps
1. Redeploy backend with updated CORS configuration
2. Ensure frontend build includes all static assets
3. Test login flow end-to-end
4. Verify image loading
