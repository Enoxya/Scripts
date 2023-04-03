
$vms = Get-content C:\VMList.txt 

Get-LastBootUpTime -ComputerName srv-nor-rproxy

Get-LastBootUpTime -ComputerName srv-nor-iis

function Get-LastBootUpTime {
    param([Parameter(Mandatory=$true)][string[]] $ComputerName)
    foreach ($Computer in $ComputerName) {
        New-Object psobject -Property @{
            ComputerName = $Computer
            LastBootUpTime = [Management.ManagementDateTimeConverter]::ToDateTime( (Get-WmiObject -Class Win32_OperatingSystem -Computer $Computer | Select -Exp LastBootUpTime) )
        }
    }
}

 
