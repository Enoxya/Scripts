#----------------------------------------------------------------------------------------------------------
#
# Ce script déplace les comptes AD machine non connectés depuis plus de XX jours/mois dans une OU à définir
# et/ou
# désactive les comptes AD machines non connectés depuis plus de XX jours/mois
#
# ---------------------------------------------------------------------------------------------------------

#Paramètres obligatoires :
$temps = (Get-Date).AddDays(-365)
$OUSource = "" #De la forme "OU=ZZZ,OU=YYY,DC=XXX,DC=com/fr"
$OUCible = "" #De la forme "OU=ZZZ,OU=YYY,DC=XXX,DC=com/fr"

#Paramètre optionnel :
#$serveurSMTP = bbbbbb.domaine.com/fr


###DÉBUT DU SCRIPT###

#RECHERCHE DES COMPTES AD MACHINE NON CONNECTÉS DEPUIS $temps
#------------------------------------------------------------
$listeMachinesNonConnecteesDepuisXTemps = Get-ADComputer -Filter {lastLogonDate -lt $temps} -Properties CN,lastlogondate -SearchBase $OUSource | Select-Object "CN","LastLogonDate"

#Possibilité d'envoyer un mail à X personnes contenant la liste de ces comptes AD machines :
#$corpsMail = $listeMachinesNonConnecteesDepuisXTemps | out-string
#Send-MailMessage -To "toto@aaaa.fr" -From "titi@aaaa.fr" -Subject "Liste des machines déplacées" -Body $corpsMail -SmtpServer #$serveurSMTP


#DÉPLACEMENT DES COMPTES AD MACHINE NON CONNECTÉS DEPUIS $temps
#--------------------------------------------------------------
$listeMachinesNonConnecteesDepuisXTemps | Move-ADObject -TargetPath $OUCible


#DÉSACTIVATION ET SUPPRESSION DES COMPTES AD MACHINES NON CONNECTÉS DEPUIS $temps
#--------------------------------------------------------------------------------
#Désactivation des comptes AD machines dans l'OU cible :
Get-ADComputer -Filter {lastLogonDate -lt $temps} -Properties CN,lastlogondate -SearchBase $OUCible | Disable-ADAccount

#Suppression des comptes AD machines dans l'OU cible :
Get-ADComputer -Filter {lastLogonDate -lt $temps} -Properties CN,lastlogondate -SearchBase $OUCible | Remove-ADComputer
