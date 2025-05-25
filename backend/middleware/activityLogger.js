import ActivityLogger from '../services/ActivityLogger.js';

const logActivity = (action, resource, options = {}) => {
  return async (req, res, next) => {
    // Store original methods to intercept responses
    const originalJson = res.json;
    const originalSend = res.send;
    
    // Override res.json
    res.json = function(data) {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // Extract resource ID from response data or request params
        const resourceId = options.getResourceId ? 
          options.getResourceId(data, req) : 
          (data?._id || data?.id || req.params.id || null);

        // Build details object
        const details = {
          method: req.method,
          endpoint: req.originalUrl,
          statusCode: res.statusCode,
          ...(req.method !== 'GET' && req.body ? { requestBody: req.body } : {}),
          ...(options.includeResponse ? { responseData: data } : {})
        };

        // Log the activity
        ActivityLogger.log({
          userId: req.user._id,
          userEmail: req.user.email,
          userRole: req.user.role,
          action,
          resource,
          resourceId,
          details,
          req
        });
      }
      
      return originalJson.call(this, data);
    };
    
    // Override res.send for non-JSON responses
    res.send = function(data) {
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ActivityLogger.log({
          userId: req.user._id,
          userRole: req.user.role,
          action,
          resource,
          resourceId: req.params.id || null,
          details: {
            method: req.method,
            endpoint: req.originalUrl,
            statusCode: res.statusCode
          },
          req
        });
      }
      
      return originalSend.call(this, data);
    };
    
    next();
  };
};

// Middleware for automatic logging based on HTTP methods
const autoLogActivity = (resource) => {
  return (req, res, next) => {
    const methodToAction = {
      'POST': 'create',
      'PUT': 'update',
      'PATCH': 'update',
      'DELETE': 'delete',
      'GET': 'view'
    };

    const action = `${methodToAction[req.method] || 'action'}_${resource}`;
    return logActivity(action, resource)(req, res, next);
  };
};

export { logActivity, autoLogActivity };