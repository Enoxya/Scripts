#Si besoin Install-Module -Name SFTP 
Import-Module PSFTP

$FTPServer = '10.55.0.164'
$FTPUsername = 'cml3214-ftp01'
$FTPPassword = 'leiz0Yooth'
$FTPSecurePassword = ConvertTo-SecureString -String $FTPPassword -asPlainText -Force
$FTPCredential = New-Object System.Management.Automation.PSCredential($FTPUsername,$FTPSecurePassword)  

#On monte la connexion FTP
Set-FTPConnection -Credentials $FTPCredential -Server $FTPServer -Session SessionTest -UsePassive 

#Stockage des infos de connexion dans la variable $Session pour pouvoir les utiliser dans les commandes ensuite
$Session = Get-FTPConnection -Session SessionTest  

#Lister le contenu du répertoire (ici racine, possible de mettre un -Recurse)
Get-FTPChildItem -Session $Session -Path "/"

#Pour télécharger un fichier du FTP vers son poste :
Get-FTPItem -Path "/test/test.txt" -LocalPath C:\Temp\ftp\ -Session $Session -Verbose

#Envoyer un fichier vers le FTP :
Add-FTPItem -Session $Session -Path "/FTP_dossierCible/" -LocalPath "C:\Temp\ftp\test.txt"

#Envoyer le contenu d'un dossier local vers le FTP
Get-ChildItem "Fichiers récupérés depuis un dosiser en local et à envoyer, exemple C:\temp\dossierEnvoi" | Add-FTPItem -Session $Session -Path /FTP_dossierCible/