-- WindowShopper by Rotem Shiffman (c)2011 --

(
try(::windowShopper.dnFm.close())catch()
clearListener()
global windowShopper
struct windowShopperStr
(	
	--COMPONENTS
	dnTL,
	dnFm,
	controls,	
	wrapper,
	splitter,
	vSplitter,
	thisWrapper,	
	user32,
	msgSnooper,
	msgList,
	lastMsgCode,
	hlForm,	
	hlTimer,
	
	--INCLUDE/EXCLUE COMPONENTS
	excPanel,
	excList = #(),
	
	--OPTIMIZATION
	intPtr = dotnetClass "System.intPtr",	
	rctCls = dotnetClass "System.Drawing.Rectangle",
	lvI = dotNetClass "ListViewItem",
	
	--DATA STATES
	hlTimerTicks = 0,
	
	--USER OPTIONS
	showInvisible = off,
	flashFrame = on,
	msgSnooping = on,
	
	--FUNCTIONS
	fn createAssembly =
	(		
		str="using System;\n"
		str+="using System.Runtime.InteropServices;\n"
		str+="using System.Windows.Forms;\n"
		str+="namespace WindowShopper\n"
		str+="{\n"
		str+="class MessageSnooper : NativeWindow\n"
		str+="{\n"
		str+="	public delegate void MessageHandler(object msg);\n"
		str+="	public event MessageHandler MessageEvent;\n"
		str+="	protected override void WndProc(ref Message m)\n"
		str+="	{\n"
		str+="		if (MessageEvent != null) MessageEvent((object)m);\n"
        str+="		base.WndProc(ref m);\n"
		str+="	}\n"
		str+="}\n"
		str+="class User32\n"
		str+="{\n"
		str+="	 public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }\n"     
		str+="	 [DllImport(\"user32.dll\")]\n"
		str+="	 private static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);\n" 
		str+="	 [DllImport(\"user32.dll\")]\n"
		str+="	 public static extern bool IsWindowVisible(IntPtr hWnd);\n" 
		str+="	 public int[] GetWindowRect(IntPtr hWnd)\n"
		str+="   {\n"
		str+="       RECT rect;\n"
		str+="       if (GetWindowRect(hWnd, out rect))\n"
		str+="       {\n"
		str+="           return new int[4] {rect.Left, rect.Top, rect.Right - rect.Left, rect.Bottom - rect.Top };\n"
		str+="       }\n"
		str+="       else return null;\n"
		str+="    }\n"
		str+="}\n"
		str+="}\n"

		local csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
		local compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
		compilerParams.ReferencedAssemblies.addRange #("System.dll","System.Windows.Forms.dll","System.Drawing.dll")
		compilerParams.GenerateInMemory = on
		local compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(str)
		
		for er =0 to compilerResults.errors.count-1 do print (compilerResults.errors.item[er].tostring())
		user32 = compilerResults.CompiledAssembly.CreateInstance "WindowShopper.User32"
		msgSnooper = compilerResults.CompiledAssembly.CreateInstance "WindowShopper.MessageSnooper"
	),
	
	fn showInvisibleToggle s e =
	(
		windowShopper.showInvisible = s.checked
		windowShopper.refresh()
	),
	
	fn flashWindowToggle s e =
	(
		windowShopper.flashFrame = s.checked
	),
	
	fn clearMsgWindow s e =
	(
		windowShopper.msgList.rows.clear()
	),
	
	fn msgSnooperToggle s e =
	(
		windowShopper.msgSnooping = s.checked
		if not s.checked then windowShopper.msgSnooper.releaseHandle()
		else if windowShopper.dnTL.selection.count > 0 do
		(
			local intPt = dotnetObject windowShopper.intPtr windowShopper.dnTL.selection.item[0].item[2]
			windowShopper.msgSnooper.assignHandle intPt
		)
	),
	
	fn getMsgName code =
	(
		case code of
		(
			0x0000: ("WM_NULL");0x0001: ("WM_CREATE");0x0002: ("WM_DESTROY");0x0003: ("WM_MOVE")
			0x0005: ("WM_SIZE");0x0006: ("WM_ACTIVATE");0x0007: ("WM_SETFOCUS");0x0008: ("WM_KILLFOCUS")
			0x000A: ("WM_ENABLE");0x000B: ("WM_SETREDRAW");0x000C: ("WM_SETTEXT");0x000D: ("WM_GETTEXT")
			0x000E: ("WM_GETTEXTLENGTH");0x000F: ("WM_PAINT");0x0010: ("WM_CLOSE");0x0011: ("WM_QUERYENDSESSION")
			0x0012: ("WM_QUIT");0x0013: ("WM_QUERYOPEN");0x0014: ("WM_ERASEBKGND");0x0015: ("WM_SYSCOLORCHANGE")
			0x0016: ("WM_ENDSESSION");0x0018: ("WM_SHOWWINDOW");0x001A: ("WM_WININICHANGE");0x001A: ("WM_SETTINGCHANGE")
			0x001B: ("WM_DEVMODECHANGE");0x001C: ("WM_ACTIVATEAPP");0x001D: ("WM_FONTCHANGE");0x001E: ("WM_TIMECHANGE")
			0x001F: ("WM_CANCELMODE");0x0020: ("WM_SETCURSOR");0x0021: ("WM_MOUSEACTIVATE");0x0022: ("WM_CHILDACTIVATE")
			0x0023: ("WM_QUEUESYNC");0x0024: ("WM_GETMINMAXINFO");0x0026: ("WM_PAINTICON");0x0027: ("WM_ICONERASEBKGND")
			0x0028: ("WM_NEXTDLGCTL");0x002A: ("WM_SPOOLERSTATUS");0x002B: ("WM_DRAWITEM");0x002C: ("WM_MEASUREITEM")
			0x002D: ("WM_DELETEITEM");0x002E: ("WM_VKEYTOITEM");0x002F: ("WM_CHARTOITEM");0x0030: ("WM_SETFONT")
			0x0031: ("WM_GETFONT");0x0032: ("WM_SETHOTKEY");0x0033: ("WM_GETHOTKEY");0x0037: ("WM_QUERYDRAGICON")
			0x0039: ("WM_COMPAREITEM");0x003D: ("WM_GETOBJECT");0x0041: ("WM_COMPACTING");0x0044: ("WM_COMMNOTIFY")
			0x0046: ("WM_WINDOWPOSCHANGING");0x0047: ("WM_WINDOWPOSCHANGED");0x0048: ("WM_POWER");0x004A: ("WM_COPYDATA")
			0x004B: ("WM_CANCELJOURNAL");0x004E: ("WM_NOTIFY");0x0050: ("WM_INPUTLANGCHANGEREQUEST");0x0051: ("WM_INPUTLANGCHANGE")
			0x0052: ("WM_TCARD");0x0053: ("WM_HELP");0x0054: ("WM_USERCHANGED");0x0055: ("WM_NOTIFYFORMAT")
			0x007B: ("WM_CONTEXTMENU");0x007C: ("WM_STYLECHANGING");0x007D: ("WM_STYLECHANGED");0x007E: ("WM_DISPLAYCHANGE")
			0x007F: ("WM_GETICON");0x0080: ("WM_SETICON");0x0081: ("WM_NCCREATE");0x0082: ("WM_NCDESTROY")
			0x0083: ("WM_NCCALCSIZE");0x0084: ("WM_NCHITTEST");0x0085: ("WM_NCPAINT");0x0086: ("WM_NCACTIVATE")
			0x0087: ("WM_GETDLGCODE");0x0088: ("WM_SYNCPAINT");0x00A0: ("WM_NCMOUSEMOVE");0x00A1: ("WM_NCLBUTTONDOWN")
			0x00A2: ("WM_NCLBUTTONUP");0x00A3: ("WM_NCLBUTTONDBLCLK");0x00A4: ("WM_NCRBUTTONDOWN");0x00A5: ("WM_NCRBUTTONUP")
			0x00A6: ("WM_NCRBUTTONDBLCLK");0x00A7: ("WM_NCMBUTTONDOWN");0x00A8: ("WM_NCMBUTTONUP");0x00A9: ("WM_NCMBUTTONDBLCLK")
			0x0100: ("WM_KEYFIRST");0x0100: ("WM_KEYDOWN");0x0101: ("WM_KEYUP");0x0102: ("WM_CHAR")
			0x0103: ("WM_DEADCHAR");0x0104: ("WM_SYSKEYDOWN");0x0105: ("WM_SYSKEYUP");0x0106: ("WM_SYSCHAR")
			0x0107: ("WM_SYSDEADCHAR");0x0108: ("WM_KEYLAST");0x010D: ("WM_IME_STARTCOMPOSITION");0x010E: ("WM_IME_ENDCOMPOSITION")
			0x010F: ("WM_IME_COMPOSITION");0x010F: ("WM_IME_KEYLAST");0x0110: ("WM_INITDIALOG");0x0111: ("WM_COMMAND")
			0x0112: ("WM_SYSCOMMAND");0x0113: ("WM_TIMER");0x0114: ("WM_HSCROLL");0x0115: ("WM_VSCROLL")
			0x0116: ("WM_INITMENU");0x0117: ("WM_INITMENUPOPUP");0x011F: ("WM_MENUSELECT");0x0120: ("WM_MENUCHAR")
			0x0121: ("WM_ENTERIDLE");0x0122: ("WM_MENURBUTTONUP");0x0123: ("WM_MENUDRAG");0x0124: ("WM_MENUGETOBJECT")
			0x0125: ("WM_UNINITMENUPOPUP");0x0126: ("WM_MENUCOMMAND");0x0132: ("WM_CTLCOLORMSGBOX");0x0133: ("WM_CTLCOLOREDIT")
			0x0134: ("WM_CTLCOLORLISTBOX");0x0135: ("WM_CTLCOLORBTN");0x0136: ("WM_CTLCOLORDLG");0x0137: ("WM_CTLCOLORSCROLLBAR")
			0x0138: ("WM_CTLCOLORSTATIC");0x0200: ("WM_MOUSEFIRST");0x0200: ("WM_MOUSEMOVE");0x0201: ("WM_LBUTTONDOWN")
			0x0202: ("WM_LBUTTONUP");0x0203: ("WM_LBUTTONDBLCLK");0x0204: ("WM_RBUTTONDOWN");0x0205: ("WM_RBUTTONUP")
			0x0206: ("WM_RBUTTONDBLCLK");0x0207: ("WM_MBUTTONDOWN");0x0208: ("WM_MBUTTONUP");0x0209: ("WM_MBUTTONDBLCLK")
			0x020A: ("WM_MOUSEWHEEL");0x020A: ("WM_MOUSELAST");0x0209: ("WM_MOUSELAST");0x0210: ("WM_PARENTNOTIFY")
			0x0211: ("WM_ENTERMENULOOP");0x0212: ("WM_EXITMENULOOP");0x0213: ("WM_NEXTMENU");0x0214: ("WM_SIZING")
			0x0215: ("WM_CAPTURECHANGED");0x0216: ("WM_MOVING");0x0218: ("WM_POWERBROADCAST");0x0219: ("WM_DEVICECHANGE")
			0x0220: ("WM_MDICREATE");0x0221: ("WM_MDIDESTROY");0x0222: ("WM_MDIACTIVATE");0x0223: ("WM_MDIRESTORE")
			0x0224: ("WM_MDINEXT");0x0225: ("WM_MDIMAXIMIZE");0x0226: ("WM_MDITILE");0x0227: ("WM_MDICASCADE")
			0x0228: ("WM_MDIICONARRANGE");0x0229: ("WM_MDIGETACTIVE");0x0230: ("WM_MDISETMENU");0x0231: ("WM_ENTERSIZEMOVE")
			0x0232: ("WM_EXITSIZEMOVE");0x0233: ("WM_DROPFILES");0x0234: ("WM_MDIREFRESHMENU");0x0281: ("WM_IME_SETCONTEXT")
			0x0282: ("WM_IME_NOTIFY");0x0283: ("WM_IME_CONTROL");0x0284: ("WM_IME_COMPOSITIONFULL");0x0285: ("WM_IME_SELECT")
			0x0286: ("WM_IME_CHAR");0x0288: ("WM_IME_REQUEST");0x0290: ("WM_IME_KEYDOWN");0x0291: ("WM_IME_KEYUP")
			0x02A1: ("WM_MOUSEHOVER");0x02A3: ("WM_MOUSELEAVE");0x0300: ("WM_CUT");0x0301: ("WM_COPY")
			0x0302: ("WM_PASTE");0x0303: ("WM_CLEAR");0x0304: ("WM_UNDO");0x0305: ("WM_RENDERFORMAT")
			0x0306: ("WM_RENDERALLFORMATS");0x0307: ("WM_DESTROYCLIPBOARD");0x0308: ("WM_DRAWCLIPBOARD");0x0309: ("WM_PAINTCLIPBOARD")
			0x030A: ("WM_VSCROLLCLIPBOARD");0x030B: ("WM_SIZECLIPBOARD");0x030C: ("WM_ASKCBFORMATNAME");0x030D: ("WM_CHANGECBCHAIN")
			0x030E: ("WM_HSCROLLCLIPBOARD");0x030F: ("WM_QUERYNEWPALETTE");0x0310: ("WM_PALETTEISCHANGING");0x0311: ("WM_PALETTECHANGED")
			0x0312: ("WM_HOTKEY");0x0317: ("WM_PRINT");0x0318: ("WM_PRINTCLIENT");0x0358: ("WM_HANDHELDFIRST")
			0x035F: ("WM_HANDHELDLAST");0x0360: ("WM_AFXFIRST");0x037F: ("WM_AFXLAST");0x0380: ("WM_PENWINFIRST")
			0x038F: ("WM_PENWINLAST");0x8000: ("WM_APP");0x0400: ("WM_USER"); default:("UNKNOWN")
		)
	),	
	
	fn msgEvent m =
	(
		if findItem windowShopper.excList m.msg > 0 do return undefined
		--try
		(
			--if m.msg != windowShopper.lastMsgCode do
			(
				windowShopper.lastMsgCode = m.msg
				windowShopper.msgList.rows.insert 0 #( \
					"0x" + formattedPrint m.msg format:"04X",
					windowShopper.getMsgName m.msg,
					"0x" + formattedPrint m.wParam format:"08X",
					"0x" + formattedPrint m.lParam format:"08X",
					(dotnetClass "System.DateTime").now.toString "HH:mm:ss.ffffff")
				if windowShopper.msgList.rowCount > 200 do windowShopper.msgList.rowCount = 200
			)
		)
		--catch ()
	),
	
	fn changeHLOpacity =
	(
		try
		(
			windowShopper.hlTimerTicks+= 72			
			windowShopper.hlForm.Opacity = (sin windowShopper.hlTimerTicks)
			windowShopper.hlForm.invalidate()
			if windowShopper.hlTimerTicks == 720 do 
			(
				windowShopper.hlTimer.stop()
				windowShopper.hlForm.Hide()
			)
		)
		catch()
	),
	
	fn disableHLTimer = windowShopper.hlTimer.enabled = off,
	
	fn initHighlightForm =
	(
		hlForm = dotNetObject "Form"
		hlForm.backColor = hlForm.backColor.Red
		hlForm.opacity = 1.0
		hlForm.formBorderStyle = hlForm.formBorderStyle.none
		hlForm.topMost = off
		hlForm.showInTaskBar = off
		hlTimer = dotNetObject "Timer"
		hlTimer.interval = 50
		dotnet.addEventHandler hlTimer "Tick" changeHLOpacity
		dotnet.addEventHandler hlForm "Closed" disableHLTimer
	),

	fn chkBoxFactory txt posX width func checked =
	(
		local ch = dotNetObject "CheckBox"
		ch.text = txt
		ch.height = 20
		ch.width = width
		ch.location.y = 5
		ch.location.x = posX	
		ch.checked = checked
		dotnet.addEventHandler ch "CheckedChanged" func
		ch
	),	
	
	fn btnFactory txt posX width func =
	(
		local btn = dotNetObject "Button"
		btn.text = txt
		btn.height = 20
		btn.width = width
		btn.location.y = 5
		btn.location.x = posX
		dotnet.addEventHandler btn "Click" func
		btn
	),
	
	fn getWindowsRecursive hWnd parent init:off =
	(
		for i in windows.getChildrenHwnd (if init then 0 else hWnd) parent:hWnd do
		(
			local ip = dotnetObject intPtr i[1]
			if showInvisible or user32.IsWindowVisible ip do
			(
				local rect = user32.GetWindowRect ip
				local node = dnTL.appendNode #(i[4],i[5],i[1],rect[1],rect[2],rect[1]-parent.item[3],rect[2]-parent.item[4],rect[3],rect[4]) parent.id
				getWindowsRecursive i[1] node
			)
		)		
	),
	
	fn refresh =
	(
		setWaitCursor()
		dnTl.nodes.clear()
		local maxHwnd = windows.getMaxHwnd()
		local dskTop = windows.getDesktopHwnd()
		local rect = user32.GetWindowRect (dotnetObject intPtr maxHwnd)
		local treeRoot = dnTL.appendNode #("3dsmax", "3dsmax", maxHwnd, rect[1], rect[2], rect[1], rect[2], rect[3], rect[4]) 0
		getWindowsRecursive maxHwnd treeRoot
		getWindowsRecursive maxHwnd treeRoot init:on
		
		local mxsEditor = for w in windows.getChildrenHwnd dskTop where w[4] == "MXS_SciTEWindow" collect w[1]
		if mxsEditor[1] != undefined do
		(
			local mxsRect = user32.GetWindowRect (dotnetObject intPtr mxsEditor[1])			
			mxsRoot = dnTL.appendNode #("MaxScript Editor", uiaccessor.getWindowText mxsEditor[1], mxsEditor[1], \
				rect[1], rect[2], rect[1], rect[2], rect[3], rect[4]) 0
			getWindowsRecursive mxsEditor[1] mxsRoot
		)
		dnTL.columns.item[0].sortOrder = dnTL.columns.item[0].sortOrder.ascending
		dnTL.nodes.item[0].expanded = on
		setArrowCursor()
	),
	
	fn refreshHandler s e = windowShopper.refresh(),
	
	fn selectionChanged node =
	(			
		local intPt = dotnetObject intPtr node.item[2]
		local rect = user32.GetWindowRect intPt
		msgSnooper.releaseHandle()
		msgList.rows.clear()
		if flashFrame do
		(
			if rect == undefined do return undefined
			if not hlForm.visible do hlForm.show()
			hlForm.bounds = dotnetObject rctCls rect[1] rect[2] rect[3] rect[4]
			for x in #(#(3,1),#(5,1),#(4,2),#(7,3),#(8,4)) do node.setValue x[1] rect[x[2]]		
			if node.ParentNode != undefined do
			(
				node.setValue 5 (rect[1] - node.ParentNode.item[3])
				node.setValue 6 (rect[2] - node.ParentNode.item[4])
			)
			hlTimerTicks = 0
			hlTimer.enabled = on
			hlForm.bringtoFront()
		)
		if msgSnooping do msgSnooper.assignHandle intPt
	),
	
	fn selectionChangedHandler s e =
	(		
		windowShopper.selectionChanged s.selection.item[0]
	),	
	
	fn initControls =
	(
		controls = for chk in #( \
			#("Show Invisible", 10, 100, showInvisibleToggle, off),
			#("Flash Windows", 120, 100, flashWindowToggle, on),
			#("Log WM Messages", 230, 120, msgSnooperToggle, on)
		) \
		collect (chkBoxFactory chk[1] chk[2] chk[3] chk[4] chk[5])
		controls+= for btn in #( \
			#("Refresh", 360, 100, refreshHandler),
			#("Clear Messages", 460, 100, clearMsgWindow)
		) \
		collect (btnFactory btn[1] btn[2] btn[3] btn[4])
		dnFm.controls.addRange controls
	),
	
	fn updateExcList = 
	(
		sort excList
		local items = for i in excList collect (dotNetObject "ListViewItem" ("0x" + formattedPrint i format:"04X" + ": " + getMsgName i))
		excPanel.items.clear()
		excPanel.items.addRange items
	),
	
	fn excludeMsg s e =
	(
		if e.columnIndex != 5 do return undefined
		local msg = s.rows.item[e.rowindex].cells.item[0].value
		if msg == undefined or msg == "" do return undefined
		local msgInt = bit.hexAsInt msg
		appendIfUnique windowShopper.excList msgInt
		windowShopper.updateExcList()
	),
	
	fn initMsgList =
	(
		msgList = dotnetObject "DataGridView"
		msgList.rowHeadersVisible = off
		msgList.dock = msgList.dock.fill
		
		local codeCol = dotnetObject "DataGridViewTextBoxColumn"
		codeCol.name = "Message Code"
		codeCol.width = 100
		codeCol.autoSizeMode = codeCol.autoSizeMode.none
		local nameCol = dotnetObject "DataGridViewTextBoxColumn"
		nameCol.name = "Message Name"
		nameCol.width = 150
		nameCol.autoSizeMode = nameCol.autoSizeMode.none
		local wpCol = dotnetObject "DataGridViewTextBoxColumn"
		wpCol.name = "W-Param"
		wpCol.width = 100
		wpCol.autoSizeMode = wpCol.autoSizeMode.none
		local lpCol = dotnetObject "DataGridViewTextBoxColumn"
		lpCol.name ="L-Param"
		lpCol.width = 100
		lpCol.autoSizeMode = lpCol.autoSizeMode.none
		local timeCol = dotnetObject "DataGridViewTextBoxColumn"
		timeCol.name ="Timestamp"
		timeCol.width = 130
		timeCol.autoSizeMode = timeCol.autoSizeMode.none
		codeCol.readonly = nameCol.readOnly = wpCol.readOnly = lpCol.readOnly =timeCol.readOnly = on
		local exCol = dotnetObject "DataGridViewButtonColumn"
		exCol.text = exCol.name = "Exclude"
		exCol.width = 50
		exCol.cellTemplate.UseColumnTextForButtonValue = on
		msgList.columns.addRange #(codeCol, nameCol, wpCol, lpCol, timeCol, exCol)
		msgList.allowUserToResizeRows = off
		msgList.rowCount = 1
		--msgList.selectionMode = msgList.selectionMode.fullRowSelect
		dotnet.addEventHandler msgList "CellContentClick" excludeMsg
	),
	
	fn initMsgSnooper =
	(
		dotnet.addEventHandler msgSnooper "MessageEvent" msgEvent
	),
	
	fn closeStruct =
	(
		local w = windowShopper
		w.msgSnooper.releaseHandle()
		w.splitter.dispose()
		w.dnTl.dispose()
		w.msgList.dispose()
	),
	
	fn excPanelKey s e =
	(
		if e.keyCode == e.keyCode.delete and s.SelectedIndices.count > 0 do
		(
			for i = s.SelectedIndices.count to 1 by - 1 do
			(
				deleteItem windowShopper.excList (s.selectedIndices.item[i-1] + 1)
			)
			windowShopper.updateExcList()
		)
	),
	
	fn initIncExc =
	(
		excPanel = dotNetObject "ListView"
		--incPanel.dock = incPanel.dock.bottom
		excPanel.anchor = dotnet.combineEnums excPanel.anchor.left excPanel.anchor.right excPanel.anchor.top excPanel.anchor.bottom
		excPanel.view = excPanel.view.details
		excPanel.columns.add "Excluded Messages" 200
		dotnet.addEventHandler excPanel "KeyUp" excPanelKey
	),
	
	fn initForm =
	(
		dnFm = dotnetObject "maxCustomControls.maxForm"
		dnFm.showInTaskbar = off
		dnFm.width = 900
		dnFm.height = 725
		dnFm.text = "WindowShopper"		
		wrapper = dotNetObject "maxCustomControls.win32HandleWrapper" (dotNetObject "System.IntPtr" (windows.getMaxHwnd()))
		dotnet.addEventHandler dnFm "Closed" closeStruct
	),	
	
	fn initTL =
	(
		dnTL = dotnetObject "DevExpress.XtraTreeList.TreeList"
		dnTl.dock = dnTl.dock.fill		
		for c in #("Type","Text","Handle","Absolute X","Absolute Y","Relative X","Relative Y","W","H") do
		(
			local col = dnTL.columns.add()
			col.caption = c
			col.visibleIndex = dnTL.columns.count - 1
			col.OptionsColumn.allowEdit = off
			col.OptionsColumn.readOnly = on
		)
		dotnet.addEventHandler dnTL "AfterFocusNode" selectionChangedHandler		
	),
	
	fn initSplitters =
	(
		vSplitter = dotNetObject "SplitContainer"
		vSplitter.orientation = vSplitter.orientation.vertical
		vSplitter.panel1.controls.add msgList
		vSplitter.panel2.controls.add excPanel
		vSplitter.dock = vSplitter.dock.fill
		vSplitter.SplitterDistance = 111
		
		splitter = dotNetObject "SplitContainer"
		local sa = splitter.anchor
		splitter.anchor = dotnet.combineEnums sa.left sa.right sa.bottom sa.top
		splitter.orientation = splitter.orientation.horizontal
		splitter.panel1.controls.add dnTl
		splitter.panel2.controls.add vSplitter
		dnFm.controls.add splitter
		splitter.bounds = dotnetObject rctCls 0 25 884 662		
	),
	
	fn init =
	(		
		createAssembly()
		initForm()
		initHighlightForm()
		initTL()
		initMsgList()
		initMsgSnooper()
		initControls()
		initIncExc()
		initSplitters()
		dnFm.show wrapper
		thisWrapper = dotNetObject "maxCustomControls.win32HandleWrapper" (dotNetObject intPtr dnFm.handle)
		refresh()
	),
	
	_init = init()
)
windowShopper = windowShopperStr()
ok
)