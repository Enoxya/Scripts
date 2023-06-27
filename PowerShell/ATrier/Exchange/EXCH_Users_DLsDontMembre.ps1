clear
$Username = "s.saunier"

$domaine = "@autobernard.com"
$adresseMail = $Username+$domaine

$DistributionGroups = Get-DistributionGroup | where { (Get-DistributionGroupMember $_.Name | foreach {$_.PrimarySmtpAddress}) -contains "$adresseMail"}
if ($DistributionGroups -eq $null) {
    Write-Host "Il n'y a pas de groupe de distribution pour l'utilisateur" $adresseMail
    }
else {
    Write-Host $DistributionGroups
    }