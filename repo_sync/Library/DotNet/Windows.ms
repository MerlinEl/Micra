assemblyFileName = "e:\Micra3\\App\\MaxCustomControls.dll"
dotNet.loadAssembly assemblyFileName
maxWin = dotNetObject "MaxCustomControls.MaxForm"
maxWin.size = dotNetObject "System.Drawing.Size" 800 600
maxWin.text = "Max DotNet Dialog"
maxWin.showmodeless()


  assemblyFileName = "e:\Micra3\\App\\MaxCustomControls.dll"
  dotNet.loadAssembly assemblyFileName
  form = dotNetObject "MaxCustomControls.MaxForm"
  mcsystem.show form
  p = DotNetObject "System.IntPtr" ( Windows.GetMAXHWND() )
  maxHwnd = DotNetObject "MaxCustomControls.Win32HandleWrapper" p -- I like it!
  form.Show ( maxHwnd )



hwnd = DotNetObject "IntPtr" ( Windows.GetMAXHWND() )
if hwnd != hwnd.Zero
then print "found"
else print "3DsMax is not running."




diag = dotnetclass "System.Diagnostics.Process"
p =diag.GetCurrentProcess()
p.Handle
p.HandleCount
mcsystem.show p

wp = diag.GetProcessesByName "3Dsmax"
mcsystem.show wp[1]
wp[1].MainModule
wp[1].GetLifetimeService()
wp[1].MainWindowHandle
wp[1].MainWindowTitle
wp[1].Handle
wp[1].HandleCount
wp[1].Id
wp[1].MachineName
wp[1].PrivateMemorySize
wp[1].WorkingSet
wp[1].Threads.Item 1
wp[1].ProcessName
wp[1].Container
wp[1].VirtualMemorySize
wp[1].UserProcessorTime
wp[1].Threads
wp[1].GetCurrentProcess()

(dotnetObject "System.Type" ((dotnetObject "form").GetType()))
.<System.Runtime.Remoting.ObjRef>CreateObjRef <System.Type>requestedType
wp[1].CreateObjRef p--(mc2_Dialog_F.GetType()).Assembly

maxHwnd = DotNetObject "System.Windows.Forms.IWin32Window" wp[1].BasePriority

ctrl = DotNetObject "System.Windows.Forms.Control"
ctrl = dotNetclass "System.Windows.Forms.Control"
p = DotNetObject "System.IntPtr" ( Windows.GetMAXHWND() )
ha = ctrl.FromHandle p



  
 global WindowWrapper 
(
 fn getWindowWrapper = 
 (
	  source = ""
	  source += "using System;\n"
	  source += "using System.Windows.Forms;\n"
	  source += "public class WindowWrapper : IWin32Window\n"
	  source += "{\n"
	  source += "	public WindowWrapper(IntPtr handle) { _hwnd = handle; }\n"
	  source += "	public WindowWrapper(Int32 handle) { _hwnd = (IntPtr)handle; }\n"
	  source += "	public IntPtr Handle { get { return _hwnd; } }\n"
	  source += "	private IntPtr _hwnd;\n"
	  source += "}\n"
	  -- Compile on fly
	  csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	  compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	  compilerParams.ReferencedAssemblies.Add("System.dll");
	  compilerParams.ReferencedAssemblies.Add("System.Windows.Forms.dll");
	  compilerParams.GenerateInMemory = on
	  compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	  
	  compilerResults.CompiledAssembly
 )
 
 try(form.close())catch()
 if WindowWrapper == undefined do
 (
	  getWindowWrapper()
	  WindowWrapper = dotnetobject "WindowWrapper" (windows.getMAXHWND()) 
 )  
 form = dotNetObject "Form"
form.AllowTransparency = true
 form.ShowInTaskBar = false
 form.opacity = 10
)
form.Show ( WindowWrapper ) 
  
  
 
 
 mc2_Dialog_F.show(dotnetobject "WindowWrapper" (windows.getMAXHWND()))
  
  
  
  
  
  
  