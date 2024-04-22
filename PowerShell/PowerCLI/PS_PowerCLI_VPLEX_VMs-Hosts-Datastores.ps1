
$Date = (Get-Date).ToString("yyyyMMdd")
$Rapport = @()
$Domaine = 'chb.ts1.local'
$ESX_Gamma = @("gaza.$Domaine", "geneve.$Domaine", "gibraltar.$Domaine", "grenade.$Domaine")
$ESX_Ki = @("kaboul.$Domaine", "kampala.$Domaine", "kiev.$Domaine", "kyoto.$Domaine")
$ConsistencyGroup_Gamma_Nom = 'PRIO_GA'
$ConsistencyGroup_Ki_Nom = 'PRIO_KI'
$ConsistencyGroup_Gamma_VirtualVolumes = @('Unity-VPLEX_2To_01', 'Unity-VPLEX_2To_03', 'Unity-VPLEX_2To_05', 'Unity-VPLEX_2To_07', 'Unity-VPLEX_4To_01')
$ConsistencyGroup_Ki_VirtualVolumes =  @('Unity-VPLEX_2To_02', 'Unity-VPLEX_2To_04', 'Unity-VPLEX_2To_06', 'Unity-VPLEX_2To_08', 'Unity-VPLEX_4To_02')


.\PowerShell\PowerCLI\PS_PowerCLI_vCenter_Connexion-Infos.ps1

$Datastores = Get-datastore | Where-Object {$_.name -like '*VPLEX*'} | Sort-Object
Foreach ($Datastore in $Datastores) {
    $VMs = $Datastore | Get-VM
    Foreach ($VM in $VMs) {
        $Erreur = ""
        $Line = "" | Select-Object Name, Host, Datastore, Erreur, DRSGroup
        $Line.Name      = $VM.Name
        $Line.Host      = Get-VMHost -VM $VM.Name
        $Line.Datastore = $Datastore.Name
        
        #$VM_Host = Get-VMHost -VM $VM.Name
        if ($ConsistencyGroup_Gamma_VirtualVolumes.Contains($Datastore.Name)) {
            #Le datastore de la VM appartient bien au Consistency Group de Gamma
            #On récupère l'hôte ESX de la VM et on vérifie qu'il fait bien partie de ceux de la salle Gamma
            if ($ESX_Gamma.Contains((Get-VMHost -VM $VM.Name).Name)) {
                #C'est bien le cas => OK
            }
            else {
                $Erreur = "Problème d'ESX : la VM $($VM.Name) est sur l'ESX $((Get-VMHost -VM $VM.Name).Name) alors que son datastore $($Datastore.Name) est dans le CG $ConsistencyGroup_Gamma_Nom"
            }
        }
        elseif ($ConsistencyGroup_Ki_VirtualVolumes.Contains($Datastore.Name)) {
            #Le datastore de la VM appartient au Consistency Group de Ki
            #Donc on va vérifier que son hôte ESX fait bien partie de ceux de la alle Ki
            if ($ESX_Ki.Contains((Get-VMHost -VM $VM.Name).Name)) {
                #C'est bien le cas => OK
            }
            else {
                $Erreur = "Problème d'ESX : la VM $($VM.Name) est sur l'ESX $((Get-VMHost -VM $VM.Name).Name) alors que son datastore $($Datastore.Name) est dans le CG $ConsistencyGroup_Ki_Nom"
            }
        }
        else {
            $Erreur = "Problème MAJEUR : Le datastore de la VM $($VM.Name) n'appartient ni au Consistency Group de Gamma, ni à celui de Ki"
        }
        $Line.Erreur        = $Erreur
        $Line.DRSGroup = Get-DrsClusterGroup -VM $VM.Name
        $Rapport           += $Line
    }
}
$Rapport | Format-Table -AutoSize
$Rapport | Export-csv -Path C:\Temp\VPLEX_VMs-DS-ESX_$Date.csv -NoTypeInformation -Delimiter ";" -Encoding Unicode
