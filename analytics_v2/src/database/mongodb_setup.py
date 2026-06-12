import pymongo
import json
import logging
import os
import time
from datetime import datetime
from typing import Dict, List, Optional
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

logger = logging.getLogger('corn_system')

class MongoDBManager:
    def __init__(self):
        """Initialize MongoDB connection with retry mechanism"""
        self.initialized = False
        self.connection_attempts = 0
        self.max_retries = 3
        
        try:
            with open('config/settings.json', 'r') as f:
                self.config = json.load(f)
            
            self.client = None
            self.db = None
            self.collections = {}
            
            # Initialize connection with retry
            while not self.initialized and self.connection_attempts < self.max_retries:
                try:
                    self.connect()
                    self.initialized = True
                    logger.info("MongoDB connection initialized successfully")
                except Exception as e:
                    self.connection_attempts += 1
                    if self.connection_attempts >= self.max_retries:
                        logger.error(f"Failed to connect to MongoDB after {self.max_retries} attempts")
                        raise
                    logger.warning(f"Connection attempt {self.connection_attempts} failed, retrying...")
                    time.sleep(1)  # Wait before retry
                    
        except Exception as e:
            logger.error(f"Failed to initialize MongoDB connection: {e}")
            raise
    
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
        """Establish MongoDB connection with optimized settings"""
        try:
            mongodb_uri = self._get_config_value(self.config['database']['mongodb_uri'])
            
            # Configure connection pool and timeouts
            self.client = pymongo.MongoClient(
                mongodb_uri,
                serverSelectionTimeoutMS=5000,  # 5 second timeout
                socketTimeoutMS=30000,          # 30 second socket timeout
                connectTimeoutMS=10000,         # 10 second connection timeout
                maxPoolSize=100,                # Maximum number of connections
                minPoolSize=10,                 # Minimum number of connections
                retryWrites=True,
                retryReads=True
            )
            
            # Test connection with a ping
            self.client.admin.command('ping')
            
            # Get database reference
            db_name = self.config['database']['database_name']
            self.db = self.client[db_name]
            
            logger.info(f"Connected to MongoDB Atlas: {db_name}")
            
            # Initialize collections
            self._setup_collections()
            
            # Create indexes if they don't exist
            self.create_indexes()
            
        except pymongo.errors.ServerSelectionTimeoutError as e:
            logger.error(f"MongoDB server selection timeout: {e}")
            raise
        except pymongo.errors.ConnectionFailure as e:
            logger.error(f"MongoDB connection failed: {e}")
            raise
        except Exception as e:
            logger.error(f"Unexpected error connecting to MongoDB: {e}")
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
        if not self.client:
            self.connect()
            
        if collection_key not in self.collections:
            # If collection not in config, use the key as collection name
            if collection_key not in self.config['database']['collections'].values():
                logger.warning(f"Collection {collection_key} not in config, using direct access")
                return self.db[collection_key]
            else:
                raise ValueError(f"Collection {collection_key} not found in database configuration")
                
        collection = self.collections.get(collection_key)
        if collection is None:
            raise ValueError(f"Failed to access collection: {collection_key}")
            
        return collection
    
    def close(self):
        """Close database connection"""
        if self.client:
            self.client.close()
            logger.info("MongoDB connection closed")

# Global instance
db_manager = MongoDBManager()