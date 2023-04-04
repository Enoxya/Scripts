##VARIABLES
$Repertoire_Travail = "Z:\monewin"
$Repertoire_Backup = "Z:\monewin\Backup"
$FichierCSV_Entree = "import_compte.csv"
$DateDuJour = (Get-Date).ToString('yyyyMMdd')
$FichierExcel_Sortie = "import_compte.xlsx"

##FONCTIONS
#Fonction qui exporte le contenu du fichier Excel en fichier CSV
Function ExcelToCsv ($FileXls_In, $FileCSV_Out) {
    $Excel = New-Object -ComObject Excel.Application
    $Excel.DisplayAlerts = $false
    $Excel.visible = $false
    $wb = $Excel.Workbooks.Open($FileXls_In)
    foreach ($ws in $wb.Worksheets) {
        $ws.SaveAs($FileCSV_Out, 42)
    }
    #Avant de fermer Excel on ferme bine tous les classeurs
    while ($Excel.Workbooks.Count -gt 0) {
        $Excel.Workbooks.Item(1).Close()
    }
    #On ferme Excel
    $Excel.Quit
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Remove-Variable -Name Excel
}

##PROGRAMME
#On importe les données du fichier CSV dans une variable
$Donnees = Import-Csv -Path ($Repertoire_Travail + "\" + $FichierCSV_Entree) -Header 1,2,3,4,5,6,7,8,9,10 -Delimiter ";" -Encoding utf8

#On ouvre excel, on créé un classeur, on change le format de la colonne 8 (@ = Texte)
$Excel = New-Object -ComObject excel.Application
$Excel.DisplayAlerts = $false
$Excel.visible = $false
$Workbook = $Excel.Workbooks.add()
$WorkSheet = $WorkBook.ActiveSheet
$WorkSheet.activate()
$WorkSheet.Columns.Item(8).NumberFormat = "@" 

#On boucle sur chaque ligne de la variable remplie précédemment par le contenu du fichier CSV pour remplir le fichier Excel
$i = 1
foreach ($Donnee in $Donnees) {
    $Excel.Cells.Item($i,1) = $Donnee.1
    $Excel.Cells.Item($i,2) = $Donnee.2
    $Excel.Cells.Item($i,3) = $Donnee.3
    $Excel.Cells.Item($i,4) = $Donnee.4
    $Excel.Cells.Item($i,5) = $Donnee.5
    $Excel.Cells.Item($i,6) = $Donnee.6
    $Excel.Cells.Item($i,7) = $Donnee.7
    $Excel.Cells.Item($i,8) = $Donnee.8
    $Excel.Cells.Item($i,9) = $Donnee.9
    $Excel.Cells.Item($i,10) = $Donnee.10
    $i++
}

##Gestion des étudiants boursiers - Repas à 1€
#Changement intitulé colonne si telle autre colonne contient telle valeur
$NbreLignes = $WorkSheet.UsedRange.Rows.Count
For($j=1;$j -lt $NbreLignes+1 ;$j++) { 
    $ValeurCellule = $WorkSheet.Cells.Item($j, 7).Value2
    #Si la cellule en question contiennt telle valeur
    if ($ValeurCellule -eq "B") {
        Write-Host "Il y a la valeur 'B' à la ligne " $i
        #Alors on change l'intitulé
        $WorkSheet.Cells.Item($j, 6).Value2 = "Etudiants IFSI 1€"
    } 
}
#Suppression colonne G - la 7ième - qui contient la lettre identifiant les boursiers (B)
$WorkSheet.Columns.Item(7).EntireColumn.Delete()

#Sauvegarde fichier xlsx + on ferme Excel
$Workbook.SaveAs($Repertoire_Travail + "\" + $FichierExcel_Sortie)
while ($Excel.Workbooks.Count -gt 0) {
    $Excel.Workbooks.Item(1).Close()
}
$Excel.Quit
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
Remove-Variable -Name Excel

##Backup
#On déplace le fichier "import_compte" du jour (avant modification) dans le dossier de Backup et on le renomme à la date du jour
Move-Item -Path ($Repertoire_Travail + "\" + $FichierCSV_Entree) -Destination ($Repertoire_Backup +"\"+ ($FichierCSV_Entree -replace '.{4}$')+"_$DateDuJour.csv")

#On se sert du fichier xlsx créé pour le re-exporter en CSV
$FichierExcel_Entree = Get-ChildItem $Repertoire_Travail -filter *.xlsx
$FichierCSV_Sortie = $Repertoire_Travail + "\" + ($FichierExcel_Entree.Name -replace (".xlsx","_$DateDuJour.csv"))
ExcelToCsv $FichierExcel_Entree $FichierCSV_Sortie

#On renomme le fichier transformé de "import_compte_$DateDuJour.csv" en "import_compte.csv"
Rename-Item -Path $FichierCSV_Sortie -NewName ($Repertoire_Travail + "\" + $FichierCSV_Entree)
#On supprime le fichier "xlsx" créé temporairement
Remove-Item -Path ($Repertoire_Travail + "\" + $FichierExcel_Sortie)
