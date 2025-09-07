# Development Notes

## Functions/Code to Remove Before Production

### Security Considerations
- All debug print statements containing sensitive data should be removed
- Authentication debug logs in field_registration_screen.dart (lines 373-377, 433-438)
- Farm creation debug logs in field_registration_screen.dart (lines 433-438)
- Backend logging in farmController.ts createSimpleFarm method (lines 536-543)

### Deprecated Code
- Flutter `withOpacity` usage should be replaced with `withValues()` in field_registration_form_pages.dart
- Remove any unused imports flagged by Flutter analyzer

### Testing Code
- Remove any test authentication tokens or hardcoded credentials
- Ensure all API endpoints use proper authentication middleware

## Recent Changes Made

### Authentication Flow Fixes
1. **Fixed authentication state management** in field registration flow
2. **Added proper token refresh** mechanism in farm data submission
3. **Enhanced authentication checks** before farm creation with fallback to login

### Farm Registration System
1. **Fixed location derivation** from user address data (barangay, municipality, province, region)
2. **Implemented proper field creation** with soil type, planting date, and growth stage
3. **Fixed device registration** to be user-specific and properly linked to fields
4. **Updated farm creation** to properly reference fields array with embedded devices

### Backend Improvements
1. **Enhanced createSimpleFarm endpoint** to properly handle address derivation
2. **Added proper field creation** with device registration in single atomic operation
3. **Improved location parsing** from frontend address data
4. **Added comprehensive logging** for debugging (to be removed in production)

### Database Schema
- Farms now properly store location derived from user address
- Fields are created with proper soil type, planting date, and growth stage
- Devices are embedded in field documents with proper user ownership
- Growth stage is automatically calculated based on planting date

## Security Best Practices Implemented
- All farm API endpoints require authentication
- JWT tokens are securely stored and automatically refreshed
- User-specific device registration prevents unauthorized access
- Proper error handling for authentication failures

## Current Status
- Backend API is functional with Redis integration
- Mobile app has authentication and farm registration working
- Database schema includes User, Farm, Field models with embedded devices
- **COMPLETED**: Comprehensive backend documentation created in `tasks/backend-documentation.md`

## Backend Analysis Summary

### Architecture Overview
- **Tech Stack**: Node.js, TypeScript, Express.js, MongoDB, Redis, Socket.IO
- **Security**: JWT authentication, bcrypt hashing, rate limiting, CORS protection
- **Real-time**: Socket.IO with Redis adapter for horizontal scaling
- **Caching**: Redis-based caching for sensor data and analytics

### Key API Endpoints for Mobile
1. **Authentication**
   - `POST /api/auth/register` - User registration with mobile support
   - `POST /api/auth/login` - Login with username (mobile) or email (web)
   - `POST /api/auth/refresh` - Token refresh mechanism

2. **Farm Management**
   - `POST /api/farms/simple` - Simplified farm creation for mobile
   - `GET /api/farms` - Get user's farms
   - `GET /api/farms/:id/analytics` - Farm analytics and insights

3. **Sensor Data**
   - `GET /api/farms/:farmId/readings/latest` - Latest sensor readings
   - `POST /api/sensors/:id/readings` - Record new sensor data
   - Socket.IO events for real-time updates

### Data Models
- **User**: Full authentication with Philippine address structure
- **Farm**: Simple farm info linked to user
- **Field**: Contains embedded devices array with auto-growth stage calculation
- **SensorReading**: Timestamped sensor data with quality metrics

## Key Components to Remove Before Production

### Backend Cleanup Required
1. **Unused Services**
   - `pythonAnalyticsService.ts` - appears to be unused
   - Overlapping methods in `analyticsService.ts` that duplicate farm service functionality

2. **Legacy Controller Methods**
   - Redundant device linking methods in `farmController.ts`
   - Some analytics endpoints that duplicate farm analytics

3. **Deprecated Model Fields**
   - Legacy sensor model fields now handled by Field model
   - Unused indexes and virtual fields

4. **Configuration Cleanup**
   - Old environment variable references
   - Unused ThingSpeak configurations if not being used

5. **Middleware Optimization**
   - Overly complex rate limiting configurations
   - Unused validation rules

### Security Audit Completed 
- JWT secrets properly configured with separate refresh tokens
- Rate limiting implemented with Redis backing
- Password hashing uses bcrypt with cost 12
- Input validation with express-validator on all endpoints
- CORS and Helmet security headers configured
- Account lockout after 5 failed login attempts
- Refresh token rotation and cleanup

## Mobile Implementation Guidelines

### Authentication Flow
1. Use username-based login for mobile devices
2. Store tokens securely with flutter_secure_storage
3. Implement automatic token refresh with retry logic
4. Handle 401 errors gracefully with re-authentication

### Data Management
1. Use `/api/farms/simple` endpoint for streamlined farm registration
2. Implement local caching for frequently accessed data
3. Use Socket.IO for real-time sensor updates
4. Implement offline mode with local storage fallback

### Error Handling
1. Standardized error responses with field-level validation
2. Rate limiting awareness (100 req/15min general, 5 req/15min auth)
3. Network error handling with user-friendly messages
4. Proper loading states and error recovery

## Mobile App Production Readiness

### Code Cleanup Required
1. **Debug Logging Removal**
   - Remove all console.log statements with sensitive data in authentication flows
   - Clean up debug prints in farm registration screens
   - Remove development-only logging from API calls

2. **Unused/Legacy Code Identified**
   - `SecureStorageService` class appears to duplicate `SecureStorage` functionality
   - Consider consolidating storage services for consistency
   - Remove any unused imports flagged by Flutter analyzer

3. **Security Hardening**
   - Ensure all API endpoints use production URLs (not localhost)
   - Verify SSL certificate pinning is enabled for production builds
   - Remove any hardcoded development tokens or credentials

4. **Performance Optimization**
   - Implement proper image caching and optimization
   - Add loading states for all async operations
   - Optimize build size by removing unused dependencies

### Mobile App Architecture Strengths
- Clean Architecture implementation with proper layer separation
- Comprehensive BLoC state management pattern
- Secure token storage with automatic refresh mechanism
- Robust error handling and user feedback systems
- Multi-environment configuration support

## Connection Timeout Fixes Applied

### Mobile App Timeout Improvements
- **Increased Dio timeout settings** from 20s to 30s for connect, receive, and send timeouts
- **Enhanced error handling** in farm data source with specific HTTP status code handling
- **Improved splash screen logic** to distinguish between network errors and legitimate "no farms" scenarios
- **Better user feedback** with specific error messages for different failure types

### Backend MongoDB Connection Improvements
- **Increased connection timeouts**: serverSelectionTimeoutMS (5s → 10s), socketTimeoutMS (45s → 60s)
- **Added explicit connectTimeoutMS** (10s) and connection retry logic
- **Implemented automatic reconnection** with 3 retry attempts and 5-second delays
- **Enhanced connection monitoring** with heartbeat frequency and idle timeout settings
- **Graceful error handling** with proper logging and fallback mechanisms

### Connection Issues Resolved
- Backend now successfully connects to MongoDB Atlas cluster
- Mobile app login timeout errors fixed with increased timeout settings
- Proper error differentiation between network issues vs authentication problems
- Farmers now get clear error messages instead of being incorrectly redirected to farm registration

## Farm Structure Refactor - Recent Updates

### Widget Fixes Completed (Latest Session)
1. **corn_progress_widget.dart** - Updated to work with new embedded farm structure
   - Fixed data access to use `farm.fields[0]` instead of separate field object
   - Updated sensor data access to use `field.sensors` array
   - Modified growth progress and current conditions to work with new structure
   - Maintained all existing UI functionality

2. **debug_data_view.dart** - Enhanced to display complete farm hierarchy
   - Added hierarchical display: Farm → Fields → Sensors → Readings
   - Fixed property names to match actual Farm entity structure
   - Removed unnecessary null-aware operators (fixed lint warnings)
   - Now shows complete farm data structure for debugging

### Legacy Code Identified for Removal
1. **Backend Legacy Items**
   - Old Field model (`Field.ts`) - now embedded in Farm model
   - Separate field creation endpoints - replaced with embedded field creation
   - Legacy field controller methods that operate on separate Field collection

2. **Frontend Legacy Items**
   - Any references to separate field entities in old monitoring widgets
   - Unused field-specific API calls that are now handled through farm endpoints
   - Old field registration flows that don't use embedded structure

### Farm Data Structure Changes
- **Backend**: Farm model now embeds fields array with sensors
- **Frontend**: Farm entity includes fields with sensors and readings
- **Database**: Single Farm document contains all field and sensor data
- **API**: Farm creation accepts complete structure in single request

## Next Steps for Production
1. Remove identified legacy code components (Field model, separate field endpoints)
2. Implement comprehensive logging and monitoring
3. Set up proper backup strategies for MongoDB and Redis
4. Configure SSL/TLS certificates
5. Set up CI/CD pipeline with automated testing
6. Implement proper environment variable management
7. Configure production-ready Docker containers
8. **Mobile App**: Remove debug logging and consolidate storage services
9. **Mobile App**: Enable SSL pinning and production environment settings
10. **Mobile App**: Implement comprehensive error tracking and analytics
11. **Connection Monitoring**: Set up alerts for MongoDB connection issues
12. **Performance**: Monitor timeout settings in production and adjust as needed
13. **Database Migration**: Create migration script to convert existing separate Field documents to embedded structure
