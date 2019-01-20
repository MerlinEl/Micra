--------------------------------------------------------------------------------
/* mcMsx by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	search_str = "getParentDir"
	text_pos = mcMsx.findText search_str
	mcMsx.moveCarretTo (text_pos-1)
	mcMsx.selectText text_pos search_str.count
*
*/
struct MICRA_MSX (
	
	--variables
	marshal = dotnetclass "System.Runtime.InteropServices.Marshal",
	mxse_hwnd = (dotNetClass "Autodesk.Max.GlobalInterface").Instance.TheMxsEditorInterface.EditorGetEditHWND,
	struct_end_marker = "/*<end>*/",
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn focus = (mcWin32.SetFocus mxse_hwnd),
	/**
	*@Usage
		edit structure file in Maxscript Editor
	*@Example
		mcMsx.editStrucrure "mcFile"
	*/
	fn editStrucrure structure_name = (
	
		local structure_instance = execute structure_name
		if structure_instance == undefined do (
			
			format "mcMsx > editStrucrure > Unknown Structure: [ % ]\n" structure_name
			return false
		)
		if hasProperty structure_instance "getSource" then (
		
			ShowSource structure_instance.getSource
			format "mcMsx > editStrucrure > Edit Structure: [ % ]\n" structure_name
			return true
		) else (
		
			format "mcMsx > editStrucrure > Function [ getSource ] not found in Structure [ % ]\n" structure_name
			return false
		)
		false
	),
	/*fn InsertText str offset = (
	
		local prev_offset = windows.sendmessage mxse_hwnd mcWinMsg.SCI_GETCURRENTPOS 0 0
		windows.sendMessage mxse_hwnd mcWinMsg.SCI_GOTOPOS offset 0
		windows.sendMessage mxse_hwnd mcWinMsg.EM_SETSEL offset offset
		windows.sendmessage mxse_hwnd mcWinMsg.EM_REPLACESEL offset ptr
		windows.sendMessage mxse_hwnd mcWinMsg.EM_SETSEL offset offset
		
		if prev_offset > (offset + str.count) then
		(
			windows.sendMessage mxse_hwnd mcWinMsg.SCI_GOTOPOS (prev_offset + str.count) 0
		)
		else
		(
			windows.sendMessage mxse_hwnd mcWinMsg.SCI_GOTOPOS prev_offset 0
		)
	),*/
	fn replaceText offset_pos str = (
	
		local ptr = marshal.StringToHGlobalUni str
		windows.sendmessage mxse_hwnd mcWinMsg.EM_REPLACESEL offset_pos ptr 
	),
	fn selectText offset str_len = (

		windows.sendmessage mxse_hwnd mcWinMsg.EM_SETSEL (offset-1) (offset+str_len-1)
	),
	fn moveCarretTo offset = (
	
		windows.sendMessage mxse_hwnd mcWinMsg.SCI_GOTOPOS offset 0
	),
	fn findText str = ( --OK
		
		local current_script_text = mcWin32.GetWindowText mxse_hwnd
		findString current_script_text str
	),
	fn insertFunctionAtStructureEnd fn_str = (
	
		focus()
		fn_str += "\n\t" + struct_end_marker
		format "mcMsx > insertFunction >\n%\n" fn_str
		local end_pos = findText struct_end_marker
		if end_pos == undefined do return false
		format "mcMsx > insertFunction > end_pos:%\n" end_pos
		moveCarretTo (end_pos-1)
		selectText end_pos struct_end_marker.count
		replaceText end_pos fn_str
		focus()
	)
	/*<end>*/
)	
 --create instance
Global mcMsx = Micra.instanceStructure MICRA_MSX "mcMsx"
