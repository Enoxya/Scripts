#Variables
$repertoireSource = "\\srv-nor-sauv\IIS\"
$annee = Get-Date -Format yyyy
$moisMoinsUn = (Get-Date).AddMonths(-1).ToString('MM')
$dossierDestination_Annee = "\\srv-nor-fich\informatique\Logs\SRV-NOR-SP\IIS\" + $annee

#Si le dossier correspondant à l'année en cours n'existe pas
if(-Not(Test-Path -Path $dossierDestination_Annee)) {
    New-Item -ItemType directory -Path $dossierDestination_Annee
    #Si le dossier correspondant au mois précédent n'existe pas
    $dossierDestination_Annee_MoisMoinsUn = $dossierDestination_Annee + "\" + $moisMoinsUn
    if(-Not(Test-Path -Path $dossierDestination_Annee_MoisMoinsUn)) {
        New-Item -ItemType directory -Path $dossierDestination_Annee_MoisMoinsUn
    }
}
Else { 
    #Sinon = le dossier correspondant à l'année en cours existe, on vérifie si le dossier correspondant au mois précédent n'existe pas
    $dossierDestination_Annee_MoisMoinsUn = $dossierDestination_Annee + "\" + $moisMoinsUn
    if(-Not(Test-Path -Path $dossierDestination_Annee_MoisMoinsUn)) {
        New-Item -ItemType directory -Path $dossierDestination_Annee_MoisMoinsUn
    }
}
$dossierDestination_Annee_MoisMoinsUn_Chemin = $dossierDestination_Annee_MoisMoinsUn + "\"

#Récupération des noms des sous-dossiers du répertoire source et de leur chemin complet
$listeRepertoires = Get-ChildItem -Path $repertoireSource -Directory
$listeRepertoires_Chemin = Get-ChildItem -Path $repertoireSource -Directory | % { $_.FullName }

#Boucle
ForEach ($repertoire_Chemin in $listeRepertoires_Chemin) {
    #On récupère tous les fichiers du chemin du repertoire en cours
    $fichiersRepertoire_Chemin = $repertoire_Chemin + "\*"
    
    #On récupère le nom du repertoire en cours (pas son chemin)
    $nomRepertoire = $repertoire_Chemin | split-path -leaf
    
    #On définit le nom du fichier ZIP
    $nomFichierZIP = $nomRepertoire + ".zip"
    
    #Compression en ZIP
    Compress-Archive -Path $fichiersRepertoire_Chemin -CompressionLevel Optimal -DestinationPath ($dossierDestination_Annee_MoisMoinsUn_Chemin + $nomFichierZIP)
    #Suppression du contenu du dossier qui contenait les fichiers de logs
    $repertoire_CheminComplet = $repertoire_Chemin + "\"
    Remove-Item $repertoire_CheminComplet*.*
    }


