$Resultat = Import-Csv "C:\Users\mayn\Desktop\En cours\Exports\ActiveDirectory\sansmails.csv" -Header "DisplayName", "Firstname" -Delimiter ";" | `
ForEach {
    $nom = $_.DisplayName
    $prenom = $_.FirstName
    $ligne = Get-AdUser -Filter {(sn -Like $nom) -and (GivenName -Like $prenom)} -Properties mail | Select mail
    if ([string]::IsNullOrEmpty($ligne)) {
        echo "Pas d'adresse mail"
        }
    else {echo $ligne}
    }
$Resultat | Out-File "C:\Users\mayn\Desktop\En cours\Exports\ActiveDirectory\sansmails2.txt"

