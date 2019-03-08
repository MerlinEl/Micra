--------------------------------------------------------------------------------
/* Create Win32 Assembly created by denisT 2010 */
--------------------------------------------------------------------------------
Global mcWin32
Global mcWin32Assembly
fn CreateWin32Assembly forceRecompile:on = (
	if forceRecompile or not iskindof ::mcWin32Assembly dotnetobject or (::mcWin32Assembly.GetType()).name != "Assembly" do (
	
		source = "using System;\n"
		source += "using System.Runtime.InteropServices;\n"
		source += "using System.Text;\n"
		source += "class Win32\n"
		source += "{\n"
		source += "		[DllImport(\"user32\", CharSet = CharSet.Auto, SetLastError = true)]\n"
		source += "		public static extern Int32 SetFocus(Int32 hWnd);\n"
		source += "		[DllImport(\"user32\", CharSet = CharSet.Auto, SetLastError = true)]\n"
		source += "		internal static extern int GetWindowTextLength(Int32 hWnd);\n"
		source += "		[DllImport(\"user32\", CharSet = CharSet.Auto, SetLastError = true)]\n"
		source += "		internal static extern int GetWindowText(Int32 hWnd, [Out, MarshalAs(UnmanagedType.LPTStr)] StringBuilder lpString, int nMaxCount);\n"
		source += "		public static string GetWindowText(Int32 hWnd)\n"
		source += "		{\n"
		source += "			int length = GetWindowTextLength(hWnd);\n"
		source += "			StringBuilder sb = new StringBuilder(length + 1);\n"
		source += "			GetWindowText(hWnd, sb, sb.Capacity);\n"
		source += "			return sb.ToString();\n"
		source += "		}\n"
		source += "}\n"
		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"

		compilerParams.ReferencedAssemblies.Add "System.dll"
		compilerParams.ReferencedAssemblies.Add "System.Drawing.dll"

		compilerParams.GenerateInMemory = true
		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
		
		mcWin32Assembly = compilerResults.CompiledAssembly
		mcWin32Assembly.CreateInstance "Win32"
	)
	/*<end>*/
)
mcWin32 = CreateWin32Assembly()