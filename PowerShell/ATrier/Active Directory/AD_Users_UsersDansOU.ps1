$OUpath = 'ou=Enquete HAW, OU=Branches, OU=Utilisateurs, OU=Bernard, dc=groupe-bernard,dc=lan'
$ExportPath = 'c:\users\saunies\desktop\users_in_ou1.csv'
Get-ADUser -Filter * -SearchBase $OUpath | Select-object DistinguishedName,Name,UserPrincipalName | Export-Csv -NoType $ExportPath