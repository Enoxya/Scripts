function New-SplitFiles {
    [CmdletBinding()]
    Param( 
        [Parameter(Mandatory=$False)]
        [string]$DirectoryContainingFiles = $(Read-Host -Prompt "Please enter the full path to the directory that contains the files you need to split."),

        [Parameter(Mandatory=$False)]
        [string]$OutputDirectory = $DirectoryContainingFiles,

        [Parameter(Mandatory=$False)]
        [int]$LineNumberToSplitOn,

        [Parameter(Mandatory=$False)]
        [switch]$Recurse

    )

    ### BEGIN Parameter Validation ###

    if (!$(Test-Path $DirectoryContainingFiles)) {
        Write-Error "The path $DirectoryContainingFiles was not found! Halting!"
        $global:FunctionResult = "1"
        return
    }
    if ($(Get-Item $DirectoryContainingFiles) -isnot [System.IO.DirectoryInfo]) {
        Write-Error "The path $DirectoryContainingFiles is not a directory! Halting!"
        $global:FunctionResult = "1"
        return
    }
    if ($(Get-Item $OutputDirectory) -isnot [System.IO.DirectoryInfo]) {
        Write-Error "The path $OutputDirectory is not a directory! Halting!"
        $global:FunctionResult = "1"
        return
    }

    ### END Parameter Validation ###

    ### BEGIN MAIN Body ###
    
    if ($Recurse) {
        $FilesInDirectory = Get-ChildItem -Recurse $DirectoryContainingFiles | Where-Object {$_.PSIsContainer -eq $false}
    }
    else {
        $FilesInDirectory = Get-ChildItem $DirectoryContainingFiles | Where-Object {$_.PSIsContainer -eq $false}
    }

    $FilesCreatedColection = @()
    foreach ($file in $FilesInDirectory) {
        $FileContent = Get-Content $(Get-Item $file.FullName)
        $LineCount = $FileContent.Count
        # Round Up Total Number of Files Needed...
        $TotalNumberOfSplitFiles = [math]::ceiling($($LineCount / $LineNumberToSplitOn))

        if ($TotalNumberOfSplitFiles -gt 1) {
            for ($i=1; $i -lt $($TotalNumberOfSplitFiles+1); $i++) {
                $StartingLine = $LineNumberToSplitOn * $($i-1)
                if ($LineCount -lt $($LineNumberToSplitOn * $i)) {
                    $EndingLine = $LineCount
                }
                if ($LineCount -gt $($LineNumberToSplitOn * $i)) {
                    $EndingLine = $LineNumberToSplitOn * $i
                }

                New-Variable -Name "$($file.BaseName)_Part$i" -Value $(
                    $FileContent[$StartingLine..$EndingLine]
                ) -Force

                $(Get-Variable -Name "$($file.BaseName)_Part$i" -ValueOnly) | Out-File "$DirectoryContainingFiles\$($file.BaseName)_Part$i$($file.Extension)"

                $FilesCreatedCollection +=, $(Get-Variable -Name "$($file.BaseName)_Part$i" -ValueOnly)
            }
        }
    }
}