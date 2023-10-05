Get-VM | Select-Object Name, @{N='DRSGroup';E={$script:group = Get-DrsClusterGroup -VM $_; $script:group.Name}}, @{N='GroupType';E={$script:group.GroupType}}


