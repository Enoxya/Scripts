# Exporte les adresses SMTP dans un fichier CSV
# JGE - Juillet 2016

Import-Module ActiveDirectory

Get-ADUser -LdapFilter '(proxyAddresses=SMTP*)' -Properties proxyAddresses |
    select-object name, sAMAccountName, @{L="Proxy Addresses";E={$tmp = $_.proxyAddresses | where-object {$_ -match "smtp"}; $tmp -join ","}} |
    export-csv C:\users\mayn\EXPORT-AD-MAIL.csv -NoTypeInformation
