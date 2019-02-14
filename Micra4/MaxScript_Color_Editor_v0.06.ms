--Maxscript Color Editor
try(destroyDialog mcMaxScriptColorEditorDialog)catch()
--Create a rollout
rollout mcMaxScriptColorEditorDialog "MaxScript Theme Editor:"  width:680 height:516
(
	local user_file = getDir #maxData+"\\MXS_EditorUser.properties"
	struct TEXT_DATA (checked, pos, line, hex, clr, hint, ftype="Arial", fstyle="Regular", fsize=12)
	local user_data = #(), sel_item_index = 0, str_stream
	local all_colors =#\ --40
	(
		"colour.global.back=",
		"colour.global.fore=",
		"colour.code.comment.line=",
		"colour.code.comment.box=",
		"colour.notused=",
		"colour.brace.highlight=",
		"colour.brace.incomplete=",
		"colour.indentationguide=",
		"colour.indentationguide=",
		"colour.linenumbers=",
		"colour.linenumbers=",
		"fold.margin.colour=",
		"fold.margin.highlight.colour=",
		"colour.whitespace=",
		"colour.number=",
		"colour.keyword=",
		"colour.reserved=",
		"colour.string=",
		"colour.string.verbatim=",
		"colour.string.open=",
		"colour.string.open=",
		"colour.char=",
		"colour.operator=",
		"colour.argument=",
		"colour.preproc=",
		"colour.pathname=",
		"colour.function=",
		"colour.class=",
		"colour.maxclass=",
		"colour.superclass=",
		"colour.coreinterface=",
		"colour.objectset=",
		"colour.struct=",
		"colour.constantglobals=",
		"colour.globals=",
		"colour.user=",
		"caret.fore=",
		"caret.line.back=",
		"selection.fore=",
		"selection.back="
	)
	local key_names =#\ --40
	(
		"background",
		"foreground",
		"comment line",
		"comment box",
		"not used",
		"brace hilight",
		"brace incomplete",
		"indentation guide fore",
		"indentation guide back",
		"line numbers fore",
		"line numbers back",
		"margin",
		"margin hilight",
		"whitespace",
		"number",
		"keyword",
		"reserved",
		"string",
		"string verbatim",
		" string open fore",
		"string open back",
		"char",
		"operator",
		"argument",
		"preproc",
		"path name",
		"function",
		"class",
		"maxclass",
		"superclass",
		"coreinterface",
		"objectset",
		"struct",
		"constant globals",
		"globals",
		"user",
		"caret fore",
		"caret line back",
		"selection fore",
		"selection back"
	)
	local keywords_01=#\
	(
		"global","local","struct","fn","function","for","in","do","or","case","return","on","while","when","collect","and",
		"then","else","animate","attributes","by","exit","from","rollout","set","mapped","rcmenu","throw","max","rollout"
	)
	local keywords_02=#\--preproc
	(
		"subRollout","slider","button","spinner","checkbox","checkButton","pickButton","radioButtons","activeXControl",
		"groupBox","label","editText","dropDownList","listBox","multiListBox","colorPicker","timer","progressBar","colorpicker",
		"dotNetControl"
	)	
	local keywords_03=#\--functions
	(
		"messagebox","querybox","yesNoCancelBox","disableSceneRedraw","enableSceneRedraw","forceCompleteRedraw",
		"redrawViews","CompleteRedraw","render","createDialog","destroyDialog","select","random","closeRolloutFloater",
		"addRollout","removeRollout","open","displaycontroldialog","skipspace","readfloat","reset",
		"collectFileData","findStringInArray","getItemColor","mcColor.hexToRGB"
	)	
	local keywords_04=#\--class
	(
		"maxtvutility","moflow","trackviewpick","array","matrix3","integer","dotnetObject","stringStream","Color"
	)	
	local keywords_05=#\
	(
		"box","ffd_2x2x2","cameramapspacewarp"
	)	
	local keywords_06=#\
	(
		"camera","shape","soundclass","texturemap"
	)	
	local keywords_07=#\
	(
		"assemblymgr","channelinfo","iparserloader","trackselectionsets","pluginmanager"
	)	
	local keywords_08=#\
	(
		"objects","geometry","lights","cameras","helpers","shapes","systems","spacewarps","selection"
	)	
	local keywords_09=#\
	(
		"meshops","mouse","dof","cui","camerafov","xrefs","listView"
	)	
	local keywords_10=#\
	(
		"red","pi","true","false","undefined","meditmaterials","x_axis"
	)	
	local keywords_11=#\
	(
		"animationrange","slidertime","backgroundcolor","rootnode"
	)	
	local keywords_12=#\
	(
		"treeView","textBox","entered","changed","selected","pressed","selectionEnd","doubleClicked","picked","clicked",
		"buttondown","buttonup","tick","resized","mousedown","mouseup","click","dblclick","mouseover","mouseout","selChanged",
		"ptChanged","tangentChanged","deleted","ColumnClick","keyUp","DoubleClick","keyPress","KeyDown","MouseMove",
		"netDrColor","netDrFont","netFile","mc2Path","mc2System"
	)
	local operators=#("[","]","{","}","(",")","+","-","*","=","/","\\",".",",","&","^","%","!","?","<",">")
	local numbers =for i=0 to 9 collect i as string

	local edit_text =\
	"
	Global ColorPattern
	struct TEXT_DATA (pos, line, hex, clr, hint)
	--line comment	
	\"string comment\"
	--function
	fn collectFileData =
	(
		local user_file_text = netFile.ReadAllLines user_file                      
		for c in all_colors do
		(
			local d = ( findStringInArray user_file_text c )
			user_data += #( TEXT_DATA pos: d [ 1 ] line: d [ 2 ] )
		)
		for s in user_data do
		(
			local hex =\"#\" + getItemColor s.line
			s. hex = hex
			s.clr = mcColor.hexToRGB hex
		)
		return user_data
	) 
	--class
	#( dotnetObject, stringStream, color )
	--char
	#( #char, #integer, #name )
	--preproc
	#( dotNetControl, colorPicker, spinner, dropDownList )
	/*	
		#(
			\"colour.global.back=\",
			\"colour.global.fore=\",
			\"colour.code.comment.line=\"
		)
	*/
	"
	--Create the dotNet listview control
	dotNetControl lv_colors "listView" pos:[392,4] width:283 height:504
	dotNetControl text_box "RichTextBox" pos:[8,4] width:380 height:428
	--Font components
	dropDownList ddl_font "" pos:[8,440] width:268 height:21
	button btn_bold "B" pos:[328,440] width:20 height:20
	button btn_italic "I" pos:[348,440] width:20 height:20
	button btn_under "U" pos:[368,440] width:20 height:20
	dropDownList ddl_size "" pos:[280,440] width:44 height:21
	
	--new interface
	/*
		dotNetControl lv_colors "listView" pos:[392,4] width:283 height:508
		dotNetControl text_box "RichTextBox" pos:[8,4] width:380 height:428
		spinner spn_fot_size "" pos:[280,443] width:44 height:16 range:[0,255,0] type:#integer scale:1
		button btn_gen "Generate" pos:[4,468] width:384 height:40
		dropdownList ddl_font "" pos:[40,440] width:212 height:21
		button btn_bold "B" pos:[328,440] width:20 height:20
		button btn_italic "I" pos:[348,440] width:20 height:20
		button btn_under "U" pos:[368,440] width:20 height:20
		label lbl_font "Font:" pos:[8,444] width:28 height:16
		label lbl_font_size "Size:" pos:[260,444] width:24 height:16
	*/
	
	--action components
	button btn_gen "Generate" pos:[312,468] width:76 height:40
	
	fn findStringInArray arr str =
	(
		for i=1 to arr.count where findString arr[ i ] str != undefined do return #( i, arr[ i ])
		return undefined
	)
	fn getItemColor str =
	(
		local fs = FilterString str "#, ,"
		return fs[2]
	)
	fn collectFileData = 
	(
		local netFile        = (dotnetClass "IO.File")
		local user_file_text = netFile.ReadAllLines user_file	
		for c=1 to all_colors.count do
		(
			local d = (findStringInArray user_file_text  all_colors[c]) 
			user_data += #(TEXT_DATA checked:false pos:d[1] line:d[2] hint:key_names[c])
		)
		for s in user_data do 
		(
			local hex ="#" + getItemColor s.line
			s. hex = hex
			format "hex:%\n" s.hex
			s.clr = mcColor.hexToRGB hex
		)
		return user_data
	)
	fn initLv theLv=
	(
		--Setup the forms view
		theLv.view=(dotNetClass "system.windows.forms.view").details
		theLv.FullRowSelect=true		--Set so full width of listView is selected and not just first column.
		theLv.GridLines=true			--Show lines between the items. 
		theLv.MultiSelect=false			--Allow for multiple selections. 
		theLv.checkBoxes= true
		theLv.HideSelection = true --false = stay marked when lose focus
		theLv.foreColor = netDrColor black
	)
	--Add columns. 
	fn addColumns theLv columnsAr sizeArr = (for i=1 to columnsAr.count do theLv.columns.add columnsAr[i] sizeArr[i])
	--Adds rows of data to the listView
	fn populateList theLv=
	(
		rows=#()		--Empty array to collect rows of data
		for i in user_data do		--Loop through all the objects in the scene. 
		(
			
			local li=dotNetObject "ListViewItem" ""	--Create a listViewItem object and name it. 
			li.UseItemStyleForSubItems = false
			--li.Checked = i.checked
			li.subitems.add "" --Add data to the first column.
			li.subitems.item[1].backColor = netDrColor i.clr --Add color to the second column
			li.subitems.add i.hex		--Add data to the shrid column.
			li.subitems.add i.hint		--Add data to the fourth column.
			append rows li		--Added the listViewItem to the rows array
		)
		theLv.items.addRange rows		--Add the array of rows to the listView control. 
	)
	fn colorize str clr font:"Arial" size:10 style:"regular" search:1=
	(
		if classOf clr != Color do return false 
		text_box.SelectionStart = 0
		local search_type = case search of
		(
			1: (dotnetClass "RichTextBoxFinds").WholeWord
			2: (dotnetClass "RichTextBoxFinds").MatchCase
			3: (dotnetClass "RichTextBoxFinds").NoHighlight
			4: (dotnetClass "RichTextBoxFinds").Reverse
			5: (dotnetClass "RichTextBoxFinds").None
		)
		while (text_box.find str text_box.SelectionStart search_type) != -1 and not keyboard.escPressed do
		(
			text_box.SelectionFont = netDrFont font:font size:size style:style
			text_box.SelectionColor = netDrColor clr
			--.text_box.SelectionBackColor
			text_box.SelectionStart+=1
		)
	)
	fn higlightLine num clr:green =
	(
		local first = text_box.GetFirstCharIndexFromLine num
		local last = text_box.GetFirstCharIndexFromLine (num + 1)
		If last == -1 do last = text_box.TextLength
		text_box.Select first (last - first)
		text_box.SelectionBackColor = netDrColor clr
	)
	fn colorizeLineComments=
	(
		text_box.SelectionStart = 0
		local start_pos=0
		struct STRING_DATA (txt, line, pos)
		local sd = #()
		local fs = undefined
		for i=1 to text_box.lines.count where (fs=findString text_box.lines[i] "--") !=undefined do sd += #(STRING_DATA text_box.lines[i] i fs)
		local search_type = (dotnetClass "RichTextBoxFinds").None
		for i in sd do
		(
			--format "start_pos:%\n" start_pos
			local commented_text=substring i .txt i.pos -1
			text_box.Find commented_text start_pos search_type
			text_box.SelectionColor = netDrColor user_data[3].clr
			text_box.SelectionFont = netDrFont font:"Arial" size:10 style:"regular"
			start_pos=(text_box.GetFirstCharIndexFromLine i.line)
		)
	)
	fn colorizeBoxComments=
	(
		text_box.SelectionStart = 0
		local start_pos=0
		local search_type = (dotnetClass "RichTextBoxFinds").None
		start_pos=text_box.Find "/*" start_pos search_type
		if start_pos == -1 do return false
		end_pos =text_box.Find "*/" start_pos search_type
		if end_pos == -1 do return false
		text_box.select start_pos end_pos
		text_box.SelectionColor = netDrColor user_data[4].clr
	)
	fn colorizeStrings=
	(
		local start_pos=0
		text_box.SelectionStart = 0
		local search_type = (dotnetClass "RichTextBoxFinds").None
		
		while start_pos != -1 do
		(
			start_pos=text_box.Find "\"" start_pos search_type
			if start_pos == -1 do return false
			end_pos =text_box.Find "\"" (start_pos+1) search_type
			if end_pos == -1 do return false
			local text_length = end_pos - (start_pos-1)
			text_box.select start_pos text_length
			text_box.SelectionColor = netDrColor user_data[18].clr	
			text_box.SelectionFont = netDrFont font:"Arial" size:10 style:"regular"
			start_pos = start_pos+text_length
		)
--text_box.HideSelection = false
	)
	fn colorizeKeyword k_array clr:1 size:10 style:"regular" comments:true=
	(
		for k in k_array do colorize k user_data[clr+1].clr size:size style:style
		if comments do
		(
			colorizeStrings()
			colorizeLineComments()
			colorizeBoxComments()
		)
	)
	fn inicializeColors =
	(
		text_box.BackColor = netDrColor user_data[1].clr
		text_box.ForeColor = netDrColor user_data[2].clr
		colorizeKeyword keywords_01 clr:15 size:10 style:"bold" comments:false
		colorizeKeyword operators clr:22 size:10 style:"bold"  comments:false
		colorizeKeyword numbers clr:14 style:"bold"
		colorizeKeyword keywords_03 clr:26 size:10 style:"bold"
		colorizeKeyword keywords_04 clr:27 style:"bold"
		colorizeKeyword #("#") clr:13 style:"bold"
		colorizeKeyword #("#char", "#integer", "#name") clr:21 style:"bold"
		colorizeKeyword #("line:","pos:") clr:23 
		colorizeKeyword keywords_02 clr:24
		--colorize comments
		colorizeStrings()
		colorizeLineComments()
		colorizeBoxComments()
		higlightLine 8 clr:user_data[38].clr
	)
	fn findItem2 arr str caseSensitive:false=
	(
		str = toLower str
		for i=1 to arr.count where (toLower arr[i]) == str do return i
		return 0
	)
	fn colorizeSimpleText =
	(
		--text_box.ForeColor = netDrColor clr
		
		--collect all keywords
		local all_keywords =(keywords_01+keywords_02+keywords_03+keywords_04+keywords_05+
			keywords_06+keywords_07+keywords_08+keywords_09+keywords_10+keywords_11+keywords_12)
		--get text_box text
--for i in all_keywords do print i
		local box_text = filterString text_box.text "  .,/\\!?:*-=(){}[]+\"#0123456789\t\n"
		--remove all keywords from text
		for k in all_keywords do
		(
			local index = findItem2 box_text k
			while index != 0 do
			(
				deleteItem box_text index
				index = findItem2 box_text k
			)
		)
		--colorize remain text
		local next_pos=0
		text_box.SelectionStart = 0
		for i in box_text do
		(
			next_pos=text_box.Find i next_pos (dotnetClass "RichTextBoxFinds").WholeWord   
			text_box.SelectionColor = netDrColor  user_data[2].clr
		)
		--colorize all comment lines -- and boxes /* */
		colorizeLineComments()
		colorizeBoxComments()
		text_box.update()
		text_box.refresh()
	)
	fn inicializeColorsBySelection type:"user" =
	(
		local sel=sel_item_index+1
		local clr=user_data[sel].clr
		case user_data[sel].hint of
		(
			"background":(text_box.BackColor = netDrColor clr )
			"foreground":(colorizeSimpleText() )
			"comment line":(colorizeLineComments() )
			"comment box":(colorizeBoxComments() )
			"not used":( )
			"brace hilight":( )
			"brace incomplete":( )
			"indentation guide fore":( )
			"indentation guide back":( )
			"line numbers fore":( )
			"line numbers back":( )
			"margin":()
			"margin hilight":()
			"whitespace":(colorizeKeyword #("#") clr:13 style:"bold")
			"number":(colorizeKeyword numbers clr:14 style:"bold")
			"keyword":(colorizeKeyword keywords_01 clr:15 size:10 style:"bold")
			"reserved":( )
			"string":(colorizeStrings();colorizeLineComments(); colorizeBoxComments())
			"string verbatim":( )
			" string open fore":( )
			"string open back":( )
			"char":(colorizeKeyword #("#char", "#integer", "#name") clr:21 style:"bold")
			"operator":(colorizeKeyword operators clr:22 size:10 style:"bold")
			"argument":(colorizeKeyword #("line:","pos:") clr:23 )
			"preproc":(colorizeKeyword keywords_02 clr:24 )
			"path name":( )
			"function":(colorizeKeyword keywords_03 clr:26 size:10 style:"bold")
			"class":(colorizeKeyword keywords_04 clr:27 style:"bold" )
			"maxclass":( )
			"superclass":( )
			"coreinterface":( )
			"objectset":( )
			"struct":( )
			"constant globals":( )
			"globals":( )
			"user":( )
			"caret fore":( )
			"caret line back":(higlightLine 8 clr:user_data[38].clr)
			"selection fore":( )
			"selection back":( )
		)
	)

	--change item color by colorpicker event
	fn setButtonColor net_clr = (
		
		local clr = netColorToRGB net_clr
		local hex = mcColor.rgbToHex clr
		local sel_item = lv_colors.SelectedItems.Item[0]
		
		--update color list
		sel_item.subItems.item[1].backColor = net_clr --update color in color list
		sel_item.subItems.item[2].text = "#"  + hex  --update hex value in color list
		
		--update user dictionary
		user_data[sel_item_index+1].clr = clr
		user_data[sel_item_index+1].hex = hex
		
		--update textbox colors
		inicializeColorsBySelection()
	)
	
	fn colorizeCurrentText net_clr = (
		
		local clr = netColorToRGB net_clr
		local hex = mcColor.rgbToHex clr
		--update user dictionary
		user_data[sel_item_index+1].clr = clr
		user_data[sel_item_index+1].hex = hex
		
		--update textbox colors
		inicializeColorsBySelection()
	)	

	fn getSelectedItemData =
	(
		local clr = user_data[sel_item_index+1].clr --get color from selected item
		local net_clr = netDrColor clr
		if mcColorPickerDialog != undefined and mcColorPickerDialog.visible() do mcColorPickerDialog.setColor net_clr
		--TODO
		--get font and font settings
		
	)

	fn uncheckAll list = (
		
		for i = 0 to list.Items.count-1 do list.Items.item[ i ].checked = false	
	)
	
	fn inicializeInterface =
	(
		user_data = collectFileData()
		initLv lv_colors
		addColumns lv_colors #("?", "RGB","HEX","Name") #(24, 32, 68, lv_colors.width-(32+68)-22 - 24)
		populateList lv_colors
		 --select first item
		lv_colors.Items.item[0].Selected = true
		lv_colors.Items.item[0].Checked = true
		sel_item_index = 0
		getSelectedItemData()
		--setup tabs size
		local int_arr = dotnetObject "System.Int32[]" 6
		local tab_size = 0
		for i=0 to 5 do int_arr.SetValue (tab_size+=20) i
		text_box.SelectAll()
		text_box.SelectionTabs = int_arr
		--
		--mcSystem.show text_box
		text_box.ShowSelectionMargin = true
		--text_box.RightMargin = text_box.width
		--text_box.Margin = dotnetObject "Padding" 0
		text_box.ReadOnly = true
		text_box.text=edit_text
		str_stream= stringStream edit_text
		inicializeColors()
		
		local clr = user_data[sel_item_index+1].clr --get color from selected item
		mcGM.setParam "color_picker_start_color" (netDrColor clr)
		mcEvents.registerEvent "COLOR_PICKER_ADD_COLOR" setButtonColor
		mcEvents.registerEvent "COLOR_PICKER_MOD_COLOR" colorizeCurrentText
		mcFile.fileInVersion "Color_Picker"
	)

	on lv_colors DoubleClick s a do ( --open color picker with selected color
		
		if mcColorPickerDialog != undefined and not mcColorPickerDialog.visible() do (
			
			local clr = user_data[sel_item_index+1].clr --get color from selected item
			mcGM.setParam "color_picker_start_color" (netDrColor clr)
			mcFile.fileInVersion "Color_Picker"
		)
	)
	
	/*on lv_colors ItemCheck s a do(
		
		format "checked:\n"
	)*/
	/*on lv_colors Click s a do(
		
		format "Click s:% a:%\n" s a
	)*/
	
	on lv_colors mouseUp s a do
	(
		local sel_item = s.SelectedItems.Item[0]
	
		uncheckAll s -- oly one item is checked at same time
		sel_item.checked = true
		--format "mouseUp > item:% index:% a:%\n" sel_item.Position  sel_item.index a
		--local hit=(lv_colors.HitTest (dotNetObject "System.Drawing.Point" a.x a.y))
		--sel_item_index = hit.item.Index
		sel_item_index = sel_item.Index
		getSelectedItemData()	
	)
	
	--on lv_colors LostFocus s a do (s.Focus())	--selected item stay marked (or fill backcolor on selected item to stay)
	
	on btn_gen pressed do
	(
		text_box.text = ""
		for i in user_data do
		(
			local hex_pos = (findString i.line "#")
			local line_array = filterstring i.line "# ,"
			local hex_len = line_array[2].count+1 
			i.line = replace i.line hex_pos hex_len i.hex
			text_box.text += i.line+"\n"
		)
	)
	on mcMaxScriptColorEditorDialog open do  inicializeInterface()
	on mcMaxScriptColorEditorDialog close do ( --unregister events

		mcEvents.unregisterEventSet "COLOR_PICKER_ADD_COLOR" --remove event add color to palete
		mcEvents.unregisterEventSet "COLOR_PICKER_MOD_COLOR" --remove event mod color to selection
		if mcColorPickerDialog != undefined and mcColorPickerDialog.visible() do mcColorPickerDialog.Close()
	)		
)
CreateDialog mcMaxScriptColorEditorDialog



/*
#-------------------------------------------#
#    Custom Color Scheme
#------------------------------------------#

# Give symbolic names to the set of fonts used in the standard styles.(Consolas, ISOCPEUR, Swis721 Cn BT, Lucida Sans Unicode)
font.base=font:Swis721 Cn BT,size:11
font.small=font:Swis721 Cn BT,size:10
font.comment=font:Arial,size:9,bold,italics
font.code.comment.box=$(font.comment)
font.code.comment.line=$(font.comment)
font.code.comment.doc=$(font.comment)
font.code.comment.nested=$(font.comment)
font.text=font:Arial,size:10
font.text.comment=font:Arial,size:10,italics
font.embedded.base=font:Arial,size:10,italics
font.embedded.comment=font:Arial,size:8
font.monospace=font:Consolas,size:10

# Symbolic names:
colour.global.back=#272C42
colour.global.fore=#E4C590
colour.code.comment.line=fore:#787878
colour.code.comment.box=fore:#787878
colour.notused=back:#FF0000
colour.brace.highlight=fore:#39EA11
colour.brace.incomplete=fore:#FF0F0F
colour.indentationguide=fore:#AAAFA5
colour.indentationguide=fore:#AAAFA5
colour.linenumbers=back:#8C8C8C
colour.linenumbers=back:#8C8C8C
fold.margin.colour=#B4B4B4
fold.margin.highlight.colour=#B4B4B4
colour.whitespace=fore:#CB39AE,bold
colour.number=fore:#367C86,bold
colour.keyword=fore:#F6EE18,bold
colour.reserved=fore:#313187
colour.string=fore:#B07037,regular,italics
colour.string.verbatim=fore:#BC5454
colour.string.open=fore:#AB28284
colour.string.open=fore:#AB28284
colour.char=fore:#B361B2
colour.operator=fore:#E8FFFF,bold
colour.argument=fore:#68686E
colour.preproc=fore:#873162
colour.pathname=fore:#6DBC5B
colour.function=fore:#35B6E6
colour.class=fore:#8B4CCB
colour.maxclass=fore:#F3FF69
colour.superclass=fore:#4479D6
colour.coreinterface=fore:#0049CA
colour.objectset=fore:#FCE6A3
colour.struct=fore:#AA6A25,bold
colour.constantglobals=fore:#ADF2FF
colour.globals=fore:#9AFF56,bold
colour.user=fore:#FFBABA,bold,italics
caret.fore=#ECECEC
caret.line.back=#F3EDF7
selection.fore=#FAFAFA
selection.back=#405F87



# Apply Colours and font settings:
caret.width=3
caret.line.back.alpha=40
selection.alpha=256
colour.code.comment.doc=$(colour.code.comment.box)
colour.code.comment.nested=$(colour.code.comment.box)
colour.text.comment=$(colour.code.comment.box)
colour.other.comment=$(colour.code.comment.box)
colour.embedded.comment=$(colour.code.comment.box)
colour.indentationguide=back:$(colour.global.back)
colour.foldmargin=$(colour.indentationguide)
fold.symbols=0
fold.on.open=0
blank.margin.left=5
blank.margin.right=5

# Maxscript.properties style overrides ( those override the properties in maxscript.properties )
# Line number
style.MAXScript.33=$(colour.linenumbers),$(font.small)
# Brace highlight
style.MAXScript.34=$(colour.brace.highlight),bold
# Brace incomplete highlight
style.MAXScript.35=$(colour.brace.incomplete),bold
# Control characters
style.MAXScript.36=
# Indentation guides
style.MAXScript.37=$(colour.indentationguide)

#################################################################################################

# Default
style.MAXScript.32=$(font.base),back:$(colour.global.back),fore:$(colour.global.fore)
# White space
style.MAXScript.0=$(colour.whitespace)
# Comment: /*.
style.MAXScript.1=$(colour.code.comment.box),$(font.code.comment.box)
# Line Comment: --.
style.MAXScript.2=$(colour.code.comment.line),$(font.code.comment.line)
# Number
style.MAXScript.3=$(colour.number),$(font.base)
# String
style.MAXScript.4=$(colour.string)
# Verbatim strings
style.MAXScript.5=$(colour.string.verbatim)
# End of line where string is not closed
style.MAXScript.6=$(colour.string.open)
# Identifiers
style.MAXScript.7=
# Operators
style.MAXScript.8=$(colour.operator)
# Keyword arg name
style.MAXScript.9=$(colour.argument)
# Name value
style.MAXScript.10=$(colour.char)
# Pathname
style.MAXScript.11=$(colour.pathname),$(font.monospace)
# Keywords1 - Keywords
style.MAXScript.12=$(colour.keyword)
# Keywords2 - Rollout controls
style.MAXScript.13=$(colour.preproc)
# Keywords3 - Functions
style.MAXScript.14=$(colour.function)
# Keywords4 - MXS Classes
style.MAXScript.15=$(colour.class)
# Keywords5 - MAXClasses
style.MAXScript.16=$(colour.maxclass)
# Keywords6 - MAXSuperClasses
style.MAXScript.17=$(colour.superclass)
# Keywords7 - Core interfaces
style.MAXScript.18=$(colour.coreinterface)
# Keywords8 - Object sets
style.MAXScript.19=$(colour.objectset)
# Keywords9 - StructDefs
style.MAXScript.20=$(colour.struct)
# Keywords10 - Const reserved globals
style.MAXScript.21=$(colour.constantglobals)
# Keywords11 - Reserved globals
style.MAXScript.22=$(colour.globals)
# Keywords12 - User defined
style.MAXScript.23=$(colour.user)
*/


--backup 01
/*
colour.global.back=#2C2C45
colour.global.fore=#CEB690
colour.code.comment.line=fore:#C4C4B7
colour.code.comment.box=fore:#808080
colour.notused=back:#FF0000
colour.brace.highlight=fore:#D6FF34
colour.brace.incomplete=fore:#FF0F0F
colour.indentationguide=fore:#AAAFA5
colour.indentationguide=back:#AAAFA5
colour.linenumbers=back:#8C8C8C
colour.linenumbers=fore:#1E1E1E
fold.margin.colour=#B4B4B4
fold.margin.highlight.colour=#B4B4B4
colour.whitespace=fore:#D83939,bold
colour.number=fore:#367C86,bold
colour.keyword=fore:#EEDC18,bold
colour.reserved=fore:#313187
colour.string=fore:#B07037,regular,italics
colour.string.verbatim=fore:#BC5454
colour.string.open=fore:#AB28284
colour.string.open=back:#C39DBE
colour.char=fore:#B361B2
colour.operator=fore:#E8FFFF,bold
colour.argument=fore:#68686E
colour.preproc=fore:#873162
colour.pathname=fore:#6DBC5B
colour.function=fore:#35A655
colour.class=fore:#8B4CCB
colour.maxclass=fore:#F3FF69
colour.superclass=fore:#4479D6
colour.coreinterface=fore:#0049CA
colour.objectset=fore:#FCE6A3
colour.struct=fore:#AA6A25,bold
colour.constantglobals=fore:#ADF2FF
colour.globals=fore:#9AFF56,bold
colour.user=fore:#FFBABA,bold,italics
caret.fore=#ECECEC
caret.line.back=#FFFFFF
selection.fore=#FAFAFA
selection.back=#405F87
*/

--backup 02
/*
colour.global.back=#25224B
colour.global.fore=#E4C590
colour.code.comment.line=fore:#787878
colour.code.comment.box=fore:#787878
colour.notused=back:#FF0000
colour.brace.highlight=fore:#39EA11
colour.brace.incomplete=fore:#FF0F0F
colour.indentationguide=fore:#AAAFA5
colour.indentationguide=back:#AAAFA5
colour.linenumbers=fore:#918FA4
colour.linenumbers=back:#615E85
fold.margin.colour=#4A4496
fold.margin.highlight.colour=#B4B4B4
colour.whitespace=fore:#CB39AE,bold
colour.number=fore:#F9E936,bold
colour.keyword=fore:#B643FF,bold
colour.reserved=fore:#313187
colour.string=fore:#12BC56,regular,italics
colour.string.verbatim=fore:#BC5454
colour.string.open=fore:#AB28284
colour.string.open=fore:#AB28284
colour.char=fore:#B361B2
colour.operator=fore:#CE7FF2,bold
colour.argument=fore:#558DFF
colour.preproc=fore:#F305C3,bold
colour.pathname=fore:#6DBC5B
colour.function=fore:#35B6E6
colour.class=fore:#8B4CCB
colour.maxclass=fore:#F3FF69
colour.superclass=fore:#4479D6
colour.coreinterface=fore:#0049CA
colour.objectset=fore:#FCE6A3
colour.struct=fore:#AA6A25,bold
colour.constantglobals=fore:#ADF2FF
colour.globals=fore:#9AFF56,bold
colour.user=fore:#FFBABA,bold,italics
caret.fore=#ECECEC
caret.line.back=#F3EDF7
selection.fore=#FAFAFA
selection.back=#405F87
*/