#$listeUtilisateurs = Get-Aduser -Filter * -SearchBase "OU=Pouet, OU=Norelan, OU=Branches, OU=Utilisateurs, OU=Bernard, DC=groupe-bernard, DC=lan"
$listeUtilisateurs = Get-ADGroupMember GRP_Norelan2

ForEach ($utilisateur in $listeUtilisateurs)
    {
    Set-ADUser $utilisateur -PasswordNeverExpires $False
    Set-ADUser $utilisateur -Replace @{pwdLastSet='0'}
    }

