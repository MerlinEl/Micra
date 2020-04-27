--Load Assemblies
dotNet.loadAssembly (micra.AssemblyDir + "Orien.Tools.dll")
dotNet.loadAssembly (micra.AssemblyDir + "Orien.NetUi.dll")

--instance  mcPopUp and WindowType classes
_mcPopUp = mcDotnet.loadAssembly "Orien.NetUi.dll" "Orien.NetUi.McPopUp" 
p_types =  dotnetClass "Orien.NetUi.mcPopup+WindowType" --works on enum
p_options = dotNetClass "Orien.NetUi.McPopup+Options>"	--not works on calss

p_types = _mcPopUp.GetTypes() --works on enum
p_options =  _mcPopUp.GetOptions() --works on calss
_mcPopUp.Awesome --works on constant string

p_types.E_Progress
p_options.ConfirmToClose = true


progb = _mcPopUp.Create "A" "B"
progb.Show()

progb = _mcPopUp.Create "Progress To" ""  p_types.E_Progress p_options
progb.Show(mcMicraDialog)	
progb.close()

--<<<<< WORKS :-D nice

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
	

	--Tooltip Test
	test_form = dotNetObject "MaxCustomControls.MaxForm"
	test_btn = dotNetObject "button"
	test_btn.text = "Tooltip Test"
	test_tptp = mcDotnet.loadAssembly "Orien.NetUi.dll" "Orien.NetUi.mcImageTooltip" 
	test_tptp.AutoSize = false
	--test_tptp.Size 200 64
    test_tptp.SetToolTip test_btn "Button 1. ToolTip with Image"
	test_btn.Tag = (dotNetClass "Drawing.Image").FromFile  (micra.ImagesPath + "TooltipIcons\\tltp_flatten_01.png")
	test_form.controls.add test_btn
	mcDotnet.dShow test_form