#!/usr/bin/env python3
"""
Simple Python test script to verify Python environment
"""

import sys
import os

print("Python version:", sys.version)
print("Python executable:", sys.executable)
print("Current working directory:", os.getcwd())
print("Python path:", sys.path)
print("Environment variables:")
for key, value in os.environ.items():
    if 'PYTHON' in key or 'MONGO' in key or 'THINGSPEAK' in key:
        print(f"  {key}: {value}")

print("✅ Python environment test completed successfully!")
