rollout mcMoveWindowToZeroDialod "Bring My Window Back:" width:488 height:84
(
	groupBox 'grp1' "actions:" pos:[4,4] width:476 height:72 align:#left
	dropDownList 'ddl_names_list' "Window Name" pos:[152,24] width:316 height:40 items:#("LS3D Data Manager", "Scene Explorer - Layer Explorer") align:#left
	button 'btn_action' "Move To Zero" pos:[12,24] width:136 height:40 align:#left
	function GetWinClass =  (
		local source = "
			using System;
			using System.Runtime.InteropServices;
			public class Window {
			
				[DllImport(\""+"user32.dll"+"\")]
				public static extern bool SetWindowPos(int hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);
				[DllImport(\""+"user32.dll"+"\")]
				static extern bool GetWindowRect(int hWnd, out POS rect);
				public struct POS {
				
					public int Left;
					public int Top;
					public int Right;
					public int Bottom;
				}
				public int[] GetWindowPosAndSize(int hWnd) {
				
					POS rect;
					if ( GetWindowRect(hWnd, out rect) ) {
					
						return new int[] { rect.Left, rect.Top, rect.Right - rect.Left, rect.Bottom - rect.Top };
					}
					return null;
				}
			}
		"
        csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
        compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
        compilerParams.GenerateInMemory = on
        compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
        compilerResults.CompiledAssembly.CreateInstance "Window"
    )
	fn moveWindowToZero = (
		
		if miauuWindClass_efioj981 == undefined do global miauuWindClass_efioj981 = GetWinClass()
		maxVer = (maxVersion())[1]
		newPosX = 100
		newPosY = 200
		local selected_name = ddl_names_list.text
		for child in (windows.getChildrenHWND 0 parent:#max) where (findString child[5] selected_name != undefined)  do
		(
			if maxVer < 16000 then
			(
				dataArr = ::miauuWindClass_efioj981.GetWindowPosAndSize child[1]
				::miauuWindClass_efioj981.SetWindowPos child[1] 0 newPosX newPosY dataArr[3] dataArr[4] 1
			)
			else
			(
				--    "3dsMax 2014+"
				windPosAndSize = windows.getWindowPos child[1]
				windows.setWindowPos child[1] newPosX newPosY windPosAndSize.w windPosAndSize.h true
			)
		)
	)
	on btn_action pressed  do moveWindowToZero()
)
createDialog mcMoveWindowToZeroDialod