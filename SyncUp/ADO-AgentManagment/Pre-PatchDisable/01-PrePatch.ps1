# Define API URL and Personal Access Token
$apiUrl = "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools?api-version=5.1"
$pat = "3TdM0lfC2XzuJASboHxyDygSoW1h28OMgWfvuHNWzHmO2i7mJoyuJQQJ99BDACAAAAAl4kWTAAASAZDO1SOW"
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$organization = "kmbl-devops"

# Define target pools
$targetPools = @("UAT3")

# Function to list agents in a pool
function List-Agents {
    param (
        [string]$poolId,
        [string]$poolName
    )

    $agentsApiUrl = "https://dev.azure.com/$organization/_apis/distributedtask/pools/$poolId/agents?api-version=5.1"
    try {
        $agentsResponse = Invoke-RestMethod -Uri $agentsApiUrl -Headers @{
            Authorization = "Basic $base64AuthInfo"
        } -Method Get

        if ($agentsResponse.value) {
            Write-Output "Agents in Pool: $poolName"
            Write-Output "---------------------------------------------"
            foreach ($agent in $agentsResponse.value) {
                Write-Output "  Agent Name: $($agent.name)"
                Write-Output "  Agent ID: $($agent.id)"
                Write-Output "  Agent CreatedOn: $($agent.createdOn)"
                Write-Output "  Agent Status: $($agent.status)"
                Write-Output "  Agent Enabled: $($agent.enabled)"
                Write-Output "---------------------------------------------"
            }
        } else {
            Write-Output "  No agents found in pool: $poolName"
        }
    } catch {
        Write-Output "  [ERROR] Failed to fetch agents for pool ${poolName}: $_"
    }
}

# Fetch agent pools
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Headers @{
        Authorization = "Basic $base64AuthInfo"
    } -Method Get

    if ($response.value) {
        foreach ($pool in $response.value) {
            if ($targetPools -contains $pool.name) {
                Write-Output "Agent Pool Name: $($pool.name)"
                Write-Output "  Pool ID: $($pool.id)"
                Write-Output "---------------------------------------------"
                List-Agents -poolId $pool.id -poolName $pool.name
            }
        }
    } else {
        Write-Output "No agent pools found."
    }
} catch {
    Write-Output "  [ERROR] Failed to fetch agent pools: $_"
}