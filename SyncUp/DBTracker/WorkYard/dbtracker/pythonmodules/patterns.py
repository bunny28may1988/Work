import re
# DDL Regex pattern
DDL_PATTERN = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*?SQL> CREATE [\s\S]*?END [\s\S]*?Procedure created', re.IGNORECASE | re.DOTALL)
# EXEC Regex pattern
EXEC_PATTERN = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*?SQL> EXEC[\s\S]*?procedure successfully completed', re.IGNORECASE | re.DOTALL)
# DML Regex patterns
UPDATE_PATTERN = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*?SQL> UPDATE[\s\S]*?Commit complete', re.IGNORECASE | re.DOTALL)
ROWS_UPDATED_PATTERN = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*?SQL> UPDATE[\s\S]*?row[\s\S]*?updated', re.IGNORECASE | re.DOTALL)
INSERT_PATTERN = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*?SQL> INSERT[\s\S]*?Commit complete', re.IGNORECASE | re.DOTALL)
ROWS_INSERTED_PATTERN = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*?SQL> INSERT[\s\S]*?row[\s\S]*?inserted', re.IGNORECASE | re.DOTALL)
DELETE_PATTERN = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*?SQL> DELETE[\s\S]*?Commit complete', re.IGNORECASE | re.DOTALL)
ROWS_DELETED_PATTERN = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*?SQL> DELETE[\s\S]*?row[\s\S]*?deleted', re.IGNORECASE | re.DOTALL)
# TimeStamp Regex pattern
TIMESTAMP_PATTERN = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z\s*')
# Line number Regex pattern
LINE_NUMBER_PATTERN = re.compile(r'^\d+\s+', re.MULTILINE)  # Pattern to remove line numbers
# Tab Regex pattern
TAB_PATTERN = re.compile(r'\s{2,}') 
# Regex pattern to match DEFINE statements
DEFINE_PATTERN = re.compile(r'DEFINE\s+(\w+)\s*=\s*"([^"]+)"\s*\(CHAR\)', re.IGNORECASE)
# Define interested variables
INTERESTED_VARIABLES = ['_DATE', '_CONNECT_IDENTIFIER', '_USER', '_PRIVILEGE', '_SQLPLUS_RELEASE', '_EDITOR', '_O_VERSION', '_O_RELEASE']
LOG_FILE_PATTERN = re.compile(r'^\d+_deploy', re.IGNORECASE)
#INITIALIZE_JOB_LOG_PATTERN = re.compile(r'^\d+_InitializeJob', re.IGNORECASE)
INITIALIZE_JOB_LOG_PATTERN = re.compile(r'1_Initialize job\.log')
