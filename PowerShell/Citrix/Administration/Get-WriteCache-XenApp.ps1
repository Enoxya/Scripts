Add-PSSnapin Citrix.Broker.Admin.V2

$List = Get-Content "C:\_admin\Scripts\Listes-VM\Liste-XenApp-All.txt"

foreach ($Server in $List)

{

#Get-DesktopGroup

$WriteCache = Get-item "\\$Server\d$\vdiskdif.vhdx"
$Size = $WriteCache.Length

Write-Host $Server : "Write Cache size" $Size
if ($Size -gt 4194304)
{Write-Host "$Server : Write Cache memory full"}

}