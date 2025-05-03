$apiUrl = "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools?api-version=5.1"

$personalAccessToken = "73R2ngt2AbtWvoNILpS7QlLMmBkBsdtTXNX7LdoXJwtgx1PNyyNxJQQJ99BAACAAAAAl4kWTAAASAZDOiVv0"

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))

$targetPools = @("UAT","OnPremDRUnix","OnPremWinDR","OnPrimeProdUnix","OnPremUnix","Prod","UAT2","Unix Build","Private Build")

$response = Invoke-RestMethod -Uri $apiUrl -Headers @{
    Authorization = "Basic $base64AuthInfo"
} -Method Get

if ($response.value) {
    foreach ($pool in $response.value) {
        if ($pool.name -eq "UAT Agent Pool") {
            Write-Output "Agent Pool Name: $($pool.name)"
        }
    }
} else {
    Write-Output "No agent pools found."
}