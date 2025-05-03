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
        enabled = $true
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
            $index = 1
            $agentsMap = @{}

            foreach ($agent in $agentsResponse.value) {
                $agentKey = "$index.$index"
                $agentsMap[$agentKey] = $agent
                Write-Output "  [$agentKey] Agent Name: $($agent.name)"
                Write-Output "       Agent ID: $($agent.id)"
                Write-Output "       Agent Status: $($agent.status)"
                Write-Output "       Agent Enabled: $($agent.enabled)"
                Write-Output "---------------------------------------------"
                $index++
            }

            # Ask user for action
            $action = Read-Host "Enter the agent number (e.g., 1.1) to disable a specific agent, or type 'all' to disable all agents"
            if ($action -eq "all") {
                foreach ($agent in $agentsResponse.value) {
                    Disable-Agent -poolId $poolId -agentId $agent.id -agentName $agent.name
                }
            } elseif ($agentsMap.ContainsKey($action)) {
                $selectedAgent = $agentsMap[$action]
                Disable-Agent -poolId $poolId -agentId $selectedAgent.id -agentName $selectedAgent.name
            } else {
                Write-Output "    [INFO] Invalid selection. No action taken."
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
                Manage-Agents -poolId $pool.id -poolName $pool.name
            }
        }
    } else {
        Write-Output "No agent pools found."
    }
} catch {
    Write-Output "  [ERROR] Failed to fetch agent pools: $_"
}