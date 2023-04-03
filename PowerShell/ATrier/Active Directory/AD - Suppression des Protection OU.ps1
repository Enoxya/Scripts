
New-PSDrive -PSProvider ActiveDirectory -Name AD -Root "DC=groupe-bernard,DC=lan"

cd AD:

cd '.\DC=groupe-bernard,DC=lan'
cd '.\OU=GROUPE BERNARD'
cd '.\OU=CITRIX-ORDI'



Get-ADOrganizationalUnit -Filter * -Property ProtectedFromAccidentalDeletion | Where{ $_.ProtectedFromAccidentalDeletion -eq $true } | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $false

