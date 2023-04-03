# Exporte les memebre d'un groupe AD

Get-ADGroupMember -identity “TRESO Suite Entreprise BP” | select name | Export-csv -path C:\TRESO3.csv -NoTypeInformation

Get-ADUSer -identity "charleo" -properties *



# Autres méthode

$group = '_Norelan'
$server = "SRV-NOR-CTRL1"
   

   
 $ADSIGroup = [ADSI]"WinNT://$server/$group" 
   
 foreach ($member in $ADSIGroup.Members()) { 
   
   $ADSIName = $member.GetType().InvokeMember("AdsPath","GetProperty",$null,$member,$null) 
   
   # Dans certains cas, on peut avoir un SID à la place du nom d'utilisateur. 
   # Dans ces cas-là, on affiche le SID sans chercher à reconstruire la 
   # chaîne domaine\utilisateur: 
   
   if ($ADSIName -match "[^/]/[^/]") { 
     [String]::Join("\", $ADSIName.Split("/")[-2..-1]) 
   } 
   else { 
     $ADSIName.Split("/")[-1] 
   } 
 }
   
   
    Get-ADUser -properties  DisplayName, Manager -Filter {SamAccountName -eq 'gadennj'}