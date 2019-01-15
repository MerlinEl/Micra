SCI_BRACEMATCH = 2353
struct test
( /* <--  opening_parenthesis_offset */
	a = 0,
	b = "())",
	fn abc = 111,
		
	on create do ()
	/*<struct test  end>*/
)


mxse_hwnd = (dotNetClass "Autodesk.Max.GlobalInterface").Instance.TheMxsEditorInterface.EditorGetEditHWND 
opening_parenthesis_offset = 36
match = windows.sendMessage mxse_hwnd SCI_BRACEMATCH opening_parenthesis_offset 0


fn InsertInMXSE offset str = 
(
	local marshal = dotnetclass "System.Runtime.InteropServices.Marshal"
	local ptr = marshal.StringToHGlobalUni str
	local mxse_hwnd = (dotNetClass "Autodesk.Max.GlobalInterface").Instance.TheMxsEditorInterface.EditorGetEditHWND
	
	local EM_REPLACESEL = 0x00C2	
	local SCI_GETCURRENTPOS = 2008
	local SCI_GOTOPOS = 2025
	local EM_SETSEL = 0x00B1	
	
	local prev_offset = windows.sendmessage mxse_hwnd SCI_GETCURRENTPOS 0 0
	
	windows.sendMessage mxse_hwnd SCI_GOTOPOS offset 0

	windows.sendMessage mxse_hwnd EM_SETSEL offset offset
	windows.sendmessage mxse_hwnd EM_REPLACESEL offset ptr
	windows.sendMessage mxse_hwnd EM_SETSEL offset offset
	
	if prev_offset > (offset + str.count) then
	(
		windows.sendMessage mxse_hwnd SCI_GOTOPOS (prev_offset + str.count) 0
	)
	else
	(
		windows.sendMessage mxse_hwnd SCI_GOTOPOS prev_offset 0
	)
	

)



function_to_insert = "fn abc a b = a * b"


if match != -1 do
(
	codeblock = "\t,\r\n\t" + function_to_insert + "\r\n"
	InsertInMXSE (match-1) codeblock
)