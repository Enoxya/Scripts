	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.150
	 Created on:   	3/16/2018 10:33 PM
	 Created by:   	Bradley Wyatt
	 Version:		1.0.1     	
	===========================================================================
	.DESCRIPTION
		This script is best ran as a scheduled task set daily. It will monitor a share and a file for NTFS and Share permissions.
		Each day it is ran it will check to see if it has ran the day previously
		If it has it will run again, compare todays NTFS and Share permissions to yesterday's and export to a CSV file what has changed
		
		If only one item changed (NTFS and not shared for example) it will export the NTFS changes to the results file and 
		in the folder for today it will add a log text file letting you know that share permissions did not change from the previous day
 
		Each day it runs it will create a folder with the date formated as MMddyyyy
		The results file will also be formatted with MMddyyyy
 
		This file requires the NTFSSecurity module which can be installed by running Install-Module -Name NTFSSecurity
 
		The changes for both NTFS and Share will continusly be added to a single results csv. From there you can see what changed each day
		that there was a change. It will not create a new file everytime 
 
			Line 39: Creates a variable that will be the folder name of that days results. 
			Line 46: The location where the results will be stored
			Line 52: The share it will monitor permissions for
			Line 58: The folder it will monitor NTFS permissions for
			Line 67: The person the results will be email to
			Line 69: The email the results are emailed from
			Line 71: The SMTP server it will send through
			Line 73: The SMTP Port
 
#>
 
 
###VARIABLES#####
Write-Host "Getting today's date..." -ForegroundColor Yellow
$ResultsFolderName = ((get-date).ToString("MMddyyyy"))
 
#CSV path where the results will be stored
$CSVPath = "C:\Results\"
 
#Creates todays folder to store results in
Write-Host "Creating today's folder to store results in..." -ForegroundColor Yellow
$TodayResultFolder = New-Item -ItemType Directory ($CSVPath + $ResultsFolderName) -ErrorAction SilentlyContinue
Write-Host "Created folder $TodayResultFolder located at $CSVPath" -ForegroundColor Yellow
 
#The share name you want to monitor share permissions on
Write-Host "Getting Share..." -ForegroundColor Yellow
#Share Name
$ShareName = "1"
Write-Host "Share name is $ShareName" -ForegroundColor Yellow
 
#The NTFS folder you want to monitor NTFS permissions on
Write-Host "Getting NTFS Folder..." -ForegroundColor Yellow
#NTFS Folder
$NTFSFolder = "C:\1"
Write-Host "NTFS Folder is $NTFSFolder" -ForegroundColor Yellow
 
#Counter var's 
$var1 = 0
$var2 = 0
 
#EMAIL VARIABLES
#Who to send the email of changes to
$To = 'brad@bwya77.com'
#Who the email is from
$From = 'brad@bwya77.com'
#SMTP server to use
$SMTPServer = 'smtp.office365.com'
#SMTP port
$Port = 587
 
#Check for SMTP credentials
Write-Host "Checking for E-mail credentials..." -ForegroundColor Yellow
$SMTPCred = Test-Path ($CSVPath + "\" + "filemonitor.cred")
#if no credentials are found then prompt the user for them and save them
If ($SMTPCred -eq $false)
{
	$Credential = Get-Credential
	$Credential | Export-CliXml -Path ($CSVPath + "\" + "filemonitor.cred")
}
 
 
#CSV file name used to track share permissions
$CSVShare = "share_permissions.csv"
#CSV file name used to track NTFS permissions
$CSVNTFS = "ntfs_permissions.csv"
 
#Check for the NTFSSecurity module which is required
Write-Host "Checking for NTFSSecurity module..." -ForegroundColor Yellow
Import-Module NTFSSecurity -ErrorAction SilentlyContinue
$ModCheck = Get-Module | Where-Object { $_.Name -like "NTFSSecurity" }
If ($ModCheck -eq $Null)
{
	Write-Host "WARNING: NTFSSecurity module is not installed! 
Please install it by running 'Install-Module -Name NTFSSecurity' " -ForegroundColor Red
}
Else
{
	
	function Get-ChangeLog($referenceObject, $differenceObject, $identifier)
	{
		$props = $referenceObject | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
		$diff = Compare-Object $referenceObject $differenceObject -Property $props -PassThru |
		Group-Object $identifier
		#capture modifications
		$today = (Get-Date).ToShortDateString()
		$modifications = ($diff | Where-Object Count -eq 2).Group | Group-Object $identifier
		foreach ($modification in $modifications)
		{
			#compare properties of each group
			foreach ($prop in $props)
			{
				if ($modification.Group[0].$prop -ne $modification.Group[1].$prop)
				{
					$output = $modification.Group | Where-Object { $_.SideIndicator -eq '<=' } |
					Select-Object (Write-Output Date $identifier ChangeType ChangedProperty From To)
					$output.Date = $today
					$output.ChangeType = "Modified"
					$output.ChangedProperty = $prop
					$output.From = ($modification.Group | Where-Object { $_.SideIndicator -eq '<=' }).$prop
					$output.To = ($modification.Group | Where-Object { $_.SideIndicator -eq '=>' }).$prop
					$output
				}
			}
		}
		#capture removals and additions
		$removalAdditions = $groupedDiff = ($diff | Where-Object Count -eq 1).Group | Group-Object $identifier
		foreach ($removalAddition in $removalAdditions)
		{
			$ht = [ordered]@{ }
			$ht.Add('Date', $today)
			$ht.Add($identifier, $removalAddition.Name)
			$ht.Add('ChangeType', '')
			$ht.Add('ChangedProperty', '')
			$ht.Add('From', '')
			$ht.Add('To', '')
			#addition
			if ($removalAddition.Group.SideIndicator -eq "=>")
			{
				$ht.ChangeType = 'Added'
			}
			#removal
			else
			{
				$ht.ChangeType = 'Removed'
			}
			New-Object PSObject -Property $ht
		}
	}
	
	
	Write-Host "Checking to see if yesterday's results are present..." -ForegroundColor Yellow
	If ((Test-Path -Path ($CSVPath + ((get-date).AddDays(-1).ToString("MMddyyyy")) + "\" + ((get-date).AddDays(-1).ToString("MMddyyyy")) + $CSVShare)) -eq $true -and (Test-Path -Path ($CSVPath + ((get-date).AddDays(-1).ToString("MMddyyyy")) + "\" + ((get-date).AddDays(-1).ToString("MMddyyyy")) + $CSVShare)) -eq $true)
	{
		Write-Host "Importing yesterday's share permissions result file..." -ForegroundColor Yellow
		#Import the last ran Share permissions CSV to the shell
		$YesterdaysShareCSV = Import-csv ($CSVPath + (get-date).AddDays(-1).ToString("MMddyyyy") + "\" + ((get-date).AddDays(-1).ToString("MMddyyyy")) + $CSVShare)
		Write-Host "Done!" -ForegroundColor Green
		
		Write-Host "Importing yesterday's NTFS permissions result file..." -ForegroundColor Yellow
		#Import last ran NTFS permissions csv to the shell
		$YesterdaysNTFSCSV = Import-csv ($CSVPath + (get-date).AddDays(-1).ToString("MMddyyyy") + "\" + ((get-date).AddDays(-1).ToString("MMddyyyy")) + $CSVNTFS)
		Write-Host "Done!" -ForegroundColor Green
		
		Write-Host "Getting today's share permissions..." -ForegroundColor Yellow
		#Gather todays share permissions
		$TodaysShareCSV = Get-SMBShareAccess -Name $ShareName | Select-Object Name, AccountName, AccessControlType, AccessRight | Export-Csv ($CSVPath + ((get-date).ToString("MMddyyyy")) + "\" + ((get-date).ToString("MMddyyyy")) + $CSVShare) -NoTypeInformation -Force
		Write-Host "Done!" -ForegroundColor Green
		
		Write-Host "Getting today's NTFS permissions..." -ForegroundColor Yellow
		#Gather todays NTFS Permissions 
		$TodaysNTFSCSV = Get-NTFSAccess -Path $NTFSFolder | Select-Object Account, AccessRights, AccessControlType | Export-Csv ($CSVPath + ((get-date).ToString("MMddyyyy")) + "\" + ((get-date).ToString("MMddyyyy")) + $CSVNTFS) -NoTypeInformation -Force
		Write-Host "Done!" -ForegroundColor Green
		
		Write-Host "Importing today's Share permissions..." -ForegroundColor Yellow
		#Import todays Share permissions
		$TodaysShare = Import-csv ($CSVPath + ((get-date).ToString("MMddyyyy")) + "\" + ((get-date).ToString("MMddyyyy")) + $CSVShare)
		Write-Host "Done!" -ForegroundColor Green
		
		Write-Host "Importing today's NTFS permissions..." -ForegroundColor Yellow
		#Import todays NTFS permissions
		$TodaysNFTS = Import-csv ($CSVPath + ((get-date).ToString("MMddyyyy")) + "\" + ((get-date).ToString("MMddyyyy")) + $CSVNTFS)
		Write-Host "Done!" -ForegroundColor Green
		
		Write-Host "Comparing yesterday's share permissions to today's..." -ForegroundColor Yellow
		#Compare yesterdays Share output to todays
		$ShareChange = Get-ChangeLog -differenceObject $TodaysShare -referenceObject $YesterdaysShareCSV ('AccountName')
		If ($ShareChange -eq $Null)
		{
			Write-Host "Share permissions haven't changed since yesterday's run..." -ForegroundColor Green
			"No Share permissions have changed since yesterday's results" | Out-File -FilePath ($CSVPath + ((get-date).ToString("MMddyyyy")) + "\" + "Sharelog.txt") -Force
		}
		Else
		{
			Write-Host "Share permissions have changed! Exporting the changed at $CSVPath" -ForegroundColor Green
			$var1 = 1
			$ShareChange | Export-Csv ($CSVPath + "DifferenceShares.csv") -NoTypeInformation -Append | Out-Null
		}
		
		Write-Host "Comparing yesterday's NTFS permissions to today's..." -ForegroundColor Yellow
		#Compare yesterdays NTFS output to todays
		$NTFSChange = Get-ChangeLog -differenceObject $TodaysNFTS -referenceObject $YesterdaysNTFSCSV ('Account')
		If ($NTFSChange -eq $Null)
		{
			Write-Host "NTFS permissions haven't changed since yesterday's run..." -ForegroundColor Green
			"No NTFS permissions have changed since yesterday's results" | Out-File -FilePath ($CSVPath + ((get-date).ToString("MMddyyyy")) + "\" + "NTFSlog.txt") -Force
		}
		Else
		{
			Write-Host "NTFS permissions have changed! Exporting the changed at $CSVPath" -ForegroundColor Green
			$var2 = 1
			$NTFSChange | Export-Csv ($CSVPath + "DifferenceNTFS.csv") -NoTypeInformation -Append | Out-Null
		}
		#IF both files changed, email both files
		If (($var1 -eq 1) -and ($var2 -eq 1))
		{
			Write-Host "NTFS and Share permissions changed, sending e-mail of changes to $To"
			Send-MailMessage `
							 -To $To `
							 -Subject 'Permission Monitor - NTFS + Share' `
							 -Body "NTFS and Share permissions changed for $ShareName and $NTFSFolder. Please see the attachment" `
							 -UseSsl `
							 -Port $Port `
							 -SmtpServer $SMTPServer `
							 -From $From `
							 -Credential (Import-CliXml -Path ($CSVPath + "\" + "filemonitor.cred"))`
							 -Attachments ($CSVPath + "\" + "DifferenceNTFS.csv"), ($CSVPath + "\" + "DifferenceShares.csv")
		}
		#IF NTFS permissions but Share permissions did not change
		ElseIf (($var1 -eq 0) -and ($var2 -eq 1))
		{
			Write-Host "NTFS permissions changed, sending e-mail of changes to $To"
			Send-MailMessage `
							 -To $To `
							 -Subject 'Permission Monitor - NTFS Only' `
							 -Body "NTFS permissions changed for $NTFSFolder. Please see the attachment" `
							 -UseSsl `
							 -Port $Port `
							 -SmtpServer $SMTPServer `
							 -From $From `
							 -Credential (Import-CliXml -Path ($CSVPath + "\" + "filemonitor.cred"))`
							 -Attachments ($CSVPath + "\" + "DifferenceNTFS.csv")
		}
		ElseIf (($var1 -eq 1) -and ($var2 -eq 0))
		{
			Write-Host "Share permissions changed, sending e-mail of changes to $To"
			Send-MailMessage `
							 -To $To `
							 -Subject 'Permission Monitor - Share Only' `
							 -Body "Share permissions changed for $ShareName. Please see the attachment" `
							 -UseSsl `
							 -Port $Port `
							 -SmtpServer $SMTPServer `
							 -From $From `
							 -Credential (Import-CliXml -Path ($CSVPath + "\" + "filemonitor.cred"))`
							 -Attachments ($CSVPath + "\" + "DifferenceShares.csv")
		}
		Else
		{
			Write-Host $_
		}
	}
	Else
	{
		Write-Host "No results from the previous day were found" -ForegroundColor Magenta
		
		Write-Host "Getting share permissions for today..." -ForegroundColor Yellow
		#Gather todays share permissions
		Get-SMBShareAccess -Name $ShareName | Select-Object Name, AccountName, AccessControlType, AccessRight | Export-Csv ($CSVPath + ((get-date).ToString("MMddyyyy")) + "\" + ((get-date).ToString("MMddyyyy")) + $CSVShare) -NoTypeInformation
		Write-Host "Done!" -ForegroundColor Green
		
		Write-Host "Getting NTFS permissions for today..." -ForegroundColor Yellow
		#Gather todays NTFS Permissions 
		Get-NTFSAccess -Path $NTFSFolder | Select-Object Account, AccessRights, AccessControlType | Export-Csv ($CSVPath + ((get-date).ToString("MMddyyyy")) + "\" + ((get-date).ToString("MMddyyyy")) + $CSVNTFS) -NoTypeInformation
		Write-Host "Done!" -ForegroundColor Green
	}
}