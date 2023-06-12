$List = Get-Content "C:\_admin\Scripts\ListeXenApp-Renault.txt"

foreach ($Server in $List)

{

$WriteCache = Get-item "\\$Server\d$\vdiskdif.vhdx"
$Size = $WriteCache.Length

Write-Host $Server : "Write Cache size" $Size
if ($Size -gt 4194304)
{Write-Host "$Server : Write Cache memory full"}

}