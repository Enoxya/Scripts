$compteurUtilisateurHumainAvecAdresseMail = 0
$listeUtilisateurs = get-aduser -filter * -Properties * | where {$_.enabled -eq "True"} | Select Name, DistinguishedName, Mail -ExpandProperty DistinguishedName
Foreach ($utilisateur in $listeUtilisateurs) {
    if ($utilisateur.DistinguishedName -Match "OU=Messagerie,OU=Groupes,OU=Utilisateurs,OU=Bernard,DC=groupe-bernard,DC=lan") {
        #$utilisateur.Name 'est un compte génerique, on le skip
    }
    else {
        if ($utilisateur.mail -match "@autobernard.com") { #On ne compte que les comptes disposant d'une adresse mail
            $compteurUtilisateurHumainAvecAdresseMail++
        }
    }
}
write-host 'nbre total utilisateurs actifs et humains (non génériques) et avec une @ mail : ' $compteurUtilisateurHumainAvecAdresseMail
write-host 'nbre total utilisateurs actifs et humains (non génériques) : ' $listeUtilisateurs.count 
