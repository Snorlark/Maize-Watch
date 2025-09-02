Backend Maize Watch Structure

backend/
├── src/
│ ├── config/
│ │ ├── database.js # Database configuration
│ │ ├── redis.js # Redis configuration
│ │ └── thingspeak.js # ThingSpeak API config
│ ├── controllers/
│ │ ├── authController.js # Authentication logic
│ │ ├── userController.js # User management
│ │ ├── sensorController.js # Sensor data handling
│ │ ├── farmController.js # Farm management
│ │ └── analyticsController.js # Analytics endpoints
│ ├── middleware/
│ │ ├── auth.js # JWT authentication
│ │ ├── validation.js # Input validation
│ │ ├── errorHandler.js # Global error handler
│ │ ├── rateLimiter.js # Rate limiting
│ │ └── logging.js # Request logging
│ ├── models/
│ │ ├── User.js # User schema
│ │ ├── Farm.js # Farm schema
│ │ ├── Sensor.js # Sensor schema
│ │ └── SensorReading.js # Sensor data schema
│ ├── routes/
│ │ ├── auth.js # Auth routes
│ │ ├── users.js # User routes
│ │ ├── sensors.js # Sensor routes
│ │ ├── farms.js # Farm routes
│ │ └── analytics.js # Analytics routes
│ ├── services/
│ │ ├── authService.js # Authentication business logic
│ │ ├── sensorService.js # Sensor data processing
│ │ ├── analyticsService.js # Analytics calculations
│ │ ├── thingspeakService.js # ThingSpeak integration
│ │ └── notificationService.js # Notifications
│ ├── sockets/
│ │ ├── socketHandlers.js # Main socket handlers
│ │ ├── sensorSocket.js # Real-time sensor data
│ │ └── notificationSocket.js # Real-time notifications
│ ├── utils/
│ │ ├── logger.js # Winston logger setup
│ │ ├── validator.js # Custom validators
│ │ ├── helpers.js # Utility functions
│ │ └── constants.js # App constants
│ └── tests/
│ ├── unit/ # Unit tests
│ ├── integration/ # Integration tests
│ └── fixtures/ # Test data
├── scripts/
│ ├── seed.js # Database seeding
│ └── deploy.sh # Deployment script
├── docs/
│ ├── API.md # API documentation
│ └── DEPLOYMENT.md # Deployment guide
├── .env.example # Environment variables template
├── .gitignore
├── package.json
├── package-lock.json
├── Dockerfile # Docker configuration
├── docker-compose.yml # Local development
├── nginx.conf # Nginx configuration
└── README.md
