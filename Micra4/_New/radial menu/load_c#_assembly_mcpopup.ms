--Load Assemblies
dotNet.loadAssembly (micra.AssemblyDir + "Orien.Tools.dll")
dotNet.loadAssembly (micra.AssemblyDir + "Orien.NetUi.dll")
--Create mcPopUp Class instance
cls = dotNet.getType "Orien.NetUi.mcPopUp" 
activator = (dotNetClass "System.Activator")
mcPopUp_Instance = activator.CreateInstance cls --> dotNetObject:Orien.NetUi.mcPopUp
--call progressbar
mcPopUp_Instance.ProgBar
-- Unknown property: "ProgBar" in dotNetObject:Orien.NetUi.mcPopUp