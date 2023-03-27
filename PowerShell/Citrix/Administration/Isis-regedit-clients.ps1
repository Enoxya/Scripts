$Liste = Get-Content "C:\Temp\Liste.txt"
$Path = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\POSTEVENDEUR\Clients"

ForEach ($User in $Liste)
{

New-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\POSTEVENDEUR\Clients" -Name $User -PropertyType String -Value "Y:\Isis"

}