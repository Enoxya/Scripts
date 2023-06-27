# -------------------------------------------------------------
# Script de nettoyage des fichiers
# PowerShell 3.0
# By Jérémie GADENNE - 30 octobre 2014
# -------------------------------------------------------------

# 1. Nettoyage des fichiers de sauvegarde
$pathSource = "\\SRV-NOR-FRP\Sage\Reporting"
$DateLimit = (Get-Date).Adddays(-1)
Get-ChildItem -Path $pathSource -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $DateLimit } | Remove-Item -force

