' List Service Status


strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colRunningServices = objWMIService.ExecQuery("Select * from Win32_Service")

Wscript.Echo "Service StartMode State"
For Each objService in colRunningServices 
	Wscript.Echo objService.Name & " " & objService.StartMode & " " & objService.State
Next
