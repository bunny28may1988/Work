# Define email parameters
$SmtpServer = "10.240.20.136" # SMTP server for Outlook/Office 365
#$SmtpPort = 587                   # SMTP port for Outlook/Office 365
$From = "donotreply@kotak.com"    # Sender's email address
$To = "kirankumar.dumpa@kotak.com" # Recipient's email address
$Bcc = "mohan.pemmaraju@kotak.com" # BCC recipients
$Subject = "[Notification]| AzureDevOps Agent Alert Notification"

# Define the email body
$Body = @"
Hello, <br/><br/>
This is a test alert notification sent from PowerShell using Outlook.<br/><br/>
Best regards,<br/>
PowerShell Script
"@

# Securely store and retrieve the sender's email password
# Replace 'your-password' with the actual password or use a secure method to store it
$password = ConvertTo-SecureString "your-password" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($From, $password)

# Send the email
try {
    Send-MailMessage -To $To -From $From -Bcc $Bcc -Subject $Subject -BodyAsHtml $Body -SmtpServer $SmtpServer
    Write-Output "Email sent successfully to $To."
} catch {
    Write-Output "Failed to send email: $_"
}