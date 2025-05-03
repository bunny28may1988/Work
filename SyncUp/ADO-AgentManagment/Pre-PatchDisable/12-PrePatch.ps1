param(
    $userInputGroupNames
)
#$token=$env:SECRET
$organization = "kmbl-devops"
$apiUrl = "https://dev.azure.com/$organization/_apis/distributedtask/pools?api-version=6.0"
$pat = "3TdM0lfC2XzuJASboHxyDygSoW1h28OMgWfvuHNWzHmO2i7mJoyuJQQJ99BDACAAAAAl4kWTAAASAZDO1SOW"
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$organization = "kmbl-devops"
#$targetPools =$env:POOLNAME
$targetPools = "UAT3"
#Write-Host $targetPools
function Disable-Agent {
    param (
        [string]$poolId,
        [string]$agentId,
        [string]$agentName
    )
    $disableAgentApiUrl = "https://dev.azure.com/$organization/_apis/distributedtask/pools/$poolId/agents/$agentId`?api-version=6.0"
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
function List-Agents {
    param (
        [string]$poolId,
        [string]$poolName,
        [string[]]$userInputGroupNames
    )
    $agentsApiUrl = "https://dev.azure.com/$organization/_apis/distributedtask/pools/$poolId/agents?api-version=5.1"
    try {
        $agentsResponse = Invoke-RestMethod -Uri $agentsApiUrl -Headers @{
            Authorization = "Basic $base64AuthInfo"
        } -Method Get

        if ($agentsResponse.value) {
            Write-Output "Agents in Pool: $poolName"
            Write-Output "---------------------------------------------"
            if ($userInputGroupNames -contains "0") {
                Write-Output "Disabling all agents in the pool: $poolName"
                foreach ($agent in $agentsResponse.value) {
                    Disable-Agent -poolId $poolId -agentId $agent.id -agentName $agent.name
                }
                return
            }
            $groupedAgents = $agentsResponse.value | Group-Object { $_.name -replace "Agent\d*$", "" }
            #groupedAgents = $agentsResponse.value | Group-Object { $_.name -replace "Agent", "" }

            foreach ($userInputGroupName in $userInputGroupNames) {
                $matchFound = $false
                foreach ($group in $groupedAgents) {
                    $groupName = $group.Name
                    $agentCount = $group.Group.Count
                    if ($groupName -eq $userInputGroupName) {
                        Write-Output "Match Found: Group $groupName matches the user input."
                        $matchFound = $true
                        foreach ($agent in $group.Group) {
                            Disable-Agent -poolId $poolId -agentId $agent.id -agentName $agent.name
                        }
                    }

                    Write-Output "Group: $groupName (Count: $agentCount)"
                    foreach ($agent in $group.Group) {
                        Write-Output "  Agent Name: $($agent.name)"
                        Write-Output "  Agent ID: $($agent.id)"
                        Write-Output "  Agent Status: $($agent.status)"
                        Write-Output "  Agent Enabled: $($agent.enabled)"
                    }
                    Write-Output "---------------------------------------------"
                }
                if (-not $matchFound) {
                    Write-Output "No Match Found for group name: $userInputGroupName"
                }
            }
        } else {
            Write-Output "  No agents found in pool: $poolName"
        }
    } catch {
        Write-Output "  [ERROR] Failed to fetch agents for pool ${poolName}: $_"
    }
}
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
                List-Agents -poolId $pool.id -poolName $pool.name -userInputGroupNames $userInputGroupNames
            }
        }
    } else {
        Write-Output "No agent pools found."
    }
} catch {
    Write-Output "  [ERROR] Failed to fetch agent pools: $_"
}