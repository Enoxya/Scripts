# -------------------------------------------------------------
# Script de déplacement de fichiers
# PowerShell 3.0
# By Jérémie GADENNE - 22 octobre 2014
# -------------------------------------------------------------

$pathSource = "\\SRV-NOR-SAGE\Sage\Reporting"
$pathDest = "\\srv-nor-exbt\Donnees\BT_Echange_RAF\Archives Reporting"
$DateLimit = (Get-Date).Adddays(-8)

Set-Location $pathSource

#Déplacer les fichiers
Get-ChildItem -Path $pathSource -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $DateLimit } | Move-Item -dest $pathDest

#Envoyer mail de réussite
$serveur = "SRV-NOR-EXCH1"
$expediteur = "admin@autobernard.com"
$destinataire = "j.gadenne@autobernard.com"
$objet = "Archivage Reporting OK"
$texte = "Fichiers transférés vers \\srv-nor-exbt\Donnees\BT_Echange_RAF\Archives Reporting"
$message = new-object System.Net.Mail.MailMessage $expediteur, $destinataire, $objet, $texte
$client = new-object System.Net.Mail.SmtpClient $serveur
$client.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
$client.Send($message)