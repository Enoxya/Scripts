################################################
# SCript automatisation opération AD
# Jérémie GADENNE - Déc. 2016
# Ajout des Managers
################################################


# Nécessite un tableau séparé par des VIRGULES
$temp = Get-Content "C:\managers.txt"
#$temp = "OUAZAN ABITBOL"
$array = @()


$temp | Foreach {
    $elements=$_.split(" ")
    $val1 = NameToSam($elements[0])
    $val2 = NameToSam($elements[1])
    $array+= ,@($val1,$val2)
}

$array

# Affecte les valeurs 
foreach($value in $array) {
    $filter = $value[0]
    Get-ADUser -properties  DisplayName, Manager -Filter {SamAccountName -eq $filter} # | Set-ADUser -Manager $value[1] | Out-Null
} 


# Affiche les informations APRES changement
foreach($value in $array) {
    $filter = $value[0]
    Get-ADUser -properties  DisplayName, Manager -Filter {SamAccountName -eq $filter} | select DisplayName, @{n="Manager";e={$_.Manager.Split(",")[0].Replace("CN=","")}} # | ft -HideTableHeaders -AutoSize
} 


# Ajustements manuels
    # Get-ADUser -properties  DisplayName, Manager -Filter {SamAccountName -eq "montell"} | Set-ADUser -Manager mazuyn
    # Get-ADUser -properties  DisplayName, Manager -Filter {SamAccountName -eq "abitboa"} | Set-ADUser -Manager giallar


    #Get-ADUSer -properties  DisplayName, Manager -Filter "*" | where { $_.Manager -EQ "CN=BUENADICHA  Gregory,OU=PGlaravoire,OU=PEUGEOT,OU=GROUPE BERNARD,DC=groupe-bernard,DC=lan"} | Set-ADUser -Manager $null



      Get-ADUser -properties displayname, Manager, Department, Title -Filter {company -eq 'BERNARD SERVICES'} | select DisplayName, @{n="Manager";e={$_.Manager.Split(",")[0].Replace("CN=","")}}, department, Title | export-csv C:\GroupList.txt -NoTypeInformation