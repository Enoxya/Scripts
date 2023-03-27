$List = Get-Content "C:\_admin\Scripts\ListeXenApp-Renault.txt"

$Event = Read-Host "Id d'événement à interroger : "

#$Event1 = "1002"
#$Event2 = "7011"

foreach ($Server in $List)
{

Write-Host "Nom du serveur : " $Server
#Get-WinEvent -LogName Application -ComputerName $Server | Where-Object {$_.Id -eq $Event1} | fl TimeCreated,ProviderName,Id
Get-WinEvent -LogName System -ComputerName $Server | Where-Object {$_.Id -eq $Event} | fl TimeCreated,ProviderName,Id

}