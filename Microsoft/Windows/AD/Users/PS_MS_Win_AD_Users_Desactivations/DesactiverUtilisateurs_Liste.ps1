$PathImportCSV = "C:\Users\saunies\Desktop\Test.csv"

Import-Module ActiveDirectory

$ListeUtilisateurs = import-csv -delimiter ";" -Path $PathImportCSV

ForEach ( $Utilisateurs in $ListeUtilisateurs)
    {
    $samAccountName = $Utilisateurs.ID
    Disable-ADAccount -Identity $samAccountName
}