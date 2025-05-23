def format_report(analysis, recommendations):
    """
    Format the analysis results and recommendations into a readable report.
    """
    report = []
    report.append(f"Corn Growth Stage: {analysis['corn_stage']}")
    report.append(f"Crop Status: {analysis['health_status']}")
    
    # Add stress level if available
    if "stress_level" in analysis:
        report.append(f"Stress Level: {analysis['stress_level']}")
    
    # Add yield prediction if available 
    # DISREGARD PERO DI WAG MUNA TANGGALIN !
    if "predictions" in analysis and "yield_class" in analysis["predictions"]:
        yield_class = analysis["predictions"]["yield_class"]["prediction"]
        confidence = analysis["predictions"]["yield_class"]["confidence"]
        report.append(f"Predicted Yield: {yield_class.upper()} (confidence: {confidence}%)")
    
    # Add parameter importance if available (RANK BASED NA I2)
    # basically yung random forest yung nag rrank neto and binabase nya sa score kung anong parameter yung may pinaka malayo sa optimal range and so dun ako nag base ng ranking pero aint sure that's the right basis for that xD
    if "predictions" in analysis and "parameter_importance" in analysis["predictions"]:
        if "top_parameters" in analysis["predictions"]["parameter_importance"]:
            top_params = analysis["predictions"]["parameter_importance"]["top_parameters"]
            if top_params:
                report.append("\nKey Parameters by Importance:")
                for param in top_params:
                    importance = analysis["predictions"]["parameter_importance"]["importance_scores"][param]
                    report.append(f"* {param.title()}: {round(importance * 100, 1)}% impact")
    
    # Add issues if crop is stressed (RANK BASED NA RIN PERO MAY ERROR PA TEKA)
    if analysis["health_status"] == "Stressed":
        # First check if we have ML-identified important issues
        if "important_issues" in analysis and analysis["important_issues"]:
            report.append("\nCurrent Issues (reason for stress, ranked by importance):")
            for issue in analysis["important_issues"]:
                param = issue["parameter"]
                min_val, max_val = issue["optimal_range"]
                unit = issue["unit"]
                condition = issue["condition"]
                value = issue["value"]
                importance = round(issue["importance_score"] * 100, 1)
                
                report.append(f"* {param.title()} is {condition}: {value} {unit} (Optimal: {min_val}-{max_val} {unit}) - {importance}% impact")
        else:
            # Otherwise show all issues
            report.append("\nCurrent Issues (reason for stress):")
            for param, details in analysis["issues"].items():
                min_val, max_val = details["optimal_range"]
                unit = details["unit"]
                condition = details["condition"]
                value = details["value"]
                
                report.append(f"* {param.title()} is {condition}: {value} {unit} (Optimal: {min_val}-{max_val} {unit})")
    
    report.append("\nRecommended Actions:")
    for rec in recommendations:
        report.append(f"* {rec}")
    
    return "\n".join(report)