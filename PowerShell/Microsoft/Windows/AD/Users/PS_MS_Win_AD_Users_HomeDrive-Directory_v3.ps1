

Remove-Variable * -ErrorAction SilentlyContinue
$HomeDirectory_Theorique ="\\chb.ts1.local\Fichiers\Utilisateurs\"
$HomeDrive_Theorique = "U:"
$OU = "OU=Agents,OU=Informaticiens,OU=Utilisateurs,OU=CHBOURG,DC=chb,DC=ts1,DC=local"
$Domaine = "chb"
$Export_Dossier = "C:\Temp\"
$Export_Fichier = "ExportComptes_"+(Get-Date -Format "yyyydd-HHmmss")+".csv"

function Verifications {
    Clear-Host
    #Verification $OU existe
    if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OU'") {
        Write-Host "L'OU '$OU' existe bien."
    } else {
        Write-Host "L'OU '$OU' n'existe pas, donc à corriger !"
        SousMenu-OU_Afficher
    }

}

function MenuPrincipal_Afficher {
    Clear-Host
    $MenuPrincipal_Continue = $true
    while ($MenuPrincipal_Continue) {
        Write-host "---------------------- MENU PRINCIPAL -----------------------" -ForegroundColor Yellow
        Write-host "1. OU (afficher / modifier)" -ForegroundColor Yellow
        Write-host "2. Exporter les comptes de l'OU" -ForegroundColor Yellow
        Write-host "3. Corriger les comptes de l'OU" -ForegroundColor Yellow
        Write-host "X. Sortie du programme" -ForegroundColor Yellow
        Write-host "------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host "Faire un choix (1 à 4 ou X) :" -ForegroundColor Yellow
        $MenuPrincipal_Choix = Read-host
        switch ($MenuPrincipal_Choix) {
            1 {SousMenu-OU_Afficher}
            2 {ComptesOU_Exporter}
            3 {Comptes_Corriger}
            ‘X’ {$MenuPrincipal_Continue = $false}
            default {Write-Host "Choix invalide"-ForegroundColor Red}
        }
    }
}

##### OPTION 1 - OU - Afficher / modifier #####
function SousMenu-OU_Afficher {
    
    $SousMenuOU_Continue = $true
    while ($SousMenuOU_Continue) {
        Write-Host "`n"
        Write-host "---------------------- SOUS-MENU OU -----------------------" -ForegroundColor Green
        Write-host "1. Afficher OU" -ForegroundColor Green
        Write-host "2. Modifier OU" -ForegroundColor Green
        Write-host "X. Sortie du sous-menu 'OU' et retour au menu principal (avec vérifications avant)" -ForegroundColor Green
        Write-host "-----------------------------------------------------------" -ForegroundColor Green
        Write-host "Faire un choix (1 à 2 ou X) :" -ForegroundColor Green
        $SousMenuOU_Choix = Read-host
        switch ($SousMenuOU_Choix) {
            1 {OU_Afficher}
            2 {OU_Modifier}
            ‘X’ {
                $SousMenuOU_Continue = $false
                Verifications
            }
            default {Write-Host "Choix invalide" -ForegroundColor Red}
        }
    }
}

function OU_Afficher {
    Write-Host "`n"
    Write-Host "OU =" $OU -ForegroundColor Red
    Write-Host "`n"
    Write-Host "Retour au sous-menu 'OU' dans 5 secondes..." -ForegroundColor Green
    Start-Sleep -Seconds 5
    SousMenu-OU_Afficher
}

function OU_Modifier {
    Write-Host "`n"
    $OU = Read-host "Entrer la nouvelle OU (sous la forme 'OU=YYY,OU=XXX,OU=CHBOURG,DC=chb,DC=ts1,DC=local')"
    #Verification que OU rentrée est correcte
    Write-Host "`n"
    Write-Host "La nouvelle 'OU' est :" $OU -ForegroundColor Red
    Write-Host "`n"
    Write-Host "Retour au sous-menu 'OU' dans 5 secondes..." -ForegroundColor Green
    Start-Sleep -Seconds 5
    SousMenu-OU_Afficher
}


##### Comptes AD inactifs - Inclure ou exclure #####
function ComptesADInactifs_InclureExclure {
    $ComptesADInactifsInclureQuestion_Continue = $true
    
    while ($ComptesADInactifsInclureQuestion_Continue) {
        Write-Host "`n"
        $ComptesADInactifsInclureQuestion_Reponse = Read-Host "Voulez-vous inclure les comptes AD inactifs (Oui/Non) ?"
        switch ($ComptesADInactifsInclureQuestion_Reponse) {
            { $ComptesADInactifsInclureQuestion_Reponse -like 'oui' } {
                $script:ComptesADInactifsInclure_Etat = $true
                $ComptesADInactifsInclureQuestion_Continue = $false
            }
            { $ComptesADInactifsInclureQuestion_Reponse -like 'non' } { 
                $ComptesADInactifsInclure = 0
                $script:ComptesADInactifsInclure_Etat = $false
                $ComptesADInactifsInclureQuestion_Continue = $false
            }
            default { Write-Host "Choix invalide" -ForegroundColor Red }
        }
    }
}

##### OPTION 2 - Comptes - Exporter #####
function Comptes_RecupererListe {
    ComptesADInactifs_InclureExclure
    if ($script:ComptesADInactifsInclure_Etat) {
        $script:ComptesADInactifs_Resultat = Get-AdUser -Filter * -Properties * -SearchBase $OU | Select Enabled, SamAccountName, HomeDrive, HomeDirectory, CanonicalName |
        foreach {
            new-object psobject -Property @{
                CompteActif = $_.Enabled
                Utilisateur = $_.sAMAccountName
                DossierDeBase_Lettre = $_.HomeDrive
                DossierDeBase_Chemin = $_.HomeDirectory
                OU = Split-Path -Path $_.CanonicalName
            }
        } | Select CompteActif, Utilisateur, DossierDeBase_Lettre, DossierDeBase_Chemin, OU
        
    }
    else {
        $script:ComptesADInactifs_Resultat = Get-AdUser -Filter * -Properties * -SearchBase $OU | Where { $_.Enabled -ne $script:ComptesADInactifsInclure_Etat } | Select Enabled, SamAccountName, HomeDrive, HomeDirectory, CanonicalName |
        foreach {
            new-object psobject -Property @{
                CompteActif = $_.Enabled
                Utilisateur = $_.sAMAccountName
                DossierDeBase_Lettre = $_.HomeDrive
                DossierDeBase_Chemin = $_.HomeDirectory
                OU = Split-Path -Path $_.CanonicalName
            }
        } | Select CompteActif, Utilisateur, DossierDeBase_Lettre, DossierDeBase_Chemin, OU
    }
}

function HomeDirectory_Verification {
    Param(
        [Parameter(Mandatory=$true,Position=0)] [string]$DossierDeBase_Chemin,
        [Parameter(Mandatory=$true,Position=1)] [string]$Utilisateur
    )
    #Verification que le HomeDirectory est bien égal à celui défini dans les variables en haut du script
    if (($(Split-path -Path $DossierDeBase_Chemin)+"\") -ne $HomeDirectory_Theorique) {
        #DossierDeBase_Chemin différent de $HomeDirectory_Theorique
        write-host "Le chemin du dossier personnel pour le compte [$Utilisateur] n'est pas bon : [$(Split-path -Path $DossierDeBase_Chemin)\] au lieu de [$HomeDirectory_Theorique]"
        #On le modifie :
        Clear-Variable DossierDeBase_Chemin
        HomeDirectory_Modification $Utilisateur
    }
    else {
        #$(Split-path -Path $compte.DossierDeBase_Chemin)+"\") égale à $HomeDirectory_Theorique
        Write-Host "La racine du [HomeDirectory] de la fiche AD de l'utilisateur [$Utilisateur] vaut [$(Split-path -Path $DossierDeBase_Chemin)\] ce qui correspond bien au [HomeDirectory] théorique [$HomeDirectory_Theorique] (donc on ne le modifie pas)"
        #Tout bon, on ne change rien et on passe à la vérification suivante (le nom du dossier de l'utilisateur par rapport à son nom d'utilisateur) :
        #On recupère le nom du dossier (à la fin du chemin)
        #On le compare avec le nom d'utilisateur :
        if ($Utilisateur -ne (Split-path $DossierDeBase_Chemin -Leaf)) {
            #Si différent alors on informe et on demande si on souhaite tout de même la modifcation
            $HomeDirectoryVerificationNomDifferentQuestion_Continue = $true 
            while ($HomeDirectoryVerificationNomDifferentQuestion_Continue) {
                Write-Host "Le dossier dans le chemin de l'utilisateur [$(Split-path $DossierDeBase_Chemin -Leaf)] est différent du nom d'utilisateur [$Utilisateur]"
                $HomeDirectoryVerificationNomDifferentQuestion_Reponse = Read-Host "Voulez-vous tout de même modifier le nom du dossier de l'utilisateur (Oui/Non) ?"
                switch ($HomeDirectoryVerificationNomDifferentQuestion_Reponse) {
                    { $HomeDirectoryVerificationNomDifferentQuestion_Reponse -like 'oui' } {
                        #On modifie
                        Write-Host "On modifie !"
                        HomeDirectory_Modification $Utilisateur
                        $HomeDirectoryVerificationNomDifferentQuestion_Continue = $false
                    }
                    { $HomeDirectoryVerificationNomDifferentQuestion_Reponse -like 'non' } { 
                        #On laisse tel quel
                        Write-Host "On laisse tel quel !"
                        $HomeDirectoryVerificationNomDifferentQuestion_Continue = $false
                    }
                    default { Write-Host "Choix invalide" -ForegroundColor Red }
                }
            }
        }
        else {
            Write-Host "Dans le [HomeDirectory], le nom du dossier de l'utilisateur [$Utilisateur] vaut [$(Split-path $DossierDeBase_Chemin -Leaf)] et est donc identique au nom de l'utilisateur, donc on ne le modifie pas"
            #Nom du dossier identique au nom de l'utilisateur, on ne fait rien !
        }
    }
}

function HomeDirectory_Modification {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0)] [string]$Utilisateur_Modification
    )
    #On le modifie :
    $script:HomeDirectory_Corrige = $HomeDirectory_Theorique+$Utilisateur_Modification
    Set-ADUser -Identity $Utilisateur_Modification -HomeDirectory $script:HomeDirectory_Corrige
    #Write-Host "On modifie le HomeDirectory avec ce nouveau chemin :" $HomeDirectory_Theorique$Utilisateur_Modification
    $script:HomeDirectory_Modifie = 1
    #On revérifie que le chemin est bon et comme ça va être OK, on va comparer le nom du dossier et le nom d'utilisateur
    HomeDirectory_Verification $HomeDirectory_Corrige $Utilisateur_Modification
}

function HomeDrive_Verification {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=0)] [string]$DossierDeBase_Lettre,
        [Parameter(Mandatory=$True,Position=1)] [string]$Utilisateur
    )
    #Verification que le HomeDrive est bien égal à celui défini dans les variables en haut du script
    if ($DossierDeBase_Lettre -ne $HomeDrive_Theorique) {
        #DossierDeBase_Lettre différent de $HomeDrive_Theorique
        write-host "La lettre pour le dossier personnel du compte [$Utilisateur] n'est pas bonne : [$DossierDeBase_Lettre] au lieu de : [$HomeDrive_Theorique]"
        #On le modifie :
        HomeDrive_Modification $Utilisateur
        }
    else {
        #$DossierDeBase_Lettre égale $HomeDrive_Chemin
        #Tout bon, on ne change rien
        Write-Host "La lettre pour le dossier personnel du compte [$Utilisateur] est égale à [$DossierDeBase_Lettre] et est donc correcte (donc on ne fait rien et on passe à la vérif du HomeDirectory)"
    }
}

function HomeDrive_Modification {
    [CmdletBinding()]    
    Param(
        [Parameter(Mandatory=$True,Position=0)] [string]$HomeDriveModification_Utilisateur
    )
    #On le modifie :
    Write-Host "On modifie le HomeDrive de l'utilisateur [$HomeDriveModification_Utilisateur] avec cette nouvelle lettre : [$HomeDrive_Theorique]"
    Set-ADUser -Identity $HomeDriveModification_Utilisateur -HomeDrive $HomeDrive_Theorique
}

function Droits_Modification {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,Position=0)] [string]$Utilisateur,
        [Parameter(Mandatory=$True,Position=1)] [string]$HomeDirectory
    )

    $CompteAD = $Domaine+"\"+$Utilisateur

    $FileSystemAccessRights=[System.Security.AccessControl.FileSystemRights]"FullControl"
    $InheritanceFlags=[System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit"
    $PropagationFlags=[System.Security.AccessControl.PropagationFlags]::None
    $AccessControl=[System.Security.AccessControl.AccessControlType]::Allow
    
    $NewAccessrule = New-Object System.Security.AccessControl.FileSystemAccessRule ` ($CompteAD, $FileSystemAccessRights, $InheritanceFlags, $PropagationFlags, $AccessControl)
    
    #Test si dossier de l'utilisateur existe, si oui on change les droits, sinon on le créé d'abord
    Write-Host "Définition des droits"
    Write-Host "On vérifie si le dossier [$HomeDirectory] existe"
    if (Test-Path -Path $HomeDirectory) {
        Write-Host "Le dossier existe et on définit les droits dessus"
        $CurrentACL=Get-ACL -path $HomeDirectory
        $CurrentACL.SetAccessRule($NewAccessrule)
        Set-ACL -path $HomeDirectory -AclObject $CurrentACL
    } else {
        Write-Host "Le dossier n'existe pas donc on le créé et on définit les droits dessus"
        New-Item -Path $HomeDirectory -ItemType Directory
        $CurrentACL=Get-ACL -path $HomeDirectory
        $CurrentACL.SetAccessRule($NewAccessrule)
        Set-ACL -path $HomeDirectory -AclObject $CurrentACL
    }
}

function Comptes_Corriger {
    Comptes_RecupererListe
    $CompteurComptes=1
    $CompteurComptes_Total = $script:ComptesADInactifs_Resultat.Count
    Write-Host "`n---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------`n"
    foreach ($compte in $script:ComptesADInactifs_Resultat) {        
        Write-Progress -Activity "Traitement des comptes" -status "Traitement du compte n°$CompteurComptes / $CompteurComptes_Total" -PercentComplete ($CompteurComptes / $CompteurComptes_Total * 100)
        Write-Host "Login :" $compte.Utilisateur
        Write-Host "Lettre :" $compte.DossierDeBase_Lettre
        Write-Host "Chemin :" $compte.DossierDeBase_Chemin
        #HomeDrive_Verification -DossierDeBase_Lettre $compte.DossierDeBase_Lettre -Utilisateur $compte.Utilisateur
        #Avant de vérifer que la lettre de lecteur est bonne, on vérifie qu'elle n'est pas nulle (sinon on ne peut pas appeler la fonction)
        Write-Host "`n### Verification HomeDrive ###"
        if ($compte.DossierDeBase_Lettre) {
            Write-Host "Lettre définie, donc on la vérifie"
            HomeDrive_Verification $compte.DossierDeBase_Lettre $compte.Utilisateur
        } else {
            Write-Host "Lettre NON DÉFINIE, donc on la définit directement"
            HomeDrive_Modification $compte.Utilisateur
            $compte.DossierDeBase_Lettre = $HomeDrive_Theorique # = "U:"
            Write-Host "Lettre :" $compte.DossierDeBase_Lettre
        }

        #Et de même #Avant de vérifer que le chemin du dossier personnel est bon, on vérifie qu'il n'est pas nul (sinon on ne peut pas appeler la fonction)
        Write-Host "`n### Verification HomeDirectory ###"
        if ($compte.DossierDeBase_Chemin) {
            Write-Host "Chemin NON VIDE, donc on le vérifie"
            HomeDirectory_Verification $compte.DossierDeBase_Chemin $compte.Utilisateur
            
            #Si la variable $script:HomeDirectory_Modifie = 1 alors c'est que le chemin a été définit ou modifié et donc il faut positionner les droits
            Write-Host "`n### Verification/Modification Droits ###"
            if ($script:HomeDirectory_Modifie -eq 1) {
                Droits_Modification $compte.Utilisateur $script:HomeDirectory_Corrige
                $script:HomeDirectory_Modifie = 0
            } else {
                Write-Host "Le [HomeDirectory] de l'utilisateur ["$compte.Utilisateur"] n'a pas été modifié, donc on ne modifie pas les droits !"
            }
            Write-Host "`n---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------`n"
            $CompteurComptes+=1
        } else {
            Write-Host "Chemin VIDE, donc on le définit directement"
            #$compte.DossierDeBase_Chemin = $HomeDirectory_Theorique+$compte.Utilisateur #="\\chb.ts1.local\Fichiers\Utilisateurs\ + compte utilisateur"
            #$script:HomeDirectory_Modifie = 1
            HomeDirectory_Modification $compte.Utilisateur
            Write-Host "Chemin :" $script:HomeDirectory_Corrige
            #CHemin modifié (définit) donc on positionne les droits
            Droits_Modification $compte.Utilisateur $script:HomeDirectory_Corrige
            $script:HomeDirectory_Modifie = 0
            Write-Host "`n---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------`n"
            $CompteurComptes+=1
        }
    }
    exit
}

Verifications
MenuPrincipal_Afficher