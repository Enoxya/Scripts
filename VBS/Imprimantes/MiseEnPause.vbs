strComputer = "."
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colInstalledPrinters = objWMIService.ExecQuery _
("Select * from Win32_Printer")

For Each objPrinter in colInstalledPrinters 
ObjPrinter.Pause
Next