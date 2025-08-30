import requests
import json
import logging
import os
from datetime import datetime, timedelta
from typing import Dict, Optional, List
from dotenv import load_dotenv
import pytz

# Load environment variables
load_dotenv()

logger = logging.getLogger('corn_system')

class ThingSpeakClient:
    """ThingSpeak API client for sensor data"""
    
    def __init__(self):
        """Initialize ThingSpeak client"""
        with open('config/settings.json', 'r') as f:
            config = json.load(f)
        
        self.base_url = config['thingspeak']['base_url']
        self.channel_id = self._get_config_value(config['thingspeak']['channel_id'])
        self.read_api_key = self._get_config_value(config['thingspeak']['read_api_key'])
        self.fields = config['thingspeak']['fields']
        self.timezone = pytz.timezone(config['system']['timezone'])
    
    def _get_config_value(self, value: str) -> str:
        """Get configuration value, handle env variables"""
        if value.startswith('env:'):
            env_var = value[4:]  # Remove 'env:' prefix
            env_value = os.getenv(env_var)
            if not env_value:
                raise ValueError(f"Environment variable {env_var} not found")
            return env_value
        return value
    
    def get_daily_averages(self, date: datetime = None) -> Optional[Dict]:
        """Get 24-hour averages for a specific date"""
        if date is None:
            # Get yesterday's data by default
            date = datetime.now(self.timezone).date() - timedelta(days=1)
        
        try:
            # Set time range (6 AM to 6 AM next day)
            start_time = datetime.combine(date, datetime.min.time().replace(hour=6))
            end_time = start_time + timedelta(hours=24)
            
            # Convert to UTC for API
            start_utc = self.timezone.localize(start_time).astimezone(pytz.UTC)
            end_utc = self.timezone.localize(end_time).astimezone(pytz.UTC)
            
            logger.info(f" Fetching ThingSpeak data from {start_utc} to {end_utc}")
            
            # Build API URL
            url = f"{self.base_url}{self.channel_id}/feeds.json"
            params = {
                'api_key': self.read_api_key,
                'start': start_utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'end': end_utc.strftime('%Y-%m-%dT%H:%M:%SZ'),
                'results': 8000  # Max results to ensure we get all data
            }
            
            # Make API request
            response = requests.get(url, params=params, timeout=30)
            response.raise_for_status()
            
            data = response.json()
            feeds = data.get('feeds', [])
            
            if not feeds:
                logger.warning(f"No data found for {date}")
                return None
            
            # Calculate averages
            averages = self._calculate_averages(feeds)
            
            logger.info(f"Retrieved {len(feeds)} readings, calculated averages for {date}")
            return averages
            
        except requests.RequestException as e:
            logger.error(f"ThingSpeak API error: {e}")
            return None
        except Exception as e:
            logger.error(f"Error processing ThingSpeak data: {e}")
            return None
    
    def _calculate_averages(self, feeds: List[Dict]) -> Dict:
        """Calculate averages from feed data"""
        totals = {field: 0 for field in self.fields.values()}
        counts = {field: 0 for field in self.fields.values()}
        
        for feed in feeds:
            for param, field in self.fields.items():
                value = feed.get(field)
                if value is not None and value != '':
                    try:
                        float_value = float(value)
                        totals[field] += float_value
                        counts[field] += 1
                    except (ValueError, TypeError):
                        continue
        
        # Calculate averages
        averages = {}
        field_mapping = {v: k for k, v in self.fields.items()}  # Reverse mapping
        
        for field, total in totals.items():
            count = counts[field]
            param_name = field_mapping[field]
            
            if count > 0:
                averages[param_name] = round(total / count, 2)
            else:
                averages[param_name] = None
                logger.warning(f"No valid data for {param_name}")
        
        # Add metadata
        averages['data_points'] = max(counts.values()) if counts else 0
        averages['date'] = feeds[0]['created_at'][:10] if feeds else None
        
        return averages
    
    def test_connection(self) -> bool:
        """Test ThingSpeak API connection"""
        try:
            url = f"{self.base_url}{self.channel_id}/feeds.json"
            params = {'api_key': self.read_api_key}
            
            response = requests.get(url, params=params, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            channel_name = data.get('name', 'Unknown')
            
            logger.info(f"ThingSpeak connection successful - Channel: {channel_name}")
            return True
            
        except Exception as e:
            logger.error(f"ThingSpeak connection failed: {e}")
            return False

# Global instance
thingspeak_client = ThingSpeakClient()