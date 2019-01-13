/*
	MXS_Help.ms
	MaxScript Local Help Launcher
	dotnet User32 magic  vastely inspired by DenisT
*/

/*
macroscript MXS_HELP
category:"MAX Script"
toolTip:"Context Help"
(
	
	on execute do
	(
*/
		fn CreateWin32Assembly forceRecompile:off =
		(
			if forceRecompile or not iskindof ::Win32Assembly dotnetobject or (::Win32Assembly.GetType()).name != "Assembly" do
			(
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

				Win32Assembly = compilerResults.CompiledAssembly
				Win32Assembly.CreateInstance "Win32"
			)
		)
		
		global Win32 = CreateWin32Assembly()

		/* Launches IE
		*/
		fn LaunchHelp str =
		(
			MXS_HELP_DIR="D:/3D/3ds Max 2012/help/maxscript-doc-2012/"
			IE32 = "C:\\Program Files (x86)\\Internet Explorer\\iexplore.exe"
			IE = "C:\\Program Files\\Internet Explorer\\iexplore.exe"
			url="file:///"+MXS_HELP_DIR+"index.html"
			if str.count>0 do url += ("?query=" + str)
			--ShellLaunch url "" -- :( :( :( DOES NOT PLAY WITH FIREFOX...
			-- This Works wIth x64 Windows
			if doesFileExist IE32 then ShellLaunch IE32 url
			else if doesFileExist IE then ShellLaunch IE url
			else ShellLaunch url ""
		)
		
		fn GetWordatCarretPos =
		(
			/* Retreives a complete Word (made of valid chars) at a given position in a string
			*/
			fn GetWord str pos =
			(
				fn isStopChar s =
				(
					local valid = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789"
					local i =  findstring valid s
					if i == undefined or i == 0 then true else false
				)
				
				local start=pos, end=pos, res=""
				start = if isStopChar str[pos] then (pos+1)
				else if isStopChar str[pos-1] then pos else (for i = pos to 1 by -1 do if isStopChar str[i] do exit with (i+1))
				end = if isStopChar str[pos+1] then (pos+1) else (for i = (pos+1) to str.count do if isStopChar str[i] do exit with (i))
				res = substring str start (end-start)
				res
			)
			
			fn _mxs_Textbox =
			(
				tb = for c in (windows.getchildrenhwnd 0) where c[4] == "MXS_SciTEWindow" do exit with
				(
					for t in (windows.getchildrenhwnd c[1]) where t[4] == "MXS_Scintilla" do exit with t[1]
				)
				if tb != ok then tb else undefined
			)
			
			EM_GETSEL = 0x00B0
			tb = _mxs_Textbox()
			tx = Win32.GetWindowText tb
			Win32.SetFocus tb
			CarretPos = (windows.sendmessage tb EM_GETSEL 0 0)/65535
			GetWord tx CarretPos
		)
		LaunchHelp (GetWordatCarretPos())
/*
	)
)
*/