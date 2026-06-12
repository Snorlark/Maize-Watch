import pandas as pd
import json
import logging
from datetime import datetime
from typing import List, Dict
from .mongodb_setup import db_manager
from .data_models import HistoricalWeather

logger = logging.getLogger('corn_system')

class PAGASADataImporter:
    """Import PAGASA historical weather data"""
    
    def __init__(self):
        self.collection = db_manager.get_collection('historical_weather')
    
    def import_from_excel(self, file_path: str) -> bool:
        """Import PAGASA data from Excel file"""
        try:
            logger.info(f"Starting PAGASA data import from: {file_path}")
            
            # Read Excel file
            df = pd.read_excel(file_path)
            
            # Clean and rename columns for easier handling
            column_mapping = {
                'Date(UTC)': 'date',
                'Rainfall': 'rainfall',
                'MaxTemp': 'max_temp',
                'MinTemp': 'min_temp',
                'RelHumidity': 'humidity'
            }
            
            df.rename(columns=column_mapping, inplace=True)
            
            # Data cleaning
            df = self._clean_data(df)
            
            # Convert to documents
            documents = self._create_documents(df)
            
            # Batch insert
            result = self._batch_insert(documents)
            
            logger.info(f"Imported {result} weather records successfully")
            return True
            
        except Exception as e:
            logger.error(f"Failed to import PAGASA data: {e}")
            return False
    
    def _clean_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean the weather data"""
        logger.info("Cleaning weather data...")
        
        # Convert date column
        df['date'] = pd.to_datetime(df['date'])
        
        # Handle missing values
        numeric_columns = ['rainfall', 'max_temp', 'min_temp', 'humidity']
        
        for col in numeric_columns:
            # Convert to numeric, coerce errors to NaN
            df[col] = pd.to_numeric(df[col], errors='coerce')
            
            # Fill NaN with column mean
            df[col].fillna(df[col].mean(), inplace=True)
        
        # Remove any rows with invalid dates
        df = df.dropna(subset=['date'])
        
        # Sort by date
        df = df.sort_values('date')
        
        logger.info(f"Cleaned data: {len(df)} records ready for import")
        return df
    
    def _create_documents(self, df: pd.DataFrame) -> List[Dict]:
        """Convert DataFrame to MongoDB documents"""
        documents = []
        
        for _, row in df.iterrows():
            doc = HistoricalWeather.create_document(
                date=row['date'],
                rainfall=float(row['rainfall']),
                max_temp=float(row['max_temp']),
                min_temp=float(row['min_temp']),
                humidity=float(row['humidity'])
            )
            documents.append(doc)
        
        return documents
    
    def _batch_insert(self, documents: List[Dict]) -> int:
        """Batch insert documents to MongoDB"""
        batch_size = 1000
        total_inserted = 0
        
        for i in range(0, len(documents), batch_size):
            batch = documents[i:i + batch_size]
            
            try:
                # Use upsert to avoid duplicates
                for doc in batch:
                    self.collection.update_one(
                        {"date": doc["date"]},
                        {"$set": doc},
                        upsert=True
                    )
                
                total_inserted += len(batch)
                logger.info(f"Inserted batch: {total_inserted}/{len(documents)} records")
                
            except Exception as e:
                logger.error(f"Failed to insert batch: {e}")
        
        return total_inserted
    
    def verify_import(self) -> Dict:
        """Verify the imported data"""
        try:
            total_count = self.collection.count_documents({})
            
            # Get date range
            oldest = self.collection.find().sort("date", 1).limit(1)
            newest = self.collection.find().sort("date", -1).limit(1)
            
            oldest_date = list(oldest)[0]['date'] if total_count > 0 else None
            newest_date = list(newest)[0]['date'] if total_count > 0 else None
            
            verification = {
                "total_records": total_count,
                "date_range": {
                    "start": oldest_date,
                    "end": newest_date
                },
                "sample_record": self.collection.find_one() if total_count > 0 else None
            }
            
            logger.info(f"Data verification: {total_count} records from {oldest_date} to {newest_date}")
            return verification
            
        except Exception as e:
            logger.error(f"Failed to verify import: {e}")
            return {}

# Usage function
def import_pagasa_data(file_path: str):
    """Main function to import PAGASA data"""
    importer = PAGASADataImporter()
    success = importer.import_from_excel(file_path)
    
    if success:
        verification = importer.verify_import()
        return verification
    return None