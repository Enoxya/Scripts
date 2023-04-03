#On entre la date de filtre. Attention : le filtre se basse sur l'heure aussi si la date est la même journée que celle recherchée !
$dateFiltre = (Get-Date -Year 2019 -Month 12 -Day 11 -Hour 12 -Minute 00)

#le site pilote = groupe AD dans l'OU "PSO"
$sitePilote = "PSO_Test"

#fichier de logs, qui va contenir la liste des utilisateurs qui n'ont pas changé le mot de passe depuis la date définie
$utilisateurs_listeCeuxDevantChangerMDP = "C:\Users\saunies\Desktop\Liste_Utilisateurs_DevantChangerDeMDP.txt"

$utilisateurs_NAyantPasChangeMDPAvtDate = Get-ADGroupMember $sitePilote | Get-ADuser -Properties PasswordLastSet | where {$_.PasswordLastSet -lt ($dateFiltre)} | ft Name, PasswordLastSet
if (!$utilisateurs_NAyantPasChangeMDPAvtDate) {
    Write-Host "Tous les utilisateurs du groupe $sitePilote ont changé leur MDP après la date filtre ($dateFiltre)"
    }
    Else {
        #Il y a au moins un utilisateur dont la date du dernier de changement du MDP est "postérieure" à la date définie
        #On ecrit son nom et la date de son dernier hangement de MDP dans le fichier de logs
        $utilisateurs_NAyantPasChangeMDPAvtDate >> $utilisateurs_listeCeuxDevantChangerMDP
    }

Clear-Variable dateFiltre
Clear-Variable sitePilote
Clear-Variable utilisateurs_NAyantPasChangeMDPAvtDate
Clear-Variable utilisateurs_listeCeuxDevantChangerMDP
