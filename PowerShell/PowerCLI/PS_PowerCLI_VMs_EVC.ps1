Get-VM | Select-Object Name,HardwareVersion,
@{Name='VM_EVC_Mode';Expression={$_.ExtensionData.Runtime.MinRequiredEVCModeKey}},
@{Name='Cluster_Name';Expression={$_.VMHost.Parent}},
@{Name='Cluster_EVC_Mode';Expression={$_.VMHost.Parent.EVCMode}} | Format-Table # ConvertTo-CSV