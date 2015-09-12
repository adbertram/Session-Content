'This script accompanies the book Windows Management Instrumentation
'by Matthew Lavy and Ashley Meggitt (New Riders, 2001)
'The code is copyright 2001, Matthew Lavy & Ashley Meggitt
'You are free to use and modify the script at will
'provided you understand that all code here is made available AS IS, with
'NO WARRANTY WHATSOEVER. The authors take NO RESPONSIBILITY AT ALL for
'problems that result from the use of this script or any part thereof

'showproperties.vbs - display the names and values
'of all the properties of an object whose object path
'is given as a command-line parameter. Warning: this
'script does not like objects some of whose properties
'contain embedded objects!
Option Explicit
On Error Resume Next
Dim refWMI
Dim refObject
Dim refProperty
Dim theValue 'for property values (type is unknown)

'first check cmd-line for sanity
If WScript.Arguments.Count <> 1 Then
	WScript.Echo "Usage: showproperties.vbs <objpath>"
	WScript.Quit
End If

'connect to WMI
Set refWMI = GetObject("winMgmts:")
If Err <> 0 Then
	WScript.Echo "Could not connect to WMI"
	WScript.Quit
End If

'attempt to retrieve specified object
Set refObject = refWMI.Get(WScript.Arguments(0))
If Err <> 0 Then
	WScript.Echo "Could not retrieve object."
	WScript.Quit
End If

'iterate through property collection
'for arrays, print the name and value list
'for nonarrays, print "name: value"
For Each refProperty in refObject.Properties_
	If refProperty.IsArray Then
		WScript.Echo refProperty.Name & ":-"
		For Each theValue In refProperty.Value
			WScript.Echo " " & theValue
		Next
	Else
		WScript.Echo refProperty.Name & ": " & _
			refProperty.Value
	End If
Next

Set refObject = Nothing
Set refWMI = Nothing