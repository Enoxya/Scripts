cls

 
#Attention il faut ajouter une heure de décalage en plus sur l'horaire affichée pour avoir l'heure exacte

[datetime]$date = '01/01/1601'

$requete = '(&(objectCategory=person)(objectClass=user))'
$de = new-object system.directoryservices.directoryentry
$objRecherche = new-object system.directoryservices.directorysearcher -argumentlist $de
$objRecherche.Filter=$requete
$comptes = $objRecherche.FindAll()

$comptes  | sort @{Expression={$_.properties.lastlogontimestamp}; Ascending=$false} | Select-object @{e={$_.properties.cn};n='Nom commun'},
                @{e={$_.properties.whencreated};n='Date de création'},
                @{e={$date.AddTicks($($_.properties.lastlogontimestamp))};
                   n='Last'} | Format-Table # > "c:\ADUsers.csv"
          
