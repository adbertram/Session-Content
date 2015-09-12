Option Explicit
Dim objWMIService, strComputer
Dim objItem, colItems, property
Dim strSelect
dim strParams
dim strParamsArray
' Get our parameters
strParams = WScript.Arguments(0)
strParamsArray = Split(strParams, ",")
strComputer = "."
strSelect = "Select " & strParams & " from Win32_OperatingSystem"

WScript.Echo strSelect

' WMI Connection to the object in the CIM namespace
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

' WMI Query
Set colItems = objWMIService.ExecQuery(strSelect)

' Loop through the results
For Each objItem in colItems
 ' Loop through the properties of each returned item
 WScript.Echo "Pass"
 For Each property in objItem.Properties_
  If property.Name = "Name" Then
   WScript.Echo "found name"
  Else 
   ' Output Result
   'WScript.Echo property.Name & ": " & property.Value
   'WScript.Echo property.Value
   If property.IsArray Then
    WScript.Echo property.Name & ":-"
    For Each theValue In property.Value
     WScript.Echo " " & theValue
    Next
   Else
    WScript.Echo property.Name & ": " & _
 		property.Value
   End If
  End IF
 Next
Next

' Exit
WScript.Quit
