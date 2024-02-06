# -----------------------------------------------
# ADMINISTRATION EXCHANGE
# -----------------------------------------------

# ---- CONNEXION AU POWERSHELL EXCHANGE
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://srv-nor-cas1/PowerShell/ -Authentication Kerberos 
Import-PSSession $Session
#Remove-PSSession $Session

# ---- REQUETES SERVEURS
 Get-Mailbox -Server SRV-NOR-EXCH1 
 Get-Mailbox -Server SRV-NOR-EXCH2 
 Get-Mailbox -Server SRV-NOR-EXCH3 

# ---- ETAT DES BASES
 Get-MailboxDatabase -Status | ft
 Get-MailboxDatabaseCopyStatus -Server SRV-NOR-MBX1 | Ft -AutoSize #| Sort-Object Status –Descending
 Get-MailboxDatabaseCopyStatus -Server SRV-NOR-MBX2 | Ft -AutoSize #| Sort-Object Status –Descending


 
 
 

 Get-MailboxDatabaseCopyStatus *
