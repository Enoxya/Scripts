#Variables
$dossierSource = "C:\Windows\System32\LogFiles\Radius\"
$fichiersSource = "C:\Windows\System32\LogFiles\Radius\*"
$dossierDestination = "\\SRV-NOR-SAUV\Logs\SRV-NOR-CERT\Radius"

$anneeEncours = Get-Date -Format yyyy
$nomFichierZIP = "SRV-NOR-CERT_Logs_Radius_" + $anneeEncours + ".zip"

$SMTPServer = "EXCH-RELAIS"                
$EmailUsers = @("dsiinfra@autobernard.com")
$EmailFrom = "Logs@autobernard.com"

#Compression en ZIP
Compress-Archive -Path $fichiersSource -CompressionLevel Optimal -DestinationPath ($dossierSource + $nomFichierZIP)

#Déplacement de l'archive créée et suppression du contenu du dossier qui contenait les fichiers de logs
Move-Item -Path ($dossierSource + $nomFichierZIP) -Destination $dossierDestination
Remove-Item $dossierSource*.*

#Envoi du mail à DSI Infra
ForEach ($User in $EmailUsers)  
    {
        $Smtp = New-Object Net.Mail.SmtpClient($SMTPServer)
        $Subject = "Logs - SRV-NOR-CERT - Radius - Archivage " + $anneeEncours
        $Body = "La création du fichier ZIP `"$nomFichierZIP`" à réussi. `n`nArchivage du fichier dans : " + $dossierDestination
        $Smtp.Send($EmailFrom,$User,$Subject,$Body)
    }