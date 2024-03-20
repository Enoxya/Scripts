#Variables
$Logs_Dossier = $PSScriptRoot+"\Logs"
$Date = Get-Date -Format yyyyMMdd
$ScriptPS_Nom = $MyInvocation.MyCommand.Name
$Logs_FichierChemin = "$Logs_Dossier"+"\$ScriptPS_Nom"+"_$Date.log"

$vCenter = "bob.sia-f.local"

function LogsDossier_Verification {
    #Tests
    if (!(test-path $Logs_Dossier)) {
        New-Item $Logs_Dossier -ItemType Directory
    }
}

function vCenter_Connexion {
    #Connexion au vCenter
    If (!$vCenter) {
        $vCenter = Read-Host "`nEntrez le FQDN du vCenter ou son IP"
    } #Si on en veut pas mettre le nom du vCenter dans les variables
    Try {
        Connect-VIServer -server $vCenter -EA Stop | Out-Null
    }
    Catch {
        "`r`n`r`nImpossible de se connecter au vCenter $vCenter" >> $Logs_FichierChemin
        "Fin du programme...`r`n`r`n" >> $Logs_FichierChemin
        Exit
    }
}


Function Get-TimeSpanPretty {
    <#
    .Synopsis
       Displays the time span between two dates in a single line, in an easy-to-read format
    .DESCRIPTION
       Only non-zero weeks, days, hours, minutes and seconds are displayed.
       If the time span is less than a second, the function display "Less than a second."
    .PARAMETER TimeSpan
       Uses the TimeSpan object as input that will be converted into a human-friendly format
    .EXAMPLE
       Get-TimeSpanPretty -TimeSpan $TimeSpan
       Displays the value of $TimeSpan on a single line as number of weeks, days, hours, minutes, and seconds.
    .EXAMPLE
       $LongTimeSpan | Get-TimeSpanPretty
       A timeline object is accepted as input from the pipeline. 
       The result is the same as in the previous example.
    .OUTPUTS
       String(s)
    .NOTES
       Last changed on 28 July 2022
    #>

    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory,ValueFromPipeline)][ValidateNotNull()][timespan]$TimeSpan
    )

    Begin {}

    Process{
        # Initialize $TimeSpanPretty, in case there is more than one timespan in the input via pipeline
        [string]$TimeSpanPretty = ""
    
        $Ts = [ordered]@{
            Semaine   = [math]::Floor($TimeSpan.Days / 7)
            Jours    = [int]$TimeSpan.Days % 7
            Heures   = [int]$TimeSpan.Hours
            Minutes = [int]$TimeSpan.Minutes
            Secondes = [int]$TimeSpan.Seconds
        } 
        # Process each item in $Ts (week, day, etc.)
        foreach ($i in $Ts.Keys){
            # Skip if zero
            if ($Ts.$i -ne 0) {
                # Append the value and key to the string
                $TimeSpanPretty += "{0} {1}, " -f $Ts.$i,$i
                
            } #Close if
        } #Close for
    
        # If the $TimeSpanPretty is not 0 (which could happen if start and end time are identical.)
        if ($TimeSpanPretty.Length -ne 0){
            # delete the last coma and space
            $TimeSpanPretty = $TimeSpanPretty.Substring(0,$TimeSpanPretty.Length-2)
        }
        else {
            # Display "Less than a second" instead of an empty string.
            $TimeSpanPretty = "Moins d'une seconde"
        }
        $TimeSpanPretty
    } # Close Process
    End {}
} #Close function Get-TimeSpanPretty

function VMsWithSnapshots_Get {
    #$script:VMsAvecSnapshots = @()
    $script:VMsAvecSnapshots = Get-VM | Where-Object { $_.Name -notmatch '_replica' } | ForEach-Object {
        $($_) | Get-Snapshot | `
        Select-Object @{Label = "VM"; Expression = {$_.VM}}, 
        @{Label = "Snapshot Name";Expression = {$_.Name}},
        @{Label = "Created Date"; Expression = {$_.Created}},
        @{Label = "Snapshot Size"; Expression = {$_.SizeGB}},
        @{Label = "Number of days since creation"; Expression = {(New-TimeSpan -Start $_.Created -End $(Get-Date) | Get-TimeSpanPretty )}} | Add-Content $Logs_FichierChemin -PassThru #>
    }
    Write-Host $script:VMsAvecSnapshots
}


function Email_Envoi { 
    if ($null -ne $script:VMsAvecSnapshots) {
        #Il y a des VMs avec snapshots

        $From = "vCenter-CHB@ch-bourg.ght01.fr"
        $To = "exploitation@ch-bourg01.fr"
        #$Cc = ""
        #$Attachment = "C:\Temp\XXX.jpg"
        $Subject = "CHB - VIRT - VMs - VM(s) avec snapshot"
        $Body = "<h2>Problème : il existe des machines virtuelles possédant un ou plusieurs snapshot(s)</h2><br>"

        if ($script:VMsAvecSnapshots.Length -eq 1) {
            #Il y a une seule VM avec snapshot
            $Body += "" + $script:VMsAvecSnapshots.Length + " seule VM avec snapshot a été trouvée :<br><br>"
        }
        else {
            $Body += "" + $script:VMsAvecSnapshots.Length + " VMs avec des snapshots ont été trouvées :<br><br>"
        }

        $VMsAvecSnapshots_Liste = @()
        #On cree un tableau qui va recevoir les valeurs des champs de chaque snapshot de chaque VM (nom vm, nom snapshot, taille, etc.)
        #Et on boucle sur chaque snapshot pour récupérer ces infos et les mettre dans le tableau
        for ($i = 0; $i -lt $script:VMsAvecSnapshots.Length; $i++) {
            $VMsAvecSnapshots_VM = $script:VMsAvecSnapshots[$i]
            $DureeDepuisCreationSnapshot = (New-TimeSpan -Start ($VMsAvecSnapshots_VM.'Created Date') -End $(Get-Date) | Get-TimeSpanPretty )
            $VMsAvecSnapshots_Liste += "VM : " + $VMsAvecSnapshots_VM.VM + "<br>Nom du snapshot : " + $VMsAvecSnapshots_VM.'Snapshot Name' + "<br>Durée depuis création Snapshot : " + $DureeDepuisCreationSnapshot + "<br><br>"
        }

        $Body += $VMsAvecSnapshots_Liste
        #$SMTPServer = "smtp.ght01.fr"
        $SMTPServer = "mercure.chb.ts1.local"
        #$SMTPPort = "587"
        $SMTPPort = "25"
        #Send-MailMessage -From $From -to $To -Cc $Cc-Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment -Encoding UTF8
        Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Port $SMTPPort -Encoding UTF8
    }
    else {
        #Pas de VM avec snapshot donc pas de mail à envoyer
    }
}


LogsDossier_Verification
vCenter_Connexion
VMsWithSnapshots_Get
Email_Envoi

