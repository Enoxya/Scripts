################################################
# SCript automatisation opération AD
# Jérémie GADENNE - Nov. 2016
# Export des vieux comptes AD
################################################

# Chargement du module AD
# Import-Module ActiveDirectory

# Import des module Exchange
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://srv-nor-cas1/PowerShell/ -Authentication Kerberos 
Import-PSSession $Session

# Titre des colonnes
$result="Login, Nom complet, Marque, Ville, Titre, Derniere connexion AD, Email, Derniere connexion exchange,`r`n"

# Liste des controleurs de domaine
$dcs = Get-ADDomainController -Filter {Name -like "SRV-NOR-DC*"}
$DaysInactive = 120
$time = (Get-Date).Adddays(-($DaysInactive)) 

# Liste des Users AD
$AllUsers = Get-ADUser -Properties LastLogonTimeStamp, DisplayName, title, company, PhysicalDeliveryOfficeName, emailaddress -Filter {(Name -like "BOUCH*") } 

    foreach($user in $AllUsers)
           {
                    $DCLogonTimes = @()
                    foreach ($dc in $DCs) 
		            {
                       $DCLogonTimes += (Get-ADUser -Identity $user.SamAccountName -Server $dc.Name -Properties LastLogonDate).LastLogonDate 
                    }
					
                    #Tri des dates pour récupérer la plus récente
                    $DCLogonTimes = $DCLogonTimes | Sort-Object -Descending
      
# Si Date < 120 jours ou dernière date de connexion AD vide
if (($DCLogonTimes -lt $time) -or (!$DCLogonTimes)) 
{
$result += $user.SamAccountName,",",$user.DisplayName,",", $user.Company, ",", $user.PhysicalDeliveryOfficeName, ",", $user.Title, "," 
if ($DCLogonTimes) { $result += $DCLogonTimes[0].ToString("dd/MM/yyyy") } else { $result += "01/01/1900"}
$result += ","

# Si Adresse mail 
if ($user.EmailAddress)
   { $mailboxLastAccessTime = Get-MailboxStatistics -identity $user.DisplayName | select lastlogontime
     $result += $user.EmailAddress,",",$mailboxLastAccessTime.lastlogontime.ToString("dd/MM/yyyy")  
   } 
else
   {  $result += "NO-EMAIL",",","01/01/1900"
   }                
$result += "`r`n"
   } 
}                
                
$result > C:\liste.csv

Remove-Session $Session
