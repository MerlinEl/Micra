Global mcProgLog
Global mcProgLogDialog
--------------------------------------------------------------------------------
/* mcProgLog by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	display messages in new consloe window (info, warnings, errors, open close tasks)
*
*@Example	
	mcProgLog.msg "@" --clear log
	mcProgLog.msg "ASSET BUILDER LOG:" ti:"Initialize...." ty:"new_task"
	mcProgLog.msg "Creating Max File" ti:"3DsMax..." ty:"task_open"
	mcProgLog.msg "Paths and Name is OK" ty:"proc"
	mcProgLog.msg "Name OK" ty:"proc"
	output_dir = @"E:\Aprog\Orien\Micra\Micra4\_New\AssetBulider"
	mcProgLog.msg ("Failed Save Max File. Unable to find Directory.\n\tPath:[ "+output_dir+" ]") ti:"Aborted!" ty:"error" tl:1
	mcProgLog.msg "All Done" ty:"task_close"
*
*/
struct MC_PROG_LOG (
	
	--variables
	text_box,
	pb_sub_task,
	pb_sum_task,
	new_line = (dotNetClass "System.Environment").newline,
	font_style = dotNetClass "System.Drawing.FontStyle",
	alphaStr = "0123456789ABCDEF",
	WM_SETFOCUS = 0x7,
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn show = (
		CreateDialog mcProgLogDialog style:#(
		
			-- #style_resizing,
			#style_minimizebox,
			#style_titlebar, 
			#style_border, 
			#style_sysmenu
			-- #style_sunkenedge
		)
		-- if (MaxVersion())[1] >= 21000 do mcProgLogDialog.autoLayoutOnResize = true 
	),
	fn focus scrollDown:false = (
	
		windows.SendMessage mcProgLogDialog.hwnd WM_SETFOCUS 0 0 --set focus to mcProgLogDialog
		if scrollDown do (
		
			text_box.SelectionStart = text_box.TextLength --get text end
			text_box.ScrollToCaret() --move carret to end
			text_box.Focus() --set focus to textbox
		)
		-- format "Set Focus To mcProgLogDialog...\n"
	),
	fn close = (DestroyDialog mcProgLogDialog),
	/**
	*@Example   
		for i=1 to 1000 do mcProgLog.progSub i 1000 clr:yellow
		for i=1 to 1000 do mcProgLog.progSum i 1000
	*/
	fn progSub val_step val_total clr:(color 255 115 255) = ( --color 255 153 255, color 0 255 255
		
		
		pb_sub_task.color = clr
		pb_sub_task.value = 100.*val_step/val_total
	),
	fn progSum val_step val_total clr:(color 147 38 255) = ( --color 147 38 255, color 38 147 255
		
		pb_sum_task.color = clr
		pb_sum_task.value = 100.*val_step/val_total
	),
	fn cloneChar char cnt = (local str = "";	for i=1 to cnt do str += char; str),
	fn intTo32 int = (
	
		local int_arr = dotnetObject "System.Int32[]" 6
		local tab_size = 0
		for i=0 to 5 do int_arr.SetValue (tab_size+=int) i
		int_arr
	),
	fn hexToDec num = ( -- used to convert single hex bit to 0-255 color value

		local n_ = findString alphaStr (substring num 1 1)
		local _n = findString alphaStr (substring num 2 1)
		_n -= 1
		n_ -= 1
		(n_ * 16 + _n)
	),
	fn hexToRGB hex_color= ( --thanks to Mark Tsang
		
		local hex_string = substituteString hex_color "#" "" -- audits string for pound sign and deletes it
		hex_string = toUpper hex_string
		local r = hexToDec (substring hex_string 1 2)
		local g = hexToDec (substring hex_string 3 2)
		local b = hexToDec (substring hex_string 5 2)
		color r  g  b
	),
	fn netDrColor clr = (
	
		local dotnet_color = case classOf clr of (
			
			Name:(
				local hex_as_color = hexToRGB clr
				if hex_as_color == undefined do return undefined
				(dotNetClass "Drawing.Color").fromArgb hex_as_color.r hex_as_color.g hex_as_color.b
			)
			Color:(dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b
		)
		return dotnet_color
	),
	fn higlightLine num clr:green = (
	
		local first =text_box.GetFirstCharIndexFromLine num
		local last =text_box.GetFirstCharIndexFromLine (num + 1)
		If last == -1 do last =text_box.TextLength
		text_box.Select first (last - first)
		text_box.SelectionBackColor = netDrColor clr
	),
	fn getTextWidth str fname fsize fstyle = (
	
		local font = dotnetObject "System.Drawing.Font" fname fsize fstyle
		((dotnetclass "TextRenderer").MeasureText str font).width
	),
	fn stylizeText start end clr bold italic fsize fname = (

		local fstyle = font_style.Regular
		if bold and italic then (
			
			fstyle = dotnet.combineenums font_style.bold font_style.italic
			
		) else if bold then (
			
			fstyle = font_style.Bold
			
		) else if italic do (
			
			fstyle = font_style.Italic
		) 
		local netFont = dotnetObject "System.Drawing.Font" fname fsize fstyle
		
		text_box.SuspendLayout()
		text_box.Select start end
		text_box.SelectionColor = netDrColor clr
		text_box.SelectionFont = netFont
		text_box.resumelayout()
	),
	fn replaceTabs str new_str = ( --"@_tab_@" --Not used
		 
		--if findString str "\t" == undefined do return str
		local rgx = dotnetObject "System.Text.RegularExpressions.Regex" "\t"
		rgx.Replace str new_str
	),
	/**
	*@Usage
		str		= string msg (string "@" will clear log)
		nl		= new line
		ti		= title
		ty		= message type (warn, error, proc, task_close, task_close) ---different formating and color
		\t		= inside str will be replaced for tabs (tl)
		clr		= text color
		bold	= text bold
		italic	= text size 
		fsize	= text size
	*@Example   
		mcProgLog.msg "Welcome to trace log." nl:true tt:"Pass 1" ty:"head1"
		mcProgLog.msg "progress 1" nl:true tl:1 ti:"Pass 1"
	*/
	fn msg str nl:true ti:"" ty:"proc" clr:black bold:false italic:false fsize:12 fname:"Times New Roman" = (
		
		if not (isDialogVisible mcProgLogDialog) do show()
		if str == "@" do (mcProgLogDialog.clearLog(); return OK)
		--"Tahoma" --"Verdana"
		local d1 = cloneChar "-" 234	--dash(1*  width)
		-- local d2 = cloneChar "-" 115	--dash(3/4 width)
		-- local d3 = cloneChar "-" 77	--dash(1/2 width)
		-- local d4 = cloneChar "-" 38	--dash(1/4 width)
		
		-- format "str:%     type:%\n" str ty
		case ty of ( --Stylyze str
		
			"new_task": ( --full line text
				
				clr = #73dcff
				bold = true
				/*local tb_width = text_box.width 
				local dash_width = getTextWidth "-" f_name fsize font_style.Bold
				local cnt = tb_width / dash_width
				local d1 = cloneChar "-" cnt
				format "width tb:% dash:% cnt:%\n" tb_width dash_width cnt*/
				str = d1 + new_line + str + new_line + d1
			) 
			"task_open": ( --open a process
				
				clr = #ffdc73
				bold = true
				str = "\t" + str + " >>"
			) 
			"task_close": ( --close current proces
				
				if msg != "" do msg str ty:"proc"
				clr = #ffdc73
				bold = true
				str = "<<"
			) 
			"error": (
				
				clr = #ff4c4d
				bold = true
				local head = "\t\t" + "ERROR >>"
				str = replaceTabs str "\t\t\t"
				str = head + "\n " + "\t\t\t" + str + "\n\t\t<<"
			)
			"warn": (
				
				clr = #ff8000
				bold = true
				local head = "\t\t" + "WARNING >>"
				str = replaceTabs str "\t\t\t"
				str = head + "\n " + "\t\t\t" + str + "\n\t\t<<"
			)
			"proc": ( --add in to current process
				
				clr = #36d900
				-- italic = true
				str = replaceTabs str "\t\t"
				str = "\t\t" + str
			)
			default: ()
		)
		if nl do str += new_line --New Line
		local start = text_box.text.count
		text_box.AppendText str
		local end = text_box.text.count
		-- format "from:% to:% clr:% blod:% italic:%\n" start end clr bold italic
		stylizeText start end clr bold italic fsize fname
		mcProgLogDialog.title =  "Proces: " + ti
	),
	fn init = (
	
		if mcProgLogDialog != undefined do DestroyDialog mcProgLogDialog
		rollout mcProgLogDialog "Proces:  ..." width:1200 height:600
		(
		
			GroupBox 'grp1' "Log:" pos:[4,4] width:1192 height:592 align:#left
			dotNetControl 'text_box' "System.Windows.Forms.RichTextBox" pos:[8,20] width:1180 height:520 align:#left
			progressBar 'pb_sub_task' "Progress Bar Sub Task" pos:[8,544] width:1180 height:8 align:#left
			progressBar 'pb_sum_task' "Progress Bar Summary Task" pos:[8,558] width:1180 height:8 align:#left
			button 'btn_Copy' "Copy All" pos:[8,572] width:80 height:20 align:#left
			button 'btn_Clear' "Clear" pos:[92,572] width:80 height:20 align:#left
			button 'btn_close' "Close" pos:[1108,572] width:80 height:20 align:#left
			fn clearLog = (
	
				text_box.text = ""
				mcProgLogDialog.title =  "Proces: "
				pb_sub_task.value = 0
				pb_sum_task.value = 0
			)
			-- on mcProgLogDialog resized size do ()
			on mcProgLogDialog open do (
			
				text_box.ReadOnly		= true
				text_box.Multiline		= true
				text_box.WordWrap		= false
				text_box.BackColor = netDrColor #424251
				text_box.ForeColor = netDrColor black
				text_box.AcceptsTab		= true
				text_box.SelectionTabs 	= intTo32 12
				text_box.ScrollBars		= text_box.ScrollBars.Both
				text_box.update()
				text_box.refresh()
			)
			on btn_clear pressed do clearLog()
			on btn_close pressed do DestroyDialog mcProgLogDialog
			on btn_copy pressed do setclipboardText text_box.text
		)
		text_box = mcProgLogDialog.text_box --instance dialog
		pb_sub_task  = mcProgLogDialog.pb_sub_task
		pb_sum_task  = mcProgLogDialog.pb_sum_task
 	),
	i = init()
	/*<end>*/
)	

--create instance
if (mcProgLog == undefined) do (

	mcProgLog = MC_PROG_LOG()
)


---test
/*
mcProgLog.msg "@" --clear log
mcProgLog.msg "ASSET BUILDER LOG:" ti:"Initialize...." ty:"new_task"
mcProgLog.msg "Creating Max File" ti:"3DsMax..." ty:"task_open"
mcProgLog.msg "Paths and Name is OK" ty:"proc"
mcProgLog.msg "Name OK" ty:"proc"
output_dir = @"E:\Aprog\Orien\Micra\Micra4\_New\AssetBulider"
mcProgLog.msg ("Failed Save Max File. Unable to find Directory.\n\tPath:[ "+output_dir+" ]") ti:"Aborted!" ty:"error" tl:1
mcProgLog.msg "All Done" ty:"task_close"

mcProgLog.msg "ADD FILES TO PERFORCE:" ti:"P4V...." ty:"new_task" 
for i=1 to 1000 do mcProgLog.prog i 1000
mcProgLog.prog 0 0	
*/


/*
on text_box KeyPress sender e do (
	
		--if (e.keyvalue == 13) do text_box.paste("\r\n");
		case e.keychar of (
			
			("\r"):(e.keychar = "") --replace returns with newlines
		)
)
			"dash3": (
			
				clr = #73dcff
				bold = true
				font = "Tahoma"
				str = d3 + new_line + tabs + str + new_line + d3
			) 
			"dash4": (
				
				
				clr = #73dcff
				bold = true
				font = "Tahoma"
				str = d4 + new_line + tabs + str + new_line + d4
			)
text_box.TextAlign= (dotNetClass "System.Drawing.ContentAlignment").BottomRight
text_box.SelectAll()
text_box.SelectionBackColor = telep.BackColor
text_box.DeselectAll()
text_box.SelectionFont = netDrColor font:font size:size style:style
text_box.SelectionColor = netDrColor clr
text_box.SelectionBackColor
text_box.AcceptsReturn	= true
text_box.ShowSelectionMargin = true
text_box.RightMargin = text_box.width
text_box.Margin = dotnetObject "Padding" 0
text_box.SelectionStart = 0
text_box.selectionstart = p_start
text_box.Selectionlength = p_end
*/
/*
mcProgLogDialog.show()
mcProgLogDialog.close()
*/

