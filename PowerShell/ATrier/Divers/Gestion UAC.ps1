$UAC = Get-ItemProperty -Path registry::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA 
$UAC.EnableLUA