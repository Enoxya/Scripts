Install-Module Unity-Powershell -Scope CurrentUser


Import-Module Unity-Powershell
        <#Welcome to Unity-Powershell!

 Log in to an EMC Unity:  Connect-Unity
 To find out what commands are available, type:  Get-Command -Module Unity-Powershell
 To get help for a specific command, type: get-help [verb]-Unity[noun] (Get-Help Get-UnityVMwareLUN)
 To get extended help for a specific command, type: get-help [verb]-Unity[noun] -full (Get-Help Get-UnityVMwareLUN -Full)
 Documentation available at http://unity-powershell.readthedocs.io/en/latest/
 Issues Tracker available at https://github.com/equelin/Unity-Powershell/issues

 Licensed under the MIT License. (C) Copyright 2016-2017 Erwan Quelin and the community.
 #>


 Get-Command -Module Unity-Powershell

<#CommandType     Name                                               Version    Source                                                                           
-----------     ----                                               -------    ------                                                                           
Function        Connect-Unity                                      0.16.2     Unity-Powershell                                                                 
Function        Disable-UnityFastCache                             0.16.2     Unity-Powershell                                                                 
Function        Disconnect-Unity                                   0.16.2     Unity-Powershell                                                                 
Function        Enable-UnityFastCache                              0.16.2     Unity-Powershell                                                                 
Function        Get-UnityAlert                                     0.16.2     Unity-Powershell                                                                 
Function        Get-UnityAlertConfig                               0.16.2     Unity-Powershell                                                                 
Function        Get-UnityBasicSystemInfo                           0.16.2     Unity-Powershell                                                                 
Function        Get-UnityBattery                                   0.16.2     Unity-Powershell                                                                 
Function        Get-UnityCIFSServer                                0.16.2     Unity-Powershell                                                                 
Function        Get-UnityCIFSShare                                 0.16.2     Unity-Powershell                                                                 
Function        Get-UnityDae                                       0.16.2     Unity-Powershell                                                                 
Function        Get-UnityDataCollectionResult                      0.16.2     Unity-Powershell ... 
#>


Connect-Unity -Server 10.64.10.24

<#Server      User  Name     Model      SerialNumber  
------      ----  ----     -----      ------------  
10.64.10.24 admin UNITY-GA Unity 350F CKM00190900306
#>


Get-UnityNTPServer

<#Id Addresses    
-- ---------    
0  {10.11.15.22}
#>