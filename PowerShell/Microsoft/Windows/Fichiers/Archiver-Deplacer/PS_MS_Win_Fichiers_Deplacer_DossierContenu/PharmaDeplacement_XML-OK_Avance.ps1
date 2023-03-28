$liste_Numeros = "ListeNumeros.txt"
$dossier_ListeNumeros = "C:\Users\ssaunier\Desktop\A"
$dossier_RechercheFichiersXML = "C:\Users\ssaunier\Desktop\A\dossier_RechercheFichiersXML" #"C:\Users\user\Desktop\Dossier\HM-CHB\Prescription"
$dossier_DeplacementFichiers_Racine = "C:\Users\ssaunier\Desktop\A\dossier_DeplacementFichiers_Racine" #"C:\Users\user\Desktop\Dossier\REPRIS"
$extensionFichier = "*.xml"
$numeros_ARechercher = Get-Content ($dossier_ListeNumeros+"\"+$liste_Numeros)
$UF_ARechercher = '"HM_UF">'



$listeFichiersXML = Get-ChildItem $dossier_RechercheFichiersXML -Filter $extensionFichier | %{$_.FullName} 
Foreach ($fichierXML in $listeFichiersXML) {
    #Pour chaque fichier xml, on cherche s'il contient un numéro de la liste des numéros
    foreach ($numero in $numeros_ARechercher) {
        #Pour chaque numéro, on regarde si un fichier xml le contient
        if ($fichierXML_Contenu_Numero = Select-String -Path $fichierXML -Pattern $numero -CaseSensitive -SimpleMatch -List | %{$_.Line}) {
            #Le fichier xml $fichierXML contient le numéro $numero, donc on continue
            #On définit $fichierOK avec le même nom que le fichier XML en cours de traitement :
            $fichierOK = $fichierXML -Replace '\.xml','.ok'
            #On recherche l'UF dans le fichier $fichierXML :
            $fichierXML_Contenu_UF = Select-String -Path $fichierXML -Pattern $UF_ARechercher -CaseSensitive -SimpleMatch -List | %{$_.Line}
            if ($fichierXML_Contenu_UF) {
                #On affiche le numero pour vérification
                Write-host "Numéro : "$numero 
                #La balise $UF_ARechercher est trouvée dans le fichier, on va récupérer l'UF
                $chaine_UF = $fichierXML_Contenu_UF.Substring($fichierXML_Contenu_UF.IndexOf($UF_ARechercher), 12).Substring($fichierXML_Contenu_UF.Substring($fichierXML_Contenu_UF.IndexOf('HM_UF'), 12).Length-4)
                write-host "chaine UF :" $chaine_UF
                $dossier_DeplacementFichiers_UF = $dossier_DeplacementFichiers_Racine+"\"+$chaine_UF
                #On vérifie si un sous-dossier au nom de l'UF existe ou pas :
                if(test-path $dossier_DeplacementFichiers_UF) {
                    write-host "Le dossier "$chaine_UF "existe déjà, on déplace juste les deux fichiers dedans"
                    #Copie du fichier XML
                    Move-Item $fichierXML -Destination $dossier_DeplacementFichiers_UF
                    write-host "Fichier déplacé :" $fichierXML "dans" $dossier_DeplacementFichiers_UF
            
                    #Copie du fichier ok qui a le même nom 
                    Move-Item $fichierOK -Destination $dossier_DeplacementFichiers_UF
                    write-host "Fichier déplacé :" $fichierOK "dans" $dossier_DeplacementFichiers_UF "\n"
                    break
                }
                else {    
                    write-host "Le dossier "$chaine_UF " nexiste pas donc on le crée"
                    New-Item -ItemType Directory -Path $dossier_DeplacementFichiers_UF

                    #Et on copie les deux fichiers dedans"
                    #Copie du fichier XML
                    Move-Item $fichierXML -Destination $dossier_DeplacementFichiers_UF
                    write-host "Fichier déplacé :" $fichierXML "dans" $dossier_DeplacementFichiers_UF
            
                    #Copie du fichier ok qui a le même nom 
                    Move-Item $fichierOK -Destination $dossier_DeplacementFichiers_UF
                    write-host "Fichier déplacé :" $fichierOK "dans" $dossier_DeplacementFichiers_UF "\n"
                    break
                }
            }
            else {
                #Dans le fichier $fichierXML contenant le numéro $numéro, il n'y a pas de balise $UF_ARechercher :
                write-host "Le fichier" $fichierXML "qui contient le numéro" $numero "ne contient pas la balise" $UF_ARechercher "\n"
            }
        }
        else {
            #Le fichier $fichierXML ne contient pas le numéro $numéro, on passe au numéro suivant
            Write-Host "Le fichier" $fichierXML "ne contient pas le numéro" $numero ", on passe au numéro suivant \n"
        }
  
    }
}