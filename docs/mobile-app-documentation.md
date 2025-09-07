# Maize-Watch Mobile App Documentation

## Overview
The Maize-Watch mobile application is a Flutter-based cross-platform app designed for agricultural monitoring and management. It provides farmers with tools to register farms, monitor sensor data, and manage agricultural operations through an intuitive mobile interface.

## Architecture

### Clean Architecture Implementation
The app follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Shared utilities and configurations
├── features/               # Feature-based modules
│   ├── authentication/    # User authentication
│   ├── farm/             # Farm management
│   ├── live_monitoring/  # Real-time monitoring
│   ├── prescriptions/    # Treatment prescriptions
│   └── settings/         # App settings
└── generated/            # Generated files (l10n, etc.)
```

### Layer Structure
Each feature follows the same architectural pattern:
- **Domain Layer**: Entities, use cases, repositories (interfaces)
- **Data Layer**: Models, data sources, repository implementations
- **Presentation Layer**: BLoC state management, screens, widgets

## Core Components

### 1. Dependency Injection (`core/di/`)
- Uses `get_it` for service locator pattern
- Centralized dependency registration in `injection_container.dart`
- Supports different configurations for testing and production

### 2. Network Layer (`core/network/`)
- **DioFactory**: Creates configured Dio instances with interceptors
- **AuthInterceptor**: Handles automatic token refresh and authentication
- **Error Handling**: Comprehensive error mapping and user-friendly messages

### 3. Storage (`core/storage/`)
- **SecureStorage**: Encrypted storage for sensitive data (tokens, user data)
- **Session Management**: Handles login/logout state persistence

### 4. Configuration (`core/config/`)
- **Environment**: Multi-environment support (development, staging, production)
- **API Endpoints**: Centralized endpoint management
- **Security Settings**: SSL pinning, timeouts, retry policies

## Features

### Authentication System
**Location**: `features/authentication/`

#### Key Components:
- **AuthenticationBloc**: Manages authentication state using BLoC pattern
- **User Entity**: Core user data model
- **Secure Token Management**: Automatic token refresh with fallback handling

#### Authentication Flow:
1. **Login**: Username/password authentication with JWT tokens
2. **Registration**: Multi-step user registration with address collection
3. **Session Management**: Persistent login state with secure storage
4. **Token Refresh**: Automatic token renewal with refresh tokens

#### Security Features:
- Encrypted token storage using `flutter_secure_storage`
- Automatic session cleanup on authentication failures
- JWT token validation and refresh mechanism

### Farm Management System
**Location**: `features/farm/`

#### Core Functionality:
- **Farm Registration**: Multi-step farm creation process
- **Field Management**: Individual field tracking within farms
- **Device Integration**: Sensor device linking and management
- **Location Services**: Address-based location derivation

#### Farm Registration Process:
1. **Field Naming**: Unique field identification
2. **Planting Information**: Crop type and planting date
3. **Device Setup**: Sensor device configuration
4. **Location Mapping**: GPS and address-based positioning

#### Data Models:
- **Farm Entity**: Core farm information with location and metadata
- **Device Integration**: Embedded device arrays in farm documents
- **Address Handling**: Structured address components (barangay, municipality, province, region)

### Live Monitoring
**Location**: `features/live_monitoring/`

#### Features:
- Real-time sensor data visualization
- Dashboard with key metrics
- Alert system for critical conditions
- Historical data trends

### Settings Management
**Location**: `features/settings/`

#### Configuration Options:
- Language selection (internationalization)
- Theme preferences
- Notification settings
- Account management

## State Management

### BLoC Pattern Implementation
The app uses the BLoC (Business Logic Component) pattern for state management:

#### Authentication BLoC:
```dart
// States
- AuthenticationStatus.initial
- AuthenticationStatus.loading
- AuthenticationStatus.authenticated
- AuthenticationStatus.unauthenticated
- AuthenticationStatus.failure
- AuthenticationStatus.registrationSuccess

// Events
- LoginEvent
- RegisterEvent
- LogoutEvent
- CheckAuthStatusEvent
```

#### Farm BLoC:
```dart
// States
- FarmInitial
- FarmLoading
- FarmCreated
- FarmsLoaded
- SensorCreated
- FarmError

// Events
- CreateFarmEvent
- CreateFarmWithFieldEvent
- GetUserFarmsEvent
- CreateSensorEvent
```

## API Integration

### Backend Communication
- **Base URL Configuration**: Environment-specific endpoints
- **Authentication Headers**: Automatic Bearer token injection
- **Error Handling**: Comprehensive error mapping and user feedback
- **Token Management**: Automatic refresh with fallback mechanisms

### Key Endpoints:
```
Authentication:
- POST /api/auth/login
- POST /api/auth/register
- POST /api/auth/refresh
- POST /api/auth/logout

Farm Management:
- GET /api/farms
- POST /api/farms
- GET /api/farms/:id
- PUT /api/farms/:id
- DELETE /api/farms/:id

Sensors:
- GET /api/sensors
- POST /api/sensors
- GET /api/sensors/:id
```

## UI/UX Components

### Design System
- **Material Design**: Flutter's Material Design components
- **Screen Adaptation**: Responsive design using `flutter_screenutil`
- **Theme Management**: Centralized color and typography system
- **Internationalization**: Multi-language support with `flutter_localizations`

### Key UI Components:
- **Custom Buttons**: Consistent button styling across the app
- **Form Components**: Reusable input fields and validation
- **Progress Indicators**: Multi-step process visualization
- **Error Dialogs**: User-friendly error messaging
- **Snackbars**: Toast-style notifications

### Navigation Structure:
```
/splash → Authentication Check
├── /landing → Login/Register Options
├── /home → Main Dashboard
├── /farm-registration → Multi-step Farm Setup
└── /settings → App Configuration
```

## Data Flow

### Authentication Flow:
1. App Launch → SplashScreen → Check stored credentials
2. If authenticated → Navigate to HomeScreen
3. If not authenticated → Navigate to LandingScreen
4. Login/Register → Store credentials → Navigate to appropriate screen

### Farm Registration Flow:
1. User Registration → Collect address data
2. Farm Registration → Multi-step form process
3. Field Setup → Name, planting date, soil type
4. Device Configuration → Sensor linking
5. Data Submission → Backend API call with complete payload

## Security Implementation

### Data Protection:
- **Encrypted Storage**: All sensitive data encrypted at rest
- **Token Security**: JWT tokens with automatic refresh
- **Session Management**: Secure session cleanup on logout
- **API Security**: Bearer token authentication for all API calls

### Error Handling:
- **Network Errors**: Graceful handling of connectivity issues
- **Authentication Errors**: Automatic session cleanup and re-authentication
- **Validation Errors**: User-friendly form validation messages
- **Server Errors**: Comprehensive error mapping and user feedback

## Performance Considerations

### Optimization Strategies:
- **Lazy Loading**: On-demand widget and data loading
- **Caching**: Strategic data caching for improved performance
- **Image Optimization**: Efficient image loading and caching
- **Memory Management**: Proper disposal of controllers and streams

### Network Optimization:
- **Request Timeouts**: Configurable timeout settings
- **Retry Logic**: Automatic retry for failed requests
- **Connection Pooling**: Efficient HTTP connection management

## Development Guidelines

### Code Organization:
- Feature-based module structure
- Clear separation of concerns
- Consistent naming conventions
- Comprehensive documentation

### Testing Strategy:
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for complete flows
- Mock implementations for external dependencies

### Build Configuration:
- Environment-specific configurations
- Automated build processes
- Code signing for app store releases
- Continuous integration setup

## Deployment

### Build Variants:
- **Development**: Local development with debug features
- **Staging**: Pre-production testing environment
- **Production**: Live app store releases

### Release Process:
1. Code review and testing
2. Version bumping and changelog updates
3. Build generation for target platforms
4. App store submission and approval
5. Production deployment and monitoring

## Troubleshooting

### Common Issues:
1. **Authentication Failures**: Check token expiration and refresh logic
2. **Network Connectivity**: Verify API endpoints and network configuration
3. **Data Persistence**: Ensure secure storage permissions and encryption
4. **UI Rendering**: Check screen adaptation and theme configuration

### Debug Tools:
- Flutter Inspector for widget debugging
- Network logging for API call inspection
- Secure storage inspection tools
- Performance profiling utilities

## Future Enhancements

### Planned Features:
- Offline data synchronization
- Push notification system
- Advanced analytics dashboard
- Multi-farm management
- Social features for farmer communities

### Technical Improvements:
- GraphQL API integration
- Advanced caching strategies
- Performance monitoring
- Automated testing coverage
- CI/CD pipeline enhancements
