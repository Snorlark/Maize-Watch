from typing import Dict, List, Tuple, Any, Optional
import pandas as pd

def evaluate_corn_health(row):
    """
    Evaluate corn health based on optimal parameter ranges for each growth stage.
    Returns a detailed analysis of the crop's condition and issues.
    """
    # Optimal ranges per corn growth stage 
    stage_ranges = {
        "Emergence (VE)": {
            "temperature": (25, 30, "°C"),
            "humidity": (70, 85, "%"),
            "soil_moisture": (60, 80, "%"),
            "ph": (5.5, 7.5, "pH"),
            "light": (15000, 25000, "lux")
        },
        "Early Vegetative (V2–V4)": {
            "temperature": (26, 33, "°C"),
            "humidity": (65, 80, "%"),
            "soil_moisture": (60, 80, "%"),
            "ph": (5.5, 7.5, "pH"),
            "light": (30000, 45000, "lux")
        },
        "Mid Vegetative (V5–VT)": {
            "temperature": (27, 33, "°C"),
            "humidity": (60, 80, "%"),
            "soil_moisture": (60, 80, "%"),
            "ph": (5.5, 7.5, "pH"),
            "light": (40000, 50000, "lux")
        },
        "Reproductive (R1–R3)": {
            "temperature": (27, 35, "°C"),
            "humidity": (65, 80, "%"),
            "soil_moisture": (80, 100, "%"),
            "ph": (5.5, 7.5, "pH"),
            "light": (50000, 70000, "lux")
        },
        "Maturing (R4–R5)": {
            "temperature": (25, 32, "°C"),
            "humidity": (55, 75, "%"),
            "soil_moisture": (60, 80, "%"),
            "ph": (5.5, 7.5, "pH"),
            "light": (35000, 50000, "lux")
        },
        "Maturity/Harvest (R6)": {
            "temperature": (25, 30, "°C"),
            "humidity": (50, 70, "%"),
            "soil_moisture": (60, 75, "%"),
            "ph": (5.5, 7.5, "pH"),
            "light": (0, 99999, "lux")
        }
    }

    # Get corn stage with fallback to default if missing or None
    stage = row.get("corn_stage")
    if stage is None:
        print("Warning: corn_stage is None, defaulting to 'Mid Vegetative (V5–VT)'")
        stage = "Mid Vegetative (V5–VT)"
    
    # Check if stage exists in our known ranges
    if stage not in stage_ranges:
        print(f"Warning: Unknown corn stage '{stage}', defaulting to general analysis")
        return {
            "corn_stage": stage,
            "health_status": "Unknown Stage",
            "issues": {},
            "temperature": row.get("temperature"),
            "humidity": row.get("humidity"),
            "soil_moisture": row.get("soil_moisture"),
            "ph": row.get("ph"),
            "light": row.get("light")
        }

    optimal_ranges = stage_ranges[stage]
    issues = {}

    # Check each parameter against optimal ranges
    for param in ["temperature", "humidity", "soil_moisture", "ph", "light"]:
        # Get the value, handling missing parameters
        value = row.get(param)
        
        # Skip if parameter is None
        if value is None:
            print(f"Warning: Parameter '{param}' is None for corn stage '{stage}'")
            continue
            
        min_val, max_val, unit = optimal_ranges.get(param, (None, None, None))
        
        if min_val is None or max_val is None:
            print(f"Warning: No optimal range defined for '{param}' in stage '{stage}'")
            continue
        
        try:
            # Convert value to float if it's not already numeric
            if not isinstance(value, (int, float)):
                value = float(value)
                
            # Check if value is within optimal range
            if not (min_val <= value <= max_val):
                condition = "low" if value < min_val else "high"
                issues[param] = {
                    "value": value,
                    "condition": condition,
                    "optimal_range": (min_val, max_val),
                    "unit": unit
                }
        except (TypeError, ValueError) as e:
            print(f"Error processing {param}: {e}")
            print(f"Value: {value} (type: {type(value)}), Range: {min_val}-{max_val}")
            continue

    # Determine overall health status
    health_status = "Healthy" if not issues else "Stressed"
    
    # Create results dictionary with all parameters
    result = {
        "corn_stage": stage,
        "health_status": health_status,
        "issues": issues,
        "temperature": row.get("temperature"),
        "humidity": row.get("humidity"),
        "soil_moisture": row.get("soil_moisture"),
        "ph": row.get("ph"),
        "light": row.get("light")
    }
    
    return result

def get_parameter_status(value, optimal_range):
    """
    Get the status of a parameter based on its value and optimal range.
    
    Args:
        value: The parameter value
        optimal_range: A tuple of (min, max) values
        
    Returns:
        Status string ("optimal", "low", or "high")
    """
    if value is None:
        return "unknown"
    
    try:
        min_val, max_val = optimal_range
        
        # Convert value to float if it's not already numeric
        if not isinstance(value, (int, float)):
            value = float(value)
            
        if min_val <= value <= max_val:
            return "optimal"
        elif value < min_val:
            return "low"
        else:
            return "high"
    except (TypeError, ValueError):
        return "unknown"