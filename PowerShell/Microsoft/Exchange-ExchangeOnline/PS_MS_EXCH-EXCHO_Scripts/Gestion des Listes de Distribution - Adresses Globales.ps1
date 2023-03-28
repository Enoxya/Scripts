# ---- CONNEXION AU POWERSHELL EXCHANGE ----
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://srv-nor-cas1/PowerShell/ -Authentication Kerberos 
Import-PSSession $Session
#Remove-PSSession $Session


# ---- Gestion des Listes d'Adresses Globales ----
# Get-GlobalAddressList
# Update-GlobalAddressList -Identity "Liste d'adresses globale par défaut"

# ---- Gestion des Listes de Distribution et des boites mails ----

# Get-DistributionGroup
# Set-DistributionGroup -Identity "webapvcichal" -HiddenFromAddressListsEnabled $true

# Get-DistributionGroup -Anr web | Set-DistributionGroup -HiddenFromAddressListsEnabled $true

$Liste = Get-Mailbox -Identity "ref*"

# Pour tout user dans la valeur $Liste.... 

foreach ($User in $Liste) 
    {
    
    Set-Mailbox -Identity $User.samaccountName -HiddenFromAddressListsEnabled $true
    }


# Vérification sont autorisés à recevoir des mails en interne uniquement ou externe

# Get-DistributionGroup -Identity "web*" | select Name, RequireSenderAuthenticationEnabled     
