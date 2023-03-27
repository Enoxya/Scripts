Import-Module ActiveDirectory

$pathImportCSV = "XXX\YYY\ZZZ.csv"

$listeUtilisateurs = import-csv -delimiter ";" -Path $pathImportCSV

ForEach ($utilisateur in $listeUtilisateurs)
    {
    $utilisateur_nomComplet = $utilisateur.Nom + " " + $utilisateur.Prenom

    #Recherche du compte AD correspondant au nom complet
    $listeUtilisateursAD = Get-ADUser -Filter {name -like $utilisateur_nomComplet} -Properties SamAccountName, DisplayName
    if ($listeUtilisateursAD.count -eq 0) 
        {
        Write-Host "Impossible de trouver un compte correspondant au nom $utilisateur_nomComplet - Indiquer un compte manuellement :"
        return Read-Host
    }
    elseif ($listeUtilisateursAD.Count -gt 1)
        {
        Write-Host "Ce compte possède plusieurs homonymes, il faut faire un choix : "
        foreach ($utilisateurAD in $listeUtilisateursAD)
            {
            Write-host "$i. $($utilisateurAD.SamAccountName) -> $($utilisateurAD.DisplayName) " -ForegroundColor Green
            $i=$i+1
        }
        $choix = (Read-Host) - 1 
        $utilisateur_SamAccountName = $listeUtilisateursAD[$choix].SamAccountName
    }
    else
        {
        $utilisateur_SamAccountName = $listeUtilisateursAD.SamAccountName
    }
}
    
Disable-ADAccount -Identity $utilisateur_SamAccountName