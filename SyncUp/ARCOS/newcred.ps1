echo "IP = {{IP}}"
echo "User = {{User}}"
echo "ServiceType = {{ServiceType}}"
echo "LOB = {{LOB}}"
echo "DBInstanceName = {{DBInstanceName}}"


# Define the SOAP request body
$soapBody = @"
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RequestServicePassword xmlns="http://ARCOS">
      <ARCOSWebAPIURL>https://arcos.kotak.int/ARCOSWebAPI/ARCOSWebDT.asmx</ARCOSWebAPIURL>
      <ARCOSSharedKey>ARCOSGWPWAPI@2013@Test--1</ARCOSSharedKey>
      <LOBProfile>{{LOB}}</LOBProfile>
      <ServerIP>{{IP}}</ServerIP>
      <ServiceType>{{ServiceType}}</ServiceType>
      <UserName>{{User}}</UserName>
      <DBInstanceName>{{DBInstanceName}}</DBInstanceName>
    </RequestServicePassword>
  </soap:Body>
</soap:Envelope>
"@

# Send the SOAP request
$response = Invoke-WebRequest -Uri "http://arcos.kotak.int:9090/ARCOSAPI001.asmx" -Method Post -ContentType "text/xml" -Headers @{"SOAPAction"="http://ARCOS/RequestServicePassword"} -Body $soapBody -UseBasicParsing

Write-Host "Response Content: $($response.Content)"

# Password filter from response API
if ($response.Content -match '<RequestServicePasswordResult>(.*?)</RequestServicePasswordResult>') {
    $RequestServicePasswordResult = $matches[1]
} else {
    Write-Host "No match found in the response content."
    $RequestServicePasswordResult = $null
}

# Check if the password was fetched successfully
if ($RequestServicePasswordResult -eq "soap:Server" -or [string]::IsNullOrEmpty($RequestServicePasswordResult)) {
    Write-Host "======== Unable to fetch the password ========"
    exit 1
} else {
    Write-Host "##vso[task.setvariable variable=Password;]$pass"
    #Write-Host "Password is = $RequestServicePasswordResult"
    $pass=$(RequestServicePasswordResult).ToString()
    Write-Host "Password is = $pass"
    Write-Host "##vso[task.setvariable variable=Password;]$pass"
    Write-Host "======== Password fetched ========"
}