$gLoc="D:\"
$folders = Get-ChildItem -Path  $gLoc -Directory -Filter "*.*Agent*"
foreach ($folder in $folders){
  set-location $folder.FullName
  if (Test-Path -Path .\_work){
      $rFolders=Get-ChildItem -Path .\_work -Directory | Where-Object { $_.Name -match 'r\d' }
         foreach($rFolder in $rFolders){
             Write-Host "Removing $rFolder folder at" $folder.FullName "`n"
             Remove-Item -Path .\_work\$rFolder  -Recurse -Force -Verbose
         }
      $dFolders=Get-ChildItem -Path .\_work -Directory | Where-Object { $_.Name -match '^\d' }
         foreach($dFolder in $dFolders){
             Write-Host "Removing $dFolder folder at" $folder.FullName "`n"
             Remove-Item -Path .\_work\$dFolder  -Recurse -Force -Verbose
         }   
     }
  else {
       Write-Host "_work folder not exist under" $folder.FullName
    }   
    set-location $gLoc
  }