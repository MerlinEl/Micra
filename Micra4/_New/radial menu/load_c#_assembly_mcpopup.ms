------------------	
--NEW WAY 
------------------	
--FINAL TEST Coompilled assemby (merged all in to one)
McGetCs.NewColor 20 20 20
 
mcMath_cs = mcCSharp.getClassInstance "Orien.Tools.mcMath" 
mcMath_cs.minMax 100	1	50	--> 50
mcMath_cs.minMax -1	1	50	--> 1
mcMath_cs.minMax 100	1	200	--> 100

mcConsole_cs = mcCSharp.getClassInstance "Orien.NetUi.McConsole"  constructorParams:#(mcMicraDialog) forceLoad:true
mcConsole_cs.owner = mcMicraDialog

maxWindow=mcSystem.getMaxWindow()
mcConsole_cs.owner = maxWindow --GetType()
maxWindow.DefWndProc -- <System.Windows.Forms.Message&>m

mcConsole_cs.show()
mcConsole_cs.Log "hello"
mcConsole_cs.Log "hello Rene" "Personal"
mcConsole_cs.Log "hello Rene a:{0} b:{1}" "Formated" (dotnetArray #( 15, "Custom String" ))


MaxCustomControls
maxHandlePointer=(Windows.GetMAXHWND()) 
sysPointer = DotNetObject "System.IntPtr" maxHandlePointer
maxHwnd = DotNetObject "MaxCustomControls.Win32HandleWrapper" sysPointer

	
	
	hv = DotNetObject "MaxCustomControls.MaxForm"
	sysPointer = DotNetObject "System.IntPtr" mcSystem.maxHandle
	hv.AssignHandle
	windows.SendMessage mcSystem.maxHandle mcWinMsg.WM_SETFOCUS 0 0
	
	
			assembly_path = micra.AssemblyDir + "Orien.Star.dll"
			assembly_bytes = (dotnetClass "System.IO.File").ReadAllBytes assembly_path
			assembly = (dotnetClass "System.Reflection.Assembly").Load assembly_bytes
			dotnet_class = dotNet.getType  "Orien.NetUi.McConsole"
			mcConsole_cs = (dotNetClass "System.Activator").CreateInstance dotnet_class	
	
	
--https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_F9BDCDFD_5C2D_42ED_A840_184795A2E057_htm
enableAccelerators = false
enableAccelerators = true
------------------	
--OLD WAY 
------------------	
	
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
assembly_path1 = micra.AssemblyDir + "Orien.Tools.dll"
assembly_path2 = micra.AssemblyDir + "Orien.NetUi.dll"
assemblyBytes1 = (dotnetClass "System.IO.File").ReadAllBytes assembly_path1
assemblyBytes2 = (dotnetClass "System.IO.File").ReadAllBytes assembly_path2
myAssembly1 = (dotnetClass "System.Reflection.Assembly").Load assemblyBytes1
myAssembly2 = (dotnetClass "System.Reflection.Assembly").Load assemblyBytes2

cls2 = myAssembly2.getType "Orien.NetUi.McConsole" 
McConsole_Instance = (dotNetClass "System.Activator").CreateInstance cls2

cls1 = myAssembly1.getType "Orien.Tools.McDesktop" 
McDesktop_Instance = (dotNetClass "System.Activator").CreateInstance cls1

	McConsole_Instance.show()
	McConsole_Instance.Log "hello"
	McConsole_Instance.Log "hello Rene" "Personal"
	McConsole_Instance.Log "hello Rene a:{0} b:{1}" "Formated" (dotnetArray #( 15, "Custom String" ))

		
--test4	
assembly_path1 = micra.AssemblyDir + "Orien.Star.dll"
assemblyBytes = (dotnetClass "System.IO.File").ReadAllBytes assembly_path1
myAssembly = (dotnetClass "System.Reflection.Assembly").Load assemblyBytes
cls = dotNet.getType "Orien.Tools.mcMath" 
activator = (dotNetClass "System.Activator")
mcMath_Instance = activator.CreateInstance cls
--Math operations
mcMath_Instance.minMax 100	1	50	--> 50
mcMath_Instance.minMax -1	1	50	--> 1
mcMath_Instance.minMax 100	1	200	--> 100		
		
cls2 = dotNet.getType "Orien.NetUi.McConsole" 
McConsole_Instance = (dotNetClass "System.Activator").CreateInstance cls2		
	McConsole_Instance.show()
	McConsole_Instance.Log "hello"
	McConsole_Instance.Log "hello Rene" "Personal"
	McConsole_Instance.Log "hello Rene a:{0} b:{1}" "Formated" (dotnetArray #( 15, "Custom String" ))
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
	
	
	
	
---------------------------------------------------
---------------------------------------------------	
	
global dynamicDll
fn CreateDynamicDllClass = (

  	if dynamicDll == undefined OR classof dynamicDll != dotnetobject OR NOT matchpattern ( dynamicDll.ToString() ) pattern:"Dynamics.DynamicDll" do
  	(
  		source = "
using System;
using System.Reflection;
using System.IO;
namespace Dynamics { // open namespace Dynamics
	public class DynamicDll { // open class
		public static Assembly GetAssembly(string filename) { //open GetAssembly Method
			Assembly library = null;
			using (FileStream fs = File.Open(filename, FileMode.Open)) { // open using FileStream
				using (MemoryStream ms = new MemoryStream()) { // open using MemoryStream
					byte[] buffer = new byte[1024];
					int read = 0;
					while ((read = fs.Read(buffer, 0, 1024)) > 0)
					ms.Write(buffer, 0, read);
					library = Assembly.Load(ms.ToArray());
				} // end using MemoryStream
			} // end using FileStream
			return library;
		} // end GetAssembly Method
	} // end class
} // end namespace Dynamics
"
  		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
  		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
  		compilerParams.GenerateInMemory = on
  		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
  		dynamicDll = compilerResults.CompiledAssembly.CreateInstance "Dynamics.DynamicDll"
  	)
  	dynamicDll
  )
CreateDynamicDllClass()
dynamicDll.GetAssembly (micra.AssemblyDir + "Orien.Tools.dll")  
dynamicDll.GetAssembly ( micra.AssemblyDir + "Orien.NetUi.dll")  
  
  
  --Test1 >  

cls = dotNet.getType "Orien.Tools.mcMath" 
mcMath_Instance = (dotNetClass "System.Activator").CreateInstance cls
--Math operations
mcMath_Instance.minMax 100	1	50	--> 50
mcMath_Instance.minMax -1	1	50	--> 1
mcMath_Instance.minMax 100	1	200	--> 100
  
--Test2 >

cls = dotNet.GetType "Orien.NetUi.mcPopUp" 
mcPopUp_Instance = (dotNetClass "System.Activator").CreateInstance cls
p_types = mcPopUp_Instance.GetTypes() --works on enum
p_options =  mcPopUp_Instance.GetOptions() --works on calss
p_options.ConfirmToClose = true
progb = mcPopUp_Instance.Create "Progress To" ""  p_types.E_Progress p_options --Trouble here (cant find Orien.Tools)
progb.Show(mcMicraDialog)	
progb.close()

--Test3 >
cls = dotNet.getType "Orien.NetUi.McConsole" 
McConsole_Instance = (dotNetClass "System.Activator").CreateInstance cls
	McConsole_Instance.show()
	McConsole_Instance.Log "hello"
	McConsole_Instance.Log "hello Rene" "Personal"
	McConsole_Instance.Log "hello Rene a:{0} b:{1}" "Formated" (new object[] { 15, "Custom String" })
---------------------------------------------------
---------------------------------------------------	

fn CreateTestAssembly = (
	source = "
using System;
using System.Linq;
using Orien.Tools.dll;
using Orien.NetUi.dll;
public class testClass{}
"
	local csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	local compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.ReferencedAssemblies.Add "System.dll"
    compilerParams.ReferencedAssemblies.Add "System.Core.dll"
	compilerParams.ReferencedAssemblies.Add (micra.AssemblyDir + "Orien.Tools.dll")
	compilerParams.ReferencedAssemblies.Add ( micra.AssemblyDir + "Orien.NetUi.dll")
	compilerParams.GenerateInMemory = true
	local compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	
	if (compilerResults.Errors.Count > 0 ) then (
		local errs = stringstream ""
		for i = 0 to (compilerResults.Errors.Count-1) do (
			err = compilerResults.Errors.Item[i]
			format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line err.Column err.ErrorText to:errs 
		)
		MessageBox (errs as string) title: "Errors encountered while compiling C# code"
		format "%\n" errs
		undefined
	) else (
		compilerResults.CompiledAssembly.CreateInstance "testClass"
	)
)
global testClass = CreateTestAssembly()

