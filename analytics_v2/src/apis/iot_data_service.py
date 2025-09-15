import os
import logging
from datetime import datetime, timedelta
from typing import Optional, Dict, Any, List

import pytz
from pymongo import MongoClient
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger('corn_system')


class IoTDataService:
    """
    Simple IoT data reader for daily averages from MongoDB Atlas (IoT cluster).

    Expected collection schema (collection: sensor_readings):
      {
        timestamp: ISODate,
        field_id: String,
        measurements: {
          temperature: Number,
          humidity: Number,
          soil_moisture: Number,
          soil_ph: Number,
          light_intensity: Number
        }
      }
    """

    def __init__(self) -> None:
        uri = os.getenv('MONGODB_IOT_URI') or os.getenv('MONGO_IOT_URI')
        if not uri:
            logger.warning('MONGODB_IOT_URI not set; IoT data service disabled')
            self._client = None
            self._collection = None
            return

        try:
            self._client = MongoClient(uri)
            # Use database from URI; access collection by explicit name
            db_name = self._client.get_database().name  # resolved from URI
            db = self._client[db_name]
            self._collection = db['sensor_readings']
        except Exception as e:
            logger.error(f'Failed to initialize IoT MongoDB client: {e}')
            self._client = None
            self._collection = None

        self._timezone = pytz.timezone(os.getenv('SYSTEM_TIMEZONE', 'Asia/Manila'))

    def get_daily_averages(
        self,
        date: Optional[datetime] = None,
        field_id: Optional[str] = None,
    ) -> Optional[Dict[str, Any]]:
        """
        Compute daily averages for the 24h window (06:00 to next day 06:00 local).
        If field_id is provided, filter by it. Returns None if no data.
        """
        if not self._collection:
            return None

        if date is None:
            date = datetime.now(self._timezone).date() - timedelta(days=1)
            date = datetime.combine(date, datetime.min.time().replace(hour=6))

        # Time window 06:00 local to +24h
        start_local = date if isinstance(date, datetime) else datetime.combine(date, datetime.min.time().replace(hour=6))
        end_local = start_local + timedelta(hours=24)
        start_utc = self._timezone.localize(start_local).astimezone(pytz.UTC)
        end_utc = self._timezone.localize(end_local).astimezone(pytz.UTC)

        match: Dict[str, Any] = {
            'timestamp': {
                '$gte': start_utc,
                '$lt': end_utc,
            }
        }
        if field_id:
            match['field_id'] = field_id

        try:
            pipeline: List[Dict[str, Any]] = [
                { '$match': match },
                { '$project': {
                    'temperature': '$measurements.temperature',
                    'humidity': '$measurements.humidity',
                    'soil_moisture': '$measurements.soil_moisture',
                    'soil_ph': '$measurements.soil_ph',
                    'light_intensity': '$measurements.light_intensity',
                }},
                { '$group': {
                    '_id': None,
                    'temperature': { '$avg': '$temperature' },
                    'humidity': { '$avg': '$humidity' },
                    'soil_moisture': { '$avg': '$soil_moisture' },
                    'soil_ph': { '$avg': '$soil_ph' },
                    'light_intensity': { '$avg': '$light_intensity' },
                    'data_points': { '$sum': 1 },
                }}
            ]

            result = list(self._collection.aggregate(pipeline))
            if not result:
                logger.warning(f'No IoT data found for window {start_utc} to {end_utc} (field_id={field_id})')
                return None

            agg = result[0]
            # Round values to sensible precision
            def rv(x: Any) -> Optional[float]:
                try:
                    return round(float(x), 2) if x is not None else None
                except Exception:
                    return None

            return {
                'temperature': rv(agg.get('temperature')),
                'humidity': rv(agg.get('humidity')),
                'soil_moisture': rv(agg.get('soil_moisture')),
                'soil_ph': rv(agg.get('soil_ph')),
                'light_intensity': rv(agg.get('light_intensity')),
                'data_points': int(agg.get('data_points', 0)),
                'date': start_local.date().isoformat(),
            }

        except Exception as e:
            logger.error(f'IoT aggregation failed: {e}')
            return None


iot_data_service = IoTDataService()


