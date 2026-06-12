#!/usr/bin/env python3
"""
Check farms and fields in MongoDB
"""
import os
import sys
from bson import ObjectId

# Add the src directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from database.mongodb_setup import db_manager

def check_farms():
    """Check farms and fields in database"""
    
    # Connect to database
    db_manager.connect()
    
    # Get collections
    farms_collection = db_manager.get_collection("farms")
    
    # Get all farms
    farms = list(farms_collection.find())
    print(f"🏡 Found {len(farms)} farms:")
    
    for i, farm in enumerate(farms):
        print(f"\n{i+1}. Farm: {farm.get('farmName', 'Unknown')}")
        print(f"   ID: {farm['_id']}")
        print(f"   Owner: {farm.get('owner', 'Unknown')}")
        print(f"   Fields: {len(farm.get('fields', []))}")
        
        fields = farm.get('fields', [])
        for j, field in enumerate(fields):
            print(f"     {j+1}. Field: {field.get('fieldName', 'Unknown')}")
            print(f"        ID: {field.get('field_id', 'No ID')}")
            print(f"        Soil Type: {field.get('soilType', 'Unknown')}")
            print(f"        Growth Stage: {field.get('growthStage', 'Unknown')}")

if __name__ == "__main__":
    check_farms()
