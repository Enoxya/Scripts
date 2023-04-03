##################################################
# Script de copie des fichiers RH > FINANCE
##################################################

$source = "\\srv-nor-talend\d$\Talend\ADP_RH_REFERENTIEL\in"
$destination = "\\srv-nor-fich\RESSOURCES HUMAINES\INTRANET RH\SUPPORT DRH\PAIE\FINANCE"
$SMTPServer = "EXCH-RELAIS"  
$EmailUsers = @("c.brisseau@autobernard.com","j.gadenne@autobernard.com")
$EmailFrom = "admin@autobernard.com" 
$body = "Script de copie automatique des fichiers RH à destination de la FINANCE `r`n`r`n "
$body += "Destination : {0} `r`n`r`n"  -f $destination.ToLower()
$body += "Fichier copiés : `r`n"


# 1. Effacement des fichiers
Get-ChildItem $destination | Remove-Item -Force

# 2. Copie des fichiers
$files = Get-ChildItem -Path $source -include *listerubpaie*.xls -recurse | Where-Object {$_.CreationTime -gt (Get-Date).Date} 

foreach ($file in $files) {

      Write-Host "Fichier : $File" -foregroundcolor "green"
      Copy-Item $File -Destination $destination 
      $body += $file.Name 
      $body += " `r`n"
             
    }

# 

$body += "-----------`r`n TOTAL = $((Get-ChildItem $destination).count) fichiers copiés"


#Envoyer mail de compte rendu

ForEach ($User in $EmailUsers)  
   {
        Write-Host -ForegroundColor Cyan "Envoi E-Mail Notification : $User"
        $Smtp = New-Object Net.Mail.SmtpClient($SMTPServer)
        $Subject = "Copie fichiers RH vers FINANCE" 
        $Smtp.Send($EmailFrom,$User,$Subject,$body)
    }

   



   

