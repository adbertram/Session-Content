strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colQuickFixes = objWMIService.ExecQuery _
    ("Select * from Win32_QuickFixEngineering")

Wscript.Echo "HotFixID Install Date" 
For Each objQuickFix in colQuickFixes
    if (InStr(objQuickFix.HotFixID,"File 1")) then
    else
        Wscript.Echo objQuickFix.HotFixID & " " & objQuickFix.InstalledOn
    end if
Next
	
