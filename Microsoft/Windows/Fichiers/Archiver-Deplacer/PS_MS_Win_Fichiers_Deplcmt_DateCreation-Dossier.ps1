$repertoireOrigine = "D:\CENG\Fichiers\PRODUCTION\Import\Medical\PN13\Prescriptions\HM\SVG"
$listeFichiers = Get-ChildItem -Path $repertoireOrigine -File #-Include ('*.xml', '*.ok') si besoin
ForEach ($fichier in $listeFichiers) {
    $date = $fichier.LastWriteTime.ToString('yyyy MM dd')
    If (Test-Path ($repertoireOrigine + "\" + $date)) {
        move-Item -Path ($repertoireOrigine + "\" + $fichier) -Destination ($repertoireOrigine + "\" + $date)
    }
    Else {
        New-Item -Path $repertoireOrigine -Name $date -ItemType "directory"
        move-Item -Path ($repertoireOrigine + "\" + $fichier) -Destination ($repertoireOrigine + "\" + $date)
    }
}