$longueur = "13"
$obj =@()

$listeOrdinateurs = Get-ADCOmputer -Filter * | where {($_.name).Length -ge $longueur}
foreach ($ordinateur in $listeOrdinateurs) {
    $obj += new-object psobject -Property @{
        Nom = $ordinateur.Name
        Longueur = ($ordinateur.Name).Length
    }
}

$obj | Export-Csv -Path C:\Users\ssaunier\Desktop\Postes_13Car.csv -Encoding UTF8 -NoTypeInformation
