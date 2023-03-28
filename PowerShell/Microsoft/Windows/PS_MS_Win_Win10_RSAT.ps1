$currentWU = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | select -ExpandProperty UseWUServer
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0
Restart-Service wuauserv
#Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property DisplayName, State
#Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online
#Add-WindowsCapability –online –Name Rsat.DHCP.Tools~~~~0.0.1.0
#Add-WindowsCapability –online –Name Rsat.Dns.Tools~~~~0.0.1.0
#Add-WindowsCapability –online –Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $currentWU
Restart-Service wuauserv