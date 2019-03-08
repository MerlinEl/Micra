--------------------------------------------------------------------------------
/* Create User32 Assembly created by denisT 2011 */
--------------------------------------------------------------------------------
Global mcUser32
Global mcUser32Assembly
/**
*@Example
 in this sample i simulate middle mouse click in view. i don’t send activation message because i don’t want accidentally change the active window
 fn MButtonViewClick = ( --viewport focus

  	local WM_MBUTTONDOWN 	= 0x0207
  	local WM_MBUTTONUP 	= 0x0208
  	local hwnd = for w in (windows.getChildrenHWND #max) where w[4] == "ViewPanel" do exit with w[1]
  	hwnd = (windows.getChildrenHWND hwnd)[1][1]
  
  	mcUser32.postmessage hwnd WM_MBUTTONDOWN 0 0
  	mcUser32.postmessage hwnd WM_MBUTTONUP 0 0
 )
 MButtonViewClick()
*/
fn CreateUser32Assembly forceRecompile:on = (
	if forceRecompile or not iskindof ::mcUser32Assembly dotnetobject or (::mcUser32Assembly.GetType()).name != "Assembly" do (
  	source = ""
  	source += "using System;\n"
  	source += "using System.Runtime.InteropServices;\n"
  	source += "class User32\n"
  	source += "{\n"
  	source += "	[DllImport(\"user32.dll\")]\n"
  	source += "	public static extern int PostMessage(Int32 hWnd, int wMsg, int wParam, int lParam);\n"
  	source += "}\n"
  
  	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
  	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
  					
  	compilerParams.GenerateInMemory = on
  	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
  	compilerResults.CompiledAssembly.CreateInstance "User32"
  )
	/*<end>*/
)	
 --create instance
mcUser32 = CreateUser32Assembly()



/*
Global User32
fn CreateUser32Assembly = (

	local source = "using System;\n"
	source += "using System.Runtime.InteropServices;\n"
	source += "class User32\n"
	source += "{\n"
	source += " [DllImport(\"user32.dll\")]\n"
	source += " public static extern bool SetWindowPos(Int64 hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);\n"
	source += "}\n"
	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"			
	compilerParams.GenerateInMemory = on
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	compilerResults.CompiledAssembly.CreateInstance "User32"
)
User32 = CreateUser32Assembly()
*/


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