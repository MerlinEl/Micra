fn loadMaxSharp = (
  local Assembly = dotNetClass "System.Reflection.Assembly"
  local maxroot = pathConfig.GetDir #maxroot
  Assembly.LoadFile (maxroot + "\\MaxSharp.dll")
  global Kernel = dotNetClass "MaxSharp.Kernel"  
)

fn loadAutodeskMax = (
  local Assembly = dotNetClass "System.Reflection.Assembly"
  local maxroot = pathConfig.GetDir #maxroot
  Assembly.LoadFile (maxroot + "\\Autodesk.Max.dll")
  local GlobalInterface = dotNetClass "Autodesk.Max.GlobalInterface"  
  global MaxGlobal = GlobalInterface.Instance
)
