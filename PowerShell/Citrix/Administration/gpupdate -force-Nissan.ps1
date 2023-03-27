$List = Get-Content "C:\_admin\Scripts\ListeXenApp-Nissan.txt"

foreach ($Server in $List)
{

Write-Host "Gpupdate sur serveur " $Server
invoke-command -ScriptBlock {gpupdate /force} -ComputerName $Server

}