Add-PSSnapin Citrix.Broker.Admin.V2

#Suppression du fichier Liste-XenApp-All.txt
Remove-Item "C:\_admin\Scripts\Listes-VM\Liste-XenApp-All.txt"

Get-BrokerDesktopgroup | Where-object {$_.SessionSupport -eq "MultiSession"} | foreach {$_.Name} > "C:\_admin\Scripts\Listes-VM\_Liste-XenApp-DesktopGroup.txt"

$List = Get-Content "C:\_admin\Scripts\Listes-VM\_Liste-XenApp-DesktopGroup.txt"

foreach ($Name in $List)

{

Get-BrokerDesktop | Where-object {$_.DesktopGroupName -eq $Name} | foreach {$_.DNSName} > "C:\_admin\Scripts\Listes-VM\Liste-XenApp-$Name.txt"
Get-BrokerDesktop | Where-object {$_.DesktopGroupName -eq $Name} | Where-Object {$_.MachineName -notlike "*FORM*"} | Where-Object {$_.MachineName -notlike "*MAINT*"} | Where-Object {$_.MachineName -notlike "*TEST*"} | foreach {$_.DNSName} >> "C:\_admin\Scripts\Listes-VM\Liste-XenApp-All.txt"

}
