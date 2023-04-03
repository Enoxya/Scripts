###################################################################"
# Active Directory : LAST LOGON 
###################################################################"

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://srv-nor-cas1.groupe-bernard.lan/PowerShell/ 
Import-PSSession $Session
Import-module activedirectory  

$LogTime = Get-Date -Format "yyyyMMdd_hhmmss"
$LogFileName = "C:\OldExchange"
$LogFile = $LogFilePath + $LogFileName + $LogTime + ".txt"

$domain = "groupe-bernard.lan"  
$DaysInactive = 120  
$time = (Get-Date).Adddays(-($DaysInactive)) 

cls
 
#1. Export dans un fichier
# $usergb = Get-ADUser -Filter {LastLogonTimeStamp -lt $time -and enabled -eq $true} -Properties LastLogonTimeStamp | 
# select-object SamAccountName, Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss')}} | export-csv C:\OLD_AD_Users.csv -notypeinformation 

# 2. Lien avec Exchange
$usergb = Get-ADUser -Filter {LastLogonTimeStamp -lt $time -and enabled -eq $true -and EmailAddress -like "*" } -Properties LastLogonTimeStamp, EMailAddress
foreach ($user in $usergb) {  Write-Output "$($user.SamAccountName)" | Out-File $LogFile -Append
            Write-Host " - $($user.Name) $($user.EmailAddress) " }
            
            

# 3. Lire le contenu du fichier 

$fic = Get-Content -Path $LogFile 
foreach ($ligne in $fic) { Get-MailboxStatistics -Identity $ligne | select displayname, lastlogontime }

#-  -Property DisplayName, LastLogonTime }

Get-mailbox -resultsize unlimited| Get-MailboxStatistics | select displayname, lastlogontime | Export-Csv C:\test.csv

Get-MailboxStatistics -identity invitationbourg 
Get-MailboxStatistics -OutVariable


# ------------------------------------------------------

Get-ADUser -Filter {DisplayName -like "montele*"} -properties *

  -Properties * | Select *MSExch* 
# Get-MailboxStatistics -Identity "secteuv" | ft -Property DisplayName, LastLogonTime
