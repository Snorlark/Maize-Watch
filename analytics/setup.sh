#!/bin/bash

# Create Python virtual environment if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
source .venv/bin/activate

# Install or upgrade pip
python3 -m pip install --upgrade pip

# Install required packages
echo "Installing required packages..."
pip install -r requirements.txt

echo "Python environment setup complete!" 