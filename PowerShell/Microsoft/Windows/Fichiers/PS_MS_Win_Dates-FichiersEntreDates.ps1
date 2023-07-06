$debut = Get-Date -Day 12 -Month 11 -Year 2019 -Hour 08 -Minute 00 -Second 00
$fin = Get-Date -Day 12 -Month 11 -Year 2019 -Hour 12 -Minute 00 -Second 00

$files = Get-Childitem $dir -recurse | Where-Object {($_.LastWriteTime.Date -ge $debut -and $_.LastWriteTime.Date -le $fin)}
Write-Host $files