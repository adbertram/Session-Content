' This code prints system information similar to the systeminfo command.
' ---------------------------------------------------------------
' From the book "Windows Server Cookbook" by Robbie Allen
' ISBN: 0-596-00633-0
' ---------------------------------------------------------------
Dim strObj

' Make sure there are at least 1 arguments.  
  
If (Wscript.Arguments.Count < 1) Then  
  
Wscript.Echo "Required Parameter missing"  
  
Wscript.Quit  
  
End If  
  
' Retrieve the first argument (index 0).  
  
strObj = Wscript.Arguments(0)  
  
' ------ SCRIPT CONFIGURATION ------
strComputer = "."   ' e.g. rallen-srv01
' ------ END CONFIGURATION ---------
set dicProductType = CreateObject("Scripting.Dictionary")
dicProductType.Add 1, "Workstation"
dicProductType.Add 2, "Domain Controller"
dicProductType.Add 3, "Standalone Server"

'set objWMIDateTime = CreateObject("WbemScripting.SWbemDateTime")

set objWMI = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
set colOS = objWMI.InstancesOf("Win32_OperatingSystem")
for each objOS in colOS
 select case strObj
  case "Host Name:"
   Wscript.Echo objOS.CSName
  case "OS Name:"
   Wscript.Echo objOS.Caption
  case "OS Version:"
   Wscript.Echo objOS.Version & " Build " & objOS.BuildNumber
  case "OS Manufacturer:"
   Wscript.Echo objOS.Manufacturer
  case "OS Configuration:"
   Wscript.Echo  dicProductType.Item(objOS.ProductType)
  case "OS Build Type:"
   Wscript.Echo  objOS.BuildType
  case "Registered Owner:" 
   Wscript.Echo objOS.RegisteredUser
  case "Registered Organization:" 
   Wscript.Echo objOS.Organization
  case "Product ID:" 
   Wscript.Echo objOS.SerialNumber
  case "Original Install Date:" 
   Wscript.Echo "Original Install Date: " & WMIDateStringToDate(objOS.InstallDate)
   'objWMIDateTime.Value = objOS.InstallDate
   'Wscript.Echo objWMIDateTime.GetVarDate
  case  "System Up Time:"
   Wscript.Echo "System Up Time:" & WMIDateStringToDate(objOS.LastBootUpTime)
   'objWMIDateTime.Value = objOS.LastBootUpTime
   'Wscript.Echo objWMIDateTime.GetVarDate
  case "Windows Directory:" 
   Wscript.Echo objOS.WindowsDirectory
  case "System Directory:" 
   Wscript.Echo objOS.SystemDirectory
  case "BootDevice:" 
   Wscript.Echo objOS.BootDevice
  case "System Locale:" 
   Wscript.Echo objOS.Locale
  case "Time Zone:" 
   Wscript.Echo "GMT" & objOS.CurrentTimezone
  case "Total Physical Memory:"
   Wscript.Echo round(objOS.TotalVisibleMemorySize / 1024) & " MB"
  case "Available Physical Memory:"
   Wscript.Echo round(objOS.FreePhysicalMemory / 1024) & " MB"
  case "Page File: Max Size:"
   Wscript.Echo round(objOS.TotalVirtualMemorySize / 1024) & " MB"
  case "Page File: Available:"
   Wscript.Echo round(objOS.FreeVirtualMemory / 1024) & " MB"
' case Else
'  Wscript.Echo "Object Selection:" & strObj & "Unknown"
 end select
next

set colCS = objWMI.InstancesOf("Win32_ComputerSystem")
for each objCS in colCS
 select case strObj
  case "System Manufacturer:" 
   Wscript.Echo objCS.Manufacturer
  case "System Model:"
   Wscript.Echo objCS.Model
  case "System Type:" 
   Wscript.Echo objCS.SystemType
  case "Domain:"
   WScript.Echo objCS.Domain
  case "Processor(s):" 
   Wscript.Echo objCS.NumberofProcessors & " Processor(s) Installed"
 end select
next

if (strObj = "Processor(s):") then
intCount = 0
set colProcs = objWMI.InstancesOf("Win32_Processor")
for each objProc in colProcs
   intCount = intCount + 1
   Wscript.Echo vbTab & "[" & intcount & "]: " & _
                objProc.Caption & " ~" & objProc.MaxClockSpeed & "Mhz"
next
end if

set colBIOS = objWMI.InstancesOf("Win32_BIOS")
for each objBIOS in colBIOS 
 select case strObj
  case "BIOS Version:" 
   Wscript.Echo objBIOS.Version
 end select
next

Function WMIDateStringToDate(dtmInstallDate)
    WMIDateStringToDate = CDate(Mid(dtmInstallDate, 5,2 ) & "/" & _
        Mid(dtmInstallDate,7,2) & "/" & left(dtmInstallDate, 4) _
        & " " & Mid(dtmInstallDate, 9, 2) & ":" & _
        Mid(dtmInstallDate, 11, 2) & ":" & Mid(dtmInstallDate, 13, 2))
End Function
