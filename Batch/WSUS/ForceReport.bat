sc.exe config wuauserv start= disabled
sc.exe config bits start= disabled
net stop wuauserv
net stop bits
cmd --% /c rd /S /Q C:\Windows\SoftwareDistribution
cmd --% /c rd /S /Q C:\$WINDOWS.~BT
sc.exe config wuauserv start= auto
sc.exe config bits start= auto
net start wuauserv
net start bits

Start-Service wuauserv -Verbose
$Cmd = '$updateSession = new-object -com "Microsoft.Update.Session";$updates=$updateSession.CreateupdateSearcher().Search($criteria).Updates'
powershell.exe -command $Cmd
Write-host "Waiting 10 seconds for SyncUpdates webservice to complete to add to the wuauserv queue so that it can be reported on"
Start-sleep -seconds 10
wuauclt /detectnow
(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
wuauclt /reportnow
c:\windows\system32\UsoClient.exe startscan