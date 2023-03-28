function Get-Time {
    # .SYNOPSIS
    # Get-Time is an advanced Powershell function. It obtains the local system time of a scope of computers or the system time of particular remote computers.

    # .DESCRIPTION
    # Uses the buil-in function Get-Date. Define scope or computer name.

    # .PARAMETER
    # Scope
    # Define the scope. Possible values: "AllServer", "DomainController", "Computers", "Ordinateur"

    # .PARAMETER
    # Computer
    # Provide computer name of remote computer.

    # .EXAMPLE
    # Get-Time -Scope AllServer

    # .NOTES
    # Author: Patrick Gruenauer, MVP PowerShell
    # Web: https://sid-500.com

    # Si besoin d'activer le PS Remote :
    # Allez dans le repertoire ou se troucve PsExec puis
    # .\PsExec.exe \\ComputerName -s PowerShell Enable-PSRemoting -Force

    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$false, HelpMessage='Enter the following values: AllServers, DomainControllers, AllComputers, Computer')]
        [ValidateSet("AllServers", "DomainControllers", "AllComputers", "Computer")]
        $Scope,

        [parameter(Mandatory=$false)]
        $Computer="$env:Computername"
    )

    $server=(Get-ADComputer -Filter 'operatingsystem -like "*server*"-and enabled -eq "true"').Name
    $dc=Get-ADDomainController -Filter * | Select-Object -ExpandProperty Name
    $computers=(Get-ADComputer -Filter 'operatingsystem -like "Windows 10*" -and enabled -eq "true"').Name

    $result=@()

    switch ($Scope) {
        'AllServers' {
            foreach ($s in $server) {
                $t=Invoke-Command -ComputerName $s {Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime} -ErrorAction SilentlyContinue
                $result +=New-Object -TypeName PSCustomObject -Property ([ordered]@{
                    'Server'= $s
                    'Time' = $t
                    'Local Time' = Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime
                })
            }
        }

        'DomainControllers' {
            foreach ($d in $dc) {
                $t=Invoke-Command -ComputerName $d {Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime} -ErrorAction SilentlyContinue
                $result +=New-Object -TypeName PSCustomObject -Property ([ordered]@{
                    'Server'= $d
                    'Time' = $t
                    'Local Time' = Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime
                })
            }
        }

        'AllComputers' {
            foreach ($c in $computers) {
                    $t=Invoke-Command -ComputerName $c {Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime} -ErrorAction SilentlyContinue
                    $result +=New-Object -TypeName PSCustomObject -Property ([ordered]@{
                        'Ordinateur'= $c
                        'Time' = $t
                        'Local Time' = Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime
                    })
            }
        }
        #Cette partie a été ajoutée par moi
        'Computer' {
            $computer = Read-Host  -Prompt "Entrer le nom de l'ordinateur "
            If ($computer -ne "$env:computername") {
                Try {
                    $t=Invoke-Command -ComputerName $computer {Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime} -ErrorAction Stop
                    $result +=New-Object -TypeName PSCustomObject -Property ([ordered]@{
                        'Computer'= $computer
                        'Time' = $t
                        'Local Time' = Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime
                    })
                }
                Catch {
                    $result+=New-Object -TypeName PSCustomObject -Property ([ordered]@{
                        'Computer'=$computer
                        'Time'='Computer could not be reached'
                    })
                }
            }
            else {
                #If (($computer -eq "$env:computername") -and ($scope -eq $null)) {
                Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime
            }

            #$t=Invoke-Command -ComputerName $ordinateur {Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime} -ErrorAction SilentlyContinue
            #$result +=New-Object -TypeName PSCustomObject -Property ([ordered]@{
            #    'Ordinateur'= $ordinateur
            #    'Time' = $t
            #    'Local Time' = Get-Time
            #})
        }
    #Avant il y avait ça :
#    If ($Computer -ne "$env:computername") {
#        Try {
#            $t=Invoke-Command -ComputerName $Computer {Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime} -ErrorAction Stop
#            $result +=New-Object -TypeName PSObject -Property ([ordered]@{
#                'Computer'= $Computer
#                'Time' = $t
#                'Local Time' = Get-Time
#            })
#        }
#        Catch {
#            $result+=New-Object -TypeName PSObject -Property ([ordered]@{
#                'Computer'=$Computer
#                'Time'='Computer could not be reached'
#            })
#        }
#    }

#    If (($computer -eq "$env:computername") -and ($scope -eq $null)) {
#        Get-Date -Displayhint time | Select-Object -ExpandProperty DateTime
#    }
        
    }

    Write-Output $result
}