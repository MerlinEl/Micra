(
	str="using System;\n"
	str+="using System.Collections.Generic;\n"
	str+="using System.Text;\n"
	str+="using System.Runtime.InteropServices;\n"
	str+="using System.Windows.Forms;\n"
	str+="using System.Diagnostics;\n"
	str+="using System.Drawing;\n"
	str+="class InterceptMouse\n"
	str+="{\n"
	str+="   private static IntPtr _hookID = IntPtr.Zero;\n"
	str+="   private IntPtr MaxHwnd;\n"
	str+="	private bool restrictToMax;\n"
	str+="	public IntPtr Handle\n"
	str+="	{\n"
	str+="		get\n"
	str+="		{\n"
	str+="			return MaxHwnd;\n"
	str+="		}\n"
	str+="		set\n"
	str+="		{\n"
	str+="			if (value!=MaxHwnd)\n"
	str+="			{\n"
	str+="				MaxHwnd=value;\n"
	str+="			}\n"
	str+="		}\n"
	str+="	}\n"
	str+="	public bool RestrictToMax\n"
	str+="	{\n"
	str+="		get\n"
	str+="		{\n"
	str+="			return restrictToMax;\n"
	str+="		}\n"
	str+="		set\n"
	str+="		{\n"
	str+="			if (value==true && MaxHwnd!=IntPtr.Zero || value==false) restrictToMax=value;\n"
	str+="		}\n"
	str+="	}\n"
	str+="	public delegate void MouseDownHandler(object Sender, MouseEventArgs e);\n"
	str+="	public event MouseDownHandler MouseDown;\n"
	str+="	public delegate void MouseUpHandler(object Sender, MouseEventArgs e);\n"
	str+="	public event MouseUpHandler MouseUp;\n"
	str+="	public delegate void MouseMoveHandler(object Sender, MouseEventArgs e);\n"
	str+="	public event MouseMoveHandler MouseMove;\n"
	str+="	public delegate void MouseWheelHandler(object Sender, MouseEventArgs e);\n"
	str+="	public event MouseWheelHandler MouseWheel;\n"
		
	str+="	public InterceptMouse()\n"
	str+="	{\n"
	str+="   	 _hookID = SetHook(HookCallback);\n"
	str+="		MaxHwnd = IntPtr.Zero;\n"
	str+="		restrictToMax = false;\n"
	str+="	}\n"

	str+="	public void Release()\n"
	str+="	{\n"
	str+="		UnhookWindowsHookEx(_hookID);\n"
	str+="	}\n"
	
	str+="	private static IntPtr SetHook(LowLevelMouseProc proc)\n"
	str+="	{\n"
	str+="   	 using (Process curProcess = Process.GetCurrentProcess())\n"
	str+="   	 using (ProcessModule curModule = curProcess.MainModule)\n"
	str+="   	 {\n"
	str+="    	    return SetWindowsHookEx(WH_MOUSE_LL, proc,\n"
	str+="            GetModuleHandle(curModule.ModuleName), 0);\n"
	str+="   	 }\n"
	str+="	}\n"
	
	str+="	private bool IsMaxParent()\n"
	str+="	{\n"
	str+="		return (GetAncestor(GetForegroundWindow(),3)==MaxHwnd);\n"
	str+="	}\n"

	str+="	private delegate IntPtr LowLevelMouseProc(int nCode, IntPtr wParam, IntPtr lParam);\n"

	str+="	private IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)\n"
	str+="	{\n"
	str+=" 	  if ((!restrictToMax || IsMaxParent()) && nCode >= 0)\n"
	str+="		{\n"
	str+="			MSLLHOOKSTRUCT hookStruct = (MSLLHOOKSTRUCT)Marshal.PtrToStructure(lParam, typeof(MSLLHOOKSTRUCT));\n"
	str+="			if (MouseMessages.WM_LBUTTONDOWN == (MouseMessages)wParam)\n"
	str+="			{\n"
	str+="				MouseEventArgs e = new MouseEventArgs(MouseButtons.Left,1,hookStruct.pt.x  ,hookStruct.pt.y,0);\n"
	str+="       	  	MouseDown(this, e);\n"
	str+="			}\n"
	str+="			else if (MouseMessages.WM_LBUTTONUP == (MouseMessages)wParam)\n"
	str+="			{			\n"
	str+="				MouseEventArgs e = new MouseEventArgs(MouseButtons.Left,1,hookStruct.pt.x  ,hookStruct.pt.y,0);\n"
	str+="				MouseUp(this, e);\n"
	str+="			}\n"
	str+="			else if (MouseMessages.WM_MOUSEMOVE == (MouseMessages)wParam)\n"
	str+="			{\n"
	str+="				MouseEventArgs e = new MouseEventArgs(MouseButtons.None,0,hookStruct.pt.x  ,hookStruct.pt.y,0);\n"
	str+="           	MouseMove(this, e);\n"
	str+="			}\n"
	str+="			else if (MouseMessages.WM_RBUTTONDOWN == (MouseMessages)wParam)\n"
	str+="			{\n"
	str+="				MouseEventArgs e = new MouseEventArgs(MouseButtons.Right,1,hookStruct.pt.  x,hookStruct.pt.y,0);\n"
	str+="           	MouseDown(this, e);\n"
	str+="			}\n"
	str+="			else if (MouseMessages.WM_RBUTTONUP == (MouseMessages)wParam)\n"
	str+="			{\n"
	str+="				MouseEventArgs e = new MouseEventArgs(MouseButtons.Right,1,hookStruct.pt.  x,hookStruct.pt.y,0);\n"
	str+="				MouseUp(this, e);\n"
	str+="			}\n"
	str+="			else if (MouseMessages.WM_MOUSEWHEEL == (MouseMessages)wParam)\n"
	str+="			{\n"
	str+="				int delta = (int)((hookStruct.mouseData & (0xFFFF << 16)))/120;\n"
	str+="				MouseEventArgs e = new MouseEventArgs(MouseButtons.None,1,hookStruct.pt.  x,hookStruct.pt.y,delta);\n"
	str+="				MouseWheel(this, e);\n"
	str+="			}\n"
	str+="		}\n"
	str+="       return CallNextHookEx(_hookID, nCode, wParam, lParam);\n"
	str+="   }\n"

	str+="   private const int WH_MOUSE_LL = 14;\n"

	str+="   private enum MouseMessages\n"
	str+="  	{\n"
	str+="		WM_LBUTTONDOWN = 0x0201,\n"
	str+="       WM_LBUTTONUP = 0x0202,\n"
	str+="		WM_MOUSEMOVE = 0x0200,\n"
	str+="		WM_MOUSEWHEEL = 0x020A,\n"
	str+="		WM_RBUTTONDOWN = 0x0204,\n"
	str+="		WM_RBUTTONUP = 0x0205\n"
	str+="   }\n"

	str+="	[StructLayout(LayoutKind.Sequential)]\n"
	str+="	private struct POINT\n"
	str+="	{\n"
	str+="		public int x;\n"
	str+="		public int y;\n"
	str+="	}\n"
	
	str+="	[StructLayout(LayoutKind.Sequential)]\n"
	str+="	private struct MSLLHOOKSTRUCT\n"
	str+="	{\n"
	str+="		public POINT pt;\n"
	str+="		public uint mouseData;\n"
	str+="		public uint flags;\n"
	str+="		public uint time;\n"
	str+="		public IntPtr dwExtraInfo;\n"
	str+="	}\n"

	str+="	[DllImport(\"user32.dll\", CharSet = CharSet.Auto, SetLastError = true)]\n"
	str+="	public static extern IntPtr GetAncestor(IntPtr hWnd, int type);\n"
	str+="	[DllImport(\"user32.dll\", CharSet = CharSet.Auto, SetLastError = true)]\n"
	str+="	public static extern IntPtr GetForegroundWindow();\n"
	str+="	[DllImport(\"user32.dll\", CharSet = CharSet.Auto, SetLastError = true)]\n"
	str+="	private static extern IntPtr SetWindowsHookEx(int idHook,\n"
	str+="   	LowLevelMouseProc lpfn, IntPtr hMod, uint dwThreadId);\n"
	str+="	[DllImport(\"user32.dll\", CharSet = CharSet.Auto, SetLastError = true)]\n"
	str+="	[return: MarshalAs(UnmanagedType.Bool)]\n"
	str+="	private static extern bool UnhookWindowsHookEx(IntPtr hhk);\n"
	str+="	[DllImport(\"user32.dll\", CharSet = CharSet.Auto, SetLastError = true)]\n"
	str+="	private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode,\n"
	str+="		IntPtr wParam, IntPtr lParam);\n"
	str+="	[DllImport(\"kernel32.dll\", CharSet = CharSet.Auto, SetLastError = true)]\n"
	str+="	private static extern IntPtr GetModuleHandle(string lpModuleName);\n"		
	str+="}\n"

	try(mousehook.mouseops.release())catch()
	global mouseHook
	struct mouseHookStr
	(
		mouseOps,
		
		fn CreateWinAssembly =
		(
			local csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
			local compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
				
			compilerParams.ReferencedAssemblies.addRange #("System.dll","System.Windows.Forms.dll","System.Drawing.dll")
			compilerParams.GenerateInMemory = on
			local compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(str)
			
			for er =0 to compilerResults.errors.count-1 do print (compilerResults.errors.item[er].tostring())
			mouseOps = compilerResults.CompiledAssembly.CreateInstance "InterceptMouse"
			mouseOps.handle = (dotNetObject "System.IntPtr" (windows.GetMaxHwnd()))
			mouseOps.restrictToMax = on
		),
		
		fn mouseDown s e = print "mouse down",
		fn mouseUp s e = print "mouse up",
		fn mouseMove s e = print "mouse move",
		fn mouseWheel s e = format "Mousewheel delta: %\n" e.delta,

		fn initStruct =
		(
			CreateWinAssembly()
			dotNet.addEventHandler mouseOps "MouseDown" mouseDown
			dotNet.addEventHandler mouseOps "MouseUp" mouseUp
			--dotNet.addEventHandler mouseOps "MouseMove" mouseMove
			dotNet.addEventHandler mouseOps "MouseWheel" mouseWheel
		),
		
		_init = initStruct()	
	)
	mouseHook = mouseHookStr()
)

-- call mousehook.mouseops.release() to stop it