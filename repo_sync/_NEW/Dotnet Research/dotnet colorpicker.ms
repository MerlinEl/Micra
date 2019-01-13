fn CreateMXSProxy forceRecompile:on =
 (
 	if (forceRecompile or
 		(classof ::MXSProxyAssembly) != dotNetObject or
 		((::MXSProxyAssembly.GetType()).ToString()) != "System.Reflection.Assembly") do
 	(
 		sb = "using System.Text;
"
 		sb += "class MXSProxy
"
 		sb += "{
"
 		sb += " public System.String cmd;
"
 		sb += " public MXSProxy() {
"
 		sb += " }
"
 		sb += " public void Invoke(System.Object obj, CSharpUtilities.ValueChangedEventArgs<System.Drawing.Color> clr) {
"
 		sb += " if (cmd.Length > 0) {
"
 		sb += " ManagedServices.MaxscriptSDK.ExecuteMaxscriptCommand(cmd);
"
 		sb += " }
"
 		sb += " }
"
 		sb += "}
"
 
 		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
 		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
 
 		compilerParams.ReferencedAssemblies.Add("System.dll");
 		compilerParams.ReferencedAssemblies.Add("System.Drawing.dll");
 		compilerParams.ReferencedAssemblies.Add((getdir #maxroot) + "CSharpUtilities.dll");
 		compilerParams.ReferencedAssemblies.Add((getdir #maxroot) + "ManagedServices.dll");
 
 		compilerParams.GenerateInMemory = true
 		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(sb)
 
 		if (compilerResults.Errors.Count > 0 ) then
 		(
 			errs = stringstream ""
 			for i = 0 to (compilerResults.Errors.Count-1) do
 			(
 				err = compilerResults.Errors.Item[i]
 				format "Error:% Line:% Column:% %
" err.ErrorNumber err.Line \
 				err.Column err.ErrorText to:errs
 			)
 			MessageBox (errs as string) title: "Errors encountered while compiling C# code"
 			format "%
" errs
 			::MXSProxyAssembly = undefined
 			return undefined
 		)
 		else
 		(
 			::CreateMXSProxyAssembly = compilerResults.CompiledAssembly
 		)
 	)
 	::CreateMXSProxyAssembly.CreateInstance "MXSProxy"
 )
 
 -- Create a delegate that will forward the event properties on to maxscript
 ccehType = (dotnet.gettype "ManagedServices.ConfirmColorEventHandler")
 changeDelly = (dotnetclass "Delegate").CreateDelegate ccehType (CreateMXSProxy()) "Invoke"
 confirmDelly = (dotnetclass "Delegate").CreateDelegate ccehType (CreateMXSProxy()) "Invoke"
 
 try(mcp.Close()) catch()
 mcp = dotnetobject "ManagedServices.MaxColorPicker" (dotnetobject "System.IntPtr" (windows.getMAXHWND())) off "Pick Wirecolor"
 	show mcp
 if selection.count > 0 do mcp.currentcolor = (dotNetClass "System.Drawing.Color").fromARGB selection[1].wirecolor.r selection[1].wirecolor.g selection[1].wirecolor.b
 mcp.ColorChanged = changeDelly
 mcp.ColorConfirmed = confirmDelly
 format "%
" mcp.CurrentColor
 fn applyValue =
 (
 	col = color mcp.currentcolor.R mcp.currentcolor.G mcp.currentcolor.B
 	if selection.count > 0 do selection.wirecolor = col
 		format "%
" mcp.CurrentColor
 )
 -- You can combine delegates to allow more than one event handler
 -- mcp.ColorChanged = changeDelly.combine mcp.ColorChanged changeDelly
 
 -- Note that these are C# string formating rules. You should be able to modify the maxscript that executes dynamically
 changeDelly.target.cmd = "applyValue()"
 
 mcp.showmodeless()