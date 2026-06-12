# Security Headers Configuration

## Overview
Security headers are configured for both frontend deployments (web-public and web-admin) using Render's `_headers` file support.

## Files
- `web-public/public/_headers` - Security headers for public frontend
- `web-admin/public/_headers` - Security headers for admin frontend

## Headers Configured

### 1. Strict-Transport-Security (HSTS)
```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```
- Forces HTTPS for 1 year
- Applies to all subdomains
- Eligible for browser preload lists

### 2. Content-Security-Policy (CSP)
```
Content-Security-Policy: default-src 'self'; base-uri 'self'; object-src 'none'; ...
```
- Prevents XSS attacks
- Whitelists approved content sources
- Allows connections to backend API

### 3. X-Frame-Options
```
X-Frame-Options: SAMEORIGIN
```
- Prevents clickjacking attacks
- Only allows framing from same origin

### 4. Referrer-Policy
```
Referrer-Policy: strict-origin-when-cross-origin
```
- Controls referrer information leakage
- Sends full URL for same-origin, origin only for cross-origin

### 5. Permissions-Policy
```
Permissions-Policy: accelerometer=(), camera=(), microphone=(), ...
```
- Restricts browser features and APIs
- Denies access to sensitive features (camera, microphone, geolocation)
- Allows safe features like fullscreen for self

### 6. Additional Security Headers
- `X-Content-Type-Options: nosniff` - Prevents MIME-type sniffing
- `X-DNS-Prefetch-Control: off` - Disables DNS prefetching
- `X-Download-Options: noopen` - Prevents file opening in IE
- `X-Permitted-Cross-Domain-Policies: none` - Restricts Flash/PDF
- `Cross-Origin-Opener-Policy: same-origin` - Isolates browsing context
- `Cross-Origin-Resource-Policy: same-origin` - Prevents resource loading
- `Origin-Agent-Cluster: ?1` - Isolates origin agent clusters

## Deployment

### Build Process
The `_headers` file is automatically copied to the `dist` folder during build:
```bash
npm run build
```

Vite's `copyPublicDir: true` ensures all files in `public/` (including `_headers` and `_redirects`) are copied to the output directory.

### Verification
After deployment, verify headers are applied:

1. **Using curl:**
```bash
curl -I https://www.maize-watch.com
```

2. **Using browser DevTools:**
- Open Network tab
- Refresh page
- Select any request
- View Response Headers

3. **Using online tools:**
- https://securityheaders.com
- https://observatory.mozilla.org

## Notes

### CSP Configuration
The CSP allows:
- `'unsafe-inline'` and `'unsafe-eval'` for scripts (required by Vite/React in production)
- Connections to backend API endpoints
- Images from any HTTPS source
- WebSocket connections for real-time features

### HSTS Preload
The `preload` directive makes the site eligible for browser HSTS preload lists. To submit:
1. Verify HTTPS is stable for 1+ year
2. Submit to https://hstspreload.org

### Updating Headers
To modify headers:
1. Edit `web-public/public/_headers` or `web-admin/public/_headers`
2. Rebuild the frontend: `npm run build`
3. Redeploy to Render
4. Verify changes with curl or browser DevTools

## Troubleshooting

### Headers not appearing
1. Verify `_headers` file exists in `dist/` after build
2. Check Render deployment logs for errors
3. Ensure `copyPublicDir: true` in `vite.config.ts`
4. Clear browser cache and CDN cache

### CSP blocking resources
1. Check browser console for CSP violations
2. Add allowed sources to CSP directives
3. Use `Content-Security-Policy-Report-Only` for testing

### HSTS issues
- HSTS only works over HTTPS
- Once set, cannot be easily removed (requires max-age=0)
- Test thoroughly before enabling preload
