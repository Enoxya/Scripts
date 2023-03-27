# -------------------------------------------------------------
# Script de nettoyage des fichiers
# PowerShell 3.0
# By Jérémie GADENNE - 30 octobre 2014
# -------------------------------------------------------------

# Nettoyage des fichiers de sauvegarde AUTOLINE
$pathSource = "\\srv-nor-sauv\Serveurs\AUTOLINE"
$DateLimit = (Get-Date).Adddays(-15)
Get-ChildItem -Path $pathSource -Recurse -Force |
   Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $DateLimit } |
   Remove-Item -force