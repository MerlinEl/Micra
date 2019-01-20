Global mcMSXE
struct MICRA_MSX_EDITOR (
	
	msx_hwnd = ( --MSX Editor handle
		
		for c in (windows.getchildrenhwnd 0) where c[4] == "MXS_SciTEWindow" do exit with c[1]
	),
	tb_hwnd = ( --Scintilla TextBox handle
		if msx_hwnd == undefined do return undefined
		for c in (windows.getchildrenhwnd msx_hwnd) where c[4] == "MXS_Scintilla" do exit with c[1]
	),
	fn close = (if msx_hwnd == undefined do retrun false; windows.sendmessage msx_hwnd mcWinMsg.WM_CLOSE 0 0), --OK
	fn copySel = (if tb_hwnd == undefined do retrun false; windows.sendmessage tb_hwnd mcWinMsg.WM_COPY 0 0), --OK
	fn paste = (if tb_hwnd == undefined do retrun false; windows.sendmessage tb_hwnd mcWinMsg.WM_PASTE 0 0), --OK
	fn clearAll = (if tb_hwnd == undefined do retrun false; windows.sendmessage tb_hwnd mcWinMsg.WM_CLEAR 0 0), --not works (works like backspace not clear all text)
	fn getSel = (if tb_hwnd == undefined do retrun false; windows.sendmessage tb_hwnd mcWinMsg.EM_GETSEL 0 0), --not works
	fn findStr str = ( --OK
		
		if tb_hwnd == undefined do retrun false
		local current_script_text = mcWin32.GetWindowText tb_hwnd
		local str_pos = findString current_script_text str
		if str_pos != undefined do (
			
			windows.sendmessage tb_hwnd mcWinMsg.EM_SETSEL (str_pos-1) (str_pos+str.count-1)
			mcWin32.SetFocus tb_hwnd
		)
		str_pos
	),
	fn insertAt offset_pos str = (  --need  fix
		
		if tb_hwnd == undefined do retrun false
		local marshal = dotnetclass "System.Runtime.InteropServices.Marshal"
		local ptr = marshal.StringToHGlobalUni str
		windows.sendmessage tb_hwnd mcWinMsg.EM_REPLACESEL offset_pos ptr 
		mcWin32.SetFocus tb_hwnd
		/*
		int_ptr = marshal.StringToHGlobalUni "abcd"
		marshal.PtrToStringUni (dotnetObject "System.IntPtr" int_ptr)
		*/
	)
	/*<end>*/
)
mcMSXE = MICRA_MSX_EDITOR()


/*
mcMSX.close()
mcMSX.copySel()
mcMSX.paste()
mcMSX.clearAll() --not works (works like backspace not clear all text)
mcMSX.getSel() --return integer not String
insert_pos = mcMSX.findStr "MICRA_MSX_EDITOR"
mcMSX.insertAt  insert_pos "here you are :-)" --need  fix
*/

UIAccessor.GetWindowText tb
UIAccessor.SetWindowText tb " All Your Windows Are Belong To Us"
UIAccessor.GetWindowClassName tb --MXS_Scintilla
UIAccessor.GetWindowResourceID tb --350
UIAccessor.GetChildWindows tb --#()
UIAccessor.GetParentWindow tb --263932PEM_REPLACESEL
UIAccessor.IsWindow  tb --true
UIAccessor.GetWindowDllFileName tb --"C:\Program Files\Autodesk\3ds Max 2014\MXS_SciTE.DLL"
UIAccessor.GetWindowDllDescription tb --""
--UIAccessor.CloseDialog tb --don't do int :-D
UIAccessor.SendMessageID tb mcWinMsg.EM_GETSEL --not works return false
UIAccessor.SendMessage tb mcWinMsg.WM_COPY 0 0 --copy selected text
UIAccessor.SendMessage tb mcWinMsg.WM_PASTE 0 0 --copy selected text
UIAccessor.PressButton <HWND>hwnd 
UIAccessor.PressButtonByName <HWND>hwnd <string>name 
--WM_PASTE


mcWin32.setWindowText
mystring = DotNetObject "System.String" "my_string_literate"
windows.postMessage tb mcWinMsg.WM_PASTE mystring 0
windows.sendmessage tb mcWinMsg.WM_PASTE 0  0
windows.sendmessage  tb EM_GETSEL 0 0

showInterfaces WindowHandle

fn dmnotification = (
	
	--local WindowHandle = DialogMonitorOPS.GetWindowHandle() --Returns the Window Handle of the current dialog
	local WindowHandle = getMSXScintilaTextboxHWD()
	format "Is Window: %\n" (UIAccessor.isWindow WindowHandle)
	format "=====================\n"
	true
)
DialogMonitorOPS.RegisterNotification dmnotification id:#eyeInTheSky
DialogMonitorOPS.Enabled = true
DialogMonitorOPS.ShowNotification()
DialogMonitorOPS.UnRegisterNotification id:#eyeInTheSky



theHwnd = (dotNetObject "System.Windows.Forms.NativeWindow").FromHandle WindowHandle




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
dll_MXSEshowCalltip.SendMessage tb mcWinMsg.EM_REPLACESEL  0 "abc"
dll_MXSEshowCalltip.SendMessage tb mcWinMsg.EM_SETSEL 0 7


