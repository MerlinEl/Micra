--------------------------------------------------------------------------------
/* CreateWin32Assembly created by denisT 2010 */
--------------------------------------------------------------------------------
Global mcWin32
Global mcWin32Assembly
fn CreateWin32Assembly forceRecompile:on = (
	if forceRecompile or not iskindof ::mcWin32Assembly dotnetobject or (::mcWin32Assembly.GetType()).name != "Assembly" do (
	
		source = "using System;
"
		source += "using System.Runtime.InteropServices;
"
		source += "using System.Text;
"
		source += "class Win32
"
		source += "{
"
		source += "		[DllImport(\"user32\", CharSet = CharSet.Auto, SetLastError = true)]
"
		source += "		public static extern Int32 SetFocus(Int32 hWnd);
"
		source += "		[DllImport(\"user32\", CharSet = CharSet.Auto, SetLastError = true)]
"
		source += "		internal static extern int GetWindowTextLength(Int32 hWnd);
"
		source += "		[DllImport(\"user32\", CharSet = CharSet.Auto, SetLastError = true)]
"
		source += "		internal static extern int GetWindowText(Int32 hWnd, [Out, MarshalAs(UnmanagedType.LPTStr)] StringBuilder lpString, int nMaxCount);
"
		source += "		public static string GetWindowText(Int32 hWnd)
"
		source += "		{
"
		source += "			int length = GetWindowTextLength(hWnd);
"
		source += "			StringBuilder sb = new StringBuilder(length + 1);
"
		source += "			GetWindowText(hWnd, sb, sb.Capacity);
"
		source += "			return sb.ToString();
"
		source += "		}
"
		source += "}
"
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

/*
public static string GetWindowText(IntPtr hWnd)
{
	var sb = new StringBuilder(2000);
	SendMessage(hWnd, WM.WM_GETTEXT, sb.Capacity, sb);
	return sb.ToString();
}
public static void SetWindowText(IntPtr hWnd, string text)
{
	SendMessage(hWnd, WM.WM_SETTEXT, 0, text);
}
*/



/*
dll_MXSEshowCalltip = (

	source = ""
	source += "using System;
"
	source += "using System.Text;
"
	source += "using System.Runtime.InteropServices;
"
	source += "class csharp_showCalltip
"
	source += "{
"
	source += "[DllImport(\"user32.dll\", CharSet=CharSet.Auto, SetLastError=true)]
"
	source += "public static extern int SendMessage(Int32 hWnd, int wMsg, int wParam, string lParam);
"
	source += "static public void showCalltip( Int32 hWnd, int pos, string text ){
"
	source += "SendMessage( hWnd, 0x0898, pos, text );
"
	source += "}}
"
	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.GenerateInMemory = on
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	compilerResults.CompiledAssembly.CreateInstance "csharp_showCalltip"					
)
dll_MXSEshowCalltip.SendMessage tb mcWinMsg.EM_SETSEL 0 7
dll_MXSEshowCalltip.SendMessage tb mcWinMsg.EM_REPLACESEL  0 "abc"
*/