(
    function GetWinClass = 
    (
        source = ""
        source += "using System;
"
        source += "using System.Runtime.InteropServices;
"
        source += "public class Window
"
        source += "{
"
        source += "    [DllImport(\"user32.dll\")]
"
        source += "    public static extern bool SetWindowPos(int hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);
"
        source += "    [DllImport(\"user32.dll\")]
"
        source += "    static extern bool GetWindowRect(int hWnd, out POS rect);
"
        source += "    public struct POS
"
        source += "    {
"
        source += "        public int Left;
"
        source += "        public int Top;
"
        source += "        public int Right;
"
        source += "        public int Bottom;
"
        source += "    }
"
        source += "    public int[] GetWindowPosAndSize(int hWnd)
"
        source += "    {
"
        source += "        POS rect;
"
        source += "        if ( GetWindowRect(hWnd, out rect) )
"
        source += "        {
"
        source += "            return new int[] { rect.Left, rect.Top, rect.Right - rect.Left, rect.Bottom - rect.Top };
"
        source += "        }
"
        source += "        return null;
"
        source += "    }
"
        source += "}
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
    for child in (windows.getChildrenHWND 0 parent:#max) where (child[5] == "MAXScript Listener")  do
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
