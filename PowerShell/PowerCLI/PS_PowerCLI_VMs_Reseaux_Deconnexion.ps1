#Variables
$vCenter = "gigi2.chb.ts1.local"
$VMs_Liste_PoweredOn = @()
$VMs_EnFonction = @()
$VMs_Liste_PoweredOff = @()
$nbreVms_PoweredOn = 0
$nbreVms_PoweredOff = 0
$date = Get-Date -Format ('yyyyMMdd')
$log_Dossier = "C:\Temp\"
$log_Fichier = "VMs_Deconnectees_"+$date+".txt"
$log_Fichier_Chemin = $log_Dossier + $log_Fichier

function vCenter_Connexion {
    #Connexion au vCenter
    If ($vCenter -eq "") {$vCenter = Read-Host "`nEntrez le FQDN du vCenter ou son IP"} #Si on en veut pas mettre le nom du vCenter dans les variables
    Try {
        Connect-VIServer -server $vCenter -EA Stop | Out-Null
    } Catch {
        "`r`n`r`nImpossible de se connecter au vCenter $vCenter" >> $log_Fichier_Chemin
        "Fin du programme...`r`n`r`n" >> $log_Fichier_Chemin
        Exit
    }
}

function VMs_Liste_Creation {
    #Récupération de la liste des VMs (Nom et état)
    $script:VMs_Liste =  Get-VM | Where {$_.Name -eq "CHB-DRH-VMX-01"} #| Select Name, PowerState
    write-host "La liste des VMs a bien été récupérée.`n`nAffichage de la liste des VMs :"
    Start-Sleep -Seconds 2
    write-Host $script:VMs_Liste.Name
    Write-Host "`n`nPoursuite du programme..."
    Start-Sleep -Seconds 1
}

function MenuListeVMs {
    Clear-Host
    $MenuListeVMs_Continue = $true
    while ($MenuListeVMs_Continue) {
        Write-host "---------------------- MENU LISTE DES VMS -----------------------" -ForegroundColor Yellow
        Write-host "1. Récupération de la liste des VMs depuis le vCenter" -ForegroundColor Yellow
        Write-host "2. Import d'une liste de VMs" -ForegroundColor Yellow
        Write-host "X. Sortie du programme" -ForegroundColor Yellow
        Write-host "-----------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host "Faire un choix (1, 2 ou X) :" -ForegroundColor Yellow
        $MenuListeVMs_Choix = Read-host
        switch ($MenuListeVMs_Choix) {
            1 {
                $MenuListeVMs_Continue = $false
                write-Host "`n"
                VMs_Liste_Creation
            }
            2 {
                $MenuListeVMs_Continue = $false
                write-Host "`n"
                VMs_Liste_Import
            }
            ‘X’ {$MenuListeVMs_Continue = $false}
            default {
                Write-Host "Choix invalide"-ForegroundColor Red
                Start-Sleep -Seconds 2
                MenuListeVMs
                }
        }
    }
}

function Input_Entrer() {
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

function Confirmation_Demande {
    $Confirmation_Continue = $true
    
    while ($Confirmation_Continue) {
        Write-Host "`n"
        $Confirmation_Reponse = Input_Entrer "Etes-vous sûr de vouloir déconnecter l'ensemble des machines virtuelles (Oui/Non) ?"
        switch ($Confirmation_Reponse) {
            { $Confirmation_Reponse -like 'oui' } {
                $Confirmation_Continue = $false
            }
            { $Confirmation_Reponse -like 'non' } { 
                $Confirmation_Continue = $false
                Write-host "Vous n'etes pas assez sûr de vous, sortie du programme !"
                exit 5
            }
            default { Write-Host "Choix invalide" -ForegroundColor Red }
        }
    }
}

function VMs_DesactivationReseaux {
    ForEach ($vm in $script:VMs_Liste) {
        #Si la VM est en route alors on déconnecte les cartes réseaux et on les paramètres à "Connecter lors de la mise sous tension" décochée
        if ($vm.Powerstate -eq "PoweredOn") {
            $script:nbreVms_PoweredOn ++
            $script:VMs_Liste_PoweredOn += @($vm.Name)
            Get-VM $vm | Get-NetworkAdapter | Set-NetworkAdapter -Connected:$false -StartConnected:$false -Confirm:$false #-Verbose
        }
        #Si la VM est arretée, on paramètre juste à "Connecter lors de la mise sous tension" décochée
        else {
            $script:nbreVms_PoweredOff ++
            $script:VMs_Liste_PoweredOff += @($vm.Name)
            Get-VM $vm | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected:$false -Confirm:$false #-Verbose
        }
    }
}

function Mail_Envoi {
    #Envoi du mail
    #A voir si utile car si on coupe la connexion du serveur de messagerie, il ne pourra pas envoyer de mail :-)
    $From = "vCenter@ch-bourg01.fr"
    $To = "exploitation@ch-bourg01.fr" #,"nibozonnet@ch-bourg01.fr", "ssaunier@ch-bourg01.fr"
    #$Cc = ""
    $Attachment = $log_Fichier_Chemin
    $Subject = "vCenter - Déconnexion des cartes réseaux des VMs"
        #VM(s) en route :
        If ($script:nbreVms_PoweredOn -eq 0) {
            $Body = "<h2>Il n'y a pas de VM en route ! </h2>"
            }
        ElseIf ($script:nbreVms_PoweredOn -eq 1) {
            $Body = "<h2>Unique VM en route dont la carte réseau a été déconnectée + reparamétrée : </h2>"
            }
        Else {
            $Body = "<h2>Liste des VMs en route dont les cartes réseaux ont été déconnectées + reparamétrées : </h2>"
        }
        "VMs en route dont les cartes réseaux ont été déconnectées + reparamétrées :" >> $log_Fichier_Chemin
        For ($i = 0; $i -lt $script:nbreVms_PoweredOn; $i++) {
            $Body += $script:VMs_Liste_PoweredOn[$i] + "<br>"
            $script:VMs_Liste_PoweredOn[$i] >> $log_Fichier_Chemin
        }

        #VM(s) arretée(s) :
        If ($nbreVms_PoweredOff -eq 0) {
            $Body += "<br><h2>Il n'y a pas de VM arrêtée ! </h2>"
            }
        ElseIf ($nbreVms_PoweredOff -eq 1) {
            $Body += "<br><h2>Liste de l'unique VM arrêtée dont la carte réseau a été reparamétrée : </h2>"
            }
        Else {
            $Body += "<br><h2>Liste des VMs arrêtées dont les cartes réseaux ont été reparamétrées : </h2>"
        }
        "`r`n" >> $log_Fichier_Chemin
        "VMs arrêtées dont les cartes réseaux ont été reparamétrées :" >> $log_Fichier_Chemin
        For ($j = 0; $j -lt $script:nbreVms_PoweredOff; $j++) {
            $Body += $script:VMs_Liste_PoweredOff[$j] + "<br>"
            $script:VMs_Liste_PoweredOff[$j] >> $log_Fichier_Chemin
        }
    $SMTPServer = "mercure.chb.ts1.local"
    #$SMTPPort = "587"
    #Send-MailMessage -From $From -to $To -Cc $Cc-Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment -Encoding UTF8
    Send-MailMessage -From $From -to $To -Attachments $Attachment -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Encoding UTF8
}

#Programme principal
vCenter_Connexion
MenuListeVMs
Confirmation_Demande
VMs_DesactivationReseaux
Mail_Envoi


