' OperatingSystem.vbs
' Purpose VBScript to document your Operating System
' Author Guy Thomas http://computerperformance.co.uk/
' Version 1.4 - November 2005
' -------------------------------------------------------' 
Option Explicit
Dim objWMIService, objItem, colItems
Dim strComputer, strList

On Error Resume Next
strComputer = "."

' WMI Connection to the object in the CIM namespace
Set objWMIService = GetObject("winmgmts:\\" _
& strComputer & "\root\cimv2")

' WMI Query to the Win32_OperatingSystem
Set colItems = objWMIService.ExecQuery _
("Select * from Win32_OperatingSystem")

' For Each... In Loop (Next at the very end)
For Each objItem in colItems
WScript.Echo "Machine Name: " & objItem.CSName & VbCr & _ 
"===================================" & vbCr & _ 
"Processor: " & objItem.Description & VbCr & _ 
"Manufacturer: " & objItem.Manufacturer & VbCr & _ 
"Operating System: " & objItem.Caption & VbCr & _ 
"Version: " & objItem.Version & VbCr & _
"Service Pack: " & objItem.CSDVersion & VbCr & _ 
"CodeSet: " & objItem.CodeSet & VbCr & _ 
"CountryCode: " & objItem.CountryCode & VbCr & _ 
"OSLanguage: " & objItem.OSLanguage & VbCr & _ 
"CurrentTimeZone: " & objItem.CurrentTimeZone & VbCr & _ 
"Locale: " & objItem.Locale & VbCr & _ 
"SerialNumber: " & objItem.SerialNumber & VbCr & _ 
"SystemDrive: " & objItem.SystemDrive & VbCr & _ 
"WindowsDirectory: " & objItem.WindowsDirectory & VbCr & _ 
""
Next
WSCript.Quit

' End of WMI Win32_OperatingSystem VBScript


