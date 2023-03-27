$StopWatch = [System.Diagnostics.StopWatch]::StartNew()

 

Function Test-Command ($Command)

{

    Try

    {

        Get-command $command -ErrorAction Stop

        Return $True

    }

    Catch [System.SystemException]

    {

        Return $False

    }

}

 

IF (Test-Command "Get-Mailbox") {Write-Host "Exchange cmdlets already present"}

Else {

    $CallEMS = ". '$env:ExchangeInstallPath\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto -ClientApplication:ManagementShell "

    Invoke-Expression $CallEMS


$stopwatch.Stop()
$msg = "`n`nThe script took $([math]::round($($StopWatch.Elapsed.TotalSeconds),2)) seconds to execute..."
Write-Host $msg
$msg = $null
$StopWatch = $null

}