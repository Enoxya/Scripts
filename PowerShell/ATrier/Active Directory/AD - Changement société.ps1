################################################
# SCript automatisation opération AD
# Jérémie GADENNE - Déc. 2016
################################################

# 1. Récupérer la liste des noms
$Users = Get-Content C:\Muter.txt

# 2. Faire une sauvegarde
Get-ADUser -Filter '*' -Properties DisplayName,Company | where { $Users -contains $_.SurName } | select DisplayName, Company | Out-File C:\Sauvegarde.txt

# 3. Modifier 
$result = Get-ADUser -Filter '*' -Properties DisplayName,Company | where { $Users -contains $_.SurName } | Set-ADUser -Company "BERNARD SERVICES"

# 4. Vérifier avec un filtrer selon la fonction
#$filtre = {(Name -like 'Direct*') -or (Title -like 'Ass*') }
#$filtre = {name -like 'formation*' }
$filtre = {Company -like 'BERN*'}

# Pour faire un export vers un CSV uniquement
Get-ADUser -properties * -filter $filtre  | Select DisplayName, Company, City, Department, Title, Manager, @{n="Mail";e={$_.EmailAddress.ToLower()}} | ft  # |  Export-Csv $LogFile -NoTypeInformation -Encoding Unicode

