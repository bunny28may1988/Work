import requests
import zipfile
import io
import os
import boto3
import re
from pythonmodules.patterns import LOG_FILE_PATTERN
from pythonmodules.patterns import INITIALIZE_JOB_LOG_PATTERN
from pythonmodules.logger_config import logger
from datetime import datetime


def download_logs(project_name, release_id, azure_devops_pat):
    #Define the URL for the DevOps API
  
    try:
        url = f'https://vsrm.dev.azure.com/kmbl-devops/{project_name}/_apis/release/releases/{release_id}/logs?api-version=7.1'
        # Make a GET request to the API to download the zip file
        headers = {
            'Authorization': f'Basic {azure_devops_pat}'
        }
        response = requests.get(url, headers=headers)
        response.raise_for_status()  # Check if the request was successful
    except requests.exceptions.HTTPError as http_err:
        logger.error(f"HTTP error occurred: {http_err}")    

    try: 
        # Define the path to save the zip file
        zip_file_path = os.path.join(os.getenv('BUILD_ARTIFACTSTAGINGDIRECTORY', '.'), "ReleaseLogs")
        with open(zip_file_path, "wb") as f:
            f.write(response.content)
    except Exception as e:
        logger.error(f"Failed to save zip file: {e}")    
    

    try:
        # Extract the zip file

        with zipfile.ZipFile(zip_file_path, "r") as zip_ref:
            zip_ref.extractall("extracted_logs")
    except zipfile.BadZipFile as zip_err:
        logger.error(f"Failed to extract zip file: {zip_err}")

    try:        
        # Define the directory where the logs are extracted
        extracted_logs_dir = "extracted_logs"        
        # Recursively search for the file that starts with 5_Deploy
        #deploy_file = "7_Deploy.log"
        deploy_file = None
        for root, dirs, files in os.walk(extracted_logs_dir):
            for file in files:
                if LOG_FILE_PATTERN.search(file):
                    deploy_file = os.path.join(root, file)
                    break
            if deploy_file:
                break   
    except Exception as e:
        logger.error(f"Failed to find deploy log file: {e}") 

    #print(deploy_file) 

    if not deploy_file:
        logger.error("Deploy log file not found.")
        return None   
    return deploy_file    

def fetch_values_from_log():
    crq_pattern = re.compile(r'\[CRQ\] --> \[(CHG\d+)\]')
    release_pattern = re.compile(r'\[RELEASE_RELEASENAME\] --> \[(Release-\d+)\]')
    log_file_name = None
    extracted_logs_dir = "extracted_logs" 
    # Walk through the extracted_logs directory to find the log file
    for root, dirs, files in os.walk(extracted_logs_dir):
        for file in files:
            if INITIALIZE_JOB_LOG_PATTERN.search(file):
                log_file_name = os.path.join(root, file)
                break
    print(log_file_name)            
        
    try:
        with open(log_file_name, 'r') as file:
            log_content = file.read()
            crq_match = crq_pattern.search(log_content)
            release_match = release_pattern.search(log_content)
                    
            crq_value = crq_match.group(1) if crq_match else None
            release_value = release_match.group(1) if release_match else None
            print(crq_value, release_value)
            return crq_value, release_value         
                    
    except FileNotFoundError as file_err:
        logger.error(f"File not found error reading log file: {file_err}")
        return None, None
    except IOError as io_err:
        logger.error(f"IO error reading log file: {io_err}")
        return None, None

def create_s3_key(base_name):
    try: 
        # Get the current date and time
        now = datetime.now()   
        # Extract year, month, day
        year = now.strftime("%Y")
        month = now.strftime("%m")
        day = now.strftime("%d")   
        # Get the current epoch time in seconds
        epoch_time = int(time.time())   
        # Construct the S3 key using the date and epoch time
        s3_key = f"{year}/{month}/{day}/{epoch_time}/{base_name}"   
        return s3_key
    except Exception as e:
        logger.error(f"Failed to create S3 key: {e}")
        return None    

def write_to_s3(file_name, bucket_name, s3_key):
    try:
        s3_client = boto3.client('s3')
        s3_client.upload_file(file_name, bucket_name, s3_key)        
    except boto3.exceptions.S3UploadFailedError as e:
        logger.error(f"Failed to upload file to S3: {e}") 