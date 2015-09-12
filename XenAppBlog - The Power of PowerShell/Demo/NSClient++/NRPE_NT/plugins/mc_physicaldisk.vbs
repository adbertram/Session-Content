'==========================================================================
'
' VBScript Source File -- Created with SAPIEN Technologies PrimalScript 3.1
'
' NAME: mc_physicaldisk.vbs
'
' AUTHOR: Eric Velkly , Morefield Communications, Inc.
' DATE  : 8/11/2005
'
' COMMENT: 
'
'==========================================================================
strMsg = ""

On Error Resume Next
Set objWbemLocator = CreateObject _
	("WbemScripting.SWbemLocator")
if Err.Number Then
	WScript.Echo vbCrLf & "Error # " & _
	             " " & Err.Description
End If
On Error GoTo 0	
	
On Error Resume Next
Select Case WScript.Arguments.Count
	Case 1
		strComputer = Wscript.Arguments(0)
		Set wbemServices = objWbemLocator.ConnectServer _ 
		      (strComputer,"Root\CIMV2")
		
	Case 3
		strComputer = Wscript.Arguments(0)
		strUsername = Wscript.Arguments(1)
		strPassword = Wscript.Arguments(2)
		Set wbemServices = objWbemLocator.ConnectServer _ 
      			(strComputer,"Root\CIMV2",strUsername,strPassword)

	Case Else
		strMsg = "Error # in parameters passed"
		WScript.Echo strMsg
		WScript.Quit(0)
	
End Select
' Display error number and description if applicable
if Err.Number Then
	WScript.Echo vbCrLf & "Error # " & _
	             " " & Err.Description
End If

On Error GoTo 0

On Error Resume Next

strMsg = "Name" & vbTab & "Current Disk Queue Length" & vbTab & "Reads/sec" & vbTab & "Writes/sec" & vbTab & "% Disk Time" & VbCrLf

Set cItems = wbemServices.ExecQuery("SELECT * FROM Win32_PerfRawData_PerfDisk_PhysicalDisk")
For Each oItem In cItems
	strMsg = strMsg & replace(oItem.Name," ","_") & vbTab & oItem.CurrentDiskQueueLength & vbTab & oItem.DiskReadsPerSec & vbTab & oItem.DiskWritesPerSec & vbTab & oItem.PercentIdleTime & VbCrLf
Next

WScript.Echo strMsg