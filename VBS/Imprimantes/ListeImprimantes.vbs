strComputer = "."
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colInstalledPrinters = objWMIService.ExecQuery ("Select * from Win32_Printer")

Const ForWriting = 2
Dim fso, f   
   
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.OpenTextFile("\\ser11329\c$\Documents and Settings\Administrateur.CH-VALENCE\Bureau\Liste_Imp.txt", ForWriting,true)

For Each objPrinter in colInstalledPrinters

Select case ObjPrinter.PrinterState
Case 0 : s = " prête"
Case 1 : s = " en pause"
Case Else : s = cStr (ObjPrinter.PrinterState)
End Select

   f.write("" & ObjPrinter.Name & " : " & s & " Localisation : " & ObjPrinter.Location & VbCrLf & " ")
Next
