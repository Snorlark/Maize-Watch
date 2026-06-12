# Maize-Watch Backend API Documentation

## Overview
The Maize-Watch backend is a Node.js/TypeScript REST API built with Express.js, MongoDB, and Redis. It provides authentication, farm management, sensor data collection, and analytics for the IoT agriculture monitoring system.

## Architecture

### Technology Stack
- **Runtime**: Node.js 18+
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Cache**: Redis with ioredis client
- **Authentication**: JWT with refresh tokens
- **Real-time**: Socket.IO with Redis adapter
- **Security**: Helmet, CORS, bcrypt, rate limiting

### Project Structure
```
backend/src/
├── config/          # Configuration files
├── controllers/     # Request handlers
├── middleware/      # Custom middleware
├── models/          # Database schemas
├── routes/          # API route definitions
├── services/        # Business logic
├── sockets/         # WebSocket handlers
├── utils/           # Utility functions
└── server.ts        # Main application entry
```

## API Endpoints

### Base URL
- Development: `http://localhost:8080/api`
- Production: `https://your-domain.com/api`

### Authentication Endpoints (`/api/auth`)

#### POST `/auth/register`
Register a new user account.

**Request Body:**
```json
{
  "username": "string",
  "email": "string", 
  "password": "string",
  "fullName": "string",
  "contactNumber": "string",
  "address": {
    "region": "string",
    "province": "string", 
    "municipality": "string",
    "barangay": "string"
  },
  "deviceType": "mobile" | "web"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Registration successful!",
  "data": {
    "user": {
      "_id": "string",
      "username": "string",
      "email": "string",
      "fullName": "string",
      "role": "user",
      "emailVerified": false
    },
    "accessToken": "string",
    "refreshToken": "string",
    "expiresIn": "1h"
  }
}
```

#### POST `/auth/login`
Authenticate user and get tokens.

**Request Body:**
```json
{
  "username": "string",    // For mobile
  "email": "string",       // For web
  "password": "string",
  "totpCode": "string",    // Optional 2FA code
  "deviceType": "mobile" | "web"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": { /* user object */ },
    "accessToken": "string",
    "refreshToken": "string", 
    "expiresIn": "1h",
    "requiresTwoFactor": false
  }
}
```

#### POST `/auth/refresh`
Refresh access token using refresh token.

**Request Body:**
```json
{
  "refreshToken": "string"
}
```

#### POST `/auth/logout`
Logout current session (requires authentication).

#### GET `/auth/me`
Get current user profile (requires authentication).

### Farm Management (`/api/farms`)

#### POST `/farms`
Create a new farm (requires authentication).

**Request Body:**
```json
{
  "farmName": "string",
  "location": "string",
  "description": "string"
}
```

#### POST `/farms/simple`
Create a simplified farm with field and devices (for mobile registration).

**Request Body:**
```json
{
  "farmName": "string",
  "location": "string",
  "description": "string",
  "fieldName": "string",
  "soilType": "loamy" | "sandy" | "clay" | "silty",
  "plantingDate": "ISO date string",
  "devices": [
    {
      "sensorId": "string",
      "name": "string",
      "deviceMacAddress": "string",
      "status": "active",
      "description": "string"
    }
  ],
  "address": {
    "barangay": "string",
    "municipality": "string", 
    "province": "string",
    "region": "string"
  }
}
```

#### GET `/farms`
Get all farms for current user (requires authentication).

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10)
- `owner`: Owner ID (admin only)
- `all`: Get all farms (admin only)

#### GET `/farms/:id`
Get specific farm by ID (requires authentication).

#### PUT `/farms/:id`
Update farm details (requires authentication).

#### DELETE `/farms/:id`
Delete farm (requires authentication).

#### GET `/farms/:id/analytics`
Get farm analytics and insights (requires authentication).

**Query Parameters:**
- `days`: Number of days for analytics (default: 7)

### Sensor Management (`/api/sensors`)

#### POST `/sensors`
Create a new sensor (requires authentication).

#### GET `/farms/:farmId/sensors`
Get all sensors for a specific farm (requires authentication).

#### GET `/sensors/:id`
Get sensor details by ID (requires authentication).

#### PUT `/sensors/:id`
Update sensor configuration (requires authentication).

#### DELETE `/sensors/:id`
Delete sensor (requires authentication).

#### POST `/sensors/:id/readings`
Record new sensor reading.

**Request Body:**
```json
{
  "data": {
    "temperature": "number",
    "humidity": "number", 
    "soilMoisture": "number",
    "pH": "number",
    "lightLevel": "number"
  },
  "timestamp": "ISO date string"
}
```

#### GET `/sensors/:id/readings`
Get sensor readings with pagination (requires authentication).

**Query Parameters:**
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 100)
- `startDate`: Start date filter
- `endDate`: End date filter

#### GET `/farms/:farmId/readings/latest`
Get latest readings for all sensors in a farm (requires authentication).

### User Management (`/api/users`)

#### GET `/users/profile`
Get current user profile (requires authentication).

#### PUT `/users/profile`
Update user profile (requires authentication).

#### PUT `/users/change-password`
Change user password (requires authentication).

## Data Models

### User Model
```typescript
interface IUser {
  _id: ObjectId;
  username: string;
  email: string;
  password: string; // Hashed
  fullName: string;
  contactNumber: string;
  address: {
    region: string;
    province: string;
    municipality: string;
    barangay: string;
  };
  role: "user" | "admin" | "super_admin";
  isActive: boolean;
  lastLogin?: Date;
  emailVerified: boolean;
  twoFactorEnabled: boolean;
  refreshTokens: Array<{
    token: string;
    createdAt: Date;
  }>;
  preferences?: {
    language: "en" | "tl";
    timezone: string;
    notifications: {
      email: boolean;
      sms: boolean;
      push: boolean;
    };
  };
  createdAt: Date;
  updatedAt: Date;
}
```

### Farm Model
```typescript
interface IFarm {
  _id: ObjectId;
  userId: ObjectId; // Reference to User
  farmName: string;
  location: string;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
}
```

### Field Model
```typescript
interface IField {
  _id: ObjectId;
  farmId: ObjectId; // Reference to Farm
  fieldName: string;
  soilType: "loamy" | "sandy" | "clay" | "silty";
  plantingDate: Date;
  growthStage: string; // Auto-calculated based on planting date
  devices: Array<{
    sensorId: string;
    name: string;
    deviceMacAddress?: string;
    status: "active" | "inactive" | "maintenance";
    registeredAt: Date;
    location?: {
      coordinates: [number, number];
      description?: string;
    };
  }>;
  createdAt: Date;
  updatedAt: Date;
}
```

### Sensor Reading Model
```typescript
interface ISensorReading {
  _id: ObjectId;
  sensor: ObjectId; // Reference to Sensor
  farm: ObjectId; // Reference to Farm
  data: {
    temperature?: number;
    humidity?: number;
    soilMoisture?: number;
    pH?: number;
    lightLevel?: number;
    [key: string]: any;
  };
  timestamp: Date;
  quality: "good" | "fair" | "poor";
  createdAt: Date;
}
```

## Authentication & Security

### JWT Token Structure
```json
{
  "id": "user_id",
  "username": "username",
  "role": "user",
  "isActive": true,
  "iat": 1234567890,
  "exp": 1234567890,
  "iss": "maize-watch-api",
  "aud": "maize-watch-client"
}
```

### Security Features
- Password hashing with bcrypt (cost: 12)
- JWT access tokens (1 hour expiry)
- Refresh tokens (7 days expiry)
- Account lockout after 5 failed login attempts
- Rate limiting on all endpoints
- CORS protection
- Helmet security headers
- Input validation with express-validator

### Rate Limits
- General: 100 requests per 15 minutes
- Auth endpoints: 5 requests per 15 minutes
- API endpoints: 1000 requests per 15 minutes
- Upload endpoints: 10 requests per 15 minutes

## Error Handling

### Standard Error Response
```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    {
      "field": "fieldName",
      "message": "Specific error message"
    }
  ]
}
```

### HTTP Status Codes
- `200`: Success
- `201`: Created
- `400`: Bad Request (validation errors)
- `401`: Unauthorized (invalid/missing token)
- `403`: Forbidden (insufficient permissions)
- `404`: Not Found
- `429`: Too Many Requests (rate limited)
- `500`: Internal Server Error

## Mobile Implementation Guide

### 1. Authentication Flow

#### Registration
```dart
// Register new user
final response = await http.post(
  Uri.parse('$baseUrl/auth/register'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'username': username,
    'email': email, // Can be auto-generated for mobile
    'password': password,
    'fullName': fullName,
    'contactNumber': contactNumber,
    'address': {
      'region': region,
      'province': province,
      'municipality': municipality,
      'barangay': barangay,
    },
    'deviceType': 'mobile'
  }),
);
```

#### Login
```dart
// Login user
final response = await http.post(
  Uri.parse('$baseUrl/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'username': username, // Use username for mobile
    'password': password,
    'deviceType': 'mobile'
  }),
);

// Store tokens securely
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  await secureStorage.write(key: 'access_token', value: data['data']['accessToken']);
  await secureStorage.write(key: 'refresh_token', value: data['data']['refreshToken']);
}
```

#### Token Refresh
```dart
// Refresh expired token
final refreshToken = await secureStorage.read(key: 'refresh_token');
final response = await http.post(
  Uri.parse('$baseUrl/auth/refresh'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'refreshToken': refreshToken}),
);
```

### 2. Farm Registration

#### Simple Farm Creation
```dart
// Create farm with field and devices
final response = await http.post(
  Uri.parse('$baseUrl/farms/simple'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  },
  body: jsonEncode({
    'farmName': farmName,
    'fieldName': fieldName,
    'soilType': soilType,
    'plantingDate': plantingDate.toIso8601String(),
    'devices': devices.map((device) => {
      'sensorId': device.sensorId,
      'name': device.name,
      'deviceMacAddress': device.macAddress,
      'status': 'active',
      'description': device.description,
    }).toList(),
    'address': {
      'barangay': address.barangay,
      'municipality': address.municipality,
      'province': address.province,
      'region': address.region,
    }
  }),
);
```

### 3. Data Fetching

#### Get User Farms
```dart
final response = await http.get(
  Uri.parse('$baseUrl/farms'),
  headers: {
    'Authorization': 'Bearer $accessToken',
  },
);
```

#### Get Farm Analytics
```dart
final response = await http.get(
  Uri.parse('$baseUrl/farms/$farmId/analytics?days=7'),
  headers: {
    'Authorization': 'Bearer $accessToken',
  },
);
```

#### Get Latest Sensor Readings
```dart
final response = await http.get(
  Uri.parse('$baseUrl/farms/$farmId/readings/latest'),
  headers: {
    'Authorization': 'Bearer $accessToken',
  },
);
```

### 4. Error Handling

```dart
class ApiService {
  Future<Map<String, dynamic>> makeRequest(String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      String? token;
      if (requiresAuth) {
        token = await secureStorage.read(key: 'access_token');
      }

      final response = await http.request(
        method,
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: body != null ? jsonEncode(body) : null,
      );

      if (response.statusCode == 401) {
        // Token expired, try to refresh
        final refreshed = await refreshToken();
        if (refreshed) {
          // Retry original request
          return makeRequest(endpoint, method: method, body: body, requiresAuth: requiresAuth);
        } else {
          // Refresh failed, redirect to login
          throw UnauthorizedException('Session expired');
        }
      }

      if (response.statusCode >= 400) {
        final error = jsonDecode(response.body);
        throw ApiException(error['message'] ?? 'Unknown error');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
}
```

### 5. Real-time Updates (Socket.IO)

```dart
// Connect to Socket.IO
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket socket = IO.io('$baseUrl', <String, dynamic>{
  'transports': ['websocket'],
  'auth': {
    'token': accessToken,
  },
});

socket.on('connect', (_) {
  print('Connected to server');
  // Join farm-specific room
  socket.emit('join_farm', farmId);
});

socket.on('sensor_reading', (data) {
  // Handle new sensor reading
  final reading = SensorReading.fromJson(data);
  // Update UI
});

socket.on('alert', (data) {
  // Handle alerts
  final alert = Alert.fromJson(data);
  // Show notification
});
```

## Environment Variables

### Required Variables
```env
# Server
PORT=8080
NODE_ENV=development

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_EXPIRE=1h

# CORS
FRONTEND_URL=http://localhost:3000

# Email (optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# ThingSpeak (optional)
THINGSPEAK_API_KEY=your-thingspeak-api-key
```

## Deployment Considerations

### Production Checklist
- [ ] Set `NODE_ENV=production`
- [ ] Use strong JWT secrets
- [ ] Configure proper CORS origins
- [ ] Set up SSL/TLS certificates
- [ ] Configure MongoDB replica set
- [ ] Set up Redis cluster
- [ ] Configure proper logging
- [ ] Set up monitoring and alerts
- [ ] Configure backup strategies

### Docker Deployment
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY dist ./dist
EXPOSE 8080
CMD ["node", "dist/server.js"]
```

## Legacy Code to Remove

Based on my analysis, here are components that should be removed or updated:

### 1. Unused Controllers
- Some methods in `analyticsController.ts` that duplicate farm analytics
- Legacy device linking methods in `farmController.ts`

### 2. Redundant Services
- `pythonAnalyticsService.ts` - appears to be unused
- Some methods in `analyticsService.ts` that overlap with farm service

### 3. Deprecated Models
- Legacy sensor model fields that are now handled by the Field model
- Unused indexes and virtual fields

### 4. Outdated Middleware
- Some rate limiting configurations that are overly complex
- Unused validation rules

### 5. Configuration Files
- Old environment variable references
- Unused ThingSpeak configurations if not being used

## Best Practices for Mobile Integration

1. **Token Management**: Always store tokens securely using flutter_secure_storage
2. **Network Handling**: Implement proper retry logic and offline capabilities
3. **Error Handling**: Provide user-friendly error messages
4. **Data Caching**: Cache frequently accessed data locally
5. **Real-time Updates**: Use Socket.IO for live sensor data
6. **Background Sync**: Implement background data synchronization
7. **Security**: Validate all user inputs and sanitize data
8. **Performance**: Implement pagination for large datasets
9. **Offline Mode**: Store critical data locally for offline access
10. **Push Notifications**: Integrate with Firebase for alerts

This documentation provides a comprehensive guide for implementing the mobile frontend to work with the Maize-Watch backend API.
