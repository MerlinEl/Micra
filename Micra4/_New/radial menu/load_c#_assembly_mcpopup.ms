--Load Assemblies
dotNet.loadAssembly (micra.AssemblyDir + "Orien.Tools.dll")
dotNet.loadAssembly (micra.AssemblyDir + "Orien.NetUi.dll")

--instance  mcPopUp and WindowType classes
_mcPopUp = mcDotnet.loadAssembly "Orien.NetUi.dll" "Orien.NetUi.McPopUp" 
p_types =  dotnetClass "Orien.NetUi.McPopup+WindowType" --works on enum
p_options = dotnetClass "Orien.NetUi.McPopup+Options>"	--not works on calss

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


---->>>>>> Next Method Without Locking DLL

--Loading a dll by bytes in 3dsMax
--Test1 >
assembly_path1 = micra.AssemblyDir + "Orien.Tools.dll"
assemblyBytes = (dotnetClass "System.IO.File").ReadAllBytes assembly_path1
myAssembly = (dotnetClass "System.Reflection.Assembly").Load assemblyBytes
cls = dotNet.getType "Orien.Tools.mcMath" 
activator = (dotNetClass "System.Activator")
mcMath_Instance = activator.CreateInstance cls
--Math operations
mcMath_Instance.minMax 100	1	50	--> 50
mcMath_Instance.minMax -1	1	50	--> 1
mcMath_Instance.minMax 100	1	200	--> 100
--Test2 >
assembly_path2 = micra.AssemblyDir + "Orien.NetUi.dll"
assemblyBytes = (dotnetClass "System.IO.File").ReadAllBytes assembly_path2
myAssembly = (dotnetClass "System.Reflection.Assembly").Load assemblyBytes
cls = dotNet.GetType( "Orien.NetUi.mcPopUp"  )


mcPopUp_Instance = (dotNetClass "System.Activator").CreateInstance cls
p_types = mcPopUp_Instance.GetTypes() --works on enum
p_options =  mcPopUp_Instance.GetOptions() --works on calss
p_options.ConfirmToClose = true
progb = mcPopUp_Instance.Create "Progress To" ""  p_types.E_Progress p_options --Trouble here (cant find Orien.Tools)
progb.Show(mcMicraDialog)	
progb.close()

progb = mcPopUp_Instance.Create "A" "B"
progb.Show()

--Test3 >
assembly_path1 = micra.AssemblyDir + "Orien.NetUi.dll"
assemblyBytes = (dotnetClass "System.IO.File").ReadAllBytes assembly_path1
myAssembly = (dotnetClass "System.Reflection.Assembly").Load assemblyBytes
cls = myAssembly.getType "Orien.NetUi.McConsole" 
McConsole_Instance = (dotNetClass "System.Activator").CreateInstance cls
	McConsole_Instance.show()
	McConsole_Instance.Log "hello"
	McConsole_Instance.Log "hello Rene" "Personal"
	McConsole_Instance.Log "hello Rene a:{0} b:{1}" "Formated" (new object[] { 15, "Custom String" })

--McConsole_Instance = (dotNetClass "System.Activator").CreateInstance cls mcMicraDialog
  .Log <System.String>msg <System.String>tabName
  .Log <System.String>msg <System.String>tabName <System.Object[]>args

/*
A disadvantage however is this assembly can’t access another assembly, 
even if I’ve set up the references in Visual Studio correctly. 
It will work in Visual Studio but it won’t in 3dsMax. Bummer! 
This article covers a workaround albeit a rather laborious one.*/
---------------------------------------------------------------------------------------------------------

--call progressbar

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