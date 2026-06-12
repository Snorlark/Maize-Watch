#!/usr/bin/env python3
"""
Combined analytics runner - descriptive + predictive
"""

import sys
from datetime import datetime

sys.path.append('src')

from src.utils.logger import setup_logger
from src.analytics.descriptive import descriptive_analytics
from src.analytics.predictive import predictive_analytics

def run_combined_analytics(farmer_id: str):
    """Run descriptive + predictive analytics"""
    
    logger = setup_logger()
    
    print("Corn Monitoring - Combined Analytics")
    print("=" * 50)
    
    # Step 1: Run descriptive analytics
    print(f"Step 1: Analyzing yesterday's performance for {farmer_id}...")
    descriptive_results = descriptive_analytics.analyze_daily_performance(farmer_id)
    
    if not descriptive_results:
        print("Failed to get descriptive results. Check logs.")
        return None
    
    print(f"Descriptive completed - Overall stress: {descriptive_results['overall_stress']}")
    
    # Step 2: Run predictive analytics
    print("Step 2: Generating predictions...")
    predictive_results = predictive_analytics.analyze_predictions(descriptive_results)
    
    if not predictive_results:
        print("Failed to get predictive results. Check logs.")
        return descriptive_results
    
    print(f"Predictive completed - {predictive_results['forecast_period_days']} day forecast")
    
    # Step 3: Print combined summary
    print_combined_summary(descriptive_results, predictive_results)
    
    return {
        "descriptive": descriptive_results,
        "predictive": predictive_results
    }

def print_combined_summary(descriptive: dict, predictive: dict):
    """Print simple combined summary"""
    
    print(f"\nCombined Analysis Summary - {descriptive['date']}")
    print("-" * 50)
    
    # Current status
    print(f"Growth Stage: {descriptive['growth_stage']}")
    print(f"Overall Condition: {descriptive['overall_stress'].upper()}")
    
    # Weather forecast
    weather = predictive['weather_forecast']
    print(f"\n{predictive['forecast_period_days']}-Day Weather Forecast:")
    print(f"Temperature: {weather['temperature_forecast']['min_temp']}-{weather['temperature_forecast']['max_temp']}°C")
    print(f"Humidity: {weather['humidity_forecast']}%")
    print(f"Rain Probability: {weather['rainfall_probability']['light_rain_probability']}%")
    
    # Risk assessment
    risks = predictive['risk_assessment']
    print(f"\nRisk Assessment:")
    print(f"Drought Risk: {risks['drought_risk']['level'].upper()} ({risks['drought_risk']['probability']}%)")
    print(f"Excess Moisture: {risks['excess_moisture_risk']['level'].upper()} ({risks['excess_moisture_risk']['probability']}%)")
    print(f"Temperature Stress: {risks['temperature_stress_risk']['level'].upper()} ({risks['temperature_stress_risk']['probability']}%)")
    print(f"Overall Risk: {risks['overall_risk_level'].upper()}")
    
    # Growth timeline
    growth = predictive['growth_timeline']
    print(f"\nGrowth Progression:")
    print(f"Current: {growth['current_stage']}")
    print(f"Next: {growth['next_stage']} (in ~{growth['estimated_days_to_next']} days)")
    print(f"Status: {growth['progression_status']}")
    
    print(f"\nReady for prescriptive analytics...")

if __name__ == "__main__":
    import sys
    farmer_id = sys.argv[1] if len(sys.argv) > 1 else "FARMER001"
    run_combined_analytics(farmer_id)