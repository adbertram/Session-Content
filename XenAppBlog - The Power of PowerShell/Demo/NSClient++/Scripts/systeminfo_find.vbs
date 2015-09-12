Dim strParm
Dim strResult

' Make sure there are at least 1 arguments.  
  
If (Wscript.Arguments.Count < 1) Then  
  
Wscript.Echo "Required Parameter missing"  
  
Wscript.Quit  
  
End If  
  
' Retrieve the first argument (index 0).  
  
strParm = Wscript.Arguments(0)  
  
' Retrieve the second argument.  
 
strResult = systeminfo.exe | findstr strParm  


Wscript.Echo strResult
  
