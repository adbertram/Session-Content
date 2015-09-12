Option Explicit
Const intOK = 0
Const intWarning = 1
Const intCritical = 2
Const intError = 3
Const intUnknown = 3

Dim argcountcommand
Dim tempcount
Dim arg(20)
Dim strCommandName
Dim strDescription
Dim strNameSpace
Dim strComputer
Dim strVertical
Dim strDisp
Dim strClass
Dim strProp
Dim strFormat
Dim strSQL
Dim objWMIDateTime
Dim objWMIService
Dim colItems
Dim objItem
Dim property
Dim strPropArray
Dim strFieldSep
Dim strValue
Dim strResult
Dim boolVert
Dim boolName
Dim boolFormat
'-------------------------------------------------------------------------------------------------
'Function Name:     f_Help.
'Descripton:        Display help of command include : Description, Arguments, Examples
'Input:				No.
'Output:			No.
'-------------------------------------------------------------------------------------------------
	Function f_Help()
	
		Dim str
		str="query_wmi:"&vbCrlF
  		str=str&"cscript query_wmi.vbs -disp [vert,name] -class classname -prop property"&vbCrlF
  		str=str&vbCrlF
  		str=str&"-h [--help]                 Help."&vbCrlF
  		str=str&"-disp [vert|name]           Display Results Vertical/Names"&vbCrlF  
  		str=str&"-class classname            Class name"&vbCrlF
  		str=str&"-prop property              Property of Class"&vbCrlF  
  		str=str&"-format [format pattern]    Format Pattern"&vbCrlF  
  		str=str&vbCrlF
  		str=str&"Example: cscript query_wmi.vbs -class Win32_OperatingSystem -prop Version"
  		wscript.echo str
	End Function
'-------------------------------------------------------------------------------------------------
'Function Name:     f_GetAllArg.
'Descripton:        Get all of arguments from command.
'Input:				No.
'Output:			No.
'-------------------------------------------------------------------------------------------------
	Function f_GetAllArg()
	
		On Error Resume Next
		
		Dim i
		
		argcountcommand=WScript.Arguments.Count
		
		for i=0 to argcountcommand-1
  			arg(i)=WScript.Arguments(i)
		next
		
	End Function
'-------------------------------------------------------------------------------------------------
'Function Name:     f_GetOneArg.
'Descripton:        Get an argument from command.
'Input:				Yes.
'						strName: Name of argument
'Output:			Value.
'-------------------------------------------------------------------------------------------------
	Function f_GetOneArg(strName)
	
		On Error Resume Next
		
		Dim i
		for i=0 to argcountcommand-1
			if (Ucase(arg(i))=Ucase(strName)) then
				f_GetOneArg=arg(i+1)
				Exit Function
			end if
		next
		
	End Function
'-------------------------------------------------------------------------------------------------
'Function Name:     f_SelectInfo.
'Descripton:        Get an argument from command.
'Input:				No.
'Output:			Value.
'-------------------------------------------------------------------------------------------------
	Function f_SelectInfo()
		strSQL = "Select " & strProp & " from " & strClass
		'WScript.Echo strSQL

		' WMI Connection to the object in the CIM namespace
		strComputer = "."
		set objWMIDateTime = CreateObject("WbemScripting.SWbemDateTime")
		Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

		' WMI Query
		Set colItems = objWMIService.ExecQuery(strSQL)

		if (boolFormat) then
			strResult = Ucase(strFormat)
		else
			strResult = ""
		end if

		' Loop through the results
		For Each objItem in colItems
 			' Loop through the properties of each returned item
 			For Each property in objItem.Properties_
				If property.Name <> "Name" Then
					if (boolName) then
						strResult = strResult & property.Name & ":"
					end if
					'WScript.Echo "VarType for property " & property.Name & " " & property.Value & " " & VarType(property) & " " & Len(property.Value)
					If property.IsArray Then
    						strResult = strResult & property.Name & ":-"
    						For Each strValue In property.Value
    							strResult = strResult & strValue & " "
						Next
					Else
						'if (InStr(Ucase(property.Name),"DATE"))  then
						if (VarType(property) = 8) and (Len(property.Value) = 25) and (IsDate(Mid(property.Value, 5, 2) & "/" & Mid(property.Value, 7, 2) & "/" & Left(property.Value, 4)))  then
							'WScript.Echo "Date " & property.Value
							'WScript.Echo "Date " & Mid(property.Value, 5, 2) & "/" & Mid(property.Value, 7, 2) & "/" & Left(property.Value, 4)
							objWMIDateTime.Value = property.Value
							if (boolFormat) then
								strResult = Replace(strResult,"<" & Ucase(property.Name) & ">",objWMIDateTime.GetVarDate)
							else
   								strResult = strResult & objWMIDateTime.GetVarDate
							end if
						else
							if (boolFormat) then
								strResult = Replace(strResult,"<" & Ucase(property.Name) & ">",property.Value)
							else
								strResult = strResult & property.Value
							end if
						end if
					End If
					strResult = strResult & strFieldSep
				End IF
			Next
		Next
 		WScript.Echo strResult
	End Function
'*************************************************************************************************
'                                        Main Function
'*************************************************************************************************

	strCommandName="query_vmi.vbs"
	strDescription="Query WMI"
	strNameSpace = 	"root\cimv2"
		
	f_GetAllArg()
	tempCount = argcountcommand/2
'	f_Error()
	strClass = ""
	strProp = ""
	strFormat = ""
	
  	if ((UCase(arg(0))="-H") Or (UCase(arg(0))="--HELP")) and (argcountcommand=1) then
		f_Help()
  		Wscript.Quit(intError)
  	else
		'Wscript.Echo "arg =" & argcountcommand & " temp =" & tempCount
  		if( ((argcountcommand Mod 2) = 0) and (1 < tempCount < 4)) then
  			strDisp = f_GetOneArg("-disp")
			if (InStr(Ucase(strDisp),"VERT")) then
				boolVert = true
				strFieldSep = vbCrlF
			else
				boolVert = false
				strFieldSep = " "
			end if
			if (InStr(Ucase(strDisp),"NAME")) then
				boolName = true
			else
				boolName = false
			end if
  			strClass = f_GetOneArg("-class")
  			strProp = f_GetOneArg("-prop")
  			strFormat = f_GetOneArg("-format")
			if (strFormat = "") then
				boolFormat = false
			else
				boolFormat = true
				boolName = false
				boolVert = false
			end if
			'Wscript.Echo "strDisp:" & strDisp & " strClass:" & strClass & " strProp:" & strProp & " strFormat:" & strFormat
   		else
  			Wscript.Echo "Error! Arguments wrong, please type -h for Help"
  			Wscript.Quit(intError)
  		end if  
  		
  	end if
	if((strClass = "") or (strProp = "")) then
  		Wscript.Echo "Error! Arguments wrong, require verify -class -prop parameters"
  		Wscript.Quit(intError)
  	else
  		Wscript.Echo f_SelectInfo()
  	end if

' Exit
WScript.Quit
