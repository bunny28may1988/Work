# Define script parameters
param(
    $userInputGroupName # User input for the group name
)

# Define API URL and Personal Access Token
$apiUrl = "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools?api-version=5.1"
$pat = "3TdM0lfC2XzuJASboHxyDygSoW1h28OMgWfvuHNWzHmO2i7mJoyuJQQJ99BDACAAAAAl4kWTAAASAZDO1SOW"
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$organization = "kmbl-devops"

# Define target pools
$targetPools = @("UAT")

# Function to list and group agents in a pool
function List-Agents {
    param (
        [string]$poolId,
        [string]$poolName,
        [string]$userInputGroupName
    )

    $agentsApiUrl = "https://dev.azure.com/$organization/_apis/distributedtask/pools/$poolId/agents?api-version=5.1"
    try {
        $agentsResponse = Invoke-RestMethod -Uri $agentsApiUrl -Headers @{
            Authorization = "Basic $base64AuthInfo"
        } -Method Get

        if ($agentsResponse.value) {
            Write-Output "Agents in Pool: $poolName"
            Write-Output "---------------------------------------------"

            # Group agents by their base name (removing Agent[0-9] suffix)
            $groupedAgents = $agentsResponse.value | Group-Object { $_.name -replace "Agent\d+$", "" }

            $matchFound = $false # Initialize match flag
            foreach ($group in $groupedAgents) {
                $groupName = $group.Name # Group name (prefix)
                $agentCount = $group.Group.Count # Count the number of agents in the group

                # Check if the group name matches the user input
                if ($groupName -eq $userInputGroupName) {
                    Write-Output "Match Found: Group $groupName matches the user input."
                    $matchFound = $true
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

            # If no match was found, print "No Match Found"
            if (-not $matchFound) {
                Write-Output "No Match Found for group name: $userInputGroupName"
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
                List-Agents -poolId $pool.id -poolName $pool.name -userInputGroupName $userInputGroupName
            }
        }
    } else {
        Write-Output "No agent pools found."
    }
} catch {
    Write-Output "  [ERROR] Failed to fetch agent pools: $_"
}