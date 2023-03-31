Param(
  $FichierCSV = "C:\Users\ssaunier\Desktop\a.csv",
  $FichierExcel = "C:\Users\ssaunier\Desktop\aa.csv"
)

$Donnees = Import-Csv -Path $FichierCSV -Header 1,2,3,4,5,6,7,8,9,10 -Delimiter ";" -Encoding utf8

$Excel = New-Object -ComObject excel.Application
$Excel.visible = $false
$Workbook = $Excel.workbooks.add()
$WorkSheet = $WorkBook.ActiveSheet
$WorkSheet.activate()
$WorkSheet.Columns.Item(8).NumberFormat = "@" 
$i = 1
foreach ($Donnee in $Donnees) {
    $excel.Cells.Item($i,1) = $Donnee.1
    $excel.Cells.Item($i,2) = $Donnee.2
    $excel.Cells.Item($i,3) = $Donnee.3
    $excel.Cells.Item($i,4) = $Donnee.4
    $excel.Cells.Item($i,5) = $Donnee.5
    $excel.Cells.Item($i,6) = $Donnee.6
    $excel.Cells.Item($i,7) = $Donnee.7
    $excel.Cells.Item($i,8) = $Donnee.8
    $excel.Cells.Item($i,9) = $Donnee.9
    $excel.Cells.Item($i,10) = $Donnee.10
    $i++
}

<#
# Ouverture du fichier Excel
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $true
$excel.DisplayAlerts = $false #Permet de ne plus avoir le pop-up de confirmation si le fichier existe déjà lors de l'entregistrement plus bas dans le script
$workBook = $excel.Workbooks.Open($fichierExcel)
$WorkSheet = $workBook.ActiveSheet
$WorkSheet.activate()
#>


##Gestion des étudiants boursiers - Repas à 1€
#Changement intitulé colonne si telle autre colonne contient telle valeur
$nbreLignes = $WorkSheet.UsedRange.rows.count
For($i=1;$i -lt $nbreLignes+1 ;$i++) { 
    $valeurCellule = $WorkSheet.Cells.Item($i, 7).Value2
    #Si la cellule en question contiennt telle valeur
    if ( $valeurCellule -eq "B" ) {
        Write-Host "Il y a la valeur 'B' à la ligne " $i
        #Alors on change l'intitulé
        $WorkSheet.Cells.Item($i, 6).Value2 = "Etudiants IFSI 1€"
    } 
}
#Suppression colonne G - la 7ième - qui contient la lettre identifiant les boursiers (B)
$WorkSheet.Columns.Item(7).EntireColumn.Delete()


#Sauvegarde fichier Excel
$Workbook.SaveAs($FichierExcel)
$Excel.Quit()
Remove-Variable -Name excel
[gc]::collect()
[gc]::WaitForPendingFinalizers()