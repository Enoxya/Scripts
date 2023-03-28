#---------------------------------------------------------------------------------------------------------------
#
# Ce script déplace les comptes AD utilisateurs non connectés depuis plus de XX jours/mois dans une OU à définir
# et/ou
# désactive les comptes AD utilisateurs non connectés depuis plus de XX jours/mois
# 
#---------------------------------------------------------------------------------------------------------------

#Paramètres obligatoires :
$temps = (Get-Date).AddDays(-180)
$OUSource = "" #De la forme "OU=ZZZ,OU=YYY,DC=XXX,DC=com/fr"
$OUCible = "" #De la forme "OU=ZZZ,OU=YYY,DC=XXX,DC=com/fr"

#Paramètre optionnel :
#$serveurSMTP = bbbbbb.domaine.com/fr


###DÉBUT DU SCRIPT###

#RECHERCHE DES COMPTES AD UTILISATEURS NON CONNECTÉS DEPUIS $temps
#-----------------------------------------------------------------
$listeComptesADUtilisateursNonConnectesDepuisXTemps = Get-ADUser -Filter 'Name -like "*"' {lastLogonDate -lt $temps} -Properties CN,lastlogondate -SearchBase $OUSource | Select-Object "CN","LastLogonDate"

#Possibilité d'envoyer un mail à X personnes contenant la liste de ces machines
#$corpsMail = $listeComptesADDesactives | out-string
#Send-MailMessage -To "toto@aaaa.fr" -From "titi@aaaa.fr" -Subject "Liste des machines déplacées" -Body $corpsMail -SmtpServer #$serveurSMTP

#DÉPLACEMENT DES COMPTES AD UTILISATEURS NON CONNECTÉS DEPUIS $temps DANS L'OU $OUCible
#--------------------------------------------------------------------------------------
$listeComptesADUtilisateursNonConnectesDepuisXTemps | Move-ADObject -TargetPath $OUCible

#DÉSACTIVATION DES COMPTES AD UTILISATEURS NON CONNECTÉS DEPUIS $temp DANS L'OU $OUCible
#---------------------------------------------------------------------------------------
Get-ADUser -Filter 'Name -like "*"' {lastLogonDate -lt $temps} -Properties CN,lastlogondate -SearchBase $OUCible | Disable-ADAccount