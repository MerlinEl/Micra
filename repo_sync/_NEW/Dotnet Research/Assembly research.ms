=================================================================================================
local sme_av = sme.activeView
local viewNode = sme.GetView sme_av
viewNode.SetFocus()
actionMan.executeAction 369891408 "40063" /* SME: Select All */
actionMan.executeAction 369891408 "40075" /* SME: Hide Unused Nodeslots */
actionMan.executeAction 369891408 "40064" /* SME: Select None */
actionMan.executeAction 369891408 "40060" /* arrange the view */


nodeViewImp = sme.GetView sme.activeView
nodeViewImp.SelectAll()
nodeViewImp.ZoomExtents() #all
=================================================================================================


windows.sendMessage <smeHWND> 0x111 40048 0 -- toggle Hide Unused Nodeslots
windows.sendMessage <smeHWND> 0x111 40023 0 -- select ALL
windows.sendMessage SMEwin 0x111 40048 0 -- toggle Hide Unused Nodeslots
windows.sendMessage SMEwin 0xC752 0 0 -- apply changes??

=================================================================================================
edt.TextAlign
edt = dotNetObject "textBox"


msx_editor = for c in (windows.getchildrenhwnd 0) where c[4] == "MXS_SciTEWindow" do exit with c
msx_dll = UIAccessor.GetWindowDllFileName msx_editor[1]

mat_editor = for c in (windows.getchildrenhwnd 0) where c[4] == "Material Editor" do exit with c


SMEwin = (windows.getChildHWND 0 "Slate Material Editor")[1] -- Get the HWND of the Slate Material Editor
SMElayout = (windows.getChildrenHWND SMEwin)[19][1] -- Get the HWND of the current Layout All button, 16th item in the SMEWin children array


children = UIAccessor.getChildWindows 0
for child in children do (

	local win_text = UIAccessor.getWindowText child
	if findString win_text "Material Editor" == undefined do continue
	format "%\n" child
)
mat1_dll = UIAccessor.GetWindowDllFileName 788980P
mat2_dll = UIAccessor.GetWindowDllFileName 330628P
theMCC = dotnet.loadAssembly @"C:\Program Files\Autodesk\3ds Max 2018\res1.dll"





theMCC = dotnet.loadAssembly @"C:\Program Files\Autodesk\3ds Max 2018\MaxCustomControls.dll"
theMCC = dotnet.loadAssembly @"C:\Program Files\Autodesk\3ds Max 2018\MXS_SciTE.DLL"
theMCC = dotnet.loadAssembly @"

format "ASSEMBLY PROPERTIES:\n"
showProperties theMCC
format "ASSEMBLY METHODS:\n"
showMethods theMCC
theTypes = theMCC.GetExportedTypes()
for t in theTypes do
(
	format "TYPE: \"%\"\n" t.fullname
	theObj = try(dotNetObject t.FullName)catch(dotNetClass t.fullname)
	format "CONSTRUCTORS:\n"
	dotNet.showConstructors theObj
	format "PROPERTIES:\n"
	showProperties theObj
	format "METHODS:\n"
	showMethods theObj
	format "EVENTS:\n"
	showEvents theObj
	format "\n\n"
)


=================================================================================================

/* LAYOUT VIEW START */
 
SMEwin = (windows.getChildHWND 0 "Slate Material Editor")[1] -- Get the HWND of the Slate Material Editor
SMElayout = (windows.getChildrenHWND SMEwin)[19][1] -- Get the HWND of the current Layout All button, 16th item in the SMEWin children array
nodeViewImp.SetFocus()
 
/* SelectAll() Doesn't work */
nodeViewImp.SelectAll()
 
windows.sendMessage SMEwin 0x111 40048 0 -- toggle Hide Unused Nodeslots
UIAccessor.PressButton SMElayout
nodeViewImp.SelectNone()
 
/* LAYOUT VIEW END */

=================================================================================================

=================================================================================================

RENDER SCENE DIALOG

=================================================================================================
  global _user32
  fn create_user32Assembly forceRecompile:on = if forceRecompile or not iskindof ::_user32Assembly dotnetobject do
  (
  	source  = "using System;
"
  	source += "using System.Runtime.InteropServices;
"
  	source += "class User32
"
  	source += "{
"
  	source += " 	[DllImport(\"user32.dll\", EntryPoint=\"SetWindowPos\")]
"
  	source += " 	public static extern bool SetWindowPos(IntPtr hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);
"
  	source += " 	[DllImport(\"user32.dll\")]
"
  	source += " 	public static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);
"
  	source += "}
"
  
  	csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
  	compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
  
  	compilerParams.ReferencedAssemblies.AddRange #("System.dll")
  
  	compilerParams.GenerateInMemory = true
  	compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
  	
  	_user32 = (compilerResults.CompiledAssembly).CreateInstance "User32"
  )
  create_user32Assembly()
  
  try(destroydialog RenderSetupChild) catch()
  rollout RenderSetupChild "Render Setup Child" width:347 height:54
  (
  	local d_hwnd = if d_hwnd != undefined do d_hwnd
  	local c_ptr, p_ptr
  	
  	groupbox gb pos:[4,-3] width:339 height:56
  		checkbox undoable_ch "Undoable" checked:on pos:[20,9]
  		button delete_bt "Delete All Render Elements" pos:[11,28] width:324
  
  	checkbutton display_bt width:14 height:14 pos:[1,1] tooltip:"Open Extras"
  
  	on delete_bt pressed do undo "Delete Render Elements" undoable_ch.state
  	(
  		rem = maxOps.GetCurRenderElementMgr()
  		if undoable_ch.state then 
  		(
  			for k = rem.NumRenderElements() - 1 to 0 by -1 do rem.RemoveRenderElement (rem.GetRenderElement k)
  		)
  		else rem.RemoveAllRenderElements() -- don't use because it's not undoable
  	)
  	on display_bt changed state do 
  	(
  		setfocus undoable_ch
  		if state then _user32.SetWindowPos c_ptr 0 0 0 347 54 2
  		else _user32.SetWindowPos c_ptr 0 0 0 15 15 0
  	)
  	on RenderSetupChild open do if (uiaccessor.iswindow d_hwnd) do
  	(
  		c_ptr = dotnetobject "IntPtr" (windows.getchildhwnd 0 RenderSetupChild.title)[1]
  		p_ptr = dotnetobject "IntPtr" d_hwnd
  
  		_user32.SetParent c_ptr p_ptr
  		_user32.SetWindowPos c_ptr 0 0 0 15 15 0
  	)
  )
  
  RenderSceneDialog.open()
  hwnd = for hwnd in uiaccessor.getpopupdialogs() where matchpattern ((uiaccessor.getwindowtext hwnd) as string) pattern:"Render Setup*" do exit with hwnd 
  RenderSetupChild.d_hwnd = hwnd
  createdialog RenderSetupChild style:#()
  =================================================================================================
  
  
  
  =================================================================================================
  
  How To Make Max Script Incremental Save?

  =================================================================================================
  
   /************************************************************
 by denisT
 
 Use at your own RISK!
 ************************************************************/
 
 global WinAssembly
 fn CreateWinAssembly forceRecompile:off =
 (
 	if forceRecompile or not iskindof ::WinAssembly dotnetobject or (::WinAssembly.GetType()).name != "Assembly" do
 	(
 		source  = "using System;
"
 		source += "using System.Runtime.InteropServices;
"
 		source += "using System.Text;
"
 		source += "class Win_User32
"
 		source += "{
"
 		source += " [DllImport(\"user32.dll\")]
"
 		source += " public static extern bool SetWindowPos(IntPtr hWnd, int hWndArg, int Left, int Top, int Width, int Height, int hWndFlags);
"
 		source += " [DllImport(\"user32.dll\")]
"
 		source += " public static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);
"
 		source += "	[DllImport(\"user32.dll\")]
"
 		source += "	static extern bool GetClientRect(IntPtr hWnd, out POS rect);
"
 		source += "	public struct POS
"
 		source += "	{
"
 		source += "		public int Left;
"
 		source += "		public int Top;
"
 		source += "		public int Right;
"
 		source += "		public int Bottom;
"
 		source += "	}
"
 		source += "	public int[] GetClientRect(IntPtr hWnd)
"
 		source += "	{
"
 		source += "		POS rect;
"
 		source += "		if ( GetClientRect(hWnd, out rect) )
"
 		source += "		{
"
 		source += "			return new int[] { rect.Left, rect.Top, rect.Right - rect.Left, rect.Bottom - rect.Top };
"
 		source += "		}
"
 		source += "		return null;
"
 		source += "	}
"
 		source += "}
"
 
 		csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
 		compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
 						
 		compilerParams.GenerateInMemory = on
 		compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source)
 		
 		WinAssembly = compilerResults.CompiledAssembly
 		WinAssembly.CreateInstance "Win_User32"
 	)
 )
 global Win_User32 = if Win_User32 == undefined then CreateWinAssembly() else Win_User32
 --global Win_User32 = CreateWinAssembly forceRecompile:on
 
 DialogMonitorOPS.unRegisterNotification id:#saveAsMonitor
 /***** for Debug only ********
 DialogMonitorOPS.Enabled = off
 *****************************/
  
 fn saveAs_notification = 
 (
 	local hwnd, name, owner
 	
 	name = if UIAccessor.isWindow (hwnd = DialogMonitorOPS.GetWindowHandle()) do UIAccessor.GetWindowText hwnd
 	if (name == "Save File") or (name == "Save a Copy") do
 	(
 		owner = UIAccessor.GetParentWindow hwnd
 		if getfilenamefile (UIAccessor.GetWindowDllFileName owner) == "MXS_SciTE" do 
 		(
 			-- format "Dialog Window Handle: %
" hwnd
 
 			rollout inc_rol "Increment File Name" 
 			(
 				local ui
 				button inc_bt "+" width:0 height:0 tooltip:"Incremental Save/RC - Increment Filename"
 				
 				fn incrementFilename filename = 
 				(
 					file = getfilenamefile filename
 					body = trimRight file "0123456789"
 					id = if not iskindof (id = execute (replace file 1 body.count "")) Integer then 1 else (id+1)
 					body + (formattedprint id format:"02d") + (getfilenametype filename)
 				)
 				fn getIncremental saveit:off =
 				(
 					local filename = UIAccessor.GetWindowText ui[2]
 					if filename != "" do
 					(
 						UIAccessor.SetWindowText ui[2] (incrementFilename filename)
 						if saveit do UIAccessor.PressButton ui[3]
 					)
 --					setfocus inc_rol
 				)
 				on inc_bt pressed do getIncremental saveit:on
 				on inc_bt rightClick do getIncremental saveit:off
 			)
 			createdialog inc_rol 0 0 style:#()
 			
 			input = UIAccessor.GetNextWindow (windows.getChildHWND hwnd "File &name:")[1]
 			save_bt = (windows.getChildHWND hwnd "&Save")[1]
 			inc_rol.ui = #(hwnd, input, save_bt)
 
 			d_ptr = dotnetobject "IntPtr" (d = (windows.getChildHWND 0 inc_rol.title)[1])
 			b_ptr = dotnetobject "IntPtr" (windows.getChildHWND d "+")[1]
 
 			s_ptr = dotnetobject "IntPtr" save_bt
 			rect = Win_User32.GetClientRect s_ptr
 			b_size = [rect[4]-4, rect[4]-4]
 
 			::Win_User32.SetParent d_ptr s_ptr
 			::Win_User32.SetWindowPos d_ptr 0 (rect[3]-b_size.x-2) 2 b_size.x b_size.y 0
 			::Win_User32.SetWindowPos b_ptr 0 0 0 b_size.x b_size.y 0
 			
 			-- format "-- the end --
"
 		)
 	)
 	true
 )
 
 DialogMonitorOPS.RegisterNotification saveAs_notification id:#saveAsMonitor
 DialogMonitorOPS.Enabled = on
 DialogMonitorOPS.ShowNotification()
   