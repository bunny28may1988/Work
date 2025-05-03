'''
param(${env:Agents})
$agentNames = @${env:AGENTS}
Write-Output "List of Agents:"
foreach ($agent in $agentNames) {
    Write-Output "  - $agent"
}
'''
param(
    $pattern
    )
foreach($i in $pattern){
  write-host "The Name of the Agent is $i"
}

