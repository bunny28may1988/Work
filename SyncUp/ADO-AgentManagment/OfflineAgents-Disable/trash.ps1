$apiUrl = "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools?api-version=5.1"

$personalAccessToken = "3TdM0lfC2XzuJASboHxyDygSoW1h28OMgWfvuHNWzHmO2i7mJoyuJQQJ99BDACAAAAAl4kWTAAASAZDO1SOW"

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))

#$targetPools = @("UAT","UAT3","OnPremDRUnix", "OnPremWinDR", "OnPrimeProdUnix", "OnPremUnix", "Prod", "UAT2", "Unix Build", "Private Build")
$targetPools = @("UAT3")

$response = Invoke-RestMethod -Uri $apiUrl -Headers @{
    Authorization = "Basic $base64AuthInfo"
} -Method Get

if ($response.value) {
    foreach ($pool in $response.value) {
        if ($targetPools -contains $pool.name) {
            Write-Output "Agent Pool Name: $($pool.name)"
            Write-Output "  Pool ID: $($pool.id)"
            
            $agentsApiUrl = "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools/$($pool.id)/agents?api-version=5.1"
            $agentsResponse = Invoke-RestMethod -Uri $agentsApiUrl -Headers @{
                Authorization = "Basic $base64AuthInfo"
            } -Method Get

            if ($agentsResponse.value) {
                foreach ($agent in $agentsResponse.value) {
                    Write-Output "  Agent Name: $($agent.name)"
                    Write-Output "  Agent ID: $($agent.id)"
                    Write-Output "  Agent Status: $($agent.status)"
                    Write-Output "  Agent Enabled: $($agent.enabled)"

                    # Categorize agents that are offline and enabled
                    if ($agent.status -eq "offline" -and $agent.enabled -eq $true) {
                        Write-Output "    [ACTION REQUIRED] Agent is offline and enabled."
                    } elseif ($agent.status -eq "offline" -and $agent.enabled -eq $false) {
                        Write-Output "    [INFO] Agent is offline but already disabled."
                    } elseif ($agent.status -eq "online" -and $agent.enabled -eq $true) {
                        Write-Output "    [INFO] Agent is online and enabled."
                    } elseif ($agent.status -eq "online" -and $agent.enabled -eq $false) {
                        Write-Output "    [INFO] Agent is online but disabled."
                    }
                }
            } else {
                Write-Output "  No agents found in this pool."
            }
        }
    }
} else {
    Write-Output "No agent pools found."
}