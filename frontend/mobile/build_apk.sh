#!/bin/bash

# Build script for Maize Watch Mobile APK
# This script sets the correct Java version and builds the release APK

echo "🚀 Building Maize Watch Mobile APK..."

# Set Java 17 for compatibility
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home

echo "📦 Using Java version: $(java -version 2>&1 | head -n 1)"

# Clean the project
echo "🧹 Cleaning project..."
flutter clean

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build the APK
echo "🔨 Building release APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ APK built successfully!"
    echo "📱 APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo "📏 APK size: $(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')"
else
    echo "❌ APK build failed!"
    exit 1
fi 