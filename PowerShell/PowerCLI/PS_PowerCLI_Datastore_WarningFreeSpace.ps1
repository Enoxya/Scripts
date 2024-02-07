<#
analyse les datastore de l’ESX ou du vCenter et envoie un mail si jamais il y a dépassement du seuil prédéfini.
Les préconisations VMware font état d’un besoin minimal de 20% de libre sur un datastore pour assurer le fonctionnement optimal de celui-ci.
Le script va envoyer un courriel si jamais un datastore tombe à moins de 25% d’espace libre.
#>

$From = "testscriptPS@ch-bourg.ght01.fr"
$To = "sylvain.saunier@ch-bourg.ght01.fr"
$Smtp = "smtp.ght01.fr"
$SeuilAlerte = 25

$ESXserver = "bob.sia-f.local"
$ESXUser = "sia-f.local\vCenter_SSAUNIER"
$ESXPwd = "+W{C'b[)av1?O,]"

Connect-VIServer $ESXserver -User $ESXUser -Password $ESXPwd
 
$DatastoreArray = Get-Datastore
foreach ($Datastore in $DatastoreArray) {
    $MBAvail = $Datastore.FreeSpaceMB
    $MBTotal = $Datastore.CapacityMB
    $FreeProp = ($MBAvail/$MBTotal) * 100
    if ($FreeProp -lt $SeuilAlerte) {
        $FreeProp = [math]::Round($FreeProp,1)
        $MailString = "Le datastore '$Datastore' n'a plus que $FreeProp % de libre.`r `n"
        $ContenuMail += $MailString
    }
}
Send-MailMessage -From $From -To $To -Subject "CHB - VIRT - DS - Alerte occupation Datastore(s)" -SmtpServer $Smtp -Body $ContenuMail