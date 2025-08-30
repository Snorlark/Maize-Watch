from datetime import datetime
from typing import Dict, List, Optional, Any
import json

class HistoricalWeather:
    """Historical weather data model"""
    
    @staticmethod
    def create_document(date: datetime, rainfall: float, max_temp: float, 
                       min_temp: float, humidity: float) -> Dict:
        """Create weather document"""
        return {
            "date": date,
            "rainfall_mm": rainfall,
            "max_temp_c": max_temp,
            "min_temp_c": min_temp,
            "avg_temp_c": (max_temp + min_temp) / 2,
            "humidity_percent": humidity,
            "created_at": datetime.utcnow(),
            "location": "Ambulong, Tanauan Batangas"
        }

class GrowthStage:
    """Growth stage tracking model"""
    
    @staticmethod
    def create_document(farmer_id: str, growth_stage: str, 
                       planting_date: datetime, soil_type: str) -> Dict:
        """Create growth stage document"""
        return {
            "farmer_id": farmer_id,
            "growth_stage": growth_stage,
            "planting_date": planting_date,
            "soil_type": soil_type,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
            "is_active": True
        }
    
    @staticmethod
    def update_stage(growth_stage: str) -> Dict:
        """Update growth stage"""
        return {
            "$set": {
                "growth_stage": growth_stage,
                "updated_at": datetime.utcnow()
            }
        }

class StressAssessment:
    """Daily stress assessment model"""
    
    @staticmethod
    def create_document(farmer_id: str, date: datetime, 
                       sensor_data: Dict, stress_analysis: Dict) -> Dict:
        """Create stress assessment document"""
        return {
            "farmer_id": farmer_id,
            "date": date,
            "sensor_averages": sensor_data,
            "stress_levels": stress_analysis,
            "overall_stress": stress_analysis.get('overall', 'optimal'),
            "created_at": datetime.utcnow()
        }

class DailyRecommendation:
    """Daily recommendation model"""
    
    @staticmethod
    def create_document(farmer_id: str, date: datetime, 
                       recommendations: List[Dict], priority_score: int) -> Dict:
        """Create recommendation document"""
        return {
            "farmer_id": farmer_id,
            "date": date,
            "recommendations": recommendations,
            "priority_score": priority_score,
            "status": "pending",  # pending, delivered, acknowledged
            "created_at": datetime.utcnow(),
            "delivered_at": None
        }
    
    @staticmethod
    def mark_delivered() -> Dict:
        """Mark recommendation as delivered"""
        return {
            "$set": {
                "status": "delivered",
                "delivered_at": datetime.utcnow()
            }
        }

class SystemConfig:
    """System configuration model"""
    
    @staticmethod
    def create_document(config_type: str, config_data: Dict) -> Dict:
        """Create system config document"""
        return {
            "config_type": config_type,
            "config_data": config_data,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
            "is_active": True
        }