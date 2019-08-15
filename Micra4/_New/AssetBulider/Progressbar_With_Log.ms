Global mcPprogbUI
Global mcProgressBarLogDialog
--------------------------------------------------------------------------------
/* mcPprogbUI by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct PROGRESSBAR_LOG_STRUCTURE (
	
	--variables
	text_box,
	pb_prog,
	new_line = (dotNetClass "System.Environment").newline,
	font_style = dotNetClass "System.Drawing.FontStyle",
	--functions
	fn getSource = getSourceFileName(), --get path of this script
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
	),
	fn close = (DestroyDialog mcProgressBarLogDialog),
	/**
	*@Example   
		for i=1 to 1000 do mcPprogbUI.prog i 1000
	*/
	fn prog val_step val_total color:green = (
		
		pb_prog.value = 100.*val_step/val_total
	),
	fn cloneChar char cnt = (local str = "";	for i=1 to cnt do str += char; str),
	fn intTo32 int = (
	
		local int_arr = dotnetObject "System.Int32[]" 6
		local tab_size = 0
		for i=0 to 5 do int_arr.SetValue (tab_size+=int) i
		int_arr
	),
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
	),
	fn higlightLine num clr:green = (
	
		local first =text_box.GetFirstCharIndexFromLine num
		local last =text_box.GetFirstCharIndexFromLine (num + 1)
		If last == -1 do last =text_box.TextLength
		text_box.Select first (last - first)
		text_box.SelectionBackColor = netDrColor clr
	),
	fn getTextWidth str f_name f_size f_style = (
	
		local font = dotnetObject "System.Drawing.Font" f_name f_size f_style
		((dotnetclass "TextRenderer").MeasureText str font).width
	),
	fn stylizeText p_start p_end clr bold italic f_size:8 f_name:"Times New Roman" = (

		local f_style = font_style.Regular
		if bold and italic then (
			
			f_style = dotnet.combineenums font_style.bold font_style.italic
			
		) else if bold then (
			
			f_style = font_style.Bold
			
		) else if italic do (
			
			f_style = font_style.Italic
		) 
		local netFont = dotnetObject "System.Drawing.Font" f_name f_size f_style
		
		text_box.SuspendLayout()
		text_box.Select p_start p_end
		text_box.SelectionColor = netDrColor clr
		text_box.SelectionFont = netFont
		text_box.resumelayout()
	),
	fn replaceTabs str old_str new_str = ( --"@_tab_@" --Not used
		
		local rgx = dotnetObject "System.Text.RegularExpressions.Regex" old_str
		rgx.Replace str new_str
	),
	/**
	*@Usage
		str		= string msg (string "@" will clear log)
		nl		= new line
		ti		= title
		ty		= message type (warn, error, info, dash) ---different formating and color
		\t		= inside str will be replaced for tabs (tl)
		clr		= text color
		bold	= text bold
		italic	= text size 
		fsize	= text size
	*@Example   
		mcPprogbUI.msg "Welcome to trace log." nl:true tt:"Pass 1" ty:"head1"
		mcPprogbUI.msg "progress 1" nl:true tl:1 ti:"Pass 1"
	*/
	fn msg str nl:true ti:"" ty:"info" clr:black bold:false italic:false fsize:9 = (
		
		if not (isDialogVisible mcProgressBarLogDialog) do show()
		if str == "@" do (mcProgressBarLogDialog.clearLog(); return OK)
		local f_name = "Times New Roman" --"Tahoma" --"Verdana"
		local d1 = cloneChar "-" 194	--dash(1*  width)
		-- local d2 = cloneChar "-" 115	--dash(3/4 width)
		-- local d3 = cloneChar "-" 77	--dash(1/2 width)
		-- local d4 = cloneChar "-" 38	--dash(1/4 width)
		
		format "str:%     type:%\n" str ty
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
				str = replaceTabs str "\t" "\t\t\t"
				str = head + "\n " + "\t\t\t" + str + "\n\t\t<<"
			)
			"proc": ( --add in to current process
				
				clr = #36d900
				italic = true
				str = replaceTabs str "\t" "\t\t"
				str = "\t\t" + str
			)
			default: ()
		)
		if nl do str += new_line --New Line
		local p_start = text_box.text.count
		text_box.AppendText str
		local p_end = text_box.text.count
		format "from:% to:% clr:% blod:% italic:%\n" p_start p_end clr bold italic
		stylizeText p_start p_end clr bold italic fsize:fsize fname:f_name
		mcProgressBarLogDialog.title =  "Proces: " + ti
	),
	fn init = (
	
		if mcProgressBarLogDialog != undefined do DestroyDialog mcProgressBarLogDialog
		rollout mcProgressBarLogDialog "Proces:  ..." width:800 height:600 (
		
			GroupBox grp1 "Log:" pos:[4,4] width:792 height:592
			dotNetControl text_box "System.Windows.Forms.RichTextBox" pos:[8,20] width:784 height:536
			progressBar pb_prog "ProgressBar" pos:[8,560] width:784 height:8
			button btn_copy "Copy All" pos:[8,572] width:80 height:20
			button btn_clear "Clear" pos:[92,572] width:80 height:20
			button btn_close "Close" pos:[712,572] width:80 height:20
			/*GroupBox 'grp1' "Log:" pos:[4,4] width:792 height:592 align:#left
			dotnetcontrol 'text_box' "System.Windows.Forms.RichTextBox" pos:[8,24] width:780 height:544 align:#left
			progressBar 'pb_prog' "ProgressBar" pos:[64,572] width:724 height:16 align:#left
			label 'lbl_prog' "Progress:" pos:[12,572] width:48 height:16 align:#left*/
			fn clearLog = (
	
				text_box.text = ""
				mcProgressBarLogDialog.title =  "Proces: "
			)
			-- on mcProgressBarLogDialog resized size do ()
			on mcProgressBarLogDialog open do (
			
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
			on btn_close pressed do DestroyDialog mcProgressBarLogDialog
			on btn_copy pressed do setclipboardText text_box.text
		)
		text_box = mcProgressBarLogDialog.text_box --instance dialog
		pb_prog  = mcProgressBarLogDialog.pb_prog
 	),
	i = init()
	/*<end>*/
)	
--create instance
mcPprogbUI = PROGRESSBAR_LOG_STRUCTURE()

---test
/*
mcPprogbUI.msg "@" --clear log
mcPprogbUI.msg "ASSET BUILDER LOG:" ti:"Initialize...." ty:"new_task"
mcPprogbUI.msg "Creating Max File" ti:"3DsMax..." ty:"task_open"
mcPprogbUI.msg "Paths and Name is OK" ty:"proc"
mcPprogbUI.msg "Name OK" ty:"proc"
output_dir = @"E:\Aprog\Orien\Micra\Micra4\_New\AssetBulider"
mcPprogbUI.msg ("Failed Save Max File. Unable to find Directory.\n\tPath:[ "+output_dir+" ]") ti:"Aborted!" ty:"error" tl:1
mcPprogbUI.msg "All Done" ty:"task_close"

mcPprogbUI.msg "ADD FILES TO PERFORCE:" ti:"P4V...." ty:"new_task" 
for i=1 to 1000 do mcPprogbUI.prog i 1000
mcPprogbUI.prog 0 0	
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
mcProgressBarLogDialog.show()
mcProgressBarLogDialog.close()
*/

