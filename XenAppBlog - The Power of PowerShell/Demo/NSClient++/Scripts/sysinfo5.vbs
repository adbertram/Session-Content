' This code prints system information similar to the systeminfo command.
' ---------------------------------------------------------------
' From the book "Windows Server Cookbook" by Robbie Allen
' ISBN: 0-596-00633-0
' ---------------------------------------------------------------

' ------ SCRIPT CONFIGURATION ------
strComputer = "."   ' e.g. rallen-srv01
' ------ END CONFIGURATION ---------

set dicProductType = CreateObject("Scripting.Dictionary")
dicProductType.Add 1, "Workstation"
dicProductType.Add 2, "Domain Controller"
dicProductType.Add 3, "Standalone Server"

set objWMIDateTime = CreateObject("WbemScripting.SWbemDateTime")

set objWMI = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
set colOS = objWMI.InstancesOf("Win32_OperatingSystem")
Dim label
set label = "CSName"
for each objOS in colOS
   Wscript.Echo "OS Name: " & objOS.Caption
next
