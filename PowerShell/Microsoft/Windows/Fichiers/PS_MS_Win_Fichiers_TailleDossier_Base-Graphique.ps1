$fichierLog_DossiersUtilisateursVides = "C:\Users\ssaunier\Desktop\Liste.txt"
$listeDossiersUtilisateurs = Get-ChildItem "\\obelix\e$\utilisateurs"
foreach ($dossierUtilisateur in $listeDossiersUtilisateurs) {
    $dossier = "\\obelix\e$\utilisateurs\"+$dossierUtilisateur.Name
    write-host "Utilisateur :" $dossierUtilisateur
    #Pour avoir la taille (avec juste deux chiffres après la virgurle et exprimée en Go)
    #"{0:N2} GB" -f ((gci –force $dossier –Recurse -ErrorAction SilentlyContinue| measure Length -s).sum / 1Gb)
    
    #Si taille = 0 (on pourrait mettre un autre filtre, genre si < 10 Mo, etc.)
    if (((Get-ChildItem -force $dossier -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -s).sum / 1Gb) -eq 0) {
        write-host "taille = 0"
        $dossier >> $fichierLog_DossiersUtilisateursVides
    }
}


$targetfolder='\\obelix\e$\utilisateurs\'
$dataColl = @()
Get-ChildItem -force $targetfolder -ErrorAction SilentlyContinue | Where-Object { $_ -is [io.directoryinfo] } | ForEach-Object {
    $len = 0
    Get-ChildItem -recurse -force $_.fullname -ErrorAction SilentlyContinue | ForEach-Object { $len += $_.length }
    $foldername = $_.fullname
    $foldersize= '{0:N2}' -f ($len / 1Gb)
    $dataObject = New-Object PSObject
    Add-Member -inputObject $dataObject -memberType NoteProperty -name “foldername” -value $foldername
    Add-Member -inputObject $dataObject -memberType NoteProperty -name “foldersizeGb” -value $foldersize
    $dataColl += $dataObject
}
$dataColl | Out-GridView -Title "Size of subdirectories"

