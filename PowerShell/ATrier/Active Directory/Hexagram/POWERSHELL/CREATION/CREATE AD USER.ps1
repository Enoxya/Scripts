

# SCRIPT DE CREATION COMPTE DANS L'ACTIVE DIRECTORY

# IMPORT DU FICHIER CSV

$creation_csv_path = "C:\Temp\HEXAGRAM\importer.csv"
$creation_csv = Import-Csv -Delimiter ";" -Path $creation_csv_path

# CREATION FICHIER LOG

$logfile_path = "C:\Temp\HEXAGRAM\test.log"
$logfile = New-Item -Path $logfile_path -ItemType "File" -Force

$logfile

# CREATION DE TOUS LES UTILISATEURS DANS LE FICHIER CSV

foreach ($user in $creation_csv){

    # IMPORTANT POUR LES LOGS

    $Error.Clear()

    # FONCTION DE CREATION

    function Create-CorporateADUser($user_FIRTNAME, $user_LASTNAME, $user_UPN, $user_EXPIRATIONDATE, $user_COMPANY, $user_OFFICE, $user_HIERARCHICALLIABLE, $user_TITLE, $user_INITIAL, $user_NAME, $user_DISPLAYNAME, $ou_create, $SecureADPassword, $user_SAMACCOUNTNAME)
    {

    # BIND DES VARIABLES DEPUIS LE FICHIER CSV

    $user_FIRTNAME = $user.Prenom	
    $user_LASTNAME = $user.Nom -replace '\s',''
    $user_UPN = "$user_FIRTNAME"+"."+"$user_LASTNAME"+"@groupe-bernard.lan"
    $user_EXPIRATIONDATE = $user.'D Sortie societe'
    $user_COMPANY = $user.'L Societe St. Jur.'
    $user_OFFICE = $user.'L Etablissement St. Jur.'
    $user_HIERARCHICALLIABLE_FIRSTNAME = $user.'Prenom - N+1'
    $user_HIERARCHICALLIABLE_LASTNAME = $user.'Nom - N+1'
    $user_HIERARCHICALLIABLE = Get-ADUser -Filter * -Properties * | Where-Object {($_.GivenName -eq $user_HIERARCHICALLIABLE_FIRSTNAME) -and ($_.Surname -eq $user_HIERARCHICALLIABLE_LASTNAME)} | Select-Object -ExpandProperty DistinguishedName
   

    $user_TITLE = $user.'L Emploi'
    $user_INITIAL = $user.Prenom[0] + $user.Nom[0]
    $user_NAME = "$user_FIRTNAME"+" "+"$user_LASTNAME"
    $user_DISPLAYNAME = "$user_FIRTNAME"+" "+"$user_LASTNAME" 
    $sam = $user.Nom[0..5]
    $sam1 = "$sam" -replace "\s{0,}" , ""
    $user_SAMACCOUNTNAME = $sam1 + $user.Prenom[0]

    $ADPassword = "Temp@69"
    $SecureADPassword = ConvertTo-SecureString -String "$ADPassword" -AsPlainText -Force
    
    # OU RECHERCHE et DESTINATION

    $ou = "OU=Utilisateurs,OU=Bernard,DC=groupe-bernard,DC=lan"
    $ou_create = "OU=Creation,OU=Désactivés,OU=Utilisateurs,OU=Bernard,DC=groupe-bernard,DC=lan"

    # VERIFICATION QUE L'UNIQUE ID SOIT VRAIMENT UNIQUE : SI LE TEST RENVOI LA VALEUR NULL ALORS ON CREE L'UTILISATEUR, SINON ON INFORME DANS LE LOG QUE L'ID N'EST PAS UNIQUE 
    $user_UNIQUEID = $user.Matricule
    

    # ATTENTION IL NE FAUT PAS RECHERCHER DANS TOUT L'AD SINON LES COMPTES DE SERVICES SERONT PRIS EN COMPTE ET LE SCRIPT SERA FAUX
    
    $getuser = Get-ADUser -SearchBase $ou -Filter * -Properties * | Where-Object {($_.EmployeeID -eq $user_UNIQUEID) -or ($_.SamAccountName -eq $user_SAMACCOUNTNAME) -or ($_.userPrincipalname -eq $user_UPN)}

    

    if ($getuser -eq $null){

        # PAS D'UTILISATEUR EXISTANT AVEC LE MEME UNIQUE ID ou LE MEME SAMACCOUNTNAME ou le MEME UPN

        Write-Host "Creation de l'utilisateur $user_DISPLAYNAME"


        # SI PAS DE MANAGER ET PAS DE DATE D'EXPIRATION RENSEIGNE DANS LE FICHIER CSV

        if (($user_HIERARCHICALLIABLE -eq "$null") -and ($user_EXPIRATIONDATE -eq "$null")){

         

            New-ADUser -DisplayName $user_DISPLAYNAME -Name $user_NAME -GivenName $user_FIRTNAME -Surname $user_LASTNAME -UserPrincipalName $user_UPN -SamAccountName $user_SAMACCOUNTNAME -EmployeeID $user_UNIQUEID -Company $user_COMPANY -Office $user_OFFICE -Title $user_TITLE -Initials $user_INITIAL -Path $ou_create -AccountPassword $SecureADPassword -Enabled $false -ChangePasswordAtLogon $true
            
            }



        # SI PAS DE MANAGER RENSEIGNE DANS LE FICHIER CSV

        elseif ($user_HIERARCHICALLIABLE -eq "$null"){

            New-ADUser -DisplayName $user_DISPLAYNAME  -Name $user_NAME -GivenName $user_FIRTNAME -Surname $user_LASTNAME -UserPrincipalName $user_UPN -SamAccountName $user_SAMACCOUNTNAME -EmployeeID $user_UNIQUEID -AccountExpirationDate $user_EXPIRATIONDATE -Company $user_COMPANY -Office $user_OFFICE -Title $user_TITLE -Initials $user_INITIAL -Path $ou_create -AccountPassword $SecureADPassword -Enabled $false -ChangePasswordAtLogon $true
            
            }


        # SI PAS DE DATE D'EXPIRATION RENSEIGNEE DANS LE FICHIER CSV

        elseif ($user_EXPIRATIONDATE -eq "$null"){

            
            New-ADUser -DisplayName $user_DISPLAYNAME  -Name $user_NAME -GivenName $user_FIRTNAME -Surname $user_LASTNAME -UserPrincipalName $user_UPN -SamAccountName $user_SAMACCOUNTNAME -EmployeeID $user_UNIQUEID -Company $user_COMPANY -Office $user_OFFICE -Manager $user_HIERARCHICALLIABLE -Title $user_TITLE -Initials $user_INITIAL -Path $ou_create -AccountPassword $SecureADPassword -Enabled $false -ChangePasswordAtLogon $true
            
            }


        # SI TOUTES LES VALEURS SONT RENSEIGEES DANS LE FICHIER CSV

        else{

            
            New-ADUser -DisplayName $user_DISPLAYNAME  -Name $user_NAME -GivenName $user_FIRTNAME -Surname $user_LASTNAME -UserPrincipalName $user_UPN -SamAccountName $user_SAMACCOUNTNAME -EmployeeID $user_UNIQUEID -AccountExpirationDate $user_EXPIRATIONDATE -Company $user_COMPANY -Office $user_OFFICE -Manager $user_HIERARCHICALLIABLE -Title $user_TITLE -Initials $user_INITIAL -Path $ou_create -AccountPassword $SecureADPassword -Enabled $false -ChangePasswordAtLogon $true
            
            }



        # ECRIRE DANS LE LOG LES INFORMATIONS DE L'UTILISATEUR CREE

        Add-Content -Path $logfile_path -Value "Creation de l'utilisateur : $user_NAME dans l'Active Directory `r`n
         
         Nom : $user_LASTNAME `r`n
         Prenom : $user_FIRTNAME`r`n
         UPN : $user_UPN`r`n
         Initiales : $user_INITIAL`r`n
         Samaccountname : $user_SAMACCOUNTNAME`r`n
         Nom affiche : $user_NAME`r`n
         Date expiration : $user_EXPIRATIONDATE`r`n
         Societe : $user_COMPANY`r`n
         Lieu : $user_OFFICE `r`n
         Responsable : $user_HIERARCHICALLIABLE`r`n
         Titre : $user_TITLE `r`n
         ID Unique : $user_UNIQUEID `r`n
        ####################################################################################`r`n
        ####################################################################################`r`n "

        


        }



    else {
        
        # ECRIRE DANS LE LOG QUE LE COMPTE EXISTE DEJA

        Add-Content -Path $logfile_path -Value "[ECHEC|FAILED] La creation de l'utilisateur $user_NAME dans l'Active Directory `r`n
         Verifiez les champs ID UNIQUE, SamAccountName et UserPrincipalName`r`n
        ####################################################################################`r`n
        ####################################################################################`r`n "

        
        }




    }



# APPEL DE LA FONCTION DE CREATION

Create-CorporateADUser

# BIND DES VARIABLES DE MAILING

$Mail_From = ""
$Mail_To = ""
$Mail_Subject = ""
$Mail_SmtpServer = ""

# RECUPERATION DES INFORMATIONS DU FICHIER LOG PUIS ENVOI DANS UN MAIL (a activer en retirant le commentaire sur la ligne ci-dessous)

#Get-Content -Path $logfile_path | Send-MailMessage -From $Mail_From -To $Mail_To -Subject $Mail_Subject -SmtpServer $Mail_SmtpServer





}


# END OF SCRIPT

