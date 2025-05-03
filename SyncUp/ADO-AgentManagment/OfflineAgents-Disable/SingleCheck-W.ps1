# Define API URL and Personal Access Token
$apiUrl = "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools?api-version=5.1"
$pat = "3TdM0lfC2XzuJASboHxyDygSoW1h28OMgWfvuHNWzHmO2i7mJoyuJQQJ99BDACAAAAAl4kWTAAASAZDO1SOW"
$pat = $env:SECRET
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$organization = "kmbl-devops"

$targetPools = @("UAT3")
#$targetPools = @("UAT","UAT3","OnPremDRUnix", "OnPremWinDR", "OnPrimeProdUnix", "OnPremUnix", "Prod", "UAT2", "Unix Build", "Private Build")

function Disable-Agent {
    param (
        [string]$poolId,
        [string]$agentId,
        [string]$agentName
    )

    $enable = $false
    $disableAgentApiUrl = "https://dev.azure.com/$organization/_apis/distributedtask/pools/$poolId/agents/$agentId`?api-version=6.0"
    $body = @{
        id = $agentId
        enabled = $enable
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri $disableAgentApiUrl -Headers @{Authorization = "Basic $base64AuthInfo"} -Method Patch -ContentType "application/json" -Body $body
        Write-Output "    [SUCCESS] Agent $agentName has been disabled successfully."
    } catch {
        Write-Output "    [ERROR] Failed to disable agent ${agentName}: $_"
    }
}
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
                    Write-Output "  Agent CreatedOn: $($agent.createdOn)"
                    Write-Output "  Agent Status: $($agent.status)"
                    Write-Output "  Agent Enabled: $($agent.enabled)"

                    # Categorize and take action based on agent status
                    if ($agent.status -eq "offline" -and $agent.enabled -eq $true) {
                        Write-Output "    [ACTION REQUIRED] Agent is offline and enabled. Disabling the agent.."
                        Disable-Agent -poolId $pool.id -agentId $agent.id -agentName $agent.name
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