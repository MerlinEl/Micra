--Load Assemblies
dotNet.loadAssembly (micra.AssemblyDir + "Orien.Tools.dll")
dotNet.loadAssembly (micra.AssemblyDir + "Orien.NetUi.dll")

--instance  mcPopUp and WindowType classes
_mcPopUp = mcDotnet.loadAssembly "Orien.NetUi.dll" "Orien.NetUi.mcPopUp" 


p_types = (_mcPopUp.GetTypes())
p_types = (dotnetClass ("Orien.NetUi.mcPopup+WindowType"))
	
	
_mcPopUp.Options
p_options = dotNetClass "Orien.NetUi.mcPopup+Options>"
	
_mcPopUp.Awesome


--progb = _mcPopUp.Create type msg title delay dpos crypt
confirm_box = _mcPopUp.Create "A" "B"
progb = _mcPopUp.Create "Progress To" ""  p_types.E_Progress p_options
progb.Show(mcMicraDialog)	
progb.close()


.[static]<System.Windows.Forms.Form>Create <System.String>msg <System.String>title
.[static]<System.Windows.Forms.Form>Create <System.String>msg <System.String>title <Orien.NetUi.mcPopup+WindowType>type <Orien.NetUi.mcPopup+Options>options


cls = dotNet.getType "Orien.NetUi.mcPopUp" 
activator = (dotNetClass "System.Activator")
mcPopUp_Instance = activator.CreateInstance cls --> dotNetObject:Orien.NetUi.mcPopUp
--call progressbar
mcPopUp_Instance.ProgBar
-- Unknown property: "ProgBar" in dotNetObject:Orien.NetUi.mcPopUp


msg = "Progress To"	
title = ""
delay = dotnetObject "System.Single" -1
dpos = dotnetObject "System.Drawing.Point" 100 100
crypt = false
circle_size = dotnetObject "System.Drawing.Size" 80 80
-- create window Form instance
/*.[static]<System.Windows.Forms.Form>Create 
	<Orien.NetUi.mcPopup+WindowType>type 
	<System.String>msg 
	<System.String>title 
	<System.Single>delay 
	<System.Drawing.Point>pos 
	<System.Boolean>crypt*/