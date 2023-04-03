# -------------------------------------------------------------
# Script de déplacement de fichiers
# PowerShell 3.0
# By Jérémie GADENNE - 28/07/2015
# -------------------------------------------------------------

# Déclaration des constantes 

$pathSource = "\\SRV-NOR-FRP\Sage\Reporting"
$pathDest = "\\SRV-NOR-APP1\INTERFACE\RTDMS"
$SMTPServer = "EXCH-RELAIS"                
$EmailUsers = @("j.gadenne@autobernard.com","f.becerra@autobernard.com", "v.chevalier@autobernard.com")
$EmailFrom = "admin@autobernard.com"
$count = $null

# Appel de la Fonction
$Files = Get-ChildItem $pathSource -include POM_FBA*.* -recurse
if ($Files) { $count = @($files).count }

if ($count) 
    { foreach ($File in $Files) {
      write-host "Fichier " -nonewline; write-host  "$File" -foregroundcolor "green"; 
      Copy-Item $File -Destination $pathDest }
      $body = " La copie du fichier a réussi. `n `n Emplacement : " + $pathDest + " Fichiers copiés : " + $count 
    }
else { $body = " La copie du fichier a échoué. `n Emplacement : 0 fichier copié."}

#Envoyer mail de compte rendu
ForEach ($User in $EmailUsers)  
   {
        Write-Host -ForegroundColor Cyan "Sending Email notification to $User"
        $Smtp = New-Object Net.Mail.SmtpClient($SMTPServer)
        $Subject = "Copie RTDMS vers PORTAIL RH" 
        $Smtp.Send($EmailFrom,$User,$Subject,$body)
    }

   

