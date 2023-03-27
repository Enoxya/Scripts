Import-Module PSTerminalServices

$List = Get-Content "C:\_admin\Scripts\ListeXenApp.txt"

foreach ($Server in $List)
{

Write-Host "Nom de serveur XenApp : $Server"
Get-TSSession -ComputerName $Server | Where-Object {$_.IdleTime -ne "00:00:00"} | ft UserName,IdleTime

}