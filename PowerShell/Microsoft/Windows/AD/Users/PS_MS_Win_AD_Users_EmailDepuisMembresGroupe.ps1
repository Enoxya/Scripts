Get-ADGroupMember -Identity "CTX_CI_SITE-Montceau" -Recursive | 
Get-ADUser -Properties Mail | 
Select-Object Name,Mail | 
Export-CSV -Path C:\users\saunies\desktop\file.csv -NoTypeInformation