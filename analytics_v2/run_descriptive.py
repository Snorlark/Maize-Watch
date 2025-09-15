#!/usr/bin/env python3
"""
Simple script to run descriptive analytics
"""

import sys
import os
from datetime import datetime, timedelta

# Add src to path
sys.path.append('src')

from src.utils.logger import setup_logger
from src.analytics.descriptive import descriptive_analytics

def main():
    """Run descriptive analytics for a farmer"""
    
    # Setup logger
    logger = setup_logger()
    
    print(" Corn Monitoring - Descriptive Analytics")
    print("=" * 50)
    
    # Get farmer ID from command line argument or use default
    import sys
    farmer_id = sys.argv[1] if len(sys.argv) > 1 else "FARMER001"
    
    print(f" Analyzing for Farmer: {farmer_id}")
    
    # Run descriptive analysis
    results = descriptive_analytics.analyze_daily_performance(farmer_id)
    
    if results:
        # Print simple report
        descriptive_analytics.print_simple_report(results)
        
        severe_params = [
            p.replace("_", " ").title()
            for p, analysis in results['stress_analysis'].items()
            if analysis['stress_level'] == "severe"
        ]
        
        if results['overall_stress'] != "severe" and severe_params:
            print(" NOTE: Overall looks fine, but watch out for these severe issues:")
            for p in severe_params:
                print(f"   - {p}")
        
        # Show what's ready for predictive
        print("\n Ready for Predictive Analytics:")
        print(f"/// Growth stage: {results['growth_stage']}")
        print(f"/// Yesterday's conditions: {len(results['stress_analysis'])} parameters analyzed")
        print(f"/// Overall stress: {results['overall_stress']}")
        print("/// Data saved to database for trend analysis")
        
    else:
        print("XXX Analysis failed. Check logs for details.")

if __name__ == "__main__":
    main()






#  #!/usr/bin/env python3
# """
# Simple script to run descriptive analytics
# """

# import sys
# import os
# from datetime import datetime, timedelta

# # Add src to path
# sys.path.append('src')

# from src.utils.logger import setup_logger
# from src.analytics.descriptive import descriptive_analytics

# def main():
#     """Run descriptive analytics for a farmer"""
    
#     # Setup logger
#     logger = setup_logger()
    
#     print(" Corn Monitoring - Descriptive Analytics")
#     print("=" * 50)
    
#     # Get farmer ID (for now, use a test ID)
#     farmer_id = "FARMER001"  # You can change this
    
#     print(f" Analyzing for Farmer: {farmer_id}")
    
#     # Run descriptive analysis
#     results = descriptive_analytics.analyze_daily_performance(farmer_id)

   
#     if results:
#         # Print simple report
#         descriptive_analytics.print_simple_report(results)
          
#         # Show what's ready for predictive
#         print("\n Ready for Predictive Analytics:")
#         print(f"/// Growth stage: {results['growth_stage']}")
#         print(f"/// Yesterday's conditions: {len(results['stress_analysis'])} parameters analyzed")
#         print(f"/// Overall stress: {results['overall_stress']}")
#         print("/// Data saved to database for trend analysis")
        
#     else:
#         print("XXX Analysis failed. Check logs for details.")

# if __name__ == "__main__":
#     main()
