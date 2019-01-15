fn GetWindowText hwnd =
(
	local marshal = dotnetclass "System.Runtime.InteropServices.Marshal"
	local str = ""
	try (
		
		local len = windows.sendmessage hwnd 0xE 0 0
		local lParam = marshal.AllocHGlobal (marshal.SystemDefaultCharSize*(len+1))
		windows.sendmessage hwnd 0xD (len+1) lParam 
			
		ptr = dotnetobject "System.IntPtr" lParam
		str = marshal.PtrToStringAuto ptr
		marshal.FreeHGlobal ptr
		
	) catch ()
	str
)

fn ClearMXSEHighlights =
(	
-- 	local SCI_MARKERDELETEALL = 2045
	windows.sendMessage (dotNetClass "Autodesk.Max.GlobalInterface").Instance.TheMxsEditorInterface.EditorGetEditHWND 2045 -1 -1
)

fn HighlightLines word matchcase:false keep:false =
(
	if not matchcase do word = toLower word
		
	local mxse_hwnd = (dotNetClass "Autodesk.Max.GlobalInterface").Instance.TheMxsEditorInterface.EditorGetEditHWND
	local src = getWindowText mxse_hwnd
	local doc = (if matchcase then src else toLower src) as StringStream
	local offsets = #()

	while (skipToString doc word) != undefined do
	(
		append offsets (filePos doc)
	)
	
	free doc
	
	if keep == false do
	(
		local SCI_MARKERDELETEALL = 2045
		windows.sendMessage mxse_hwnd SCI_MARKERDELETEALL -1 -1
	)
	
	if offsets.count > 0 do
	(
		local SCI_LINEFROMPOSITION = 2166		
		local SCI_MARKERADDSET = 2466
		
		
		for offset in offsets do
		(
			local line_index = windows.sendMessage mxse_hwnd SCI_LINEFROMPOSITION offset 0
			
			windows.sendMessage mxse_hwnd SCI_MARKERADDSET line_index 2
		)	
	)
	
	offsets
)

-- ClearMXSEHighlights()
HighlightLines "sendM"