import requests

# Define the variables
IP = "your_ip_here"
User = "your_user_here"
ServiceType = "your_service_type_here"
LOB = "your_lob_here"
DBInstanceName = "your_db_instance_name_here"

print(f"IP = {IP}")
print(f"User = {User}")
print(f"ServiceType = {ServiceType}")
print(f"LOB = {LOB}")
print(f"DBInstanceName = {DBInstanceName}")

# Define the SOAP request body
soap_body = f"""
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <RequestServicePassword xmlns="http://ARCOS">
      <ARCOSWebAPIURL>https://arcos.kotak.int/ARCOSWebAPI/ARCOSWebDT.asmx</ARCOSWebAPIURL>
      <ARCOSSharedKey>ARCOSGWPWAPI@2013@Test--1</ARCOSSharedKey>
      <LOBProfile>{LOB}</LOBProfile>
      <ServerIP>{IP}</ServerIP>
      <ServiceType>{ServiceType}</ServiceType>
      <UserName>{User}</UserName>
      <DBInstanceName>{DBInstanceName}</DBInstanceName>
    </RequestServicePassword>
  </soap:Body>
</soap:Envelope>
"""

# Define the headers
headers = {
    "Content-Type": "text/xml; charset=utf-8",
    "SOAPAction": "http://ARCOS/RequestServicePassword"
}

# Send the SOAP request
response = requests.post("https://arcos.kotak.int/ARCOSWebAPI/ARCOSWebDT.asmx", data=soap_body, headers=headers)

# Print the response
print(response.text)