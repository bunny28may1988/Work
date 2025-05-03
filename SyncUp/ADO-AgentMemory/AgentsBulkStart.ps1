$gLoc="D:\"
$agentHomes = Get-ChildItem -Path  $gLoc -Directory -Filter "*.*Agent*"
foreach ($agentHome in $agentHomes){
Set-Location $agentHome.FullName
Start-Process -FilePath .\run.cmd -PassThru
Set-Location $gLoc
}