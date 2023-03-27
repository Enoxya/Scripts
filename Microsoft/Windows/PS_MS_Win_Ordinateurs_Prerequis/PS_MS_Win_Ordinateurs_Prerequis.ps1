Function Get-Info_OS
{
    param ([String]$ComputerName = '.')
    $infos_OS = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName
    $infos_OS | Select-Object -property @{Name='ComputerName'; Expression = {$_.Csname}},
                                    @{Name='OS'; Expression = {$_.caption}},
                                    @{Name='ServicePack'; Expression = {$_.csdversion}}
}

Function Get-Info_Ecran
{
    param ([String]$ComputerName = '.')
    $infos_Ecran = Get-WmiObject -Class Win32_DesktopMonitor -ComputerName $ComputerName
    $infos_Ecran | Select-Object -property @{Name='Ecran_Largeur'; Expression = {$_.ScreenWidth}},
                                    @{Name='Ecran_Hauteur'; Expression = {$_.ScreenHeight}}
}

Function Get-Info_Disque
{
    param ([String]$ComputerName = '.')
    $infos_Disque = Get-WmiObject Win32_logicaldisk -ComputerName $ComputerName
    $infos_Disque | Where-Object {$_.name -eq "C:"} | Select-Object -property @{Name='Disk_Name'; Expression = {$_.name}},
                                    @{Name='Disk_Size'; Expression = {$_.Size}},
                                    @{Name='Disk_FreeSpace'; Expression = {$_.FreeSpace}}
}

Function Get-Info_CPU
{
    param ([String]$ComputerName = '.')
    $infos_CPU = Get-WmiObject Win32_Processor -ComputerName $ComputerName
    $infos_CPU | Select-Object -property @{Name='CPU_Name'; Expression = {$_.Name}},
                                    @{Name='CPU_NbreCores'; Expression = {$_.NumberOfCores}}
    $infos_RAM = ((Get-WmiObject  win32_physicalmemory -ComputerName $ComputerName -namespace "root\CIMV2").Capacity)/1GB
}

Function Get-Info_RAM
{
    param ([String]$ComputerName = '.')
    $infos_RAM = ((Get-WmiObject  win32_physicalmemory -ComputerName $ComputerName -namespace "root\CIMV2").Capacity)/1GB
}



$listeMachines = Get-Content ./ListeMachines.txt
$nbreLignes = Get-Content ./ListeMachines.txt | Measure-Object

$progression = @{
    Activity = 'Récupération des informations des machines ...'
    CurrentOperation = "loading"
    PercentComplete = 0
}
Write-Progress @progression
$compteur = 0

$resultat=@()

Foreach($ordinateur in $listeMachines) {
    $compteur = $compteur + 100/($nbreLignes.Count)
    $progression.CurrentOperation = "$ordinateur"
    $progression.PercentComplete = $compteur

    Write-Progress @progression

    #Test si machine répond au ping sinon on skip
    $resultatPing = Test-Connection -computerName $ordinateur -Count 1 -Quiet
    If ($resultatPing) {
        $informations_OS = Get-Info_OS -computerName $ordinateur
        if ((Get-WmiObject win32_operatingsystem -ComputerName $ordinateur| select osarchitecture).osarchitecture -eq "64 bits") {
            $Bits = "64 bits"
        }
        else {
            $Bits = "32 bits"
        }

        if ($informations_OS.ServicePack -eq "Service Pack 1") { #Si SP = SP1 alors on vérifie présence de la KB
            if (!(Get-HotFix -Id KB2999226 -computerName $ordinateur)) {
                $KB = "KB ABSENT"
            }
            else {
                $KB = "KB PRÉSENT"
            }
        }
        $informations_Disque = Get-Info_Disque -computerName $ordinateur
        $informations_Ecran = Get-Info_Ecran -ComputerName $ordinateur     
        $informations_CPU = Get-Info_CPU -computerName $ordinateur
        $informations_RAM = Get-Info_RAM -computerName $ordinateur
        $resultat += New-Object psobject -Property @{
            "NOM ORDINATEUR" = $ordinateur
            "CONNEXION" = "CONNECTÉ"
            OS = "$($informations_OS.OS) - $($Bits)"
            "KB 2999226" = $KB
            "ECRAN - RÉSOLUTION" = "$($informations_Ecran.Ecran_Largeur) x $($informations_Ecran.Ecran_Hauteur)"
            "SERVICE PACK" = $informations_OS.ServicePack
            "ESPACE LIBRE (C:)" = "{0:n2}"-f($informations_Disque.Disk_FreeSpace/1GB)
            "CPU - FREQUENCE"= $informations_CPU.CPU_Name
            "CPU - NBRE COEURS" = $informations_CPU.CPU_NbreCores
            "MÉMOIRE" = $infos_RAM
            }

    }    
    else {
        $resultat += New-Object psobject -Property @{
            "NOM ORDINATEUR" = $ordinateur
            "CONNEXION" = "NON CONNECTÉ"
        }
    }
}
$resultat | Select-Object "NOM ORDINATEUR", "CONNEXION", "OS", "SERVICE PACK", "KB 2999226", "ECRAN - RÉSOLUTION", "ESPACE LIBRE (C:)", "CPU - FREQUENCE", "CPU - NBRE COEURS", "MÉMOIRE" | Export-Csv -Path ./ListeMachines_Resultat.csv -Encoding UTF8 -NoTypeInformation
