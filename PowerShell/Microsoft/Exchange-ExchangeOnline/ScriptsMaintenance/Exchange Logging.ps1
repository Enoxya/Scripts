# -----------------------------------------------
# ADMINISTRATION EXCHANGE
# -----------------------------------------------

# ---- CONNEXION AU POWERSHELL EXCHANGE
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://srv-nor-cas1/PowerShell/ -Authentication Kerberos 
Import-PSSession $Session


# ---- REQUETES LOG
#$expéditeur = "sid@autobernard.com"
$destinataire =“l.coulon@autobernard.com”
$datedébut = "04/21/2017 11:00:00"
$datfin = "04/21/2017 12:00:00"

Get-MessageTrackingLog   -Recipients $destinataire -Start $datedébut -End $datfin  | ft -Property timestamp, source, eventid, sender, recipients, messagesubject, totalbytes, directionality, totalbytes, messagelatency -wrap –autosize 
# -Sender $expéditeur

#Remove-PSSession $Session

#-Sender $expéditeur
#-Recipients $destinataire

 # -Recipients $destinataire


 #$object = "Fichier du registre du personnel 1"
#$objet = "KIT CREANCES"
# -Sender $expéditeur 
# -MessageSubject $objet 
# -Recipients $destinataire

# -Sender $expéditeur 
#-MessageSubject $object

# Mise à jour LAG
#Get-GlobalAddressList | Update-GlobalAddressList<br />get-offlineaddressbook | update-offlineaddressbook



# Liste de distribution"
#Get-MessageTrackingLog -start “07/08/2016 12:00:00” -End “07/12/2016 07:00:00” -Recipients “a.chassard@autobernard.com” -ResultSize 99999 | measure-object

#Get-MessageTrackingLog -start “06/01/2016 12:00:00” -End “06/28/2016 12:00:00” -Recipients “dsiinfra@autobernard.com” -ResultSize 99999 | measure-object


 
 
#J’espère que tu vas bien. 

#Un lien qui pourra t’aider à afficher la totalité des caractères lors de tes commandes powershell :

#https://technet.microsoft.com/fr-fr/library/dd347677.aspx

#| ft -wrap –autosize 
