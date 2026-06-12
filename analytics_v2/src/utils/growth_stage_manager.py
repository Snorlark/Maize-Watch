from datetime import datetime
from database.mongodb_setup import db_manager
from database.data_models import GrowthStage
import logging

logger = logging.getLogger('corn_system')

class GrowthStageManager:
    """Simple growth stage management"""
    
    @staticmethod
    def set_farmer_stage(farmer_id: str, growth_stage: str, 
                        planting_date: datetime, soil_type: str) -> bool:
        """Set or update farmer's growth stage"""
        try:
            collection = db_manager.get_collection('growth_stages')
            
            # Deactivate previous stages
            collection.update_many(
                {"farmer_id": farmer_id},
                {"$set": {"is_active": False}}
            )
            
            # Create new active stage
            stage_doc = GrowthStage.create_document(
                farmer_id=farmer_id,
                growth_stage=growth_stage,
                planting_date=planting_date,
                soil_type=soil_type
            )
            
            collection.insert_one(stage_doc)
            logger.info(f"/// Set growth stage {growth_stage} for farmer {farmer_id}")
            return True
            
        except Exception as e:
            logger.error(f"xxx Failed to set growth stage: {e}")
            return False
    
    @staticmethod
    def get_farmer_stage(farmer_id: str) -> dict:
        """Get farmer's current growth stage"""
        try:
            collection = db_manager.get_collection('growth_stages')
            stage_doc = collection.find_one(
                {"farmer_id": farmer_id, "is_active": True}
            )
            return stage_doc if stage_doc else {}
        except Exception as e:
            logger.error(f"xxx Failed to get growth stage: {e}")
            return {}

# Example usage function
def setup_test_farmer():
    """Setup a test farmer for testing"""
    return GrowthStageManager.set_farmer_stage(
        farmer_id="test_farmer_001",
        growth_stage="V5-VT",  # Mid Vegetative
        planting_date=datetime(2025, 6, 9),
        soil_type="Loam"
    )