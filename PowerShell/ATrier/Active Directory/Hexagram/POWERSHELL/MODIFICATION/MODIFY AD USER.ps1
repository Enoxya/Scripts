#SCRIPT DE MODIFICATION DE COMPTE DANS L'ACTIVE DIRECTORY
#POUR RETROUVER L'UTILISATEUR, ON SE BASE SUR L'ID UNIQUE

#DECLARATION DES VARIABLES

$modification_csv_path = "C:\Temp\HEXAGRAM\TEST FINAL\MODIFICATION\modification.csv"
$modification_csv = Import-Csv -Delimiter ";" -Path $modification_csv_path




#IMPORT DU CSV

foreach ($user in $modification_csv){

    #BIND VARIABLES LOCALES FOREACH

    #BIND DES VARIABLES CSV

    $Lastname = $user.Nom -replace '\s',''
    $Firstname = $user.Prenom
    $ExpirationDate = $user.'D Sortie societe'
    $Company = $user.'L Societe St. Jur.'
    $Office = $user.'L Etablissement St. Jur.'

    $ManagerLastname = $user.'Nom - N+1'
    $ManagerFirstname = $user.'Prenom - N+1'
    $Manager = Get-ADUser -Filter * -Properties * | Where-Object {($_.GivenName -eq $ManagerFirstname) -and ($_.Surname -eq $ManagerLastname)} | Select-Object -ExpandProperty DistinguishedName

    $UserUniqueID = $user.Matricule
    $NewUserUniqueID = $user.NouveauMatricule


    $Title = $user.'L Emploi'

    $MobilePhone = $user.Telephone


    $Usr =  Get-ADUser -Filter * -Properties * | Where-Object {$_.EmployeeID -eq "$UserUniqueID"} | Select-Object SamAccountName, DisplayName, GivenName, Surname, AccountExpirationDate, Company, Office, Manager, Title, MobilePhone, DistinguishedName, EmployeeID

    $OLDDN = $Usr.DistinguishedName
    $UsrSam = $Usr.SamAccountName

    if ($Usr.EmployeeID -ne $NewUserUniqueID){
        Set-ADUser -Identity $UsrSam -EmployeeID $NewUserUniqueID
    }


    if ($Usr.AccountExpirationDate -ne $ExpirationDate){

        Set-ADUser -Identity $UsrSam -AccountExpirationDate $ExpirationDate

    }

    if ($usr.Company -ne $Company){
        Set-ADUser -Identity $UsrSam -Company $Company

    }


    if ($usr.Office -ne $Office){
        Set-ADUser -Identity $UsrSam -Office $Office

    }
    if ($usr.Title -ne $Title){
        Set-ADUser -Identity $UsrSam -Title $Title

    }
    if ($usr.MobilePhone -ne $MobilePhone){
        Set-ADUser -Identity $UsrSam -MobilePhone $MobilePhone

    }

    if ($usr.Manager -ne $Manager){

        Set-ADUser -Identity $UsrSam -Manager $Manager

    }

    if ($Usr.Lastname -ne "$Lastname" -or $Usr.Firstname -ne "$Firstname" ) {

        $UPN = "$Firstname"+"."+"$Lastname"+"@groupe-bernard.lan"
        $DISPLAYNAME = "$Firstname"+" "+"$Lastname"
        $INITIALS = $user.Prenom[0] + $user.Nom[0]

        $sam = $user.Nom[0..5]
        $sam1 = "$sam" -replace "\s{0,}" , ""
        $SAMACCOUNTNAME = $sam1 + $user.Prenom[0]

        Set-ADUser -Identity $UsrSam -Surname $Lastname -GivenName $Firstname -UserPrincipalName $UPN -DisplayName $DISPLAYNAME -Initials $INITIALS -SamAccountName $SAMACCOUNTNAME
        Rename-ADObject -Identity $OLDDN -NewName $DISPLAYNAME

    }

}