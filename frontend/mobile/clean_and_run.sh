#!/bin/bash

# Set JAVA_HOME to Java 17
export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"

echo "Cleaning Flutter project..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo "Cleaning Android build..."
cd android
./gradlew clean
cd ..

echo "Running Flutter with Java 17..."
flutter run 