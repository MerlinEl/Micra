Global mcUnwrapToolbardialog
if ::mcUnwrapToolbardialog != undefined do try(mcUnwrapToolbardialog.close())catch()	
(
-->Locals-----------------------------------------------------------------
local last_profile = execute (mcFile.readSettings Micra.UserSettings "Interface/lastprofile")
local profiles = #("DefaultColor", "UserColor", "ForestColor", "EarthColor", "MoonColor", "SeaColor", "SunColor", "Close")
local head_str = profiles[last_profile]
local bar_height      = 14
local form_bounds     = 2
local form_offset     = 4 --border line
local btn_size        = 24
local form_width       = 236
local form_height       = 420
local form_default_width = 224 --? don't know why but this is the default size (maybe form min max?)
local form_edit_width = 600
local cp_width        = 48
local debug = 0
-->Components---------------------------------------------------------------------
--local form = dotNetObject "Form" 
local form = dotNetObject "MaxCustomControls.Maxform"
struct UNWRAP_COMPONENTS_TAB1_STRUCT ( created = false, form_height = 200, items = #())
struct UNWRAP_COMPONENTS_TAB2_STRUCT ( created = false, form_height = 420, items = #())
struct UNWRAP_COMPONENTS_TAB3_STRUCT ( created = false, form_height = 300, items = #())
struct UNWRAP_COMPONENTS_STRUCT
(
	--variables
	lblT    = dotNetObject "label" ,
	ToolTip = dotnetobject "ToolTip",
	btnMin  = dotNetObject  "button",
	tlp_main = dotNetObject "TableLayoutPanel",
	tab     = dotNetObject "TableLayoutPanel",
	tab_buttons = #(),
	tab_1 = UNWRAP_COMPONENTS_TAB1_STRUCT(),
	tab_2 = UNWRAP_COMPONENTS_TAB2_STRUCT(),
	tab_3 = UNWRAP_COMPONENTS_TAB3_STRUCT(),
	start_mouse_pos, --mouse pos on dialog
	old_height, 
	minimized = false
	--interface
)
form.tag = dotNetMXSValue (UNWRAP_COMPONENTS_STRUCT()) --store structure here for events use

--|	--Form move
fn onLblTMouseMove s a = (  --drag form
	
	local form = s.parent
	local mcs = form.tag.value
	if a.Button == a.Button.left do  mcDialog.snapForm form mcs.start_mouse_pos
)
fn onLblTMouseDown s a = ( --start drag
		
	local form = s.parent
	local mcs = form.tag.value
	form.cursor.current = netCursors.Hand
	if a.Button == a.Button.left do ( --enable drag
		mcs.start_mouse_pos = [form.MousePosition.x, form.MousePosition.y] - [form.left, form.top]  
	)
)
fn onLblTMouseUp s a = (

	local form = s.parent
	case a.Button.ToString() of (
	
		"Left"	: (
			--format " save form:%  pos:% size:%\n" form.name (form.location.toString()) (form.size.toString())
			mcFile.saveDialogSettings form.name "Properties_2" --save form position after drag
		)
		"Right"	: (
		
			form.hide()
		)
		"Middle"	: (
		

		)
	)
)

fn onBtnMinMouseUp s a = (

	local form = s.parent
	s.text == "+"
	if form == unsupplied do form = s.parent
	local mcs = form.tag.value
	mcs.minimized = not mcs.minimized

	if mcs.minimized
	then 
	(
		mcs.btnMin.text = "+"
		mcs.old_height = form.height 
		form.height = bar_height + form_bounds*2
		mcs.tlp_main.hide()
	)
	else
	(
		mcs.btnMin.text = "-"
		form.height = mcs.old_height
		mcs.tlp_main.show()
	)
)

fn onTabButtonClick btn arg = (

	format "Clicked button:% action:%\n" btn.text btn.tag

)

fn createButton mcs btn_data i = (

	local btn_text = btn_data.text
	local bname = "btn_" + i as string
	local btn = dotNetObject "button"
	btn.text = btn_text
	btn.name = bname
	btn.size = netDrSize [btn_size, btn_size]
	-- if btn_data.pos != undefined do (
	
		-- btn.margin = mcDotNet.dPadding 24 0 0 0 --gap in x
		-- btn.Location = mcDotNet.dPoint [4, 10]
	-- )
	if btn_data.margin.count == 4 then (
		
		format "margin:%\n" btn_data.margin
		btn.margin = mcDotNet.dPadding btn_data.margin[1] btn_data.margin[2] btn_data.margin[3] btn_data.margin[4]
	) else (
	
		btn.margin =  dotnetobject "padding" 0
	)
	btn.flatstyle = btn.flatstyle.flat
	btn.FlatAppearance.BorderColor = netDrColor (mcUIColors.get #back)
	btn.FlatAppearance.BorderSize = 1
	btn.tag  = btn_data.action
	mcs.ToolTip.SetToolTip btn btn_data.tooltip
	btn.Image = mcCall.getIconDn btn_data.icon
	dotNet.addeventhandler btn "Click" onTabButtonClick
	btn
)

fn createComponent mcs data id = (

	case data.type of (
	
		"button"	: createButton mcs data id
		"spinner"	: ()
		"label"	: ()
	)
)

fn addIuComponents mcs ui_components tab_index:1 = (
	
	local cmp = for i=1 to ui_components.count collect (createComponent mcs ui_components[i] i)
	mcs.tab.Controls.addRange ( cmp ) --add items in to tab
	cmp
)

fn resizeTabWindow mcs tab_height autoarange:true = (

	form.height = tab_height
	mcs.tab.height = form.height - bar_height - btn_size - form_offset*2 --fix height of tab
	-- create grid for auto arange items
	if autoarange do (
	
		mcs.tab.ColumnCount = form.width / btn_size
		mcs.tab.RowCount = form.height / btn_size
	)
)

--INTERFACE INIT
fn addTab num mcs = (

	if debug == 1 do format "addTab > tab index:% \n" num
	--Remove All controls from Layout
	mcs.tab.Controls.Clear()
	struct UI_DATA (type = "", text = "", tooltip = "", pos, margin = #(), size, range, step, icon, action)
	--Fill layout by components of chossen type
	case num of(
		--SELECT
		1: (
		
			--Create Interface Components---------------------------------------------------------------------
			if not mcs.tab_1.created do(
				
				resizeTabWindow mcs mcs.tab_1.form_height
				local ui_components = #(
				
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"sel_edge_border"	\
						icon:41		tooltip:"Select Edge border",
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"sel_sim_faces"	\
						icon:220	tooltip:"Select Similar Faces",
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"sel_over_faces"	\
						icon:240	tooltip:"Select Overlapped Faces (+Ctrl Grow to Element)"
				)
				mcs.tab_1.items = addIuComponents mcs ui_components
			)	
		)
		--MOVE
		2: (
			--Create Interface Components---------------------------------------------------------------------
			if not mcs.tab_2.created do (
	
				resizeTabWindow mcs mcs.tab_2.form_height autoarange:false
				local ui_components = #(
				
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"align_top"		\
						icon:291	toolTip:"Align Top"	pos:[btn_size,0],
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"align_left"		\
						icon:289	toolTip:"Align Left"	pos:[0,btn_size],
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"align_right"		\
						icon:290	toolTip:"Align Right"	pos:[btn_size*3,btn_size],
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"align_bottom"	\
						icon:292	toolTip:"Align Bottom"	pos:[btn_size*2,btn_size*2],
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"align_center"		\
						icon:303	toolTip:"Align Center" pos:[btn_size,btn_size]
				)
				mcs.tab_2.items = addIuComponents mcs ui_components 
			)
		)
		--TRANSFORM
		3: ( 
			--Create Interface Components---------------------------------------------------------------------
			if not mcs.tab_3.created do (

				resizeTabWindow mcs mcs.tab_3.form_height
			)
		)
	)	 
)
fn checkTheButton b = (
	
	local mcs = b.parent.parent.tag.value
	b.BackColor = mcDotnet.uiColor #fore
	b.Forecolor = mcDotnet.uiColor #back --green--
	for i in mcs.tab_buttons where not i.Equals b do 
	(
		i.BackColor = undefined 
		i.Forecolor = mcDotnet.uiColor #text
	)
)

fn switchTabTo s a = (
	
	checkTheButton s
	local tab_struct = s.parent.parent.tag.value
	addTab s.tag tab_struct
)

fn addTabButtons mcs = (
	
	local tab_text_array = #("Select", "Move", "Transform")
	for i = 1 to tab_text_array.count do
	(
		local b = dotNetObject "Button"
		b.size  = netDrSize [btn_size*3, btn_size]
		b.FlatStyle = b.FlatStyle.flat
		b.FlatAppearance.BorderColor = mcDotnet.uiColor #back		
		b.Forecolor = mcDotnet.uiColor #text
		b.FlatAppearance.BorderSize = 1
		b.margin =  dotnetobject "padding" 0
		b.name = "btn_"+((i as integer) as string)
		b.text = tab_text_array[i]
		b.tag = i
		mcs.toolTip.SetToolTip b b.text
		dotNet.addEventHandler b "MouseUp" switchTabTo
		mcs.tab_buttons += #(b)
	)
	mcs.tlp_main.controls.addRange (mcs.tab_buttons)
)

fn onFormVisibilityChanged s a = (

	case s.visible of (
	
		true:(
			--print "UnwrapToolbar shown"
			
		)
		false:(
		
			--print "UnwrapToolbar hide"
			mcFile.saveDialogSettings s.name "Properties_2" --save form position after close
		)
	)
)

fn onFormCreated s a = ( --only when created, not open
	
	switchTabTo s.tag.value.tab_buttons[1] a --activate first tab
	s.BackColor = mcDotnet.uiColor #fore
)

fn inicializeInterface form mcs =
(
	form.name = "mcUnwrapToolbardialog"
	form.ControlBox  = false --hide main bar
	local fpos = execute (mcFile.readSettings Micra.UserProfile "Properties_2/mcUnwrapToolbardialog" type:"pos")
	format "mcUnwrapToolbardialog load pos:%\n" fpos
	form.StartPosition = form.StartPosition.Manual
	if fpos != OK do form.bounds = netDrRect fpos [form_width, form_height]
	form.FormBorderStyle = form.FormBorderStyle.none
	form.BackColor = mcDotnet.uiColor #fore --yellow
	form.ShowInTaskbar = false
	form.opacity = mcUIColors.get #opacity
	
	mcs.lblT.bounds = netDrRect [form_offset/2, form_offset/2] [form_width - form_offset*5 , bar_height]
	mcs.lblT.BackColor = mcDotnet.uiColor #back
	mcs.lblT.ForeColor = mcDotnet.uiColor #text
	local version = " v" + (mcFile.getScriptVersion "Customize") --get cript version
	mcs.lblT.Text = "UVW Toolbar:" +(if version != undefined then version else "")
	
	mcs.btnMin.bounds = netDrRect [form_width - 42, form_offset/2] [btn_size, bar_height]
	mcs.btnMin.FlatStyle = mcs.btnMin.FlatStyle.flat
	mcs.btnMin.BackColor = mcDotnet.uiColor #btn --(color 124 196 22)
	mcs.btnMin.ForeColor = netDrColor (mcUIColors.get #text)
	mcs.btnMin.text = "-"
	
	--add default layout panel
	mcs.tlp_main.bounds = netDrRect [form_offset/2, bar_height+form_offset] [form_width - form_offset*5, btn_size]
	mcs.tlp_main.backColor = mcDotnet.uiColor #btn
	mcs.tlp_main.ColumnCount = 3 --tab buttons count
	
	mcs.tab.bounds = netDrRect [form_offset/2, bar_height*2+form_offset*4] [form_width - form_offset*5, form_height - bar_height - btn_size - form_offset*6]
	mcs.tab.backColor = mcDotnet.uiColor #btn --yellow --

	--add handlers
	dotNet.addEventHandler mcs.lblT   "MouseMove" onLblTMouseMove
	dotNet.addEventHandler mcs.lblT   "MouseDown" onLblTMouseDown 
	dotNet.addEventHandler mcs.lblT   "MouseUp"   onLblTMouseUp
	dotNet.addEventHandler mcs.btnMin "MouseClick"  onBtnMinMouseUp
	dotnet.addEventHandler form "Shown" onFormCreated
	dotnet.addEventHandler form "VisibleChanged" onFormVisibilityChanged
	
	--add controls
	addTabButtons mcs
	form.controls.addRange( #(mcs.btnMin, mcs.lblT, mcs.tlp_main, mcs.tab) )
)
inicializeInterface form form.tag.value
mcUnwrapToolbardialog = form
mcDotnet.dShow mcUnwrapToolbardialog
)


/*
				local ui_components = #(
				
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"align_top"		\
						icon:291	toolTip:"Align Top"	margin:#(btn_size,0,0,0),
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"align_left"		\
						icon:289	toolTip:"Align Left"	margin:#(0,btn_size,0,0),
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"align_right"		\
						icon:290	toolTip:"Align Right"	margin:#(btn_size,btn_size,0,0),
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"align_bottom"	\
						icon:292	toolTip:"Align Bottom"	margin:#(btn_size,btn_size,0,0),
					UI_DATA type:"button" text:"" size:[btn_size, btn_size] action:"align_center"		\
						icon:303	toolTip:"Align Center" margin:#(btn_size,btn_size,0,0)
				)
*/