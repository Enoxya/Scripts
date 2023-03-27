Get-WindowsUpdate -verbose -computer PCX-SECO-CM2 -AcceptAll -Install -AutoReboot

#Installation - Specifier KB
Get-WUInstall -verbose -computer PCX-SECO-CM2 -KBArticleID KB5002351, KB5002197, KB5002254, KB5023696 -AcceptAll

#Historique
Get-WUHistory -ComputerName PCX-SECO-CM2 | Where-Object {$_.Title -match "KB5002351"} | Select-Object * | ft