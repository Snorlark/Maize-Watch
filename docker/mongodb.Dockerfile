FROM mongo:7.0

# Set environment variables
ENV MONGO_INITDB_ROOT_USERNAME=admin
ENV MONGO_INITDB_ROOT_PASSWORD=password
ENV MONGO_INITDB_DATABASE=maizewatch

# Create initialization script
COPY <<EOF /docker-entrypoint-initdb.d/init.js
db = db.getSiblingDB('maizewatch');

// Create collections
db.createCollection('users');
db.createCollection('farms');
db.createCollection('sensors');
db.createCollection('sensorreadings');
db.createCollection('fields');

// Create indexes
db.users.createIndex({ "email": 1 }, { unique: true });
db.farms.createIndex({ "userId": 1 });
db.sensors.createIndex({ "farmId": 1 });
db.sensorreadings.createIndex({ "sensor": 1, "timestamp": -1 });
db.sensorreadings.createIndex({ "farm": 1, "timestamp": -1 });
db.fields.createIndex({ "farmId": 1 });

print('Database initialized successfully');
EOF

EXPOSE 27017
