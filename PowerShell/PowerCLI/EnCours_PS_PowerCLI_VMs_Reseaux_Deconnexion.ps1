#Ameliorations possibles
#Laisser choix cluster
#Laisser choix vCenter
#Mettre les ESX retournés dans  un tableau avec index pour selectionner plus facilement qu'en mettant le FQDN
#Choisir plusieurs ESXs
#Indiquer le nom d'une VM a faire uniquement
#Précisions concernant les messages d'erreur / try/catch



### Variables
$Date = Get-Date -Format "yyyyMMdd"

$Logs_Dossier = "C:\Temp\"
$Logs_Fichier_Nom = "VMs_Deconnectees_"+$Date+".txt"
$Logs_Fichier_Chemin = $Logs_Dossier + $Logs_Fichier_Nom

$vCenter = ""

$VMs_PoweredOn_Liste = @()
$VMs_PoweredOff_Liste = @()
$VMs_Liste = @()
$VMs_PoweredOn_Nbre = 0
$VMs_PoweredOff_Nbre = 0

$Mail_Expediteur = "vCenter@ch-bourg.ght01.fr" #domaine ght01.fr pour eviter tout problème de redirection (adresse zimbra -> adresse ght01.fr)
$Mail_Destinataires = "sysaunier@ch-bourg01.fr" #,"Sylvain.SAUNIER@ch-bourg.ght01.fr""
$Mail_SMTPServer = "mercure.chb.ts1.local"
#$Mail_SMTPServer = "smtp.ght01.fr"
#$Mail_SMTPPort = "587"

### Fonctions
###### Fonctions générales
function Input_Entree() { #Fonction qui sert à avoir un affichage en couleurs lors d'input de texte (questions, etc.)
    param
    (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string]$Question,
        [string]$BackgroundColor = "Black",
        [string]$ForegroundColor = "Yellow"
    )
    Write-Host -ForegroundColor $ForegroundColor -NoNewline $Question;
    return Read-Host
}

function OuiNon ($OuiNon_Question, $OuiNon_Reponse_Non) { #Fonction qui demande oui ou non et qui boucle tant que réponse != oui et qui sort si réponse = non
    $OuiNon_Continue = $true
    while ($OuiNon_Continue) {
        Write-Host "`n"
        $OuiNon_Reponse = Input_Entree $OuiNon_Question
        switch ($OuiNon_Reponse) {
            { $OuiNon_Reponse -like 'oui' } {
                $OuiNon_Continue = $false
            }
            { $OuiNon_Reponse -like 'non' } { 
                $OuiNon_Continue = $false
                Write-host $OuiNon_Reponse_Non -ForegroundColor Red
                exit 5
            }
            default { Write-Host "Choix invalide" -ForegroundColor Red }
        }
    }
}

###### Fonctions du programme
function vCenter_Connexion {
    #Connexion au vCenter
    If ($vCenter -eq "") {$vCenter = Input_Entree "`nEntrez le FQDN du vCenter ou son IP :"} #Si on en veut pas mettre le nom du vCenter dans des variables
    Try {
        Connect-VIServer -server $vCenter -EA Stop | Out-Null
    } Catch {
        "`r`n`r`nImpossible de se connecter au vCenter $vCenter" >> $Logs_Fichier_Chemin
        "Fin du programme...`r`n`r`n" >> $Logs_Fichier_Chemin
        Exit
    }
}

function ESXs_Liste_Recuperation {
    Clear-Host
    Write-Host "Récupération de la liste des ESXs du vCenter $vCenter..."
    Try {
        $NombreVMs = @{N="Nombre de VMs"; E={($_ | Get-VM | Measure-Object).Count}}
        Get-VMHost | Where-Object { $_.PowerState -eq 'PoweredOn' } | Select-Object Name, PowerState, $NombreVMs | Tee-Object -Variable script:ESXs_Liste
        #On récupère la liste des ESX à l'état "en route" avec leur nombre de VMs et on met le résultat sur la console et dans la variable $script:ESXs_Liste
        #il n'y a pas de $ devant le nom de la variable avec la fonction Tee-Object
    } Catch {
        "`r`n`r`nImpossible de récupérer la liste des ESX, leur état et le nombre de VMs dessus" >> $Logs_Fichier_Chemin
        "Fin du programme...`r`n`r`n" >> $Logs_Fichier_Chemin
        Exit
    }
}

function Menu_ESX_Choix {
    $MenuESXChoix_Continue = $true
    while ($MenuESXChoix_Continue) {
        Write-Host "`n"
        Write-host "---------------------- MENU CHOIX ESX -----------------------" -ForegroundColor Yellow
        Write-host "1. Traiter TOUTES les VMs de TOUS les ESXs" -ForegroundColor Yellow
        Write-host "2. Selectionner un seul ESX" -ForegroundColor Yellow
        Write-host "X. Sortie du programme" -ForegroundColor Yellow
        Write-host "-----------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host "Faire un choix (1, 2 ou X) :" -ForegroundColor Yellow
        $MenuESXChoix_Choix = Read-host
        switch ($MenuESXChoix_Choix) {
            1 {
                $MenuESXChoix_Continue = $false
                $OuiNon_Question_MenuESXChoix = "Etes-vous sûr de vouloir déconnecter l'ensemble des machines virtuelles (Oui/Non) ?`n" #A personnaliser en fonction du programme
                $OuiNon_Reponse_MenuESXChoix_Non ="Vous n'etes pas assez sûr de vous, sortie du programme !`n" #Pas obligatoire, texte affiché si réponse non à la demande de confirmation
                OuiNon $OuiNon_Question_MenuESXChoix $OuiNon_Reponse_MenuESXChoix_Non
                VMs_DesactivationReseaux #On lance la fonction de désactivation des cartes réseaux car on est normalement sorti de la boucle de demande de confirmation
            }
            2 {
                $MenuESXChoix_Continue = $false
                ESX_Selection #on lance la fonction de selection de l'ESX qui elle lancera la désactivation des cartes réseaux des VMs présentes dessus
            }
            'X' {$MenuESXChoix_Continue = $false}
            default {
                Write-Host "Choix invalide `n" -ForegroundColor Red
                Start-Sleep -Seconds 2
                Menu_ESX_Choix
                }
        }
    }
}

function ESX_Selection {
    $ESXSelectionContinue_Continue = $true
    while ($ESXSelectionContinue_Continue) {
        Write-host "---------------------- SELECTION DE L'ESX -----------------------" -ForegroundColor Yellow
        $script:ESX_Selectionne = Input_Entree "`nEntrer le nom (FQDN) de l'ESX selectionné :`n" -ForegroundColor Yellow
        Write-host "-----------------------------------------------------------------" -ForegroundColor Yellow
        if ($ESX_Selectionne -in $script:ESXs_Liste.Name) {
            #Write-Host "$ESX_Selectionne est bien dans la liste des ESXs `n"
            $ESXSelectionContinue_Continue = $false
            $script:ESX_Nbre = 1
            $OuiNon_Question_ESXSelection = "Etes-vous sûr de vouloir déconnecter l'ensemble des machines virtuelles de l'ESX $ESX_Selectionne (Oui/Non) ?`n" #A personnaliser en fonction du programme
            $OuiNon_Reponse_ESXSelection_Non ="Vous n'etes pas assez sûr de vous, sortie du programme !`n" #Pas obligatoire, texte affiché si réponse non à la demande de confirmation
            OuiNon $OuiNon_Question_ESXSelection $OuiNon_Reponse_ESXSelection_Non
            VMs_DesactivationReseaux
        }
        else {
            Write-Host "le FQDN de l'ESX entré ($ESX_Selectionne) ne fait partie de la liste des ESXs du vCenter $vCenter `n" -ForegroundColor Red
        }
    }
}

function VMs_DesactivationReseaux {
    #On commence par voir si on a selectionné tous les ESX ou juste un
    if ($script:ESX_Nbre -eq 1) {
        #On a selectionné un seul ESX
        Write-Host "Récupération des VMs de l'ESX $script:ESX_Selectionne en cours..." 
        $script:VMs_Liste =  Get-VMHost $script:ESX_Selectionne | Get-VM | Select-Object Name, PowerState
        Write-Host "Récupération des VMs de l'ESX $script:ESX_Selectionne terminée !" 
    }
    else {
        #On a pas selectionné d'ESX = Tous
        Write-Host "Récupération des VMs de tous les ESXs en cours..."
        $script:VMs_Liste =  Get-VM | Select-Object Name, PowerState
        #Pour faire des tests on peut spécifier le nom d'une seul machine sous la forme : | Where-Object {$_.Name -eq "XXXXXXX"} #| Select Name, PowerState
        Write-Host "Récupération des VMs de tous les ESXs terminée !" 
    }
    <#La variable liste des VMs et les variables de celles en fonction et celles arretées ensuite sont définies au niveau du script et pas juste dans la fonction car
    On va les utiliser dans l'envoi du mail ensuite
    #>
    #Puis on désactive la ou les carte(s) réseau(x)
    Write-Host "Désactivation des cartes réseaux en cours..."
    ForEach ($VM in $script:VMs_Liste) {
        #Si la VM est en route alors on déconnecte les cartes réseaux et on les paramètres à "Connecter lors de la mise sous tension" décochée
        if ($VM.Powerstate -eq "PoweredOn") {
            $script:VMs_PoweredOn_Nbre ++
            $script:VMs_PoweredOn_Liste += @($VM.Name)
            #Get-VM $VM | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$false -StartConnected:$false -Confirm:$false #-Verbose
        }
        #Si la VM est arretée, on paramètre juste à "Connecter lors de la mise sous tension" décochée
        else {
            $script:VMs_PoweredOff_Nbre ++
            $script:VMs_PoweredOff_Liste += @($VM.Name)
            #Get-VM $VM | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$false -Confirm:$false #-Verbose
        }
    }
    Write-Host "Désactivation des cartes réseaux terminée !"
}

function Mail_Envoi {
    #Envoi du mail
    #A voir si utile car si on coupe la connexion du serveur de messagerie, il ne pourra pas envoyer de mail :-)
    #Ou alors mettre une condition pour faire la VM de messagerie en dernier, etc.
    
    ###Variables de la fonction
    #$Mail_Cc = ""
    $Mail_PieceJointe = $Logs_Fichier_Chemin
    $Mail_Sujet = "vCenter - Déconnexion des cartes réseaux des VMs"

    ###Contenu du mail : VMs en route puis éventuellement VMs arretées
    #VM(s) en route :
    if ($script:VMs_PoweredOn_Nbre -eq 0) {
        $Mail_Body = "<h2>Il n'y a pas de VM en route ! </h2>"
        "Il n'y a pas de VM en route !" >> $Logs_Fichier_Chemin
    }
    elseif ($script:VMs_PoweredOn_Nbre -eq 1) {
        $Mail_Body = "<h2>Unique VM en route dont la carte réseau a été déconnectée + reparamétrée : </h2>"
        "Unique VM en route dont la carte réseau a été déconnectée + reparamétrée :" >> $Logs_Fichier_Chemin
    }
    else {
        $Mail_Body = "<h2>Liste des VMs en route dont les cartes réseaux ont été déconnectées + reparamétrées : </h2>"
        "Liste des VMs en route dont les cartes réseaux ont été déconnectées + reparamétrées :" >> $Logs_Fichier_Chemin
    }
    For ($i = 0; $i -lt $script:VMs_PoweredOn_Nbre; $i++) {
        $Mail_Body += $script:VMs_PoweredOn_Liste[$i] + "<br>"
        $script:VMs_PoweredOn_Liste[$i] >> $Logs_Fichier_Chemin
    }

     #VM(s) arretée(s) :
     $Mail_Body += "<br>"
    "`r`r`n" >> $Logs_Fichier_Chemin
    If ($VMs_PoweredOff_Nbre -eq 0) {
        $Mail_Body += "<br><h2>Il n'y a pas de VM arrêtée !</h2>"
        "Il n'y a pas de VM arrêtée !" >> $Logs_Fichier_Chemin
    }
    ElseIf ($VMs_PoweredOff_Nbre -eq 1) {
        $Mail_Body += "<br><h2>Liste de l'unique VM arrêtée dont la carte réseau a été reparamétrée :</h2>"
        "Liste de l'unique VM arrêtée dont la carte réseau a été reparamétrée :" >> $Logs_Fichier_Chemin
    }
    Else {
        $Mail_Body += "<br><h2>Liste des VMs arrêtées dont les cartes réseaux ont été reparamétrées :</h2>"
        "Liste des VMs arrêtées dont les cartes réseaux ont été reparamétrées :" >> $Logs_Fichier_Chemin
    }
    For ($j = 0; $j -lt $script:VMs_PoweredOff_Nbre; $j++) {
        $Mail_Body += $script:VMs_PoweredOff_Liste[$j] + "<br>"
        $script:VMs_PoweredOff_Liste[$j] >> $Logs_Fichier_Chemin
    }
    
    #Send-MailMessage -From $From -to $To -Cc #$Mail_Cc -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Port $Mail_SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment -Encoding UTF8
    Send-MailMessage -From $Mail_Expediteur -to $Mail_Destinataires -Attachments $Mail_PieceJointe -Subject $Mail_Sujet -Body $Mail_Body -BodyAsHtml -SmtpServer $Mail_SMTPServer -Encoding UTF8
}

### Programme principal
$VariablesExistantes = Get-Variable
try {
    vCenter_Connexion
    ESXs_Liste_Recuperation
    Menu_ESX_Choix
    Mail_Envoi
} finally {
    Get-Variable | Where-Object Name -notin $VariablesExistantes.Name | Remove-Variable
}
