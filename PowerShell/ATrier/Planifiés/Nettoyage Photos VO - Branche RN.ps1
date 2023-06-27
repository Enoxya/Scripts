# -------------------------------------------------------------
# Script de nettoyage des fichiers
# 
# By Nathan MAY - 06 Décembre 2017
# -------------------------------------------------------------



# 1. Nettoyage des photos VO - Branche Renault

$pathSource = "\\Srv-nor-fich\branches\RENAULT\RN Bourg\Photos VO"
$DateLimit = (Get-Date).Adddays(-30)
Get-ChildItem -Path $pathSource -Recurse -Force |
   Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $DateLimit } |
   Remove-Item -force

# 2. Envoyer mail de réussite

$SMTPServer = "EXCH-RELAIS"                
$EmailUsers = @("j.gadenne@autobernard.com","n.may@autobernard.com")
$EmailFrom = "admin@autobernard.com"

 ForEach ($User in $EmailUsers)  
   {
        Write-Host -ForegroundColor Cyan "Sending Email notification to $User"
        $Smtp = New-Object Net.Mail.SmtpClient($SMTPServer)
        $Subject = "Nettoyage Mensuel Photos VO" 
        $Body = " Les photos VO du mois ont été supprimées. " 
        $Smtp.Send($EmailFrom,$User,$Subject,$Body)
    }


