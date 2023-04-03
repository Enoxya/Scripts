$users = Import-Csv -Path "C:\Temp\Tenedor.csv" -Delimiter ";"
$path = "OU=Tenedor,OU=Mercedes,OU=Branches,OU=Utilisateurs,OU=Bernard,DC=groupe-bernard,DC=lan"
$region = "Champagne Ardenne" 
$pays = "Fr"

foreach ($user in $users) {

    $user_FIRTNAME = $user.Prenom	
    $user_LASTNAME = $user.Nom -replace '\s',''
    $user_UPN = "$user_FIRTNAME"+"."+"$user_LASTNAME"+"@autobernard.com"
   
    $user_COMPANY = $user.'Societe'
    $user_OFFICE = $user.'Bureau'
   
    $address = $user.Adresse
    $city = $user.Ville
    $department = $user.Service
    $postalcode = $user.CodePostale
    $OfficePhone = $user.Telephone
    

    $user_TITLE = $user.'libelleEmploi'
    $user_INITIAL = $user.Prenom[0] + $user.Nom[0]
    $user_NAME = "$user_FIRTNAME"+" "+"$user_LASTNAME"
    $user_DISPLAYNAME = "$user_FIRTNAME"+" "+"$user_LASTNAME" 
    $sam = $user.Nom[0..5]
    $sam1 = "$sam" -replace "\s{0,}" , ""
    $user_SAMACCOUNTNAME = $sam1 + $user.Prenom[0]

    $ADPassword = "Temp@69"
    $SecureADPassword = ConvertTo-SecureString -String "$ADPassword" -AsPlainText -Force
    
New-ADUser -DisplayName $user_DISPLAYNAME -Name $user_NAME -GivenName $user_FIRTNAME -Surname $user_LASTNAME -UserPrincipalName $user_UPN -SamAccountName $user_SAMACCOUNTNAME -StreetAddress $address -City $city -Department $department -Company $user_COMPANY -Office $user_OFFICE -PostalCode $postalcode -State $region -Country $pays -Title $user_TITLE -Initials $user_INITIAL -OfficePhone $OfficePhone -Path $path -AccountPassword $SecureADPassword -Enabled $false -ChangePasswordAtLogon $true
            
            }


