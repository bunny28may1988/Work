import requests
import base64
import json

# Define variables
personal_access_token = "6g2yT65wxqLsV8Ls01Gnuh9Rmt7QQlFLCBjk2M5h7W3AgQ4RPwWeJQQJ99ALACAAAAAl4kWTAAASAZDOJ7CH"
org = "kmbl-devops"
pool_id =68
agent_id =39103

# Encode the personal access token for Basic Authentication
base64_auth_info = base64.b64encode(f":{personal_access_token}".encode("ascii")).decode("ascii")

# API URL to update the agent
rest_api_update_agent = f"https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools/68/agents/39103?api-version=6.0"

# Request body to disable the agent
request_body = {
    "enabled": False
}

# Function to send a PATCH request
def invoke_patch_request(patch_url, body):
    headers = {
        "Authorization": f"Basic {base64_auth_info}",
        "Content-Type": "application/json"
    }
    response = requests.patch(patch_url, headers=headers, data=json.dumps(body))
    return response

# Invoke the PATCH request
result = invoke_patch_request(rest_api_update_agent, request_body)

# Print the result
if result.status_code == 200:
    print(f"[SUCCESS] Agent has been disabled successfully: {result.json()}")
else:
    print(f"[ERROR] Failed to disable agent: {result.status_code} - {result.text}")