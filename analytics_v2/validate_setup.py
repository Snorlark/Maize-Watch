import os
import json
import sys

def validate_setup():
    """Validate initial setup"""
    errors = []
    
    # Check directories
    required_dirs = [
        'config', 'data', 'src', 'logs',
        'src/analytics', 'src/database', 'src/apis', 'src/utils'
    ]
    
    for dir_path in required_dirs:
        if not os.path.exists(dir_path):
            errors.append(f"Missing directory: {dir_path}")
    
    # Check config files
    config_files = ['config/settings.json', 'config/growth_matrix.json']
    for config_file in config_files:
        if not os.path.exists(config_file):
            errors.append(f"Missing config file: {config_file}")
        else:
            try:
                with open(config_file, 'r') as f:
                    json.load(f)
            except json.JSONDecodeError:
                errors.append(f"Invalid JSON in: {config_file}")
    
    # Check imports
    try:
        import pandas, numpy, scipy, pymongo, requests, schedule
        print("All required libraries installed successfully")
    except ImportError as e:
        errors.append(f"Missing library: {e}")
    
    if errors:
        print("Setup validation failed:")
        for error in errors:
            print(f"  - {error}")
        return False
    else:
        print("Setup validation passed!")
        return True

if __name__ == "__main__":
    validate_setup()