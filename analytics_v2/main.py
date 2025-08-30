#!/usr/bin/env python3
"""
Corn Growth Monitoring System - Main Application
"""

import sys
import argparse
from datetime import datetime

sys.path.append('src')

from src.utils.logger import setup_logger
from src.utils.scheduler import DailyScheduler

def main():
    """Main application entry point"""
    
    parser = argparse.ArgumentParser(description='Corn Growth Monitoring System')
    parser.add_argument('--mode', choices=['run', 'schedule'], default='run',
                       help='Run mode: single run or start scheduler')
    parser.add_argument('--farmer', default='FARMER001',
                       help='Farmer ID for single run mode')
    
    args = parser.parse_args()
    
    # Setup logger
    logger = setup_logger()
    
    if args.mode == 'run':
        # Single run mode
        from run_complete_system import run_complete_system
        print("Running single analytics cycle...")
        results = run_complete_system(args.farmer)
        
    elif args.mode == 'schedule':
        # Scheduler mode
        print("Starting daily scheduler...")
        scheduler = DailyScheduler()
        scheduler.start_scheduler()

if __name__ == "__main__":
    main()