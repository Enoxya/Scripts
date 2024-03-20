# Copyright (c) Microsoft Corporation. All rights reserved.
#
# StartDagServerMaintenenance.ps1

# .SYNOPSIS
# Calls Suspend-MailboxDatabaseCopy on the database copies.
# Pauses the node in Failover Clustering so that it can not become the Primary Active Manager.
# Suspends database activation on each mailbox database.
# Sets the DatabaseCopyAutoActivationPolicy to Blocked on the server.
# Moves databases and cluster group off of the designated server.
#
# If there's a failure in any of the above, the operations are undone, with
# the exception of successful database moves.
#
# Can be run remotely, but it requires the cluster administrative tools to
# be installed (RSAT-Clustering).

# .PARAMETER serverName
# The name of the server on which to start maintenance. FQDNs are valid

# .PARAMETER whatif
# Does not actually perform any operations, but logs what would be executed
# to the verbose stream.

# .PARAMETER overrideMinimumTwoCopies
# Allows users to override the default minimum number of database copies to require
# to be up after shutdown has completed.  This is meant to allow upgrades
# in situations where users only have 2 copies of a database in their dag.

# .PARAMETER MoveComment
# The string which is passed to the MoveComment parameter of the
# Move-ActiveMailboxDatabase cmdlet.

# .PARAMETER pauseClusterNode
# When it is true, pausing the Windows Failover Cluster node will be part of
# placing a Server into Maintenance.

# .PARAMETER UseMailboxServerRedundancy
# When it is true, Maintenance will call Get-MailboxServerRedundancy
# instead of calculating critical redundancy requirements another way.

Param(
	[Parameter(Mandatory=$true)]
	[System.Management.Automation.ValidateNotNullOrEmptyAttribute()]
	[string] $serverName,

	[string] $Force = 'false',
	[Parameter(Mandatory=$false)] [switch] $whatif = $false,
	[Parameter(Mandatory=$false)] [switch] $overrideMinimumTwoCopies = $false,
    [Parameter(Mandatory=$false)] [string] $MoveComment = "BeginMaintenance",
	[Parameter(Mandatory=$false)] [switch] $pauseClusterNode = $false,
	[Parameter(Mandatory=$false)] [switch] $UseMailboxServerRedundancy = $true
)

# Global Values
$ServerCountinTwoServerDAG = 2
$RetryCount = 2
$HAComponent = 'HighAvailability'

Import-LocalizedData -BindingVariable StartDagServerMaintenance_LocalizedStrings -FileName PS_WIN_EXCH_StartDagServerMaintenance.strings.psd1

# Define some useful functions.

# Load the Exchange snapin if it's no already present.
function LoadExchangeSnapin
{
    if (! (Get-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction:SilentlyContinue) )
    {
        Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction:Stop
    }
}

# Handle Cluster Error Codes during Start-DagServerMaintenance
function HandleClusterErrorCode ([string]$Server = $servername, [int]$ClusterErrorCode, [string]$Action)
{
	switch ($ClusterErrorCode)
	{
		# 0 is success
		0		
		{   
			log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0026 -f $Server,$Action,"Start-DagServerMaintenance")
			# clear $LastExitCode
			cmd /c "exit 0"
		}
        
        # 5 is returned when the Server is powered down 
		5
		{
			log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0025 -f $Server,$Action,"Server powered down","Start-DagServerMaintenance")
			# clear $LastExitCode
			cmd /c "exit 0"
		}
        
        # 70 is ERROR_SHARING_PAUSED - The remote server has been paused or is in the process of being started
		70
		{
			log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0025 -f $Server,$Action,"ERROR_SHARING_PAUSED","Start-DagServerMaintenance")
			# clear $LastExitCode
			cmd /c "exit 0"
		}
		
		# 1753 is EPT_S_NOT_REGISTERED
		1753
		{
			log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0025 -f $Server,$Action,"EPT_S_NOT_REGISTERED","Start-DagServerMaintenance")
			# clear $LastExitCode
			cmd /c "exit 0"
		}
		
		# 1722 is RPC_S_SERVER_UNAVAILABLE
		1722
		{
			log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0025 -f $Server,$Action,"RPC_S_SERVER_UNAVAILABLE","Start-DagServerMaintenance")
			# clear $LastExitCode
			cmd /c "exit 0"
		}
		
		# 5042 is ERROR_CLUSTER_NODE_NOT_FOUND
		5042
		{
			log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0025 -f $Server,$Action,"ERROR_CLUSTER_NODE_NOT_FOUND","Start-DagServerMaintenance")
			# clear $LastExitCode
			cmd /c "exit 0"
		}
		
		# 5043 is ERROR_CLUSTER_LOCAL_NODE_NOT_FOUND
		5043
		{
			log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0025 -f $Server,$Action,"ERROR_CLUSTER_LOCAL_NODE_NOT_FOUND","Start-DagServerMaintenance")
			# clear $LastExitCode
			cmd /c "exit 0"
		}
		
		# 5050 is ERROR_CLUSTER_NODE_DOWN
		5050
		{
			log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0025 -f $Server,$Action,"ERROR_CLUSTER_NODE_DOWN","Start-DagServerMaintenance")
			# clear $LastExitCode
			cmd /c "exit 0"
		}
		
		# Best effort to pause the node. Not a known code, so warning at this point.
		default {Log-Warning ($StartDagServerMaintenance_LocalizedStrings.res_0004 -f $Server,$Action,$ClusterErrorCode,"Start-DagServerMaintenance") -stop}
	}
}

# The meat of the script!
&{
	# Get the current script name. The method is different if the script is
	# executed or if it is dot-sourced, so do both.
	$thisScriptName = $myinvocation.scriptname
	if ( ! $thisScriptName )
	{
		$thisScriptName = $myinvocation.MyCommand.Path
	}

	# Many of the script libraries already use $DagScriptTesting
	if ( $whatif )
	{
		$DagScriptTesting = $true;
	}

	# Load the Exchange cmdlets.
	& LoadExchangeSnapin

	# Load some of the common functions.
	. "$(split-path $thisScriptName)\DagCommonLibrary.ps1";
	
	Test-RsatClusteringInstalled

	# Allow an FQDN to be passed in, but strip it to the short name.
	$shortServerName = $serverName;
	if ( $shortServerName.Contains( "." ) )
	{
		$shortServerName = $shortServerName -replace "\..*$"
	}
	
	# Variables to keep track of what needs to be rolled back in the event of failure.
	$pausedNode = $false;
	$activationBlockedOnServer = $false;
	$serverComponentStateSet = $false;
    $serverComponentStateOrg = $null;
	$scriptCompletedSuccessfully = $false;

	try {
        # Stage 1 - block auto activation on the server.
        # Also set HA server component state to Inactive (in AD and registry). This will block actives from moving back to the server.
        
		log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0008 -f $shortServerName)
		if ($DagScriptTesting)
		{
			write-host ($StartDagServerMaintenance_LocalizedStrings.res_0009 -f $shortServerName,"Set-MailboxServer","-Identity","-DatabaseCopyAutoActivationPolicy")
		}
		else
		{
			Set-MailboxServer -Identity $shortServerName -DatabaseCopyAutoActivationPolicy:Blocked
			$activationBlockedOnServer = $true;
		}
		
		log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0029 -f $shortServerName)
		if ($DagScriptTesting)
		{
			write-host ($StartDagServerMaintenance_LocalizedStrings.res_0030 -f $shortServerName,"Set-ServerComponentState","-Component HighAvailability","-State Inactive")
		}
		else
		{
            # Get-ServerComponentState test to see if HighAvailability component exists on the server
            # If it doesn't exist skip calling Set-ServerComponentState
            # For all other cases suppress the error and let Set-ServerComponentState run
            $componentExists = $true
            try
            {
                $Error.Clear()
			    $serverComponentStateOrg = Get-ServerComponentState $serverName -Component $HAComponent -ErrorAction:Stop;
            }
            catch
            {
                if ($Error.Exception.Gettype().Name -ilike 'ArgumentException')
                {
                    $componentExists = $false
                }
                $Error.Clear()
            }
            
			
			if ($componentExists)
			{
                if($serverComponentStateOrg -and $serverComponentStateOrg.State -eq 'Active')
                {
				    Set-ServerComponentState $serverName -Component $HAComponent -Requester "Maintenance" -State Inactive
				    $serverComponentStateSet = $true;
                }
			}
			else
			{
				Log-Warning ($StartDagServerMaintenance_LocalizedStrings.res_0034 -f $HAComponent, $shortServerName)
			}
		}
        
        # Stage 2 - pause the node in the cluster to stop it becoming the PAM
        
		# Explicitly connect to clussvc running on serverName. This script could
		# easily be run remotely.
		log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0000 -f $shortServerName);
		if ( $DagScriptTesting )
		{
			log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0001 )
		}
		else
		{
			# Try to fetch $dagName if we can.
			$dagName = $null
			$mbxServer = Get-MailboxServer $serverName -erroraction:silentlycontinue
			if ( $mbxServer -and $mbxServer.DatabaseAvailabilityGroup )
			{
				$dagName = $mbxServer.DatabaseAvailabilityGroup.Name;
			}

			if($pauseClusterNode)
			{
				# Start with $serverName (which may or may not be a FQDN) before
				# falling back to the (short) names of the DAG.

				$outputStruct = Call-ClusterExe -dagName $dagName -serverName $serverName -clusterCommand "node $shortServerName /pause"
				$LastExitCode = $outputStruct[ 0 ];
				$output = $outputStruct[ 1 ];
				HandleClusterErrorCode -ClusterErrorCode $LastExitCode -Action "Pause"
				$Error.Clear()
				$pausedNode = $true;
			}
		}
        
		if($dagName)
		{
			# Stage 3 - move all the resources off the server

			$numCriticalResources = 0

			# Move the critical resources off the specified server. 
			# This includes Active Databases, and the Primary Active Manager.
			# If any error occurs in this stage, script execution will halt.
			# (If we don't assign the result to a variable then the script will
			# print out 'True')
			$try = 0
			$dagObject = Get-DatabaseAvailabilityGroup $dagName			
			$dagServers = $dagObject.Servers.Count			
			$stoppedDagServers = $dagObject.StoppedMailboxServers.Count
			$moveErrors = $null
			$nextWaitUntilTime = [DateTimeOffset]::Now
			while (($try -eq 0) -or (($numCriticalResources -gt 0 -or $moveErrors -ne $null) -and $try -lt $RetryCount))
			{
				# Sleep for 60 seconds if this is not the first move attempt
				if ($try -gt 0)
				{
					$sleepTime = $nextWaitUntilTime.Subtract(([DateTimeOffset]::Now))
					if($sleepTime -gt [TimeSpan]::Zero)
					{
						Start-Sleep -Seconds $sleepTime.TotalSeconds
					}
				}
			
				$nextWaitUntilTime = [DateTimeOffset]::Now.AddMinutes(1)
				$moveErrors = Move-CriticalMailboxResources -Server $shortServerName -MoveComment $MoveComment -Force $Force
		
				# Check again to see if the moves were successful. (Unless -whatif was
				# specified, then it's pretty likely it will fail).
				if ( !$DagScriptTesting )
				{
					log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0013 -f $shortServerName,"Start-DagServerMaintenance")			
						
					if (($dagServers - $stoppedDagServers) -eq $ServerCountinTwoServerDAG -or $overrideMinimumTwoCopies)
					{				
						$criticalMailboxResources = @(GetCriticalMailboxResources $shortServerName -AtleastNCriticalCopies ($ServerCountinTwoServerDAG - 1) -UseMailboxServerRedundancy:$UseMailboxServerRedundancy)
					}
					else
					{			
						$criticalMailboxResources = @(GetCriticalMailboxResources $shortServerName -UseMailboxServerRedundancy:$UseMailboxServerRedundancy)
					}			
					$numCriticalResources = ($criticalMailboxResources | Measure-Object).Count
				}
				$try++
			}
			if( $numCriticalResources -gt 0 )
			{
				Log-Warning "MoveResults follow:`n$moveErrors`nEndOfMoveResults"
				Log-CriticalResource $criticalMailboxResources
			
				if($moveErrors.Contains("AmDbMoveMoveSuppressedBlackoutException"))
				{
					Write-Error ($StartDagServerMaintenance_LocalizedStrings.res_0035) -ErrorAction:Stop
				}
				else
				{
					Write-Error ($StartDagServerMaintenance_LocalizedStrings.res_0014 -f ( PrintCriticalMailboxResourcesOutput($criticalMailboxResources)),$shortServerName, $moveErrors) -ErrorAction:Stop
				}
			}
		}

		$scriptCompletedSuccessfully = $true;
	}
	finally
	{
		# Rollback only if something failed and Force flag was not used
		if ( !$scriptCompletedSuccessfully)
		{
			if ($Force -ne 'true')
			{
				log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0015 -f "Start-DagServerMaintenance")

				# Create a new script block so that $ErrorActionPreference only
				# affects this scope.
				&{
					# Cleanup code is run with "Continue" ErrorActionPreference
					$ErrorActionPreference = "Continue"
	                
					if ( $pausedNode )
					{
						# Explicitly connect to clussvc running on serverName. This script could
						# easily be run remotely.
						log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0018 -f $serverName,$shortServerName,$serverName);
						if ( $DagScriptTesting )
						{
							write-host ($StartDagServerMaintenance_LocalizedStrings.res_0019 )
						}
						else
						{
							$outputStruct = Call-ClusterExe -dagName $dagName -serverName $serverName -clusterCommand "node $shortServerName /resume"
							$LastExitCode = $outputStruct[ 0 ];
							$output = $outputStruct[ 1 ];
							HandleClusterErrorCode -ClusterErrorCode $LastExitCode -Action "Resume"
						}
					}
					
					if ( $activationBlockedOnServer )
					{
						log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0016 -f $shortServerName)
						
						if ( $DagScriptTesting )
						{
							write-host ($StartDagServerMaintenance_LocalizedStrings.res_0017 -f "set-mailboxserver")
						}
						else
						{
							Set-MailboxServer -Identity $shortServerName -DatabaseCopyAutoActivationPolicy:Unrestricted
						}
					}
					
					if ( $serverComponentStateSet -and $serverComponentStateOrg -and $serverComponentStateOrg.State -eq 'Active')
					{
						log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0031 -f $shortServerName)
						
						if ( $DagScriptTesting )
						{
							write-host ($StartDagServerMaintenance_LocalizedStrings.res_0032 -f "Set-ServerComponentState")
						}
						else
						{
							Set-ServerComponentState $serverName -Component 'HighAvailability' -Requester "Maintenance" -State Active							
						}
					}					
				}
			}
			else
			{
				log-verbose ($StartDagServerMaintenance_LocalizedStrings.res_0027 -f "Start-DagServerMaintenance")
			}
		}		
	}
}

# SIG # Begin signature block
# MIInzgYJKoZIhvcNAQcCoIInvzCCJ7sCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAJHSIqrH3IMywp
# l46Nicr4Z8PDYiVYXRnUn5l4i94uGqCCDYUwggYDMIID66ADAgECAhMzAAACzfNk
# v/jUTF1RAAAAAALNMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjIwNTEyMjA0NjAyWhcNMjMwNTExMjA0NjAyWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDrIzsY62MmKrzergm7Ucnu+DuSHdgzRZVCIGi9CalFrhwtiK+3FIDzlOYbs/zz
# HwuLC3hir55wVgHoaC4liQwQ60wVyR17EZPa4BQ28C5ARlxqftdp3H8RrXWbVyvQ
# aUnBQVZM73XDyGV1oUPZGHGWtgdqtBUd60VjnFPICSf8pnFiit6hvSxH5IVWI0iO
# nfqdXYoPWUtVUMmVqW1yBX0NtbQlSHIU6hlPvo9/uqKvkjFUFA2LbC9AWQbJmH+1
# uM0l4nDSKfCqccvdI5l3zjEk9yUSUmh1IQhDFn+5SL2JmnCF0jZEZ4f5HE7ykDP+
# oiA3Q+fhKCseg+0aEHi+DRPZAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU0WymH4CP7s1+yQktEwbcLQuR9Zww
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzQ3MDUzMDAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AE7LSuuNObCBWYuttxJAgilXJ92GpyV/fTiyXHZ/9LbzXs/MfKnPwRydlmA2ak0r
# GWLDFh89zAWHFI8t9JLwpd/VRoVE3+WyzTIskdbBnHbf1yjo/+0tpHlnroFJdcDS
# MIsH+T7z3ClY+6WnjSTetpg1Y/pLOLXZpZjYeXQiFwo9G5lzUcSd8YVQNPQAGICl
# 2JRSaCNlzAdIFCF5PNKoXbJtEqDcPZ8oDrM9KdO7TqUE5VqeBe6DggY1sZYnQD+/
# LWlz5D0wCriNgGQ/TWWexMwwnEqlIwfkIcNFxo0QND/6Ya9DTAUykk2SKGSPt0kL
# tHxNEn2GJvcNtfohVY/b0tuyF05eXE3cdtYZbeGoU1xQixPZAlTdtLmeFNly82uB
# VbybAZ4Ut18F//UrugVQ9UUdK1uYmc+2SdRQQCccKwXGOuYgZ1ULW2u5PyfWxzo4
# BR++53OB/tZXQpz4OkgBZeqs9YaYLFfKRlQHVtmQghFHzB5v/WFonxDVlvPxy2go
# a0u9Z+ZlIpvooZRvm6OtXxdAjMBcWBAsnBRr/Oj5s356EDdf2l/sLwLFYE61t+ME
# iNYdy0pXL6gN3DxTVf2qjJxXFkFfjjTisndudHsguEMk8mEtnvwo9fOSKT6oRHhM
# 9sZ4HTg/TTMjUljmN3mBYWAWI5ExdC1inuog0xrKmOWVMIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGZ8wghmbAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAALN82S/+NRMXVEAAAAA
# As0wDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIEmC
# VacIFYFC0VrqSBxiGQQblYBkoAXGWlvKqgiQldwNMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAw5BiGSuEvhLiflgEVyU+uLWfTaQSUmAiuN6m
# q8LYsIUMLNZwA0jCS3gSt+g3sZhRcHXjD4nhbi6mBxGWyrCWiBBPX+nnNCrk4Fh/
# 8w+XJToYhatZBycQbP9vHi7tRoB2GIYp+mOVXOFi6ZTRdfisdPux7oGMpkIWhNvK
# vEst20uklRJMQVu9Cx6tX4F3YPyucIvIEDCOQ7+iLA9UtoRMaxMhT+AibzPD2nDw
# euW9zuwVlMMIbOP1XuEZVSayb+zDQUi/OM63bl6dNmevRVG+7/GgZhkVrw8UPyBu
# 5g6Y6HWNmEaamxOfsCgVk57C8WzPZ8lmwRwpUjk6UDRbtvcirKGCFykwghclBgor
# BgEEAYI3AwMBMYIXFTCCFxEGCSqGSIb3DQEHAqCCFwIwghb+AgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFZBgsqhkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCC0fq9SykG8qSLLqbXVFP7zy0w8fDRhieZl
# KcrU3tzxngIGY/dZX/72GBMyMDIzMDMwMTE4MjA0My4yNTVaMASAAgH0oIHYpIHV
# MIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQL
# EyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsT
# HVRoYWxlcyBUU1MgRVNOOjE3OUUtNEJCMC04MjQ2MSUwIwYDVQQDExxNaWNyb3Nv
# ZnQgVGltZS1TdGFtcCBTZXJ2aWNloIIReDCCBycwggUPoAMCAQICEzMAAAG1rRrf
# 14VwbRMAAQAAAbUwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBIDIwMTAwHhcNMjIwOTIwMjAyMjExWhcNMjMxMjE0MjAyMjExWjCB0jELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9z
# b2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1UaGFsZXMg
# VFNTIEVTTjoxNzlFLTRCQjAtODI0NjElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUt
# U3RhbXAgU2VydmljZTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJcL
# CrhlXoLCjYmFxcFPgkh57dmuz31sNsj8IlvmEZRCbB94mxSIj35P8m5TKfCRmp7b
# vuw4v/t3ucFjf52yVCDFIxFiZ3PCTI6D5hwlrDLSTrkf9UbuGmtUa8ULSHpatPfE
# wZeJOzbBBPO5e6ihZsvIsBjUI5MK9GzLuAScMuwVF4lx3oDklPfdq30OMTWaMc57
# +Nky0LHPTZnAauVrJZKlQE3HPD0n4ASxKXRtQ6dsKjcOCayRcCTQNW3800nGAAXO
# bJkWQYLD+CYiv/Ala5aHIXhMkKJ45t6xbba6IwK3klJ4sQC7vaQ67ASOA1Dxht+K
# CG4niNaKhZf8ZOwPu7jPJOKPInzFVjU2nM2z5XQ2LZ+oQa3u69uURA+LnnAsT/A8
# ct+GD1BJVpZTz9ywF6eXDMEY8fhFs4xLSCxCl7gHH8a1wk8MmIZuVzcwgmWIeP4B
# dlNsv22H3pCqWqBWMJKGXk+mcaEG1+Sn7YI/rWZBVdtVL2SJCem9+Gv+OHba7Cun
# Yk5lZzUzPSej+hIZZNrH3FMGxyBi/JmKnSjosneEcTgpkr3BTZGRIK5OePJhwmw2
# 08jvcUszdRJFsW6fJ/yx1Z2fX6eYSCxp7ZDM2g+Wl0QkMh0iIbD7Ue0P6yqB8oxa
# oLRjvX7Z8WL8cza2ynjAs8JnKsDK1+h3MXtEnimfAgMBAAGjggFJMIIBRTAdBgNV
# HQ4EFgQUbFCG2YKGVV1V1VkF9DpNVTtmx1MwHwYDVR0jBBgwFoAUn6cVXQBeYl2D
# 9OXSZacbUzUZ6XIwXwYDVR0fBFgwVjBUoFKgUIZOaHR0cDovL3d3dy5taWNyb3Nv
# ZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3JsMGwGCCsGAQUFBwEBBGAwXjBcBggrBgEFBQcwAoZQaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBUaW1l
# LVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcnQwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwDQYJKoZIhvcNAQELBQAD
# ggIBAJBRjqcoyldrNrAPsE6g8A3YadJhaz7YlOKzdzqJ01qm/OTOlh9fXPz+de8b
# oywoofx5ZT+cSlpl5wCEVdfzUA5CQS0nS02/zULXE9RVhkOwjE565/bS2caiBbSl
# cpb0Dcod9Qv6pAvEJjacs2pDtBt/LjhoDpCfRKuJwPu0MFX6Gw5YIFrhKc3RZ0Xc
# ly99oDqkr6y4xSqb+ChFamgU4msQlmQ5SIRt2IFM2u3JxuWdkgP33jKvyIldOgM1
# GnWcOl4HE66l5hJhNLTJnZeODDBQt8BlPQFXhQlinQ/Vjp2ANsx4Plxdi0FbaNFW
# LRS3enOg0BXJgd/BrzwilWEp/K9dBKF7kTfoEO4S3IptdnrDp1uBeGxwph1k1Vng
# BoD4kiLRx0XxiixFGZqLVTnRT0fMIrgA0/3x0lwZJHaS9drb4BBhC3k858xbpWde
# m/zb+nbW4EkWa3nrCQTSqU43WI7vxqp5QJKX5S+idMMZPee/1FWJ5o40WOtY1/dE
# BkJgc5vb7P/tm49Nl8f2118vL6ue45jV0NrnzmiZt5wHA9qjmkslxDo/ZqoTLeLX
# bzIx4YjT5XX49EOyqtR4HUQaylpMwkDYuLbPB0SQYqTWlaVn1OwXEZ/AXmM3S6CM
# 8ESw7Wrc+mgYaN6A/21x62WoMaazOTLDAf61X2+V59WEu/7hMIIHcTCCBVmgAwIB
# AgITMwAAABXF52ueAptJmQAAAAAAFTANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0
# IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAwHhcNMjEwOTMwMTgyMjI1
# WhcNMzAwOTMwMTgzMjI1WjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDCC
# AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAOThpkzntHIhC3miy9ckeb0O
# 1YLT/e6cBwfSqWxOdcjKNVf2AX9sSuDivbk+F2Az/1xPx2b3lVNxWuJ+Slr+uDZn
# hUYjDLWNE893MsAQGOhgfWpSg0S3po5GawcU88V29YZQ3MFEyHFcUTE3oAo4bo3t
# 1w/YJlN8OWECesSq/XJprx2rrPY2vjUmZNqYO7oaezOtgFt+jBAcnVL+tuhiJdxq
# D89d9P6OU8/W7IVWTe/dvI2k45GPsjksUZzpcGkNyjYtcI4xyDUoveO0hyTD4MmP
# frVUj9z6BVWYbWg7mka97aSueik3rMvrg0XnRm7KMtXAhjBcTyziYrLNueKNiOSW
# rAFKu75xqRdbZ2De+JKRHh09/SDPc31BmkZ1zcRfNN0Sidb9pSB9fvzZnkXftnIv
# 231fgLrbqn427DZM9ituqBJR6L8FA6PRc6ZNN3SUHDSCD/AQ8rdHGO2n6Jl8P0zb
# r17C89XYcz1DTsEzOUyOArxCaC4Q6oRRRuLRvWoYWmEBc8pnol7XKHYC4jMYcten
# IPDC+hIK12NvDMk2ZItboKaDIV1fMHSRlJTYuVD5C4lh8zYGNRiER9vcG9H9stQc
# xWv2XFJRXRLbJbqvUAV6bMURHXLvjflSxIUXk8A8FdsaN8cIFRg/eKtFtvUeh17a
# j54WcmnGrnu3tz5q4i6tAgMBAAGjggHdMIIB2TASBgkrBgEEAYI3FQEEBQIDAQAB
# MCMGCSsGAQQBgjcVAgQWBBQqp1L+ZMSavoKRPEY1Kc8Q/y8E7jAdBgNVHQ4EFgQU
# n6cVXQBeYl2D9OXSZacbUzUZ6XIwXAYDVR0gBFUwUzBRBgwrBgEEAYI3TIN9AQEw
# QTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9E
# b2NzL1JlcG9zaXRvcnkuaHRtMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBkGCSsGAQQB
# gjcUAgQMHgoAUwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/
# MB8GA1UdIwQYMBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJ
# oEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01p
# Y1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYB
# BQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3J0MA0GCSqGSIb3DQEBCwUAA4ICAQCdVX38Kq3h
# LB9nATEkW+Geckv8qW/qXBS2Pk5HZHixBpOXPTEztTnXwnE2P9pkbHzQdTltuw8x
# 5MKP+2zRoZQYIu7pZmc6U03dmLq2HnjYNi6cqYJWAAOwBb6J6Gngugnue99qb74p
# y27YP0h1AdkY3m2CDPVtI1TkeFN1JFe53Z/zjj3G82jfZfakVqr3lbYoVSfQJL1A
# oL8ZthISEV09J+BAljis9/kpicO8F7BUhUKz/AyeixmJ5/ALaoHCgRlCGVJ1ijbC
# HcNhcy4sa3tuPywJeBTpkbKpW99Jo3QMvOyRgNI95ko+ZjtPu4b6MhrZlvSP9pEB
# 9s7GdP32THJvEKt1MMU0sHrYUP4KWN1APMdUbZ1jdEgssU5HLcEUBHG/ZPkkvnNt
# yo4JvbMBV0lUZNlz138eW0QBjloZkWsNn6Qo3GcZKCS6OEuabvshVGtqRRFHqfG3
# rsjoiV5PndLQTHa1V1QJsWkBRH58oWFsc/4Ku+xBZj1p/cvBQUl+fpO+y/g75LcV
# v7TOPqUxUYS8vwLBgqJ7Fx0ViY1w/ue10CgaiQuPNtq6TPmb/wrpNPgkNWcr4A24
# 5oyZ1uEi6vAnQj0llOZ0dFtq0Z4+7X6gMTN9vMvpe784cETRkPHIqzqKOghif9lw
# Y1NNje6CbaUFEMFxBmoQtB1VM1izoXBm8qGCAtQwggI9AgEBMIIBAKGB2KSB1TCB
# 0jELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMk
# TWljcm9zb2Z0IElyZWxhbmQgT3BlcmF0aW9ucyBMaW1pdGVkMSYwJAYDVQQLEx1U
# aGFsZXMgVFNTIEVTTjoxNzlFLTRCQjAtODI0NjElMCMGA1UEAxMcTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgU2VydmljZaIjCgEBMAcGBSsOAwIaAxUAjTCfa9dUWY9D1rt7
# pPmkBxdyLFWggYMwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAN
# BgkqhkiG9w0BAQUFAAIFAOepwLIwIhgPMjAyMzAzMDEyMDE2NTBaGA8yMDIzMDMw
# MjIwMTY1MFowdDA6BgorBgEEAYRZCgQBMSwwKjAKAgUA56nAsgIBADAHAgEAAgIS
# bDAHAgEAAgISRDAKAgUA56sSMgIBADA2BgorBgEEAYRZCgQCMSgwJjAMBgorBgEE
# AYRZCgMCoAowCAIBAAIDB6EgoQowCAIBAAIDAYagMA0GCSqGSIb3DQEBBQUAA4GB
# AG9ia/vzrZ8M85S7XRj8dolARSbLV20CuolYNzm06eIAU2sl8M9QObqAuHp52oJA
# M9W7nN+C0xpuuV0j06AVpnuyg0LCyrRGu5Bnm6M9RPCZbjMPWY2osEBSVUiE4JKm
# RooJvMI7+8TSWv8LamwRCzbn+AueD+/2BmU5IgZX6OtMMYIEDTCCBAkCAQEwgZMw
# fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
# TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAG1rRrf14VwbRMAAQAA
# AbUwDQYJYIZIAWUDBAIBBQCgggFKMBoGCSqGSIb3DQEJAzENBgsqhkiG9w0BCRAB
# BDAvBgkqhkiG9w0BCQQxIgQgYxNCHWqk5mG29QY7n84K0a7fBHcpd6y8wHSnlDxB
# C8IwgfoGCyqGSIb3DQEJEAIvMYHqMIHnMIHkMIG9BCAnyg01LWhnFon2HNzlZyKa
# e2JJ9EvCXJVc65QIBfHIgzCBmDCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBD
# QSAyMDEwAhMzAAABta0a39eFcG0TAAEAAAG1MCIEIKKHNk0N8o61Lgk0J8A5XorP
# vgl3gHZdHusSWc1qTSRNMA0GCSqGSIb3DQEBCwUABIICAGMaXFJklXX5oI2KhiOR
# H9SpoPwzFVGe81qX5S+9iiW/QFRPXYs7OCD1J2X55Tu5u0CmmcjaYwzHm0uBHEh5
# yoAN8tvgrsEpaQ58jLXUjpXCIQu7AxSw4D0XAjg8VLqKui33OS6nnHATMgk+TOB3
# 3iEz0vXvCqqvJ+hs8NR31z/ZGxpXEIBYap3pRr7ug6BHZwhiZEC+UDVdNkil27xq
# SlwopcqgDQcURAlcnbHBwXMWPHFfYj3cEUvH9h5OOsUfdA/P2oTPC9a+4YX+8oO1
# NeflU15YFnWnrhJQbO40lfNGQH9/xwRNS+YhqAX9YUf2SHkaL7t5sZ68O7XAvTrj
# OvT+fpg+Zg6OfYXyZuE9C8rsm4DkDmm55ZzdOuoRbBPg77LIgMNxT1MzMLdrYLoQ
# +gJOqXGLmKjo+zO9yJWGsexY8gv101zeVPVprcdcol8DkOkuRlaTLLpqwmteSQqk
# VSc6SILYkRVVuQqxq9xZiUnZaEHnDOy1jTPzZSUYn3gBANqfORO07a/RAiNyY+HS
# 33AFC3guSVCJOGMu1JyY3qFDOcgEjfZR5KhbrJ74l4MKRllWjnMlL3JFJ5c8Gd6F
# pfWDlq9NnI3U0B59Id1lCHMvWG2nGwvAQD8NJT3ofEjL7vD0qDCVACMsrRaxUKs8
# 7WCeZ3i0aj40AClLmVeO6Sye
# SIG # End signature block
