#!/bin/bash
# ==========================================
# Docker Build Test Script
# ==========================================

echo "🧪 Testing Maize-Watch Docker Build"
echo "================================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"

# Build the Docker image
echo "🔨 Building Docker image..."
docker build -t maize-watch-test .

if [ $? -eq 0 ]; then
    echo "✅ Docker build successful!"
else
    echo "❌ Docker build failed!"
    exit 1
fi

# Test the container
echo "🚀 Testing container startup..."
docker run -d \
  --name maize-watch-test \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e FLASK_ENV=production \
  -e MONGO_URI=mongodb://localhost:27017/test \
  maize-watch-test

# Wait for services to start
echo "⏳ Waiting for services to start (30 seconds)..."
sleep 30

# Test health endpoint
echo "🔍 Testing health endpoint..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health)

if [ "$response" = "200" ]; then
    echo "✅ Health check passed!"
else
    echo "❌ Health check failed! Response code: $response"
fi

# Test backend health
echo "🔍 Testing backend health..."
backend_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)

if [ "$backend_response" = "200" ]; then
    echo "✅ Backend health check passed!"
else
    echo "❌ Backend health check failed! Response code: $backend_response"
fi

# Test analytics health
echo "🔍 Testing analytics health..."
analytics_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/analytics/health)

if [ "$analytics_response" = "200" ]; then
    echo "✅ Analytics health check passed!"
else
    echo "❌ Analytics health check failed! Response code: $analytics_response"
fi

# Show container logs
echo "📋 Container logs:"
docker logs maize-watch-test --tail 20

# Cleanup
echo "🧹 Cleaning up..."
docker stop maize-watch-test
docker rm maize-watch-test

echo "================================================"
echo "🎉 Docker test completed!"
echo "================================================"
