# -------------------------------------------------------------
# Script de nettoyage des fichiers
# PowerShell 3.
# By Nathan MAY - Octobre 2017
# -------------------------------------------------------------

# 1. Nettoyage des fichiers de sauvegarde

$pathSource = "\\SRV-CDPR-TASK\F$"
$DateLimit = (Get-Date).AddYears(-3)
Get-ChildItem -Path $pathSource -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $DateLimit } | Move-Item 
