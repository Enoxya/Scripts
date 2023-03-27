# Script pour application Ice-Innovation
# Download du fichier ice.xap depuis le site d'Ice Innovation / stockage dans C:\Temp
# Comparaison taille entre fichier pr�sent dans \\srv-ctx-file\profils$\_sources\Ice-Innovation et C:\Temp
# Si diff�rence, on �crase le fichier sur le serveur de fichier
# Planifier la t�che une fois par jour depuis le File Server ou un Delivery Controller


# Import module BitsTransfer
import-module bitstransfer


# Variables
$SourceWeb = "https://icebackoffice.innovation-group.com/ClientBin/ice.xap"
$TargetTemp = "C:\Temp\ice.xap"
$TargetFileServer = "\\srv-ctx-file\profils$\_sources\Ice-Innovation\ice.xap"


# Execution du transfert du fichier ice.xap vers C:\Temp\
Start-BitsTransfer $SourceWeb $TargetTemp


# Infos longueur fichier temporaire
$FileTemp = Get-ChildItem $TargetTemp
$lengthFileTemp = $FileTemp.Length

# Write-Host $lengthFileTemp

# Infos longueur fichier target
$FileTarget = Get-ChildItem $TargetFileServer
$lengthFileTarget = $FileTarget.Length

# Write-Host $lengthFileTarget

# Comparaison entre $TargetTemp et $TargetFileServer

if ($lengthFileTemp -ne $lengthFileTarget) {
#    Write-Host "Le fichier Temporaire est diff�rent du fichier target"
    Copy-Item $TargetTemp $TargetFileServer -Force
}
