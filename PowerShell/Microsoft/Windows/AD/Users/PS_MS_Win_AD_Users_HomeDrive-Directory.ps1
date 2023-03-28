#Variables :
#-----------
$homeDirectoy_Chemin ="\\chb.ts1.local\Fichiers\Utilisateurs\"
$OU_Chemin = 'OU=Test-GPO_Utilisateurs,OU=Utilisateurs,OU=CHBOURG,DC=chb,DC=ts1,DC=local'
$domaine = "chb"


#ATTENTION : la recherche englobe aussi les comptes de services, de prest, systeme etc. (tous ceux qui n'ont pas un "U:"
$utilisateurs_AvecPB_PasU = Get-AdUser -Filter {-not(HomeDrive -like "*U*") } -Properties * -SearchBase $OU_Chemin | Select SamAccountName, HomeDirectory,HomeDrive
foreach ($utilisateur in $utilisateurs_AvecPB_PasU) {
    Set-ADUser -Identity $utilisateur.SamAccountName -HomeDrive "U:"
    Set-ADUser -Identity $utilisateur.SamAccountName -HomeDirectory $homeDirectoy_Utilisateur
    $compteAD= $domaine+"\"+$utilisateur.SamAccountName
    
    $FileSystemAccessRights=[System.Security.AccessControl.FileSystemRights]"FullControl"
    $InheritanceFlags=[System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit"
    $PropagationFlags=[System.Security.AccessControl.PropagationFlags]::None
    $AccessControl=[System.Security.AccessControl.AccessControlType]::Allow
    
    $NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule ` ($compteAD, $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)
    $CurrentACL=Get-ACL -path $homeDirectoy_Utilisateur
    $CurrentACL.SetAccessRule($NewAccessrule)
    Set-ACL -path $homeDirectoy_Utilisateur -AclObject $CurrentACL
}

#Cette recherche est pour tous les utilisateurs ont un U mais mal définit
$utilisateurs_AvecPB_CHBFS01 = Get-AdUser -Filter {(HomeDrive -like "*U*") -and (HomeDirectory -like "*CHB-FS-01*")} -Properties * -SearchBase $OU_Chemin | Select SamAccountName, HomeDirectory,HomeDrive #| Export-CSV -Path C:\Temp\Users_homedir.csv -NoTypeInformation
foreach ($utilisateur in $utilisateurs_AvecPB_CHBFS01) {
    $homeDirectoy_Utilisateur = $homeDirectoy_Chemin + $utilisateur.SamAccountName
    Set-ADUser -Identity $utilisateur.SamAccountName -HomeDirectory $homeDirectoy_Utilisateur
    $compteAD= $domaine+"\"+$utilisateur.SamAccountName
    
    $FileSystemAccessRights=[System.Security.AccessControl.FileSystemRights]"FullControl"
    $InheritanceFlags=[System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit"
    $PropagationFlags=[System.Security.AccessControl.PropagationFlags]::None
    $AccessControl=[System.Security.AccessControl.AccessControlType]::Allow
    
    $NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule ` ($compteAD, $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)
    $CurrentACL=Get-ACL -path $homeDirectoy_Utilisateur
    $CurrentACL.SetAccessRule($NewAccessrule)
    Set-ACL -path $homeDirectoy_Utilisateur -AclObject $CurrentACL
}