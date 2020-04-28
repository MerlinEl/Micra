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