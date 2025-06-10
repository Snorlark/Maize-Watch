#!/bin/bash

# Set JAVA_HOME to Java 17
export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"

# Verify Java version
echo "Using Java version:"
java -version

# Run the Flutter command passed as arguments
echo "Running Flutter command: $@"
flutter "$@" 