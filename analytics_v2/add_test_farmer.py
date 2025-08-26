#!/usr/bin/env python3
"""Add a test farmer for descriptive analytics"""

import sys
from datetime import datetime

sys.path.append('src')

from src.database.mongodb_setup import db_manager
from src.database.data_models import GrowthStage

def add_test_farmer():
    """Add a test farmer to the system"""
    
    collection = db_manager.get_collection('growth_stages')
    
    # Create test farmer
    farmer_doc = GrowthStage.create_document(
        farmer_id="FARMER001",
        growth_stage="V5-VT",  # Mid Vegetative
        planting_date=datetime(2025, 6, 9),  # Adjust as needed
        soil_type="Loam"
    )
    
    # Insert or update
    collection.update_one(
        {"farmer_id": "FARMER001"},
        {"$set": farmer_doc},
        upsert=True
    )
    
    print(" Test farmer FARMER001 added with growth stage V5-VT")
    print(" Ready for descriptive analytics testing!")

if __name__ == "__main__":
    add_test_farmer()