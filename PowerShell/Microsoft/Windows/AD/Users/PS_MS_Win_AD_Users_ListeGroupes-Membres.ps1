Import-Module ActiveDirectory

$LogFilePath = $home + "\Desktop\Test\"
$LogTime = Get-Date -Format "yyyyMMdd_hhmmss"


$listeGroupes = Get-ADGroup -Properties * -Filter * -SearchBase "OU=Comptabilité, OU=Accès dossiers, OU=Groupes, OU=Utilisateurs, OU= Bernard,DC=groupe-bernard,DC=lan" 
Foreach($groupe In $listeGroupes) {
    $LogFileName = $groupe.SamAccountName + "_Membres_"
    $LogFile = $LogFilePath + $LogFileName + $LogTime + ".csv"
    echo $groupe.SamAccountName >> $LogFile
    echo "-------------" >> $LogFile
    $listeMembres = Get-ADGroupMember $groupe
    Foreach ($membre in $listeMembres) {
        echo $membre.name >> $LogFile
    }
}


