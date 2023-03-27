<# 
.SYNOPSIS
Clone-Group
.DESCRIPTION
Clones group Members from Source to Target
.NOTES
Have both Source and Target group Distinguished Name at hand
.LINK
#> 

#Set Source and Target Group Distinguished Name
$sourceGroup = [ADSI]"LDAP://CN=CTX-LOTUS85,OU=Groupes Citrix,OU=Groupes,DC=opac-01,DC=com"
$targetGroup = [ADSI]"LDAP://CN=CTX-LOTUS,OU=Groupes Citrix,OU=Groupes,DC=opac-01,DC=com"

"Source Group: $($sourceGroup.samAccountName)"
"Target Group: $($targetGroup.samAccountName)"

"`nCloning Source Group to TargetGroup`n"

#get Source members

foreach ($member in $sourceGroup.Member)
{
$targetGroup.add("LDAP://$($member)")
}