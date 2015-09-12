strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
 & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
 
Set colOSes = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
For Each objOS in colOSes
  Wscript.Echo "Computer Name: " & objOS.CSName
  Wscript.Echo "Caption: " & objOS.Caption 'Name
  Wscript.Echo "Version: " & objOS.Version 'Version & build
  Wscript.Echo "Build Number: " & objOS.BuildNumber 'Build
  Wscript.Echo "Build Type: " & objOS.BuildType
  Wscript.Echo "OS Type: " & objOS.OSType
  Wscript.Echo "Other Type Description: " & objOS.OtherTypeDescription
  WScript.Echo "Service Pack: " & objOS.ServicePackMajorVersion & "." & _
   objOS.ServicePackMinorVersion
Next

