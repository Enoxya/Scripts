################################################
# SCript automatisation opération AD
# Jérémie GADENNE - Déc. 2016
# Suppression d'une liste d'objets AD
################################################

$liste = get-content C:\ADCompteASupprimer.txt

foreach ($user in $liste) {
$user = $user.Trim()
Get-ADuser -Filter {samAccountName -eq $user} -Properties DisplayName | Remove-ADObject -Confirm:$false -Recursive
}

Get-ADuser -Filter {samAccountName -eq "rejasss"} -Properties DisplayName  | Remove-ADObject -Confirm:$false -Recursive
