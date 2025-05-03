<#
$pass="rCxP95`$`VZwBeD1"
write-host $pass
if ($pass -match "$"){
    write-host "Yes Doller Exist"
}
else{
    write-host "No Doller Exist"
}
#>
$passkeyArg='rCxP95$VZwBeD1'
$passf="'$$passkeyArg'"
$newPass=$passf.Replace("'","")
write-host "The New Pass is $newPass"