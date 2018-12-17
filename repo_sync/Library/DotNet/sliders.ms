 fn getWinClass = 
 (
 	source = ""
 	source += "using System;\n"
 	source += "using System.Runtime.InteropServices;\n"
 	source += "public class Window\n"
 	source += "{\n"
 	source += "	[DllImport(\"user32.dll\")]\n"
 	source += "	public static extern bool SetWindowPos(int hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);\n"
 	source += "}\n"
 
 	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
 	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
 	compilerParams.GenerateInMemory = on
 	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
 	compilerResults.CompiledAssembly.CreateInstance "Window"
 )
 if wndclass == undefined do global wndclass = getWinClass()
 	
 try(destroydialog sliderRol) catch()
 rollout sliderRol "Little Sliders by denisT"
 (
 	slider s1 width:0 height:0 pos:[0,-100] ticks:0
 	slider s2 width:0 height:0 pos:[0,-100] ticks:0
 	slider s3 width:0 height:0 pos:[0,-100] ticks:0
 	slider s4 width:0 height:0 pos:[0,-100] ticks:0
 	
 	local pos = [10,4]
 	local size = [180,20]
 	
 	on sliderRol open do
 	(
 		hwnd = windows.getChildHWND 0 sliderRol.title
 		sliders = for c in (windows.getChildrenHWND hwnd[1]) where c[4] == "msctls_trackbar32" collect c[1]
 		for k=0 to sliders.count-1 do
 		(
 			::wndclass.SetWindowPos sliders[k+1] 0 pos.x (pos.y + k*size.y) size.x size.y 0
 		)
 	)
 )	
 createdialog sliderRol width:200 height:90
