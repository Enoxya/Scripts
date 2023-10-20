# -----------------------------------------------
# ADMINISTRATION EXCHANGE
# -----------------------------------------------

# ---- CONNEXION AU POWERSHELL EXCHANGE
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://srv-nor-cas1/PowerShell/ -Authentication Kerberos 
Import-PSSession $Session
#Remove-PSSession $Session


Get-GlobalAddressList
Update-GlobalAddressList -Identity "Liste d'adresses globale par défaut"

# Préférence d'activation
# 1 - Affiche les préférences d’activation
#Get-MailboxDatabase 'DATABASE_KO'|fl server, databaseCopies, activationPreference
# 2 - Modifie les préférences d’activation 
#Set-MailboxDatabaseCopy -identity 'DATABASE_KO\SRV-NOR-MBX2' -ActivationPreference 1

# Paramétrage IMAP
Get-ImapSettings -server "SRV-NOR-MBX1"
Set-ImapSettings -server "SRV-NOR-MBX1" -LoginType 1
Set-ImapSettings -server "SRV-NOR-MBX2" -LoginType 1

# Nombre de BAL
#AU TOTAL
$mbnumber=0
Get-Mailbox -ResultSize Unlimited | where-object {$_.Database -match "database"} | ForEach-Object{ if ($_.DisplayName -ne $null) {$mbnumber++}}
$mbnumber
#Par DATABASE
(get-mailboxdatabase) | foreach-object {write-host $_.name (get-mailbox -database $_.name).count}

# ---- MIGRATION DE BOITES 
# Remove-moverequest –identity grobonm                       
# New-moverequest –identity grobonm  -targetdatabase DATABASE_FJ
# Get-moverequest –identity grobonm
# Get-moverequest|get-moverequeststatistics 

# ---- REQUETES BOITES
# Get-Mailbox -Identity electionabca | fl
# Get-MailboxStatistics -database EXCH_AE | Sort LastLogonTime -Descending
# Get-MailboxStatistics -server SRV-NOR-MBX2 | Sort LastLogonTime -Descending 
# Get-MailboxStatistics -Identity xrt*


#INFORMATION SUR UNE BOITE

get-mailbox -identity diacrnpontarlier | fl 

# ---- TAILLE DE BOITES
Get-MailboxStatistics n.duverne@autobernard.com | ft DisplayName, TotalItemSize, ItemCount
#Get-MailboxStatistics  | ft DisplayName, TotalItemSize, ItemCount | Sort-Object TotalItemSize –Descending 
# TOP 10
#Get-Mailbox -ResultSize unlimited | Get-MailboxStatistics | Sort-Object -Ascending -Property TotalItemSize | Select-Object DisplayName,TotalItemSize -First 10

#Export dans un fichier
#Get-Mailbox -ResultSize Unlimited | Get-MailboxStatistics | Select DisplayName,StorageLimitStatus,@{name="TotalItemSize (MB)";expression={[math]::Round(($_.TotalItemSize.Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}},@{name="TotalDeletedItemSize (MB)";expression={[math]::Round(($_.TotalDeletedItemSize.Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}},ItemCount,DeletedItemCount | Sort "TotalItemSize (MB)" -Descending | Export-CSV "C:\My Documents\All Mailboxes.csv" -NoTypeInformation



# ---- BOITES DÉCONNECTÉES 
# Visualiser les boites déconnectées |
Get-MailboxStatistics -Server SRV-NOR-MBX1 | Where { $_.DisconnectReason -ne $null } | Sort-Object DisconnectDate | ft DisplayName, Database, DisconnectDate, DisconnectReason 
Get-MailboxStatistics -Server SRV-NOR-MBX2 | Where { $_.DisconnectReason -ne $null } | Sort-Object DisconnectDate | ft DisplayName, Database, DisconnectDate, DisconnectReason

#Reconnecter une boite aux lettres déconnectées à un utilisateur:
Connect-Mailbox -Identity diacrnpontarlier -Database DATABASE_AE -user diacrnpontarlier -ManagedFolderMailboxPolicyAllowed


# Gestion des Listes d'Adresses Globales
Get-GlobalAddressList
Update-GlobalAddressList -Identity "Liste d'adresses globale par défaut"

Get-Mailbox "securite sante" | Add-ADPermission -User "POIRIER Sandrine" -ExtendedRights "Send As"


# Exporter toutes les boites */

get-mailbox | select Name, DistinguishedName, DisplayName, ALias, EmailAddresses  | export-csv "C:\MailboxList.csv"

 Get-Mailbox | Get-Member


 # Vérifier les groupe de distirbution sont autorisés à recevoir des mails en interne uniquement ou externe
 Get-DistributionGroup -Identity "web*" | select Name, RequireSenderAuthenticationEnabled     
