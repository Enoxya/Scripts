Add-PSSnapin Citrix.Broker.Admin.V2

#Suppression du fichier Liste-XenDesktop-All.txt
Remove-Item "C:\_admin\Scripts\Listes-VM\Liste-XenDesktop-All.txt"

Get-BrokerDesktopgroup | Where-object {$_.SessionSupport -eq "SingleSession"} | foreach {$_.Name} > "C:\_admin\Scripts\Listes-VM\_Liste-XenDesktop-DesktopGroup.txt"

$List = Get-Content "C:\_admin\Scripts\Listes-VM\_Liste-XenDesktop-DesktopGroup.txt"

foreach ($Name in $List)

{

Get-BrokerDesktop | Where-object {$_.DesktopGroupName -eq $Name} | foreach {$_.DNSName} > "C:\_admin\Scripts\Listes-VM\Liste-XenDesktop-$Name.txt"
Get-BrokerDesktop | Where-object {$_.DesktopGroupName -eq $Name} | foreach {$_.DNSName} >> "C:\_admin\Scripts\Listes-VM\Liste-XenDesktop-All.txt"

}
