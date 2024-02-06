Import-Module VMware.VimAutomation.Core
$ESXI = Read-Host "vSphere vCenter server to connect to"
Connect-VIServer $ESXI
Write-Host ""
Write-Host "Collecting virtual machines list..."
Write-Host ""
$VMArrayList = Get-VM
foreach ($VM in $VMArrayList)
{
$VMView = Get-View -ViewType VirtualMachine -Filter @{"Name" = "$VM"}
if ($VMView.TriggeredAlarmState.Overallstatus -eq "red")
{
foreach ($VMAlarm in $VMView.TriggeredAlarmState)
{
$VMAlarmType = $VMView.TriggeredAlarmState.Alarm
$VMAlarmTime = $VMView.TriggeredAlarmState.Time
$VMAlarm = Get-AlarmDefinition -id $VMAlarmType
Write-Host "Virtual Machine: $VM"
Write-Host "Alarm: $VMAlarm"
Write-Host "Time: $VMAlarmTime"
Write-Host ""
}
}
}
Write-Host "Done!"
Write-Host "Now collecting physical hosts list..."
Write-Host ""
$HostArrayList = Get-VMHost
foreach ($HostSys in $HostArrayList)
{
$HostView = Get-View -ViewType HostSystem -Filter @{"Name" = "$Host"}
if ($HostView.TriggeredAlarmState.Overallstatus -eq "red")
{
foreach ($HostAlarm in $HostView.TriggeredAlarmState)
{
$HostAlarmType = $HostView.TriggeredAlarmState.Alarm
$HostAlarmTime = $HostView.TriggeredAlarmState.Time
$HostAlarm = Get-AlarmDefinition -id $HostAlarmType
Write-Host "Host: $Hostsys"
Write-Host "Alarm: $HostAlarm"
Write-Host "Time: $HostAlarmTime"
Write-Host ""
}
}
}
Write-Host "Done!"