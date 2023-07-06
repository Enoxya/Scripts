Clear-Variable dossier_RechercheFichiersXML
Clear-Variable dossier_CopieFichiers
Clear-Variable extensionFichier
Clear-Variable texte_ARechercher
Clear-Variable listeFichiersXML
Clear-Variable fichierXML
Clear-Variable fichierXML_Contenu
Clear-Variable fichierXML_ContenantUF
Clear-Variable dossier_CopieFichiers_UF


$dossier_RechercheFichiersXML = "\\clover-hm\FTP\Production\Pharma\HM-CHB\Prescription" #"C:\Users\user\Desktop\Dossier\HM-CHB\Prescription"
$dossier_CopieFichiers = "\\clover-hm\FTP\Production\Pharma\REPRIS" #"C:\Users\user\Desktop\Dossier\REPRIS"
$extensionFichier = "*.xml"
$texte_ARechercher = '"HM_UF">'


$listeFichiersXML = Get-ChildItem $dossier_RechercheFichiersXML -Filter $extensionFichier | ForEach-Object {$_.FullName} 
Foreach ($fichierXML in $listeFichiersXML) {
    $fichierXML_Contenu = Select-String -Path $fichierXML -Pattern $texte_ARechercher -CaseSensitive -SimpleMatch -List | ForEach-Object {$_.Line}
    if ($fichierXML_Contenu) {

        $fichierXML_ContenantUF = $fichierXML
        $fichierOK = $fichierXML_ContenantUF -Replace '\.xml','.ok'
        Write-Output `n`n`n
        #write-host "Nom du fichier en cours de traitement :" $fichierXML
        #write-host "Contenu du fichier en cours de traitement :" $fichierXML_Contenu
            
        $chaine_UF = $fichierXML_Contenu.Substring($fichierXML_Contenu.IndexOf($texte_ARechercher), 12).Substring($fichierXML_Contenu.Substring($fichierXML_Contenu.IndexOf('HM_UF'), 12).Length-4)
        write-host "chaine UF :" $chaine_UF

        $dossier_CopieFichiers_UF = $dossier_CopieFichiers+"\"+$chaine_UF

        If(test-path $dossier_CopieFichiers_UF) {
            write-host "Le dossier "$chaine_UF "existe déjà, on copie juste les deux fichiers dedans"
            #Copie du fichier XML
            Move-Item $fichierXML -Destination $dossier_CopieFichiers_UF
            write-host "Fichier copié :" $fichierXML_ContenantUF "dans" $dossier_CopieFichiers_UF
            
            #Copie du fichier ok qui a le même nom 
            Move-Item $fichierOK -Destination $dossier_CopieFichiers_UF
            write-host "Fichier copié :" $fichierOK "dans" $dossier_CopieFichiers_UF
        }
        else {    
            write-host "Le dossier "$chaine_UF " nexiste pas donc on le crée"
            New-Item -ItemType Directory -Path $dossier_CopieFichiers_UF

            #Et on copie les deux fichiers dedans"
            #Copie du fichier XML
            Move-Item $fichierXML -Destination $dossier_CopieFichiers_UF
            write-host "Fichier copié :" $fichierXML_ContenantUF "dans" $dossier_CopieFichiers_UF
            
            #Copie du fichier ok qui a le même nom 
            Move-Item $fichierOK -Destination $dossier_CopieFichiers_UF
            write-host "Fichier copié :" $fichierOK "dans" $dossier_CopieFichiers_UF
        }
    }
}