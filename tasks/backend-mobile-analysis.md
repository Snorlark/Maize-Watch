# Backend-Mobile Connection Analysis

## Mobile App API Usage (What's Actually Used)

### Authentication Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Token refresh

### Farm Management Endpoints
- `GET /api/farms` - Get user farms
- `POST /api/farms` - Create farm
- `GET /api/farms/:id` - Get farm by ID
- `PUT /api/farms/:id` - Update farm
- `DELETE /api/farms/:id` - Delete farm
- `POST /api/farms/:id/link-device` - Link device to farm
- `DELETE /api/farms/:id/unlink-device` - Unlink device from farm

### Sensor/Monitoring Endpoints
- `GET /api/farms/:farmId/readings/latest` - Get latest sensor readings
- `GET /api/farms/:farmId/readings/historical` - Get historical readings
- `GET /api/sensors/:sensorId/readings` - Get sensor readings by sensor ID

## Backend Endpoints NOT Used by Mobile

### User Management (Admin-only features)
- `GET /api/users` - Get all users (Admin only)
- `GET /api/users/search` - Search users (Admin only)
- `GET /api/users/stats` - User statistics (Admin only)
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user profile
- `DELETE /api/users/:id` - Delete user (Admin only)
- `PATCH /api/users/:id/status` - Toggle user status (Admin only)
- `PUT /api/users/:id/preferences` - Update user preferences
- `GET /api/users/:id/activity` - Get user activity

### Advanced Authentication Features
- `POST /api/auth/logout` - Logout (mobile handles locally)
- `POST /api/auth/logout-all` - Logout all sessions
- `POST /api/auth/forgot-password` - Password reset
- `POST /api/auth/reset-password` - Reset password
- `PUT /api/auth/change-password` - Change password
- `GET /api/auth/verify-email/:token` - Email verification
- `POST /api/auth/resend-verification` - Resend verification
- `POST /api/auth/setup-2fa` - Setup 2FA
- `POST /api/auth/verify-2fa` - Verify 2FA
- `POST /api/auth/disable-2fa` - Disable 2FA
- `GET /api/auth/me` - Get profile

### Field Management (Entire Module)
- `POST /api/fields` - Create field
- `GET /api/fields/:fieldId` - Get field by ID
- `GET /api/fields/farm/:farmId` - Get fields by farm ID
- `PUT /api/fields/:fieldId` - Update field
- `DELETE /api/fields/:fieldId` - Delete field
- `GET /api/fields/:fieldId/analytics` - Field analytics
- `POST /api/fields/:fieldId/devices` - Add device to field
- `DELETE /api/fields/:fieldId/devices/:deviceId` - Remove device from field
- `GET /api/fields/:fieldId/predictions` - Harvest predictions

### Advanced Farm Features
- `GET /api/farms/location` - Get farms by location (Admin only)
- `GET /api/farms/device/:deviceId` - Get farm by device ID
- `GET /api/farms/stats` - Farm statistics (Admin only)
- `GET /api/farms/:id/analytics` - Farm analytics
- `PATCH /api/farms/:id/status` - Update farm status
- `POST /api/farms/:id/images` - Add farm images
- `GET /api/farms/:id/predictions` - Harvest predictions

### Advanced Sensor Features
- `GET /api/sensors/maintenance` - Sensors needing maintenance (Admin only)
- `GET /api/sensors/stats` - Sensor statistics (Admin only)
- `POST /api/sensors` - Create sensor
- `GET /api/sensors/:id` - Get sensor by ID
- `PUT /api/sensors/:id` - Update sensor
- `DELETE /api/sensors/:id` - Delete sensor
- `POST /api/sensors/:id/readings` - Record sensor reading
- `POST /api/sensors/:id/sync` - Sync from ThingSpeak
- `POST /api/sensors/:id/calibrate` - Calibrate sensor

### Analytics Module (Entire Module)
- `GET /api/analytics/dashboard` - Dashboard data
- `GET /api/analytics/compare` - Compare farms
- `GET /api/analytics/data` - Aggregated data
- `GET /api/analytics/health` - Analytics health (Admin only)
- `GET /api/analytics/farms/:farmId/report` - Farm report
- `GET /api/analytics/farms/:farmId/trends` - Analyze trends
- `GET /api/analytics/farms/:farmId/correlations` - Analyze correlations
- `POST /api/analytics/farms/:farmId/predict` - Generate predictive model
- `GET /api/analytics/farms/:farmId/anomalies` - Detect anomalies
- `GET /api/analytics/farms/:farmId/optimization` - Yield optimization insights
- `GET /api/analytics/farms/:farmId/export` - Export data
- `POST /api/analytics/farms/:farmId/corn-analytics` - Python analytics v2
- `GET /api/analytics/farms/:farmId/recommendations` - Daily recommendations
- `GET /api/analytics/farms/:farmId/growth-stage` - Growth stage analysis
- `GET /api/analytics/farms/:farmId/risk-assessment` - Risk assessment
- `GET /api/analytics/crop-status/:farmId` - Crop status
- `GET /api/analytics/crop/:farmId` - Crop analytics

## Flow Diagram: Mobile App ↔ Backend

```
MOBILE APP                    BACKEND API
┌─────────────────┐          ┌─────────────────┐
│                 │          │                 │
│ Authentication  │ ────────→│ /api/auth/*     │
│ - Register      │          │ - register      │
│ - Login         │          │ - login         │
│ - Token Refresh │          │ - refresh       │
│                 │          │                 │
└─────────────────┘          └─────────────────┘
         │                            │
         ▼                            ▼
┌─────────────────┐          ┌─────────────────┐
│                 │          │                 │
│ Farm Management │ ────────→│ /api/farms/*    │
│ - List Farms    │          │ - GET /         │
│ - Create Farm   │          │ - POST /        │
│ - Update Farm   │          │ - PUT /:id      │
│ - Delete Farm   │          │ - DELETE /:id   │
│ - Link Device   │          │ - POST /:id/... │
│                 │          │                 │
└─────────────────┘          └─────────────────┘
         │                            │
         ▼                            ▼
┌─────────────────┐          ┌─────────────────┐
│                 │          │                 │
│ Live Monitoring │ ────────→│ /api/farms/*    │
│ - Latest Data   │          │ - /:id/readings │
│ - Historical    │          │ /api/sensors/*  │
│ - Sensor Data   │          │ - /:id/readings │
│                 │          │                 │
└─────────────────┘          └─────────────────┘

UNUSED BY MOBILE:
┌─────────────────┐
│ /api/users/*    │ ← Admin-only user management
│ /api/fields/*   │ ← Field management (not used)
│ /api/analytics/*│ ← Advanced analytics (not used)
│ Advanced Auth   │ ← 2FA, email verification, etc.
│ Advanced Farm   │ ← Analytics, predictions, images
│ Advanced Sensor │ ← Maintenance, calibration, etc.
└─────────────────┘
```

## Summary

The mobile app uses a **minimal subset** of the backend API:
- **3 auth endpoints** out of 13 available
- **6 farm endpoints** out of 13 available  
- **3 sensor/monitoring endpoints** out of 14 available
- **0 user endpoints** out of 8 available
- **0 field endpoints** out of 8 available
- **0 analytics endpoints** out of 20 available

**Total: 12 endpoints used out of 76 available (16% utilization)**
