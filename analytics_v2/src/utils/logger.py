import logging
import json
from logging.handlers import RotatingFileHandler
import os

def setup_logger():
    """Setup system logger based on configuration"""
    # Load config
    with open('config/settings.json', 'r') as f:
        config = json.load(f)
    
    # Create logs directory if it doesn't exist
    os.makedirs('logs', exist_ok=True)
    
    # Setup logger
    logger = logging.getLogger('corn_system')
    logger.setLevel(getattr(logging, config['logging']['level']))
    
    # File handler with rotation
    handler = RotatingFileHandler(
        config['logging']['file'],
        maxBytes=10*1024*1024,  # 10MB
        backupCount=config['logging']['backup_count']
    )
    
    # Formatter
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    
    # Console handler for development
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    return logger