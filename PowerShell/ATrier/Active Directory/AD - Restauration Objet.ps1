################################################
# SCript automatisation opération AD
# Jérémie GADENNE - Nov. 2014 
# Restauration d'un objet AD
################################################

# Chargement du module AD
 Import-module activedirectory 

# Construction du premier filtre
$filtre = {(objectClass -eq 'user')  -and (samAccountName -like "carcon*") -and (isdeleted -eq $true) }
Get-ADObject -filter $filtre -includeDeletedObjects -property * | sort WhenChanged | FT samAccountName,displayName,lastknownParent, ObjectClass, whenChanged, ObjectGUID 

# Construction du deuxième filtre
Get-ADObject -filter $filtre -includeDeletedObjects -property * | FL displayName, ObjectGUID 

#Get-ADObject -filter {samAccountName -like "gadennj"} -Property * 

# Restauration en fonction du ObjectGUID choisi
Restore-ADObject –identity fb870814-03e2-4b3a-9a24-2f6c709fc975


# AUTRES COMMANDES ASSOCIEES
# --------------------------

# Activation de la corbeille AD (une seule fois)
# Enable-ADOptionalFeature "Recycle Bin Feature" -server ((Get-ADForest -Current LocalComputer).DomainNamingMaster) -Scope ForestOrConfigurationSet -Target (Get-ADForest -Current LocalComputer)

# Vidage de la corbeille AD
# Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*"' -IncludeDeletedObjects | Remove-ADObject -Confirm:$false


 
# Find user from SID
#$strSID="S-1-5-80-1382380983-3165789108-999722155-2903346258-3018554436" -replace '-|{|}',''
#$uSid = [ADSI]"LDAP://<SID=$strSID>"
#echo $uSid

#[datetime]$StartTime = "07/04/2015"
#[datetime]$EndTime = "07/04/2015"
#Get-ADObject -Filter {(isdeleted -eq $true) -and (name -ne "Deleted Objects")} -includeDeletedObjects -property whenChanged | Where-Object {$_.whenChanged -ge $StartTime -and $_.whenChanged -le $EndTime}




