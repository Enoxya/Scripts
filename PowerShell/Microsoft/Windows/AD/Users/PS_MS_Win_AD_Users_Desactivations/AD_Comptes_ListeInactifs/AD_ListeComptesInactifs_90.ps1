# Chargement du module AD
Import-Module ActiveDirectory

# Titre des colonnes
$result="Prenom, Nom, Nom complet, Login, Marque, Ville, Titre, Date derniere connexion AD`r`n"

# Liste des controleurs de domaine
$dcs = Get-ADDomainController -Filter {Name -like "SRV-NOR-DC*"}
$DaysInactive = 90
$time = (Get-Date).Adddays(-($DaysInactive)) 

# Liste des Users AD
$AllUsers = Get-ADUser -Filter * `            -SearchBase "OU=Bernard,DC=groupe-bernard,DC=lan" `            -Properties GivenName, Surname, LastLogonTimeStamp, DisplayName, title, company, PhysicalDeliveryOfficeName

foreach($user in $AllUsers)
    {
    $DCLogonTimes = @()
    foreach ($dc in $DCs) 
	    {
        $DCLogonTimes += (Get-ADUser -Identity $user.SamAccountName -Server $dc.Name -Properties LastLogonDate).LastLogonDate
    }
					
    #Tri des dates pour r�cup�rer la plus r�cente
    $DCLogonTimes = $DCLogonTimes | Sort-Object -Descending
      
    # Si Date < 120 jours ou derni�re date de connexion AD vide
    if (($DCLogonTimes -lt $time) -or (!$DCLogonTimes)) 
        {
        $result += $user.Surname,",",$user.GivenName,",",$user.DisplayName,",",$user.SamAccountName,",",$user.Company,",",$user.PhysicalDeliveryOfficeName,",",$user.Title,"," 
        if ($DCLogonTimes)
            {
            $result += $DCLogonTimes[0].ToString("dd/MM/yyyy")
        }
        else
            {
            $result += "Jamais connect�"
        }
        $result += ",`r`n"
    } 
}
                          
$result > XXX\YYYY\ZZZ.csv