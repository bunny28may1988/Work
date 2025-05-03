# Define script parameters
param(
    [string[]]$userInputs
)

# Define API URL and Personal Access Token
$apiUrl = "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools?api-version=5.1"
$pat = "3TdM0lfC2XzuJASboHxyDygSoW1h28OMgWfvuHNWzHmO2i7mJoyuJQQJ99BDACAAAAAl4kWTAAASAZDO1SOW"
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$organization = "kmbl-devops"

# Define target pools
$targetPools = @("UAT")

# Function to disable an agent
function Disable-Agent {
    param (
        [string]$poolId,
        [string]$agentId,
        [string]$agentName
    )

    $disableAgentApiUrl = "https://dev.azure.com/$organization/_apis/distributedtask/pools/$poolId/agents/$agentId`?api-version=5.1"
    $body = @{
        id = $agentId
        enabled = $false
    } | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-RestMethod -Uri $disableAgentApiUrl -Headers @{
            Authorization = "Basic $base64AuthInfo"
        } -Method Patch -ContentType "application/json" -Body $body
        Write-Output "    [SUCCESS] Agent $agentName has been disabled successfully."
    } catch {
        Write-Output "    [ERROR] Failed to disable agent ${agentName}: $_"
    }
}

# Function to list and optionally disable agents in a pool
function Manage-Agents {
    param (
        [string]$poolId,
        [string]$poolName,
        [string[]]$userInputs
    )

    $agentsApiUrl = "https://dev.azure.com/$organization/_apis/distributedtask/pools/$poolId/agents?api-version=5.1"
    try {
        $agentsResponse = Invoke-RestMethod -Uri $agentsApiUrl -Headers @{
            Authorization = "Basic $base64AuthInfo"
        } -Method Get

        if ($agentsResponse.value) {
            Write-Output "Agents in Pool: $poolName"
            Write-Output "---------------------------------------------"

            # Group agents by their prefix (removing Agent and numeric suffix)
            $groupedAgents = $agentsResponse.value | Group-Object { $_.name -replace "Agent\d+$", "" }

            foreach ($group in $groupedAgents) {
                $groupName = $group.Name # Directly use the group name
                Write-Output "Group: $groupName"
                foreach ($agent in $group.Group) {
                    Write-Output "  Agent Name: $($agent.name)"
                    Write-Output "  Agent ID: $($agent.id)"
                    Write-Output "  Agent Status: $($agent.status)"
                    Write-Output "  Agent Enabled: $($agent.enabled)"
                }
                Write-Output "---------------------------------------------"
            }

            # Process user inputs
            foreach ($input in $userInputs) {
                if ($input -eq "0") {
                    Write-Output "Disabling all agents in the pool..."
                    foreach ($agent in $agentsResponse.value) {
                        Disable-Agent -poolId $poolId -agentId $agent.id -agentName $agent.name
                    }
                    break
                } else {
                    # Match user input with group name
                    $matchingGroup = $groupedAgents | Where-Object { $_.Name -eq $input }
                    if ($matchingGroup) {
                        Write-Output "Disabling agents in group: $input"
                        foreach ($agent in $matchingGroup.Group) {
                            Disable-Agent -poolId $poolId -agentId $agent.id -agentName $agent.name
                        }
                    } else {
                        Write-Output "    [INFO] No agents found matching group: $input"
                    }
                }
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
                Manage-Agents -poolId $pool.id -poolName $pool.name -userInputs $userInputs
            }
        }
    } else {
        Write-Output "No agent pools found."
    }
} catch {
    Write-Output "  [ERROR] Failed to fetch agent pools: $_"
}