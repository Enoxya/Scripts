function Get-FolderSize {
[CmdletBinding()]
Param (
[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
$Path
)
if ( (Test-Path $Path) -and (Get-Item $Path).PSIsContainer ) {
$Measure = Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
$Sum = '{0:N2}' -f ($Measure.Sum / 1Gb)
[PSCustomObject]@{
"Path" = $Path
"Size($Gb)" = $Sum
}
}
}

To use the function, simply run the command with the folder path as an argument:

Get-FolderSize ('C:\PS')

Et en remote : 
Invoke-Command -ComputerName hq-srv01 -ScriptBlock ${Function:Get-FolderSize} –ArgumentList 'C:\PS'