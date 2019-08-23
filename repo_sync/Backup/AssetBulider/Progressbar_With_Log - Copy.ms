Global mcProgressBarLogDialog
if mcProgressBarLogDialog != undefined do DestroyDialog mcProgressBarLogDialog
rollout mcProgressBarLogDialog "Proces:  ..." width:800 height:600
(
	GroupBox 'grp1' "Log:" pos:[4,4] width:792 height:592 align:#left
	dotnetcontrol 'text_box' "System.Windows.Forms.RichTextBox" pos:[8,24] width:780 height:544 align:#left
	progressBar 'pb_prog' "ProgressBar" pos:[64,572] width:724 height:16 align:#left
	label 'lbl_prog' "Progress:" pos:[12,572] width:48 height:16 align:#left
	fn multiChar char cnt = (local str = "";	for i=1 to cnt do str += char; str)
	fn intTo32 int = (
	
		local int_arr = dotnetObject "System.Int32[]" 6
		local tab_size = 0
		for i=0 to 5 do int_arr.SetValue (tab_size+=int) i
		int_arr
	)
	fn netDrColor clr = (
	
		local dotnet_color = case classOf clr of (
			
			Name:(
				local hex_as_color = mcColor.hexToRGB clr
				if hex_as_color == undefined do return undefined
				(dotNetClass "Drawing.Color").fromArgb hex_as_color.r hex_as_color.g hex_as_color.b
			)
			Color:(dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b
		)
		return dotnet_color
	)
	fn higlightLine num clr:green = (
	
		local first = text_box.GetFirstCharIndexFromLine num
		local last = text_box.GetFirstCharIndexFromLine (num + 1)
		If last == -1 do last = text_box.TextLength
		text_box.Select first (last - first)
		text_box.SelectionBackColor = netDrColor clr
	)
	fn stylizeText p_start p_end clr bold italic fsize:8 fname:"Times New Roman" = (

		local fStyle = dotNetClass "System.Drawing.FontStyle"
		local fstyle = fStyle.Regular
		if bold and italic then (
			
			fstyle = dotnet.combineenums fStyle.bold fStyle.italic
			
		) else if bold then (
			
			fstyle = fStyle.Bold
			
		) else if italic do (
			
			fstyle = fStyle.Italic
		) 
		local netFont = dotnetObject "System.Drawing.Font" fname fsize fstyle
		
		text_box.SuspendLayout()
		text_box.Select p_start p_end
		text_box.SelectionColor = netDrColor clr
		text_box.SelectionFont = netFont
		text_box.resumelayout()
	)
	/**
	*@Usage
		nl = new line
		tl = tab level
		ti = title
		ty = message type (warn, error, info, dash) ---different formating and color
	*@Example   
		mcProgressBarLogDialog.show()
		mcProgressBarLogDialog.msg "Welcome to trace log." nl:true tt:"Pass 1" ty:"dash1"
		mcProgressBarLogDialog.msg "progress 1" nl:true tl:1 ti:"Pass 1"
	*/
	fn msg str nl:true tl:0 ti:"" ty:"info" clr:black = (
		
		local tabs = ""
		if tl > 0 do tabs = multiChar "\t" tl
		local bold = false
		local italic = false
		local font = "Times New Roman"
		local size = 9
		local new_line = (dotNetClass "System.Environment").newline
		local d1 = tabs + (multiChar "-" 154)	--very long dash
		local d2 = tabs + (multiChar "-" 115)	--long dash
		local d3 = tabs + (multiChar "-" 77)	--medium dash
		local d4 = tabs + (multiChar "-" 38)	--smal dash
		
		format "str:%     type:%\n" str ty
		case ty of ( --Stylyze str
		
			"dash1": (
				
				clr = #73dcff
				bold = true
				font = "Tahoma"
				str = d1 + new_line + tabs + str + new_line + d1
			) 
			"dash2": (
				
				clr = #ffdc73
				bold = true
				font = "Tahoma"
				-- str = d4 + new_line + tabs + str + new_line + d4
				str = tabs + str + " >>"
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
			"error": (
			
				-- msg "ERROR:" tl:tl ty:"dash4" clr:red	
				clr = #ff4c4d
				italic = true
				bold = true
				local d = tabs + (multiChar "-" 189)
				local head = tabs + "ERROR >>"
				str = head + "\n " + tabs + str + "\n" + "<<"
				/*
				local d = tabs + (multiChar "-" 189)
				local head = tabs + "ERROR >" + "\n" + d 
				str = head + "\n " + tabs + str + "\n" + d
				*/
			)
			"confirm": (
				
				clr = #36d900
				str = tabs + str
			)
			default: (
			
				str = tabs + str
			)
		)
		if nl do str += new_line --New Line
		local p_start = text_box.text.count
		text_box.AppendText str
		local p_end = text_box.text.count
		format "from:% to:% clr:% blod:% italic:%\n" p_start p_end clr bold italic
		stylizeText p_start p_end clr bold italic fsize:size fname:font
		mcProgressBarLogDialog.title =  "Proces: " + ti
	)
	/**
	*@Example   
		for i=1 to 1000 do mcProgressBarLogDialog.prog i 1000
	*/
	fn prog val_step val_total color:green = (
		
		pb_prog.value = 100.*val_step/val_total
	)
	fn show = (
		CreateDialog mcProgressBarLogDialog style:#(
		
			-- #style_resizing,
			#style_minimizebox,
			#style_titlebar, 
			#style_border, 
			#style_sysmenu
			-- #style_sunkenedge
		)
		-- if (MaxVersion())[1] >= 21000 do mcProgressBarLogDialog.autoLayoutOnResize = true 
	)
	fn close = (DestroyDialog mcProgressBarLogDialog)
	fn init = (
		
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
		
		-- text_box.TextAlign= (dotNetClass "System.Drawing.ContentAlignment").BottomRight
		/*
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
 	)
	/*on text_box KeyPress sender e do (
		
			--if (e.keyvalue == 13) do text_box.paste("\r\n");
 			case e.keychar of (
				
 				("\r"):(e.keychar = "") --replace returns with newlines
 			)
	)*/
	on mcProgressBarLogDialog open do init()
	/*on mcProgressBarLogDialog resized size do (
	
	 
	)*/
)

/*
mcProgressBarLogDialog.show()
mcProgressBarLogDialog.close()
*/

