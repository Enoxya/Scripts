################################################
# SCript automatisation opération AD
# Jérémie GADENNE - Déc. 2016
# Changement de fonctions
################################################

# Ajustements manuels
   # Get-ADUser -properties  DisplayName, Manager -Filter {SamAccountName -eq "JOUANNM"} | Set-ADUser -Title  "CONTROLEUR DE GESTION"

Clear-Host

# FORMAT d'une ligne = fourris/COMPTABLE TRESORERIE
$fichier = Get-Content C:\Fonctions.txt

$fichier | Foreach {
    $elements=$_.split("/")
    $array+= ,@($elements[0],$elements[1].ToUpper())
}


$array

# Affecte les valeurs 
foreach($value in $array) {
    $filter = $value[0]
    Get-ADUser -properties  DisplayName, Title -Filter {SamAccountName -eq $filter} | Set-ADUser -Title $value[1] | Out-Null
} 


# Affiche les informations APRES changement
foreach($value in $array) {
     $filter = $value[0]
    Get-ADUser -properties  DisplayName, Title -Filter {SamAccountName -eq $filter} | select DisplayName, Title
} 




