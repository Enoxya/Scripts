#Variables
$tableauResultats= @()
$cheminExport = "C:\Users\saunies\Desktop\ResultatX.csv"


#$listeOrdinateurs = Get-ADComputer -Filter 'Name -like "*"' -SearchBase 'OU=Branches,OU=Ordinateurs,OU=Bernard,DC=groupe-bernard,DC=lan' -Properties * | Select-Object -ExpandProperty DistinguishedName
$listeOrdinateurs = Get-ADComputer -Filter 'Name -like "*"' -SearchBase 'OU=Branches,OU=Ordinateurs,OU=Bernard,DC=groupe-bernard,DC=lan' -Properties * | Select-Object -ExpandProperty CanonicalName

ForEach ($ordinateur in $listeOrdinateurs)
    {
    
    #$positionVirgule = $ordinateur.IndexOf(",")
    #$tableauResultats += $ordinateur | Select-Object @{
    #    "Name"="OU"
    #    "Expression"={ $ordinateur.Substring($positionVirgule+1) }},@{
    #    "Name"="NOM ORDINATEUR"
    #    "Expression"={ $ordinateur.Substring(3, 6) }}

    $tableauResultats += $ordinateur | Select-Object @{
        "Name"="OU"
        "Expression"={ Split-Path $ordinateur }},@{
        "Name"="NOM ORDINATEUR"
        "Expression"={ ($ordinateur -Split '/')[-1].Substring(0,6) }}
    }

$tableauResultats | Export-Csv -Path $cheminExport -NoTypeInformation

