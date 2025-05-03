$pat = "3TdM0lfC2XzuJASboHxyDygSoW1h28OMgWfvuHNWzHmO2i7mJoyuJQQJ99BDACAAAAAl4kWTAAASAZDO1SOW"
$base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))

$response = Invoke-RestMethod -Uri "https://dev.azure.com/kmbl-devops/_apis/distributedtask/pools?api-version=5.1" -Headers @{
    Authorization = "Basic $base64AuthInfo"
} -Method Get
Write-Host $response.value
#Write-Output "Raw API Response: $($response | ConvertTo-Json -Depth 10)"