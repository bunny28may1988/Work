$organization = "kmbl-devops"
$poolId = 68
$agentId = 39103 # pass this one from above one in a loop
$pat = "3TdM0lfC2XzuJASboHxyDygSoW1h28OMgWfvuHNWzHmO2i7mJoyuJQQJ99BDACAAAAAl4kWTAAASAZDO1SOW"
$enable = $false  # Set to $false to disable
 
# Encode PAT
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
 
# Define URL
$url = "https://dev.azure.com/$organization/_apis/distributedtask/pools/$poolId/agents/$agentId`?api-version=6.0"
 
# Define JSON body
$body = @{
    id = $agentId
    enabled = $enable
} | ConvertTo-Json
 
# Send PATCH request
$response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Basic $token"} -Method Patch -ContentType "application/json" -Body $body
 
# Output response
$response | ConvertTo-Json -Depth 100