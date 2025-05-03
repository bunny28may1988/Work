$organization = "#{OrgName}#"

$project = "#{ProjName}#"

$pat = "#{AdminPAT}#"

$url = "https://vsrm.dev.azure.com/$organization/$project/_apis/release/releases?api-version=6.0"
 
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))
 
# Define the request body

$body = @{

    definitionId = "#{RelDefId}#"  # Update with the correct definition ID
 description = "$env:SYSTEM_TEAMPROJECT-$env:RELEASE_RELEASEID-$env:RELEASE_RELEASENAME-$env:RELEASE_ENVIRONMENTNAME-$env:RELEASE_ATTEMPTNUMBER"

} | ConvertTo-Json
 
$headers = @{

    "Content-Type" = "application/json"
    "Authorization" = "Basic $base64AuthInfo"
}
 
try {

    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body $body
    Write-Host "Release triggered successfully."
    # Extract data from the response

    $releaseId = $response.id
    $releaseName = $response.name
    Write-Host "Release ID: $releaseId"
    Write-Host "##vso[task.setvariable variable=ReleaseId]$releaseId"

} catch {
    Write-Error "Failed to trigger release: $($_.Exception.Message)"
}