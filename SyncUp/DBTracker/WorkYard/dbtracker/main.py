#import boto3
#from datetime import datetime
#import time
from pythonmodules import *
import csv
import os
#import zipfile
import sys

#release_pipeline_id = os.getenv('PIPELINE_ID', None)
#release_pipeline_name = os.getenv('PIPELINE_NAME', None)
project_name = "FinacleDataPatch"
release_id = 3113
azure_devops_pat = "OkFrRzFCM0tGVHRvSlRHNXVzeVBSU1ZyblNWSHBJWDFzNTJra2F4blZXa1hjbmJmaGhJSFRKUVFKOTlBS0FDQUFBQUFsNGtXVEFBQVNBWkRPMHAwcA=="
#change_ticket = os.getenv('CHANGE_TICKET',None)
release_pipeline_name = None
change_ticket = None
date =  None
connect_identifier =  None
db_instance = None
user =  None
summary = None

def process_ddl_statements(ddl_matches, csvwriter):
    for ddl in ddl_matches:  
        try:
            timestamps = TIMESTAMP_PATTERN.findall(ddl)
            execution_timestamp = timestamps[0] if timestamps else ''            
            ddl = TIMESTAMP_PATTERN.sub('', ddl) 
            ddl_statement = TAB_PATTERN.sub(' ', ddl) 
            csvwriter.writerow([ release_id,release_pipeline_name,date,summary,project_name,change_ticket,db_instance,user,'DDL', ddl_statement, "N/A",execution_timestamp])
        except re.error as re_err:
            logger.error(f"Regex error processing DDL statement: {ddl}")
            logger.error(f"Exception: {re_err}")
        except csv.Error as csv_err:
            logger.error(f"CSV error processing DDL statement: {ddl}")
            logger.error(f"Exception: {csv_err}")    

def process_exec_statements(exec_matches,csvwriter):
    for exect in exec_matches:  
        try:
            timestamps = TIMESTAMP_PATTERN.findall(exect)
            execution_timestamp = timestamps[0] if timestamps else ''            
            execute_statement = TIMESTAMP_PATTERN.sub('', exect)               
            csvwriter.writerow([ release_id,release_pipeline_name,date,summary,project_name,change_ticket,db_instance,user,'EXEC', execute_statement, 'N/A',execution_timestamp])
        except re.error as re_err:
            logger.error(f"Regex error processing EXEC statement: {exect}")
            logger.error(f"Exception: {re_err}")
        except csv.Error as csv_err:
            logger.error(f"CSV error processing EXEC statement: {exect}")
            logger.error(f"Exception: {csv_err}")    

def process_dml_statements(all_dml_matches, csvwriter):
    for dml in all_dml_matches:
        try:
            timestamps = TIMESTAMP_PATTERN.findall(dml)
            execution_timestamp = timestamps[0] if timestamps else ''
            dml = TIMESTAMP_PATTERN.sub('', dml)
            parts = dml.split(';', 1)
            dml_statement = parts[0]
            print(dml_statement)
            second_part = parts[1] if len(parts) > 1 else ''
            number_match = re.search(r'\d+', second_part)
            row_count = number_match.group(0) if number_match else ''
            if dml_statement.strip().upper().startswith('SQL> UPDATE'):
                dml_type = 'UPDATE'
            elif dml_statement.strip().upper().startswith('SQL> INSERT'):
                dml_type = 'INSERT'
            elif dml_statement.strip().upper().startswith('SQL> DELETE'):
                dml_type = 'DELETE'    
            else:
                dml_type = 'UNKNOWN'
            print(dml_type)    
            csvwriter.writerow([release_id, release_pipeline_name, date, summary,project_name,change_ticket, db_instance, user, dml_type, dml_statement + ';', row_count, execution_timestamp])
        except re.error as re_err:
            logger.error(f"Regex error processing DML statement: {dml}")
            logger.error(f"Exception: {re_err}")
        except csv.Error as csv_err:
            logger.error(f"CSV error processing DML statement: {dml}")
            logger.error(f"Exception: {csv_err}")

# Example usage
def main():

    global release_pipeline_id,release_pipeline_name,date,summary,connect_identifier,db_instance,user,change_ticket
        
    bucket_name = 'dbtracker-logs-20241009'
    file_name = "dbtrackerlogs.csv"

    #log_file_path = "7_Deploy.log"
    output_csv_path = "/Users/kmbl325277/dblogparser/output.csv"     
    log_file_path = download_logs(project_name, release_id, azure_devops_pat)
    print(log_file_path)

    if not log_file_path:
        logger.error("Log file path is empty. Exiting the processing.")
        sys.exit(1)

    try:

        # Read the log file  
        with open(log_file_path, 'r') as file:
            log_content = file.read()
            define_matches = DEFINE_PATTERN.findall(log_content)  

            # Filter matches to include only interested variables and store in individual variables
            variables = {match[0]: match[1] for match in define_matches if match[0] in INTERESTED_VARIABLES}      
            date = variables.get('_DATE', None)
            connect_identifier = variables.get('_CONNECT_IDENTIFIER', None)
            db_instance = connect_identifier.split('/')[-1] if connect_identifier else None
            #print(_DB_INSTANCE)
            user = variables.get('_USER', None)
            summary = "Data Patch DB deployment on Instance: " + db_instance + " by User: " + user + " on Date: " + date

            log_content = log_content.replace('\t', ' ')
            log_content = log_content.replace('\n', '  ') 
            # Find all DDL matches
            ddl_matches = DDL_PATTERN.findall(log_content) 
            # Find all EXEC matches
            exec_matches = EXEC_PATTERN.findall(log_content)
            # Find all DML matches
            dml_matches = UPDATE_PATTERN.findall(log_content)
            insert_matches = INSERT_PATTERN.findall(log_content)
            delete_matches = DELETE_PATTERN.findall(log_content)

            all_dml_matches = []
            for match in dml_matches:
                dml_matches1 = ROWS_UPDATED_PATTERN.findall(match)
                all_dml_matches.extend(dml_matches1)

            for match in insert_matches:
                dml_matches2 = ROWS_INSERTED_PATTERN.findall(match)
                all_dml_matches.extend(dml_matches2)

            for match in delete_matches:
                dml_matches3 = ROWS_DELETED_PATTERN.findall(match)
                all_dml_matches.extend(dml_matches3)  
    except FileNotFoundError as file_err:
        logger.error(f"File not found error reading log file: {file_err}")
    except IOError as io_err:
        logger.error(f"IO error reading log file: {io_err}")
 
    change_ticket,release_pipeline_name = fetch_values_from_log()

    try:    

        with open(f'{project_name}.csv', 'w', newline='') as csvfile:
            csvwriter = csv.writer(csvfile)
            csvwriter.writerow(['ReleasePipelineID','ReleasePipelineName','ReleaseDate','Summary','AppicationName','ChangeTicket','DBName', 'SchemaUser', 'EventType', 'SQLStatement', 'RowsAffected', 'ExecutionTimestamp'])
            process_ddl_statements(ddl_matches,csvwriter)
            process_exec_statements(exec_matches,csvwriter)
            process_dml_statements(all_dml_matches,csvwriter)
    except csv.Error as csv_err:
        logger.error(f"CSV error writing to file: {csv_err}")
        sys.exit(1)    

    #s3_key = create_s3_key(file_name)
    #write_to_s3(file_name,bucket_name,s3_key)    

if __name__ == "__main__":
    main()