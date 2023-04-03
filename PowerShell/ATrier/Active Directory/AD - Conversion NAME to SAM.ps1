################################################
# SCript automatisation opération AD
# Jérémie GADENNE - Déc. 2016
# Changement NOM > SamAccountName
################################################


$fichier = Get-Content "C:\Names.txt"

$array = @()
Clear-Host


FUNCTION NameToSam { 
param ($name)
$filter = $name + "*"
$i = 1
$users = Get-ADUser -Filter {name -like $filter} -Properties SamAccountName, DisplayName 
if ($users.count -eq 0) { Write-Host "Impossible de trouver un compte correspondant au nom $name - Indiquer un compte manuellement :"
                          return Read-Host
                        }
if ($users.Count -gt 1) { Write-Host "Ce compte possède plusieurs homonymes, il faut faire un choix : " 
                            foreach ($user in $users) { Write-host "$i. $($user.SamAccountName) -> $($user.DisplayName) " -ForegroundColor Green
                            $i=$i+1 }
                        $choix = (Read-Host) - 1 
                        $resultat = $users[$choix].SamAccountName
                        }
else { $resultat = $users.SamAccountName }
return $resultat
}


$fichier | Foreach {

    $val = NameToSam($_)
    $array+= @($val)

}

Set-Content C:\NamesSAM.txt -Value $array