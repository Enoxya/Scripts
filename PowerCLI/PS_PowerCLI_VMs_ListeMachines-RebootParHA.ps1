﻿Get-Cluster "Cluster" | Get-VM | Get-VIEvent | where {$_.FullFormattedMessage -match "vSphere HA restarted virtual machine"} | select ObjectName,@{N="IP addr";E={(Get-view -Id $_.Vm.Vm).Guest.IpAddress}},CreatedTime,FullFormattedMessage