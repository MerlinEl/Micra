--------------------------------------------------------------------------
--Set the parent of the form to be Max. 
--------------------------------------------------------------------------

--Get the max handle pointer.
maxHandlePointer=(Windows.GetMAXHWND())

--Convert the HWND handle of Max to a dotNet system pointer
sysPointer = DotNetObject "System.IntPtr" maxHandlePointer

--Create a dotNet wrapper containing the maxHWND
maxHwnd = DotNetObject "MaxCustomControls.Win32HandleWrapper" sysPointer

--Show the Max form using the wrapper. 
mXSExtendedForm = dotNetObject "MaxCustomControls.Maxform"
mXSExtendedForm.StartPosition = mXSExtendedForm.StartPosition.Manual
--form.dock = form.dock.left
mXSExtendedForm.bounds = netDrRect [400,200] [800, 600]
mXSExtendedForm.Show (maxHwnd)

--The form (mXSExtendedForm) is now part of the max interface
	
--------------------------------------------------------------------------
--Implement a dialog in to form
--------------------------------------------------------------------------
	
dotNet.LoadAssembly (mcPath()+ "App\\MXSExtendedEditor.dll")
global mXSExtendedForm
global EXTENDED_MAXSCRIPT

struct EXTENDED_MAXSCRIPT
(
	-- Opens the windows to embed to get their handles.
	fn openWindows = 
	(
		actionMan.executeAction 0 "40839" -- Open MXSEditor
		actionMan.executeAction 0 "40469" -- Open new script
		actionMan.executeAction 0 "40472" -- Open MAX Script: MAXScript Listener
	),
	fn setHandles =
	(
		EXTENDED_MAXSCRIPT.openWindows()
		
		editorHandle = (windows.getchildhwnd 0 "(Untitled) - MAXScript")[1]
		editorHandle =  dotNetObject "IntPtr" editorHandle
		listenerHandle = (windows.getChildHwnd 0 "MAXScript Listener")[1]
		listenerHandle =  dotNetObject "IntPtr" listenerHandle
		parentHandle = windows.getMaxHWND() 
		parentHandle = dotNetObject "IntPtr" parentHandle
		explorerHandle = 0 --(windows.getChildHwnd 0 "Script Manager:")[1]
		explorerHandle = dotNetObject "IntPtr" explorerHandle
		
		mXSExtendedForm.SetScriptHandles editorHandle listenerHandle parentHandle explorerHandle
		mXSExtendedForm.EmbedScriptWindows()
	),
	fn run =
	(
		-- Set the parent of mXSExtendedForm to be MAX.  Necessary to show new dialogs correctly 
		maxHWND = dotNetObject "System.IntPtr" ( Windows.GetMAXHWND() )
		maxHWND = dotNetObject "MaxCustomControls.Win32HandleWrapper" maxHWND
			
		mXSExtendedForm = dotNetObject "MXSExtendedEditor.MainForm"
		EXTENDED_MAXSCRIPT.setHandles()		
		mXSExtendedForm.show maxHWND
	),
	fn show = (mXSExtendedForm.show maxHWND)
)

EXTENDED_MAXSCRIPT.run()
/*
currentTab = for i in windows.getchildrenhwnd mXSExtendedForm.handle where i[4] == "MXS_SciTEWindow" do exit with 
									for j in windows.getchildrenhwnd i[1] where j[4] == "MXS_Scintilla" do exit with j[1]
		if currentTab != undefined then
		mXSExtendedForm.MXSCurrentTabHandle = dotNetObject "IntPtr" currentTab
*/		
	



	