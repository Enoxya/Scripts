$List = Get-Content "C:\_admin\Scripts\ListeXenApp-Renault.txt"

foreach ($Server in $List)
{

Write-Host "Gpupdate sur serveur " $Server
invoke-command -ScriptBlock {gpupdate /force} -ComputerName $Server

}