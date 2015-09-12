' OperatingSystem.vbs
' Purpose VBScript to document your Operating System
' Author Guy Thomas http://computerperformance.co.uk/
' Version 1.4 - November 2005
' -------------------------------------------------------' 
Option Explicit
Dim objWMIService, objItem, colItems
Dim strComputer, strList
Dim strCols
Dim strSelect
Dim strSQL

'On Error Resume Next
strComputer = "."
strCols = "CSName"
strSelect = "Select " & strCols & " from Win32_OperatingSystem"

' WMI Connection to the object in the CIM namespace
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

' WMI Query to the Win32_OperatingSystem
WScript.Echo "strings:" & strCols & " as data " & strSelect
Set colItems = objWMIService.ExecQuery (strSelect)
'Set colItems = objWMIService.ExecQuery ("Select CSName from Win32_OperatingSystem")

' For Each... In Loop (Next at the very end)
For Each objItem in colItems
WScript.Echo "Machine Name: " & objItem.CSName
Next
WSCript.Quit

' End of WMI Win32_OperatingSystem VBScript

