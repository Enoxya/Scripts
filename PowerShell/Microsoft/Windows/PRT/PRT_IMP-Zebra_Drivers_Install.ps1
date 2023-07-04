Pnputil /add-driver \\chb.ts1.local\fichiers\MSI\MV\ZD5-1-16-7398\ZBRN\ZBRN.inf
Add-PrinterDriver -Name "ZDesigner ZD220-203dpi ZPL" -InfPath "C:\Windows\System32\DriverStore\FileRepository\zbrn.inf_amd64_c37ce3680341416f\ZBRN.inf"
Add-PrinterPort -Name "PortZebra" -PrinterHostAddress "10.13.38.102"
Add-Printer -DriverName "ZDesigner ZD220-203dpi ZPL" -Name "ZebraSurInfoTM" -PortName "PortZebra"