$List = Get-Content "C:\_admin\Scripts\ListeXenApp-Renault.txt"

foreach ($Server in $List)
{

$ErrorActionPreference = "SilentlyContinue"
Write-Host "Suppression du fichier DialogysMPFUser.prf sur " $Server
invoke-command -ScriptBlock {Remove-Item -Path "C:\Program Files (x86)\Dialogys\data\dialogysMPFuser.prf"} -ComputerName $Server

}