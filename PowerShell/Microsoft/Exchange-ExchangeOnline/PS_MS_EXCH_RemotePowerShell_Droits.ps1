#Interdire un liste d'utilisateurs à faire du remote Powershell Exchange
$ListeUtilisateurs_Interdits = Get-Content "C:\Users\resiliences\Desktop\UtilisateursInterdits.txt"
$ListeUtilisateurs_Interdits | foreach { Set-User -Identity $_ -RemotePowerShellEnabled $false }

#Autoriser un liste d'utilisateurs à faire du remote Powershell Exchange
$ListeUtilisateurs_Autorises = Get-Content "C:\Users\resiliences\Desktop\UtilisateursAutorises.txt"
$ListeUtilisateurs_Autorises | foreach { Set-User -Identity $_ -RemotePowerShellEnabled $true }

#Voir la liste des utilisateurs autorisés à faire du remote Powershell Exchange
Get-User -ResultSize Unlimited -Filter 'RemotePowerShellEnabled -eq $true' | FT -Autosize Name, DisplayName, UserPrincipalName, RemotePowerShellEnabled