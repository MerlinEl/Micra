(
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
    if miauuWindClass_efioj981 == undefined do global miauuWindClass_efioj981 = GetWinClass()
    
    maxVer = (maxVersion())[1]
    newPosX = 100
    newPosY = 200
    for child in (windows.getChildrenHWND 0 parent:#max) where (child[5] == "Scene Explorer - Layer Explorer")  do
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
