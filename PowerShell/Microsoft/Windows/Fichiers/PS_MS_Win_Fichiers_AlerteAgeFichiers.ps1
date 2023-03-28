$repertoire = "D:\inlogfichier\ExpResultatCrosswayPDF\"
$extension = "*.hl7"
$cheminComplet = $repertoire + $extension
$nbreJours = 0
$nbreHeures = 0
$nbreMinutes = 30

function recuperationVieuxFichiers($chemin, $nbreJoursMax, $nbreHeuresMax, $nbreMinutesMax) {
    $dateCourante = Get-Date
    #Get all children in the path where the last write time is greater than 30 minutes. psIsContainer checks whether the object is a folder.
    $vieuxFichiers = @(Get-ChildItem $cheminComplet -include *.* -recurse | where {($_.CreationTime -lt $dateCourante.AddDays(-$nbreJoursMax).AddHours(-$nbreHeuresMax).AddMinutes(-$nbreMinutesMax)) -and ($_.psIsContainer -eq $false)})

    if ($vieuxFichiers -ne $NULL) {
        $vieuxFichiers_Compteur = 0
        $vieuxFichiers_Liste=@()
        
        #Envoi du mail
        $From = "Laboflux-HL7@ch-bourg01.fr"
        $To = "dmarchis@ch-bourg01.fr", "exploitation@ch-bourg01.fr”
        #$Cc = ""
        #$Attachment = "C:\Temp\Drogon.jpg"
        $Subject = "LABOFLUX - Compteur de fichiers HL7 - Problème"
        $Body = "<h2>Problème : il existe des fichiers HL7 de plus de 30 minutes dans le répertoire $repertoire</h2><br>"
        for ($i = 0; $i -lt $vieuxFichiers.Length; $i++) {
            $vieuxFichiers_Compteur += 1
            $vieuxFichiers_Fichier = $vieuxFichiers[$i]
            
            $vieuxFichiers_Liste += $vieuxFichiers_Fichier.Name + " - " + $vieuxFichiers_Fichier.CreationTime + "<br>" #+ $vieuxFichiers_Fichier.LastWriteTime + " - "
        }
        $Body += "Un total de " + $vieuxFichiers_Compteur + " fichiers HL7 plus vieux que 30 minutes ont été trouvés :<br><br>"
        $Body += $vieuxFichiers_Liste 
        $SMTPServer = "mercure.chb.ts1.local"
        #$SMTPPort = "587"
        #Send-MailMessage -From $From -to $To -Cc $Cc-Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment -Encoding UTF8
        Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Encoding UTF8
    }
}

recuperationVieuxFichiers $cheminComplet $nbreJours $nbreHeures $nbreMinutes
