import ActivityLogService from '../services/activityLog.service.js';

export const logActivity = (action, resource) => {
  return async (req, res, next) => {
    // Store the original end function
    const originalEnd = res.end;

    // Override the end function
    res.end = async function (chunk, encoding) {
      // Restore the original end function
      res.end = originalEnd;

      // Only log if the request was successful (status code 2xx)
      if (res.statusCode >= 200 && res.statusCode < 300) {
        try {
          // Get user info from the request (set by auth middleware)
          const user = req.user;
          if (!user) {
            console.warn('No user found in request for activity logging');
            return originalEnd.call(this, chunk, encoding);
          }

          // Get IP address
          const ipAddress = req.ip || 
                          req.connection.remoteAddress || 
                          req.socket.remoteAddress || 
                          req.connection.socket?.remoteAddress;

          // Get user agent
          const userAgent = req.headers['user-agent'] || 'Unknown';

          // Create log entry
          const logData = {
            userId: user.id,
            userEmail: user.email || 'unknown@email.com',
            userRole: user.role,
            action,
            resource,
            resourceId: req.params.id || null,
            details: {
              method: req.method,
              path: req.path,
              query: req.query,
              body: req.method !== 'GET' ? req.body : undefined,
              statusCode: res.statusCode
            },
            ipAddress,
            userAgent,
            timestamp: new Date()
          };

          // Save the log asynchronously
          ActivityLogService.createLog(logData).catch(error => {
            console.error('Error saving activity log:', error);
          });
        } catch (error) {
          console.error('Error in activity logging middleware:', error);
        }
      }

      // Call the original end function
      return originalEnd.call(this, chunk, encoding);
    };

    next();
  };
}; 