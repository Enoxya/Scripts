$dateDuJour = Get-Date -UFormat "%d/%m/%Y"
$repertoireSource = "F:\Serveurs\Autoline"
$repertoireDestination = "F:\Historisation\Autoline\2018"

$fichiersADeplacer = Get-ChildItem -Path $repertoireSource | Where-Object { $_.LastWriteTime.ToShortDateString() -eq $dateDuJour }
#write-Host $fichierADeplacer
$fichiersADeplacer | Move-Item -Destination $repertoireDestination