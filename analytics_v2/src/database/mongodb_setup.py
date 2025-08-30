import pymongo
import json
import logging
import os
from datetime import datetime
from typing import Dict, List, Optional
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

logger = logging.getLogger('corn_system')

class MongoDBManager:
    def __init__(self):
        """Initialize MongoDB connection"""
        with open('config/settings.json', 'r') as f:
            self.config = json.load(f)
        
        self.client = None
        self.db = None
        self.collections = {}
        self.connect()
    
    def _get_config_value(self, value: str) -> str:
        """Get configuration value, handle env variables"""
        if value.startswith('env:'):
            env_var = value[4:]  # Remove 'env:' prefix
            env_value = os.getenv(env_var)
            if not env_value:
                raise ValueError(f"Environment variable {env_var} not found")
            return env_value
        return value
    
    def connect(self):
        """Establish MongoDB connection"""
        try:
            mongodb_uri = self._get_config_value(self.config['database']['mongodb_uri'])
            self.client = pymongo.MongoClient(mongodb_uri)
            self.db = self.client[self.config['database']['database_name']]
            
            # Test connection
            self.client.admin.command('ping')
            logger.info("Connected to MongoDB Atlas successfully")
            
            # Initialize collections
            self._setup_collections()
            
        except Exception as e:
            logger.error(f"Failed to connect to MongoDB: {e}")
            raise
    
    def _setup_collections(self):
        """Setup database collections"""
        collection_names = self.config['database']['collections']
        
        for key, name in collection_names.items():
            self.collections[key] = self.db[name]
            logger.info(f"Collection ready: {name}")
    
    def create_indexes(self):
        """Create database indexes for performance"""
        try:
            # Historical weather indexes
            self.collections['historical_weather'].create_index([
                ("date", pymongo.ASCENDING)
            ])
            
            # Growth stages indexes  
            self.collections['growth_stages'].create_index([
                ("farmer_id", pymongo.ASCENDING),
                ("created_at", pymongo.DESCENDING)
            ])
            
            # Daily recommendations indexes
            self.collections['daily_recommendations'].create_index([
                ("date", pymongo.DESCENDING),
                ("farmer_id", pymongo.ASCENDING)
            ])
            
            # Stress assessments indexes
            self.collections['stress_assessments'].create_index([
                ("date", pymongo.DESCENDING),
                ("farmer_id", pymongo.ASCENDING)
            ])
            
            logger.info("Database indexes created successfully")
            
        except Exception as e:
            logger.error(f"Failed to create indexes: {e}")
    
    def get_collection(self, collection_key: str):
        """Get collection by key"""
        return self.collections.get(collection_key)
    
    def close(self):
        """Close database connection"""
        if self.client:
            self.client.close()
            logger.info("MongoDB connection closed")

# Global instance
db_manager = MongoDBManager()