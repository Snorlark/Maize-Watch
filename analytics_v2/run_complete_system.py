#!/usr/bin/env python3
"""
Complete Corn Monitoring System - All Analytics Combined
"""

import sys
from datetime import datetime

sys.path.append('src')

from src.utils.logger import setup_logger
from src.analytics.descriptive import descriptive_analytics
from src.analytics.predictive import predictive_analytics
from src.analytics.prescriptive import prescriptive_analytics

def run_complete_system(farmer_id: str, field_id: str = None):
    """Run the complete analytics system"""
    
    logger = setup_logger()
    
    print("Corn Growth Monitoring System - Complete Analytics")
    print("=" * 60)
    print(f"Farmer ID: {farmer_id}")
    if field_id:
        print(f"Field ID: {field_id}")
    print(f"Analysis Date: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    print("=" * 60)
    
    # Step 1: Descriptive Analytics
    print("\nStep 1: Analyzing yesterday's performance...")
    descriptive_results = descriptive_analytics.analyze_daily_performance(farmer_id)
    
    if not descriptive_results:
        print("FAILED: Could not complete descriptive analysis")
        return None
    
    print(f"COMPLETED: Overall condition is {descriptive_results['overall_stress'].upper()}")
    
    # Step 2: Predictive Analytics
    print("\nStep 2: Generating forecasts and risk assessment...")
    predictive_results = predictive_analytics.analyze_predictions(descriptive_results)
    
    if not predictive_results:
        print("FAILED: Could not complete predictive analysis")
        return {"descriptive": descriptive_results}
    
    print(f"COMPLETED: {predictive_results['forecast_period_days']}-day forecast, overall risk is {predictive_results['risk_assessment']['overall_risk_level'].upper()}")
    
    # Step 3: Prescriptive Analytics
    print("\nStep 3: Generating actionable recommendations...")
    prescriptive_results = prescriptive_analytics.generate_recommendations(
        descriptive_results, predictive_results, field_id
    )
    
    if not prescriptive_results:
        print("FAILED: Could not generate recommendations")
        return {"descriptive": descriptive_results, "predictive": predictive_results}
    
    print(f"COMPLETED: {prescriptive_results['total_recommendations']} recommendations generated with priority score {prescriptive_results['priority_score']}")
    
    # Step 4: Display Final Report
    print_final_report(descriptive_results, predictive_results, prescriptive_results)
    
    return {
        "descriptive": descriptive_results,
        "predictive": predictive_results,
        "prescriptive": prescriptive_results
    }

def print_final_report(descriptive: dict, predictive: dict, prescriptive: dict):
    """Print comprehensive final report"""
    
    print("\n" + "="*60)
    print("DAILY CORN MONITORING REPORT")
    print("="*60)
    
    # Header Info
    print(f"Date: {descriptive['date']}")
    print(f"Growth Stage: {descriptive['growth_stage']}")
    print(f"Overall Condition: {descriptive['overall_stress'].upper()}")
    print(f"Priority Score: {prescriptive['priority_score']}/100")
    
    # Current Conditions
    print(f"\nYESTERDAY'S CONDITIONS:")
    for param, analysis in descriptive['stress_analysis'].items():
        status_icon = analysis['status']
        print(f"{status_icon} {param.replace('_', ' ').title()}: {analysis['stress_level'].upper()}")
        print(f"   Value: {analysis['actual_value']}, Optimal: {analysis['optimal_range'][0]}-{analysis['optimal_range'][1]}")
    
    # Weather Forecast
    weather = predictive['weather_forecast']
    print(f"\n{predictive['forecast_period_days']}-DAY WEATHER FORECAST:")
    print(f"Temperature: {weather['temperature_forecast']['min_temp']}-{weather['temperature_forecast']['max_temp']}°C")
    print(f"Humidity: {weather['humidity_forecast']}%")
    print(f"Rain Probability: {weather['rainfall_probability']['light_rain_probability']}%")
    
    # Risk Assessment
    risks = predictive['risk_assessment']
    print(f"\nRISK ASSESSMENT:")
    print(f"Drought: {risks['drought_risk']['level'].upper()} ({risks['drought_risk']['probability']}%)")
    print(f"Excess Moisture: {risks['excess_moisture_risk']['level'].upper()} ({risks['excess_moisture_risk']['probability']}%)")
    print(f"Temperature Stress: {risks['temperature_stress_risk']['level'].upper()} ({risks['temperature_stress_risk']['probability']}%)")
    print(f"Overall Risk Level: {risks['overall_risk_level'].upper()}")
    
    # Growth Timeline
    growth = predictive['growth_timeline']
    print(f"\nGROWTH PROGRESSION:")
    print(f"Current Stage: {growth['current_stage']}")
    print(f"Next Stage: {growth['next_stage']} (estimated {growth['estimated_days_to_next']} days)")
    print(f"Status: {growth['progression_status'].upper()}")
    
    # Daily Recommendations
    print(f"\nTODAY'S ACTION PLAN >>")
    recommendations = prescriptive['recommendations']
    
    urgent_actions = [r for r in recommendations if r['urgency'] == 'URGENT']
    high_actions = [r for r in recommendations if r['urgency'] == 'HIGH']
    medium_actions = [r for r in recommendations if r['urgency'] == 'MEDIUM']
    
    if urgent_actions:
        print(f"\nURGENT ACTIONS:")
        for i, rec in enumerate(urgent_actions, 1):
            print(f"{i}. {rec['details']}")
            # print(f"   {rec['details']}")
            print(f"   Timeline: {rec['timeline']}")
    
    if high_actions:
        print(f"\nHIGH PRIORITY:")
        for i, rec in enumerate(high_actions, 1):
            print(f"{i}. {rec['details']}")
          #  print(f"   {rec['details']}")
            print(f"   Timeline: {rec['timeline']}")
    
    if medium_actions:
        print(f"\nMEDIUM PRIORITY:")
        for i, rec in enumerate(medium_actions, 1):
            print(f"{i}. {rec['action']}")
            print(f"   Timeline: {rec['timeline']}")
    
    print("\n" + "="*60)
    print("Report generated successfully. Data saved to database.")
    print("="*60)

if __name__ == "__main__":
    import sys
    farmer_id = sys.argv[1] if len(sys.argv) > 1 else "FARMER001"
    field_id = sys.argv[2] if len(sys.argv) > 2 else None
    results = run_complete_system(farmer_id, field_id)