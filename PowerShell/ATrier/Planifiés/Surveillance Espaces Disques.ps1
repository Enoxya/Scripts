# -------------------------------------------------------------
# Script de surveillance espace volumes + points de montage
# PowerShell 3.0
# By Jérémie GADENNE - 18 Novembre 2014
# -------------------------------------------------------------

# 1. Initialisation des variables 
$FlagAlert= $false
$PercentFreeSpaceAlert = 10
$MountPointData = @{}
$SmtpServer = "EXCH-RELAIS"                
$Users = @("j.gadenne@autobernard.com","dsiinfra@autobernard.com")
$EmailFrom = "ADMIN Système <sysadmin@autobernard.com>"
$ComputerRange = @("SRV-NOR-SAGE","SRV-NOR-HORO","SRV-NOR-XRT", "SRV-NOR-TALEND","SRV-NOR-DWH", "SRV-NOR-SECOURS", "SRV-NOR-SQL", "SRV-NOR-BO", "SRV-NOR-MBX1", "SRV-NOR-MBX2"; "SRV-NOR-SAGEAPP")
$Body ='Serveur'.PadRight(20) + 'Volume'.PadRight(30) + 'Total'.PadRight(10) + 'Restant'.PadRight(10) + 'Libre' + "`n" 
$body += "---------------------------------------------------------------------------- `n"  

# 2. Convert from one device ID format to another.
function Get-DeviceIDFromMP {
    
    param([Parameter(Mandatory=$true)][string] $VolumeString,
          [Parameter(Mandatory=$true)][string] $Directory)
    
    if ($VolumeString -imatch '^\s*Win32_Volume\.DeviceID="([^"]+)"\s*$') {
        # Return it in the wanted format.
        $Matches[1] -replace '\\{2}', '\'
    }
    else {
        # Return a presumably unique hashtable key if there's no match.
        "Unknown device ID for " + $Directory
    }
    
}

# 3. Programme
 Clear-Host 

 Foreach ($Computer in $ComputerRange) {
        
        $WmiHash = @{
            ComputerName = $Computer
            ErrorAction  = 'Stop'
        }

        Get-WmiObject @WmiHash -Class Win32_MountPoint | ForEach-Object { $MountPointData.(Get-DeviceIDFromMP $_.Volume $_.Directory) = $_.Directory  }
        $Volumes = Get-WmiObject @WmiHash -Class Win32_Volume | Select-Object Label, Caption, Capacity, FreeSpace, DeviceID, @{n='Computer';e={$Computer}}
        $Volumes | ForEach-Object {
            
                 if ($MountPointData.ContainsKey($_.DeviceID)) 
                     {
                        if ($_.Capacity) 
                           { $PercentFree = $_.FreeSpace*100/$_.Capacity 
                             if ($PercentFree -le $PercentFreeSpaceAlert) 
                             { $FlagAlert = $true
                                $body += $_.Computer.Padright(20) + $_.Caption.PadRight(30) + [Math]::Round((($_.Capacity)/1GB),0).ToString().PadRight(10) + [Math]::Round((($_.FreeSpace)/1GB),0).ToString().PadRight(10) + [Math]::Round((($PercentFree)),0).ToString() + "%`n"     
                             }
                           }  
                        else { $PercentFree = 0 }
                       
                     }
          
                } 
}
    
# 4. Envoie des mails d'alerte
If ($FlagAlert) { ForEach ($User in $Users) {

        Write-Host -ForegroundColor Cyan "Envoi d'un mail d'alerte à : $user `n"
        Write-Host $body
        $Smtp = New-Object Net.Mail.SmtpClient($SmtpServer)
        $Subject = "Alerte Serveur - Espace disque insuffisant - Moins de $PercentFreeSpaceAlert % libre"
        
        $Smtp.Send($EmailFrom,$User,$Subject,$Body)
        
    }
}


