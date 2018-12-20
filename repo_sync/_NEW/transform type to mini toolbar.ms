--******************************************************************************************************
-- Created: 		05-11-2014
-- Last Updated:	06-11-2014
-- Version:			1.10
--
-- Author :  Kostadin Kotev / miau_u@yahoo.com / http://miauumaxscript.blogspot.com/
-- Version:  3ds max 2009 (10) (should work in older versions too!)
--
-- Discription: rearange the controls of the default Transform Type-In dialog, removes its title bar and borders and
--	changes the size of the TTI window.
--
-- Usage: Run it once to rearange the controls and to hide the borders and the title bar. Run again to show the title bar
--	and the borders, so the window can be moved
--	This file can be put to 3dsMax startup folder
--
-- Special thanks to Denis Trofimov
--
--******************************************************************************************************
-- MODIFY THIS AT YOUR OWN RISK

(
	global miauuUser32Assembly_4eifj
	function CreateUser32Assembly forceRecompile:on =
	(
		if forceRecompile or not iskindof ::miauuUser32Assembly_4eifj dotnetobject or (::miauuUser32Assembly_4eifj.GetType()).name != "Assembly" do
		(
			source = "using System;\n"
			source += "using System.Runtime.InteropServices;\n"
			source += "class user32\n"
			source += "{\n"
			source += " [DllImport(\"user32.DLL\", EntryPoint=\"GetWindowLong\")]\n"
			source += " public static extern Int32 GetWindowLong(IntPtr hWnd, Int32 index);\n"
			source += " [DllImport(\"user32.DLL\", EntryPoint=\"SetWindowLong\")]\n"
			source += " public static extern Int32 SetWindowLong(IntPtr hWnd, Int32 index, Int32 newVal);\n"
			source += "}\n"

			csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
			compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
						 
			compilerParams.GenerateInMemory = true
			compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
			::miauuUser32Assembly_4eifj = compilerResults.CompiledAssembly
		)
		::miauuUser32Assembly_4eifj.CreateInstance "user32"
	)
  	global miauuUser32_4ijh4gr = CreateUser32Assembly()
	--
	function GetWinClass = 
	(
		source = ""
		source += "using System;\n"
		source += "using System.Runtime.InteropServices;\n"
		source += "public class Window\n"
		source += "{\n"
		source += "	[DllImport(\"user32.dll\")]\n"
		source += "	public static extern bool SetWindowPos(int hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);\n"
		source += "	[DllImport(\"user32.dll\")]\n"
		source += "	static extern bool GetWindowRect(int hWnd, out POS rect);\n"
		source += "	public struct POS\n"
		source += "	{\n"
		source += "		public int Left;\n"
		source += "		public int Top;\n"
		source += "		public int Right;\n"
		source += "		public int Bottom;\n"
		source += "	}\n"
		source += "	public int[] GetWindowPosAndSize(int hWnd)\n"
		source += "	{\n"
		source += "		POS rect;\n"
		source += "		if ( GetWindowRect(hWnd, out rect) )\n"
		source += "		{\n"
		source += "			return new int[] { rect.Left, rect.Top, rect.Right - rect.Left, rect.Bottom - rect.Top };\n"
		source += "		}\n"
		source += "		return null;\n"
		source += "	}\n"
		source += "}\n"
	  
		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
		compilerParams.GenerateInMemory = on
		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
		compilerResults.CompiledAssembly.CreateInstance "Window"
	)
	if miauuWindClass_efioj98 == undefined do global miauuWindClass_efioj98 = GetWinClass()
 	--
	max move
	max tti	
	hwndMove = windows.getChildHWND 0 "Move Transform Type-In"
	hwnd = dotnetobject "IntPtr" hwndMove[1]
	--	rearange controls
	posX = 2
	--	first rearange the labels
	labelsArr = for c in (windows.getChildrenHWND hwndMove[1]) where c[4] == "Static" collect c[1]
	::miauuWindClass_efioj98.SetWindowPos labelsArr[1] 0 posX 5 18 18 0
	::miauuWindClass_efioj98.SetWindowPos labelsArr[2] 0 (posX+95) 5 18 18 0
	::miauuWindClass_efioj98.SetWindowPos labelsArr[3] 0 (posX+195) 5 18 18 0
	--	local offset labels
	::miauuWindClass_efioj98.SetWindowPos labelsArr[4] 0 (posX+300) 5 18 18 0
	::miauuWindClass_efioj98.SetWindowPos labelsArr[5] 0 (posX+400) 5 18 18 0
	::miauuWindClass_efioj98.SetWindowPos labelsArr[6] 0 (posX+500) 5 18 18 0
	--	then hide the groups
	grpBoxArr = for c in (windows.getChildrenHWND hwndMove[1]) where c[4] == "Button" collect c[1]
	for k = 0 to grpBoxArr.count - 1 do
		::miauuWindClass_efioj98.SetWindowPos grpBoxArr[k+1] 0 -40 -35 650 60 0
	
	--	rearange spinner text field
	spinnerBodyArr = for c in (windows.getChildrenHWND hwndMove[1]) where c[4] == "CustEdit" collect c[1]
	::miauuWindClass_efioj98.SetWindowPos spinnerBodyArr[1] 0 (posX+15) 5 70 17 0
	::miauuWindClass_efioj98.SetWindowPos spinnerBodyArr[2] 0 (posX+114) 5 70 17 0
	::miauuWindClass_efioj98.SetWindowPos spinnerBodyArr[3] 0 (posX+214) 5 70 17 0
	--	local offset
	::miauuWindClass_efioj98.SetWindowPos spinnerBodyArr[4] 0 (posX+318) 5 70 17 0
	::miauuWindClass_efioj98.SetWindowPos spinnerBodyArr[5] 0 (posX+418) 5 70 17 0
	::miauuWindClass_efioj98.SetWindowPos spinnerBodyArr[6] 0 (posX+518) 5 70 17 0
	
	--	rearange arrows
	arrowsArr = for c in (windows.getChildrenHWND hwndMove[1]) where c[4] == "SpinnerControl" collect c[1]
	::miauuWindClass_efioj98.SetWindowPos arrowsArr[1] 0 (posX+85) 5 12 18 0
	::miauuWindClass_efioj98.SetWindowPos arrowsArr[2] 0 (posX+184) 5 12 18 0
	::miauuWindClass_efioj98.SetWindowPos arrowsArr[3] 0 (posX+284) 5 12 18 0
	--	local offset
	::miauuWindClass_efioj98.SetWindowPos arrowsArr[4] 0 (posX+388) 5 12 18 0
	::miauuWindClass_efioj98.SetWindowPos arrowsArr[5] 0 (posX+488) 5 12 18 0
	::miauuWindClass_efioj98.SetWindowPos arrowsArr[6] 0 (posX+588) 5 12 18 0
	
	--	remove title bar and borders
	GWL_STYLE = -16
    WS_BORDER = 0x00800000L
    WS_CAPTION = 0x00C00000L    
    WS_FRAME = bit.or WS_BORDER WS_CAPTION  
	
    flags = ::miauuUser32_4ijh4gr.GetWindowLong hwnd GWL_STYLE
    flags = bit.xor flags WS_FRAME
    ::miauuUser32_4ijh4gr.SetWindowLong hwnd GWL_STYLE flags
    ::miauuUser32_4ijh4gr.GetWindowLong hwnd GWL_STYLE
	
	--	set new TTI window size
	--	before  3dsMax 2014
	pos = ::miauuWindClass_efioj98.GetWindowPosAndSize hwndMove[1]
	::miauuWindClass_efioj98.SetWindowPos hwndMove[1] 0 pos[1] pos[2] 605 20 2
	--	3dsMax 2014+
-- 	windows.setWindowPos hwndMove[1] pos[1] pos[2] 612 20 true	
)