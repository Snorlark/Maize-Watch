# Session Management Implementation

## Overview

The Maize Watch web-auth application implements a comprehensive session management system with automatic session expiration and user-friendly warnings. This system is specifically designed for admin and super_admin users to ensure security while providing a good user experience.

## Features

### 1. Automatic Session Expiration
- **Session Duration**: 15 minutes (900,000ms) of inactivity
- **Warning System**: 2 minutes (120,000ms) before expiration
- **User Activity Tracking**: Monitors mouse, keyboard, scroll, and touch events

### 2. Session Expiration Modal
- **Target Users**: Only admin and super_admin users see the modal
- **Visual Design**: Consistent with Maize Watch brand colors
- **Countdown Timer**: Real-time countdown with progress bar
- **Action Options**: Extend session or logout immediately

### 3. Security Features
- **JWT Token Validation**: Automatic token expiration checking
- **Automatic Cleanup**: Invalid/expired tokens are removed
- **Role-Based Access**: Different behavior for different user roles

## Implementation Details

### Components

#### 1. SessionExpirationModal.tsx
```typescript
interface SessionExpirationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onExtendSession: () => void;
  onLogout: () => void;
  timeRemaining: number; // in seconds
}
```

**Features:**
- Real-time countdown display
- Progress bar with color changes
- Role-based visibility (admin/super_admin only)
- Responsive design with Maize Watch branding

#### 2. AuthContext.tsx (Enhanced)
**New State Variables:**
- `warningTimer`: Timer for showing warning modal
- `showSessionModal`: Controls modal visibility
- `timeRemaining`: Countdown time in seconds

**New Functions:**
- `handleExtendSession()`: Extends session and resets timers
- `handleSessionLogout()`: Logs out user immediately
- `handleCloseSessionModal()`: Closes modal without action

### Timer Configuration

```typescript
// Production values
const INACTIVITY_TIMEOUT = 900000; // 15 minutes
const WARNING_TIMEOUT = 120000;    // 2 minutes

// Testing values (for development)
const INACTIVITY_TIMEOUT = 30000;  // 30 seconds
const WARNING_TIMEOUT = 10000;     // 10 seconds
```

### User Activity Tracking

The system monitors these events to reset the inactivity timer:
- `mousedown`
- `keypress`
- `scroll`
- `mousemove`
- `click`
- `touchstart`

## User Experience Flow

### For Admin/Super Admin Users:
1. **Login**: Session timer starts automatically
2. **Activity**: Timer resets with any user interaction
3. **Warning (13 minutes)**: Modal appears with 2-minute countdown
4. **Options**:
   - **Extend Session**: Resets timer, closes modal
   - **Logout Now**: Immediately logs out user
   - **Close Modal**: Modal closes, countdown continues
5. **Expiration (15 minutes)**: Automatic logout if no action taken

### For Regular Users:
- No modal appears
- Automatic logout after 15 minutes of inactivity
- No warning system

## Testing

### Manual Testing
1. Login as admin/super_admin user
2. Navigate to any page
3. Wait for warning modal (20 seconds in test mode)
4. Test different actions:
   - Click "Extend Session"
   - Click "Logout Now"
   - Close modal and wait for expiration

### Automated Testing
```typescript
// Run in browser console
import { testSessionExpiration } from './utils/sessionTest';
testSessionExpiration();
```

### Test Component
The `SessionTestComponent` provides a test interface:
- Shows current user role
- Provides "Reset Timer" button
- Only visible to admin/super_admin users

## Security Considerations

### Token Management
- JWT tokens expire after 24 hours (backend)
- Frontend validates tokens on each request
- Automatic cleanup of invalid tokens

### Role-Based Security
- Session modal only shows for privileged users
- Regular users have simpler session management
- Admin actions are logged for audit purposes

### Inactivity Detection
- Multiple event types tracked for reliability
- Prevents false positives from system events
- Graceful handling of browser tab switching

## Configuration

### Environment Variables
```env
# Backend JWT configuration
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=24h
```

### Frontend Configuration
```typescript
// Modify these values in AuthContext.tsx
const INACTIVITY_TIMEOUT = 900000; // 15 minutes
const WARNING_TIMEOUT = 120000;    // 2 minutes
```

## Troubleshooting

### Common Issues

1. **Modal not appearing**
   - Check user role (must be admin/super_admin)
   - Verify timer configuration
   - Check browser console for errors

2. **Timer not resetting**
   - Verify event listeners are attached
   - Check for JavaScript errors
   - Ensure user activity is being detected

3. **Immediate logout**
   - Check token validity
   - Verify backend JWT configuration
   - Check network connectivity

### Debug Mode
Enable debug logging by adding to browser console:
```javascript
localStorage.setItem('debug_session', 'true');
```

## Future Enhancements

### Planned Features
1. **Session Analytics**: Track session patterns
2. **Customizable Timeouts**: User-configurable session duration
3. **Multi-tab Support**: Synchronized session across tabs
4. **Remember Me**: Extended sessions for trusted devices

### Performance Optimizations
1. **Debounced Events**: Reduce timer reset frequency
2. **Web Workers**: Background session monitoring
3. **Service Workers**: Offline session management

## API Integration

### Backend Endpoints
- `POST /api/auth/login`: Creates session with JWT
- `POST /api/auth/refresh-token`: Extends session
- `POST /api/auth/logout`: Ends session

### Frontend Integration
- Automatic token refresh on session extension
- Seamless integration with existing auth flow
- No changes required to existing API calls

## Conclusion

The session management system provides a secure, user-friendly experience for admin users while maintaining simplicity for regular users. The implementation is robust, well-tested, and follows security best practices. 