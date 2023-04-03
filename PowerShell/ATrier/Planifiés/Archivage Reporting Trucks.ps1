# -------------------------------------------------------------
# Script de déplacement de fichiers
# PowerShell 3.0
# By Jérémie GADENNE - 28 octobre 2014
# -------------------------------------------------------------

# Déclaration des constantes 

$pathSource = "\\SRV-NOR-FRP\Sage\Reporting"
$pathDest = "\\srv-nor-fich\BRANCHES\BERNARD TRUCKS\ECHANGE RAF\ArchivesReporting"
$SMTPServer = "EXCH-RELAIS"                
$EmailUsers = @("j.gadenne@autobernard.com","annabelle.chapuis@autobernard.com")
$EmailFrom = "admin@autobernard.com"


# Fonction Compression Répertoire
Function DirectoryZip
{ 
    param ($Directory = $(throw "Paramètre de fonction non fourni!"), $ZipFileName= $(throw "Paramètre de fonction non fourni!"))

    if (test-path $ZipFileName) 
        {
            Write-Output " Le fichier d’archive $ZipFileName existe!"
            Remove-item -force $ZipFileName
            Write-Output " Le fichier d’archive existant a été supprimé"
        }

    Set-Content $ZipFileName ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
    (dir $ZipFileName).IsReadOnly = $false

    $shellApplication = New-Object -com shell.application
    $ZipFile = $shellApplication.NameSpace($ZipFileName)

    Write-Output " Compression de $Directory"
    Write-Output " vers $ZipFileName"
    $ZipFile.CopyHere($Directory)

    Do { $zipCount = $ZipFile.Items().count
         Start-Sleep -Seconds 1
       } 
    While ($ZipFile.Items().count -lt 1)

    Write-Output " Compression terminée"

    # Efface l'ancien répertoire
    #[IO.Directory]::Delete("$Directory", $True)
    #Write-Output "Fichiers de sauvegarde non compressés supprimés!"

}

# Appel de la Fonction
$day = (Get-Date).Day
$monthFic = (Get-Date).ToString('MMMM')
$monthRep = (Get-Date).AddDays(-3).ToString('MMMM')
$monthRep = $monthRep.Substring(0,1).ToUpper()+$monthRep.Substring(1).ToLower()  
$year = (Get-Date).Year

$pathDestFinal = $pathDest + "\$year\$monthRep"
New-Item -Type Directory -path $pathDestFinal

DirectoryZip $pathSource "$pathDestFinal\Archives du $day $monthFic $year.zip"

#Envoyer mail de réussite

 ForEach ($User in $EmailUsers)  
   {
        Write-Host -ForegroundColor Cyan "Sending Email notification to $User"
        $Smtp = New-Object Net.Mail.SmtpClient($SMTPServer)
        $Subject = "Archivage Fichiers Reporting" 
        $Body = " Création Archive du $day $month $year à réussi. `n Emplacement : \\srv-nor-fich\BRANCHES\BERNARD TRUCKS\ECHANGE RAF\ArchivesReporting" 
        $Smtp.Send($EmailFrom,$User,$Subject,$Body)
    }

