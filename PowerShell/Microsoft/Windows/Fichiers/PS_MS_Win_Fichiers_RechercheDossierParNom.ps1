$repertoireDepart = "C:\Temp"
$nomATrouver = "Sauv"

$MyVariable = Get-ChildItem $repertoireDepart -Recurse | Where-Object { $_.PSIsContainer -and $_.Name.StartsWith($nomATrouver)}
echo  "Chemin + nom du dossier :"
echo $MyVariable.FullName "`n"

echo "Nom du dossier uniquement :"
echo $MyVariable.Name