#VDéfinition des variables
$myVMHost = Get-VMHost "kiev.chb.ts1.local"

##Hosts
#Récupérer la liste des hôtes ESX d'un Cluster :
    Get-VMHost

##vSwitches
#Récupérer les vSwitches d'un hôte ESX
    Get-VMHost -Name $myVMHost | Get-VirtualSwitch

#Récupérer les infos d'un seul vSwitch d'un hôte ESX
    Get-VMHost -Name $myVMHost | Get-VirtualSwitch -Name vSwitch0

#Autres
    #Retrieve the virtual switch used by the virtual machine named VM :
        Get-VirtualSwitch -VM VM
    #Retrieve all virtual switches in the specified datacenter :
        Get-Datacenter -Name "MyDatacenter" | Get-VirtualSwitch
    #Retrieves all virtual switches named "vSwitch0" :
        Get-VirtualSwitch -Name "vSwitch0"


##vmnic
$myVMHostNetworkAdapter = Get-VMhost $myVMHost | Get-VMHostNetworkAdapter -Physical -Name vmnic2
#Récupérer la liste des adaptateurs physiques d'un hôte ESX :
    Get-VMhost $myVMHost | Get-VMHostNetworkAdapter -Physical