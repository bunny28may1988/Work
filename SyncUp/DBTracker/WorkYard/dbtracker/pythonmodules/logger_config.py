# logger_config.py
import logging

def configure_logger():
    logging.basicConfig(level=logging.ERROR, format='%(asctime)s - %(levelname)s - %(message)s')
    logger = logging.getLogger(__name__)
    return logger

logger = configure_logger()