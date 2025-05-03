$personalAccessToken="3TdM0lfC2XzuJASboHxyDygSoW1h28OMgWfvuHNWzHmO2i7mJoyuJQQJ99BDACAAAAAl4kWTAAASAZDO1SOW"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":${personalAccessToken}"))
$org = "kmbl-devops"
$poolId = 68
$agentId = 39103

#$requsetBody = '{"id":{agentId},"enabled":false}' #disable agent

$requestBody = @{
    "enabled" = false
} | ConvertTo-Json -Depth 10 #switch to offline

#$requsetBody = $requsetBody -replace "{agentId}", $agentId

$restApiUpdateAgent = "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools/68/agents/39103`?api-version=6.0"

$restApiUpdateAgent

function InvokePatchReques ($PatchUrl, $body)
{   
    return Invoke-RestMethod -Uri $PatchUrl 
    -Method Patch 
    -ContentType "application/json-patch+json" 
    -Headers @{
        Authorization="Basic $base64AuthInfo"
    } 
    -Body $body
}

$result = InvokePatchReques $restApiUpdateAgent $requsetBody

Write-Host $result