Function  ShowProcessorInfo()
  On  Error  Resume  Next
  DisplayOutputHeader("Processor  -  Win32_Processor")
  str  =  ""
  Set  objWMIService  =  GetWMIServices()
  Set  colItems  =  objWMIService.ExecQuery( _
    "Select  *  from  Win32_Processor")
  For  Each  objItem  in  colItems
          str  =  str  &  GetTableHeader()
          str  =  str  &  GetRow("Address  Width",  objItem.AddressWidth)
          str  =  str  &  GetRow("Architecture",  objItem.Architecture)
          str  =  str  &  GetRow("Availability",  objItem.Availability)
          str  =  str  &  GetRow("CPU  Status",  objItem.CpuStatus)
          str  =  str  &  GetRow("Current  Clock  Speed",  _
             objItem.CurrentClockSpeed)
          str  =  str  &  GetRow("Data  Width",  objItem.DataWidth)
          str  =  str  &  GetRow("Description",  objItem.Description)
          str  =  str  &  GetRow("Device  ID",  objItem.DeviceID)
          str  =  str  &  GetRow("Ext  Clock",  objItem.ExtClock)
          str  =  str  &  GetRow("Family",  objItem.Family)
          str  =  str  &  GetRow("L2  Cache  Size",  objItem.L2CacheSize)
          str  =  str  &  GetRow("L2  Cache  Speed",  objItem.L2CacheSpeed)
          str  =  str  &  GetRow("Level",  objItem.Level)
          str  =  str  &  GetRow("Load  Percentage",  objItem.LoadPercentage)
          str  =  str  &  GetRow("Manufacturer",  objItem.Manufacturer)
          str  =  str  &  GetRow("Maximum  Clock  Speed",  _
            objItem.MaxClockSpeed)
          str  =  str  &  GetRow("Name",  objItem.Name)
          str  =  str  &  GetRow("PNP  Device  ID",  objItem.PNPDeviceID)
          str  =  str  &  GetRow("Processor  Id",  objItem.ProcessorId)
          str  =  str  &  GetRow("Processor  Type",  objItem.ProcessorType)
          str  =  str  &  GetRow("Revision",  objItem.Revision)
          str  =  str  &  GetRow("Role",  objItem.Role)
          str  =  str  &  GetRow("Socket  Designation",  _
              objItem.SocketDesignation)
          str  =  str  &  GetRow("Status  Information",  objItem.StatusInfo)
          str  =  str  &  GetRow("Stepping",  objItem.Stepping)
          str  =  str  &  GetRow("Unique  Id",  objItem.UniqueId)
          str  =  str  &  GetRow("Upgrade  Method",  objItem.UpgradeMethod)
          str  =  str  &  GetRow("Version",  objItem.Version)
          str  =  str  &  GetRow("Voltage  Caps",  objItem.VoltageCaps)
          str  =  str  &  GetTableFooter()
  Next
  DisplayOutput(str)
End  Function