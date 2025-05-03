$apiUrl = "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools?api-version=5.1"

$personalAccessToken = "OkFrRzFCM0tGVHRvSlRHNXVzeVBSU1ZyblNWSHBJWDFzNTJra2F4blZXa1hjbmJmaGhJSFRKUVFKOTlBS0FDQUFBQUFsNGtXVEFBQVNBWkRPMHAwcA=="

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))

# Define the array of target agent pool names
$targetPools = @("UAT","UAT3","OnPremDRUnix", "OnPremWinDR", "OnPrimeProdUnix", "OnPremUnix", "Prod", "UAT2", "Unix Build", "Private Build")

# Get the list of agent pools
$response = Invoke-RestMethod -Uri $apiUrl -Headers @{
    Authorization = "Basic $base64AuthInfo"
} -Method Get

if ($response.value) {
    foreach ($pool in $response.value) {
        if ($targetPools -contains $pool.name) {
            Write-Output "Agent Pool Name: $($pool.name)"
            
            # Get the agents in the current pool
            $agentsApiUrl = "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools/$($pool.id)/agents?api-version=5.1"
            $agentsResponse = Invoke-RestMethod -Uri $agentsApiUrl -Headers @{
                Authorization = "Basic $base64AuthInfo"
            } -Method Get

            if ($agentsResponse.value) {
                foreach ($agent in $agentsResponse.value) {
                    Write-Output "  Agent Name: $($agent.name)"
                    Write-Output "  Agent Status: $($agent.status)"
                    Write-Output "  Agent Enabled: $($agent.enabled)"
                }
            } else {
                Write-Output "  No agents found in this pool."
            }
        }
    }
} else {
    Write-Output "No agent pools found."
}