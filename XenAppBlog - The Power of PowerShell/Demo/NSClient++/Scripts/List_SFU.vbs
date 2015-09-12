On Error Resume Next

strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\sfuadmin")

Set colItems = objWMIService.ExecQuery _
    ("Select * from version_info")

For Each objItem in colItems
    Wscript.Echo "Current release: " & objItem.curRel
    Wscript.Echo "Key Name: " & objItem.KeyName
    Wscript.Echo "PUD: " & objItem.pid
    Wscript.Echo "Version: " & objItem.Version
    Wscript.Echo
Next
