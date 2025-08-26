"""
Corn Monitoring System - Setup & Initialization Script
"""

import os
import sys
import json
import logging
from datetime import datetime

# Add src to path
sys.path.append('src')

from utils.logger import setup_logger
from database.mongodb_setup import db_manager
from database.pagasa_importer import import_pagasa_data
from apis.thingspeak_client import thingspeak_client

def main():
    """Main setup function"""
    print(" Corn Monitoring System - Setup & Initialization")
    print("=" * 60)
    
    # Setup logger
    logger = setup_logger()
    logger.info(" Starting system setup...")
    
    # Step 1: Test MongoDB connection
    print("\n Step 1: Testing MongoDB connection...")
    try:
        db_manager.create_indexes()
        print("/// MongoDB connection successful")
    except Exception as e:
        print(f"XXX MongoDB connection failed: {e}")
        return False
    
    # Step 2: Test ThingSpeak connection
    print("\n Step 2: Testing ThingSpeak connection...")
    if thingspeak_client.test_connection():
        print("/// ThingSpeak connection successful")
    else:
        print("XXX ThingSpeak connection failed")
        return False
    
    # Step 3: Import PAGASA data
    print("\n Step 3: PAGASA data import...")
    excel_file = input("Enter path to PAGASA Excel file: ").strip()
    
    if not os.path.exists(excel_file):
        print(f"XXX File not found: {excel_file}")
        return False
    
    verification = import_pagasa_data(excel_file)
    if verification:
        print(f"/// Imported {verification['total_records']} weather records")
        print(f" Date range: {verification['date_range']['start']} to {verification['date_range']['end']}")
    else:
        print("XXX PAGASA data import failed")
        return False
    
    # Step 4: Load growth matrix to database
    print("\n Step 4: Loading growth matrix...")
    try:
        with open('config/growth_matrix.json', 'r') as f:
            growth_matrix = json.load(f)
        
        config_collection = db_manager.get_collection('system_config')
        config_collection.update_one(
            {"config_type": "growth_matrix"},
            {"$set": {
                "config_type": "growth_matrix",
                "config_data": growth_matrix,
                "updated_at": datetime.utcnow(),
                "is_active": True
            }},
            upsert=True
        )
        print("/// Growth matrix loaded to database")
    except Exception as e:
        print(f"XXX Failed to load growth matrix: {e}")
        return False
    
    # Setup complete
    print("\n Setup completed successfully!")
    print("=" * 60)
    print("Next steps:")
    print("1. Update ThingSpeak credentials in config/settings.json")
    print("2. Test sensor data retrieval")
    print("3. Proceed to analytics implementation")
    
    return True

if __name__ == "__main__":
    main()