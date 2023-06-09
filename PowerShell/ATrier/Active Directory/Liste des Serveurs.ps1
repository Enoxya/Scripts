Import-module activedirectory

#1. Liste des serveurs Windows
Get-ADComputer -Filter {OperatingSystem -Like "Windows Server*"} -Property * | Format-Table Name,OperatingSystem,OperatingSystemServicePack -Wrap -Auto

#2. 

$AllServers = Get-ADComputer -Filter {OperatingSystem -Like "Windows Server*"} -Property * 
ForEach ($AllServersItem in $AllServers )
{
$ServerName = $AllServersItem.Hostname
$ServerCMID = Get-WmiObject –computer $ServerName  -class SoftwareLicensingService | Select-object ClientMachineID
Write-Output "$ServerName has the CMID: $ServerCMID "
}

