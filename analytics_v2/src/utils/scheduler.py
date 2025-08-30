import schedule
import time
import json
import logging
from datetime import datetime
import pytz

# Import your complete system
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from analytics.descriptive import descriptive_analytics
from analytics.predictive import predictive_analytics
from analytics.prescriptive import prescriptive_analytics

logger = logging.getLogger('corn_system')

class DailyScheduler:
    """Schedule daily analytics runs"""
    
    def __init__(self):
        with open('config/settings.json', 'r') as f:
            self.config = json.load(f)
        
        self.delivery_time = f"{self.config['timing']['delivery_hour']:02d}:{self.config['timing']['delivery_minute']:02d}"
        
    def run_daily_analytics(self):
        """Run the complete analytics system for all farmers"""
        try:
            logger.info("Starting scheduled daily analytics run")
            
            # Get all active farmers (you can modify this query)
            from database.mongodb_setup import db_manager
            growth_collection = db_manager.get_collection('growth_stages')
            
            active_farmers = growth_collection.find({"is_active": True})
            
            for farmer in active_farmers:
                farmer_id = farmer['farmer_id']
                
                try:
                    # Run complete system
                    descriptive_results = descriptive_analytics.analyze_daily_performance(farmer_id)
                    if descriptive_results:
                        predictive_results = predictive_analytics.analyze_predictions(descriptive_results)
                        if predictive_results:
                            prescriptive_results = prescriptive_analytics.generate_recommendations(
                                descriptive_results, predictive_results
                            )
                            
                            logger.info(f"Analytics completed for farmer {farmer_id}")
                        
                except Exception as e:
                    logger.error(f"Analytics failed for farmer {farmer_id}: {e}")
            
            logger.info("Daily analytics run completed")
            
        except Exception as e:
            logger.error(f"Scheduled run failed: {e}")
    
    def start_scheduler(self):
        """Start the daily scheduler"""
        schedule.every().day.at(self.delivery_time).do(self.run_daily_analytics)
        
        logger.info(f"Scheduler started - daily run at {self.delivery_time}")
        print(f"Daily analytics scheduled for {self.delivery_time}")
        print("Scheduler running... Press Ctrl+C to stop")
        
        try:
            while True:
                schedule.run_pending()
                time.sleep(60)  # Check every minute
        except KeyboardInterrupt:
            logger.info("Scheduler stopped by user")
            print("Scheduler stopped")

# Usage
if __name__ == "__main__":
    scheduler = DailyScheduler()
    scheduler.start_scheduler()