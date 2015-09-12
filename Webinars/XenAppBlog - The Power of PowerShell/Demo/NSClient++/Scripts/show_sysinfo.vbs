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

'set objWMIDateTime = CreateObject("WbemScripting.SWbemDateTime")

set objWMI = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
set colOS = objWMI.InstancesOf("Win32_OperatingSystem")
for each objOS in colOS
   'Wscript.Echo "Host Name: " & objOS.CSName
   Wscript.Echo "OS Name: " & objOS.Caption
   Wscript.Echo "OS Version: " & objOS.Version & " Build " & objOS.BuildNumber
   Wscript.Echo "OS Manufacturer: " & objOS.Manufacturer
   Wscript.Echo "OS Configuration: " & dicProductType.Item(objOS.ProductType)
   Wscript.Echo "OS Build Type: " & objOS.BuildType
   Wscript.Echo "Registered Owner: " & objOS.RegisteredUser
   Wscript.Echo "Registered Organization: " & objOS.Organization
   Wscript.Echo "Product ID: " & objOS.SerialNumber
   
   Wscript.Echo "Original Install Date: " & WMIDateStringToDate(objOS.InstallDate)
   
   'objWMIDateTime.Value = objOS.InstallDate
   'Wscript.Echo "Original Install Date: " & objWMIDateTime.GetVarDate
   'objWMIDateTime.Value = objOS.LastBootUpTime
   'Wscript.Echo "System Boot Date/Time: " & objWMIDateTime.GetVarDate
   Wscript.Echo "Windows Directory: " & objOS.WindowsDirectory
   Wscript.Echo "System Directory: " & objOS.SystemDirectory
   Wscript.Echo "BootDevice: " & objOS.BootDevice
   Wscript.Echo "System Locale: " & objOS.Locale
   Wscript.Echo "Time Zone: " & "GMT" & objOS.CurrentTimezone
   Wscript.Echo "Total Physical Memory: " & _ 
                round(objOS.TotalVisibleMemorySize / 1024) & " MB"
   Wscript.Echo "Available Physical Memory: " & _
                 round(objOS.FreePhysicalMemory / 1024) & " MB"
   Wscript.Echo "Page File: Max Size: " & _
                 round(objOS.TotalVirtualMemorySize / 1024) & " MB"
   Wscript.Echo "Page File: Available: " & _
                 round(objOS.FreeVirtualMemory / 1024) & " MB"
next

set colCS = objWMI.InstancesOf("Win32_ComputerSystem")
for each objCS in colCS
   Wscript.Echo "System Manufacturer: " & objCS.Manufacturer
   Wscript.Echo "System Model: " & objCS.Model
   Wscript.Echo "System Type: " & objCS.SystemType
   WScript.Echo "Domain: " & objCS.Domain
   'Wscript.Echo "Processor(s): " & objCS.NumberofProcessors & _
   '            " Processor(s) Installed."
next

'intCount = 0
'set colProcs = objWMI.InstancesOf("Win32_Processor")
'for each objProc in colProcs
'   intCount = intCount + 1
'   Wscript.Echo vbTab & "[" & intcount & "]: " & _
'                objProc.Caption & " ~" & objProc.MaxClockSpeed & "Mhz"
'next

set colBIOS = objWMI.InstancesOf("Win32_BIOS")
for each objBIOS in colBIOS 
   Wscript.Echo "BIOS Version: " & objBIOS.Version
next

Function WMIDateStringToDate(dtmInstallDate)
    WMIDateStringToDate = CDate(Mid(dtmInstallDate, 5,2 ) & "/" & _
        Mid(dtmInstallDate,7,2) & "/" & left(dtmInstallDate, 4) _
        & " " & Mid(dtmInstallDate, 9, 2) & ":" & _
        Mid(dtmInstallDate, 11, 2) & ":" & Mid(dtmInstallDate, 13, 2))
End Function