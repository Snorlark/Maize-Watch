#!/usr/bin/env python3
"""
Corn Growth Monitoring System - Flask Web Server
Provides REST API endpoints for analytics services
"""

import os
import sys
import json
import time
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS

# Add src to path for imports
sys.path.append('src')

from src.utils.logger import setup_logger
from src.analytics.descriptive import descriptive_analytics
from src.analytics.predictive import predictive_analytics
from src.analytics.prescriptive import prescriptive_analytics

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Global start time for uptime calculation
start_time = time.time()

# Setup logger
logger = setup_logger()

@app.route('/health')
def health_check():
    """
    Health check endpoint for monitoring
    Returns 200 if service is healthy
    """
    current_time = time.time()
    uptime_seconds = current_time - start_time
    
    healthcheck = {
        'status': 'healthy',
        'uptime': uptime_seconds,
        'uptime_human': f'{int(uptime_seconds // 3600)}h {int((uptime_seconds % 3600) // 60)}m',
        'message': 'Analytics service is healthy',
        'timestamp': current_time,
        'service': 'analytics-service',
        'environment': os.getenv('FLASK_ENV', 'development')
    }
    
    try:
        # Add custom health checks here:
        # - Database connection test
        # - ML model loaded check
        # - External API availability
        
        return jsonify(healthcheck), 200
    
    except Exception as e:
        healthcheck['status'] = 'unhealthy'
        healthcheck['message'] = str(e)
        healthcheck['error'] = True
        return jsonify(healthcheck), 503

@app.route('/analytics/descriptive', methods=['POST'])
def get_descriptive_analytics():
    """
    Get descriptive analytics for a farmer
    POST /analytics/descriptive
    Body: {"farmer_id": "string", "field_id": "string" (optional), "use_today": bool (optional)}
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        farmer_id = data.get('farmer_id')
        if not farmer_id:
            return jsonify({'error': 'farmer_id is required'}), 400
        
        field_id = data.get('field_id')
        use_today = data.get('use_today', True)
        
        # Convert string IDs to ObjectId format for MongoDB compatibility
        from bson import ObjectId
        try:
            if len(str(farmer_id)) == 24:
                farmer_id = ObjectId(farmer_id)
            if field_id and len(str(field_id)) == 24:
                field_id = ObjectId(field_id)
        except:
            # If not valid ObjectId, use as string
            pass
        
        logger.info(f"Running descriptive analytics for farmer {farmer_id}, field {field_id or 'ALL'}")
        
        if field_id:
            # Single field analysis
            results = descriptive_analytics.analyze_daily_performance(
                farmer_id, use_today=use_today, field_id=field_id
            )
        else:
            # Multi-field analysis
            results = descriptive_analytics.analyze_all_fields_performance(
                farmer_id, use_today=use_today
            )
        
        if not results:
            return jsonify({'error': 'Failed to generate descriptive analytics'}), 500
        
        return jsonify({
            'success': True,
            'data': results,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"Error in descriptive analytics: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/analytics/predictive', methods=['POST'])
def get_predictive_analytics():
    """
    Get predictive analytics based on descriptive data
    POST /analytics/predictive
    Body: {"descriptive_data": {...}}
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        descriptive_data = data.get('descriptive_data')
        if not descriptive_data:
            return jsonify({'error': 'descriptive_data is required'}), 400
        
        logger.info("Running predictive analytics")
        
        results = predictive_analytics.analyze_predictions(descriptive_data)
        
        if not results:
            return jsonify({'error': 'Failed to generate predictive analytics'}), 500
        
        return jsonify({
            'success': True,
            'data': results,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"Error in predictive analytics: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/analytics/prescriptive', methods=['POST'])
def get_prescriptive_analytics():
    """
    Get prescriptive analytics (recommendations)
    POST /analytics/prescriptive
    Body: {"descriptive_data": {...}, "predictive_data": {...}, "field_id": "string" (optional)}
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        descriptive_data = data.get('descriptive_data')
        predictive_data = data.get('predictive_data')
        field_id = data.get('field_id')
        
        if not descriptive_data or not predictive_data:
            return jsonify({'error': 'descriptive_data and predictive_data are required'}), 400
        
        logger.info(f"Running prescriptive analytics for field {field_id or 'ALL'}")
        
        if field_id:
            # Single field prescriptive analysis
            results = prescriptive_analytics.generate_recommendations(
                descriptive_data, predictive_data, field_id
            )
        else:
            # Multi-field prescriptive analysis
            results = prescriptive_analytics.generate_multi_field_recommendations(
                descriptive_data, predictive_data
            )
        
        if not results:
            return jsonify({'error': 'Failed to generate prescriptive analytics'}), 500
        
        return jsonify({
            'success': True,
            'data': results,
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        logger.error(f"Error in prescriptive analytics: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/analytics/complete', methods=['POST'])
def get_complete_analytics():
    """
    Get complete analytics pipeline (descriptive + predictive + prescriptive)
    POST /analytics/complete
    Body: {"farmer_id": "string", "field_id": "string" (optional)}
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        farmer_id = data.get('farmer_id')
        if not farmer_id:
            return jsonify({'error': 'farmer_id is required'}), 400
        
        field_id = data.get('field_id')
        
        logger.info(f"Running complete analytics pipeline for farmer {farmer_id}, field {field_id or 'ALL'}")
        
        # Step 1: Descriptive Analytics
        if field_id:
            descriptive_results = descriptive_analytics.analyze_daily_performance(
                farmer_id, use_today=True, field_id=field_id
            )
        else:
            descriptive_results = descriptive_analytics.analyze_all_fields_performance(
                farmer_id, use_today=True
            )
        
        if not descriptive_results:
            return jsonify({'error': 'Failed to complete descriptive analysis'}), 500
        
        # Step 2: Predictive Analytics
        predictive_results = predictive_analytics.analyze_predictions(descriptive_results)
        
        if not predictive_results:
            return jsonify({
                'error': 'Failed to complete predictive analysis',
                'descriptive': descriptive_results
            }), 500
        
        # Step 3: Prescriptive Analytics
        if field_id:
            prescriptive_results = prescriptive_analytics.generate_recommendations(
                descriptive_results, predictive_results, field_id
            )
        else:
            prescriptive_results = prescriptive_analytics.generate_multi_field_recommendations(
                descriptive_results, predictive_results
            )
        
        if not prescriptive_results:
            return jsonify({
                'error': 'Failed to generate recommendations',
                'descriptive': descriptive_results,
                'predictive': predictive_results
            }), 500
        
        # Combine all results
        complete_results = {
            'descriptive': descriptive_results,
            'predictive': predictive_results,
            'prescriptive': prescriptive_results,
            'timestamp': datetime.now().isoformat(),
            'farmer_id': farmer_id,
            'field_id': field_id
        }
        
        return jsonify({
            'success': True,
            'data': complete_results
        }), 200
        
    except Exception as e:
        logger.error(f"Error in complete analytics: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/analytics/status')
def get_analytics_status():
    """
    Get current status of analytics service
    """
    return jsonify({
        'service': 'analytics-service',
        'status': 'running',
        'uptime': time.time() - start_time,
        'version': '1.0.0',
        'endpoints': [
            '/health',
            '/analytics/descriptive',
            '/analytics/predictive', 
            '/analytics/prescriptive',
            '/analytics/complete',
            '/analytics/status'
        ]
    }), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    
    print(f'🐍 Analytics service starting...')
    print(f'📡 Port: {port}')
    print(f'🌍 Environment: {os.environ.get("FLASK_ENV", "development")}')
    
    app.run(
        host='0.0.0.0',
        port=port,
        debug=False  # IMPORTANT: Never True in production!
    )
