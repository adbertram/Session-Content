Dim wshShell, wshExec, strResult

Set wshShell = CreateObject("WScript.Shell")

strObjekt = """systeminfo.exe"""
strCmdLine = wshShell.ExpandEnvironmentStrings("%COMSPEC%")
strCmdLine = strCmdLine & " " &strObjekt

Set wshExec = wshShell.Exec(strCmdLine)

'WScript.Echo " " & wshExec

Do While Not(wshExec.StdOut.AtEndOfStream)
strResult = wshExec.StdOut.ReadLine
WScript.Echo strResult
Loop

'WScript.Echo "There were " & strResult & " processes found of " & _
'strObjekt & "."
