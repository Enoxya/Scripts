#Variables
$vCenter = "bob.chb.ts1.local"
$DiskInfo = @()

#Functions
function vCenter_Connexion {
    #Connexion au vCenter
    Write-Host "vCenter" = $vCenter
    If (!$vCenter) {$vCenter = Read-Host "`nEntrez le FQDN du vCenter ou son IP"} #Si on en veut pas mettre le nom du vCenter dans les variables
    Try {
        Connect-VIServer -server $vCenter -EA Stop | Out-Null
    } Catch {
        "`r`n`r`nImpossible de se connecter au vCenter $vCenter" #>> $log_Fichier_Chemin
        "Fin du programme...`r`n`r`n" #>> $log_Fichier_Chemin
        Exit
    }
}

#Main
vCenter_Connexion
$computers = read-host "`nEntrer le nom (hostname) du serveur dont on souhaite récupérer les informations des disques" #Or a <list of computer name>

$Username = "chb\chb_sysaunier"
$Password = "Bl4nch301.!*!"
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
$Session = New-PSSession -ComputerName $ComputerName -Credential $Credentials
$Resultat = Invoke-Command -Session $Session -ScriptBlock {

    foreach ($ComputerName in $computers) {
    
        $windiskdrives = Get-CimInstance  -ComputerName $ComputerName -Class Win32_DiskDrive -Property *
        $windiskpartitions = Get-CimInstance -ComputerName $ComputerName -Class win32_diskpartition -Property *
        $vmdiskdrives = Get-harddisk -vm $ComputerName
        $VMScsiController = Get-ScsiController -VM $ComputerName
       
        foreach ($vmdiskdrive in $vmdiskdrives) {
            $VirtualDisk = "" | Select-Object SystemName, SCSIController, DiskName, SCSI_Id, DiskFile, VMDiskSize, WindowsDisk, DriveLetter, Description, WinDisksize, winSCSIID
            $VirtualDisk.systemname = $ComputerName
            $VMUUID = ($vmdiskdrive.ExtensionData.Backing.uuid).replace("-", "")
            $SCSICont = $VMScsiController | where-object { $_.extensiondata.key -eq $vmdiskdrive.extensiondata.controllerkey }
            $VirtualDisk.SCSIController = $SCSICont.name
            $VirtualDisk.DiskName = $vmdiskdrive.name
            $VirtualDisk.SCSI_Id = "$($vmdiskdrive.ExtensionData.controllerkey - 1000) : $($vmdiskdrive.ExtensionData.unitnumber)"
            $VirtualDisk.DiskFile = $vmdiskdrive.ExtensionData.Backing.FileName
            $VirtualDisk.VMDiskSize = $vmdiskdrive.ExtensionData.CapacityinKB * 1KB / 1GB
            $diskmatch = $windiskdrives | where-object { $_.SerialNumber -eq $VMUUID }
            if ($DiskMatch) {
                $VirtualDisk.Winscsiid = "$($diskmatch.SCSIport - 2) : $($diskmatch.SCSITARGETID)"
                $VirtualDisk.WindowsDisk = "Disk $($diskmatch.Index)"
                $match1 = $windiskpartitions | where-object { $_.diskindex -eq $DiskMatch.index }
                ForEach ($partition in $match1) {
                    $logicaldisk = $null
                    $logicaldisk = Get-CimAssociatedInstance -InputObject $partition
                    if ($logicaldisk.count -gt 1) {
                        $VirtualDisk.DriveLetter = $logicaldisk.DeviceID[2]
                        $VirtualDisk.Description = $logicaldisk.VolumeName[2]
                        $VirtualDisk.windisksize = $logicaldisk.Size[2] / 1GB
                    }
                }
            }
        $DiskInfo += $VirtualDisk
        }
    }
    $DiskInfo #| Out-GridView -OutputMode Multiple
}
$Resultat | Out-GridView -OutputMode Multiple
Get-PSSession -ComputerName $ComputerName -Credential $Credentials | Disconnect-PSSession | Remove-PSSession