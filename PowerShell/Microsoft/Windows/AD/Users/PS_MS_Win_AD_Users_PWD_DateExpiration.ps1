Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed" |
>> Select-Object -Property "Displayname",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}

<#Retourne quelque chose du genre :
Displayname              ExpiryDate
-----------              ----------
VCenter_AAGNIEL          21/06/2023 14:59:13
vCenter_Sylvain SAUNIER  23/06/2023 13:40:30
vCenter_Nicolas_BOZONNET 27/06/2023 12:12:00
#>