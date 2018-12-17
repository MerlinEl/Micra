fn getWinClass = 
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
	source += "		int[] size = new int[4];\n"
	source += "		if (!GetWindowRect(hWnd, out rect)) { return null; }\n"
	source += "		size[0] = rect.Left;\n"
	source += "		size[1] = rect.Top;\n"
	source += "		size[2] = rect.Right - rect.Left;\n"
	source += "		size[3] = rect.Bottom - rect.Top;\n"
	source += "		return size;\n"
	source += "	}\n"
	source += "}\n"

	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
	compilerParams.GenerateInMemory = on
	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
	compilerResults.CompiledAssembly.CreateInstance "Window"
)
if true or wndclass == undefined do global wndclass = getWinClass()

try(delete objects) catch()

long_named = box name:"The Long Named Box Object" wirecolor:yellow pos:[0,0,0]
short_named = box name:"Just a Box" wirecolor:orange pos:[0,0,long_named.height]

try(destroydialog pickRol) catch()
rollout pickRol "Resizable Pick"
(
	pickbutton pb "Pick a Node" width:180 pos:[0,-1000] autoDisplay:on
	
	local windHWND
	local pickHWND
	local pos = [10,4]
	local size = [120,22]
	local minmax = [120,300]
	
	on pb picked obj do if obj != undefined do
	(
		w = (gettextextent obj.name).x + 16
		w = amin minmax[2] (amax minmax[1] w)
		if pickHWND != undefined do
		(
			ps = wndclass.GetWindowPosAndSize windHWND[1]
			ss = wndclass.GetWindowPosAndSize pickHWND[1]
			d = (w + 20 - ps[3])/2
			wndclass.SetWindowPos windHWND[1] 0 (ps[1]-d) ps[2] (w+26) ps[4] 0
			wndclass.SetWindowPos pickHWND[1] 0 0 0 w ss[4] 2 -- nomove
		)
	)
	
	on pickRol open do
	(
		windHWND = windows.getChildHWND 0 pickRol.title
		wndclass.SetWindowPos windHWND[1] 0 0 0 (size.x+26) (size.y+40) 2 -- nomove
		
		if (pickHWND = windows.getChildHWND windHWND[1] "Pick a Node") != undefined do
		(
			wndclass.SetWindowPos pickHWND[1] 0 pos.x pos.y size.x size.y 0
		)
	)
)	
createdialog pickRol width:0 height:0