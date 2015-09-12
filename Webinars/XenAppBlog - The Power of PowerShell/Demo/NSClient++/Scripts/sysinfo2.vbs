Dim objNetwork
Dim objShell
DIM cmd
Dim cmdout

Set objNetwork = Wscript.CreateObject("Wscript.Network")
Set objShell = WScript.CreateObject("WScript.Shell")

Set cmdout = objShell.Run "systeminfo.exe"

