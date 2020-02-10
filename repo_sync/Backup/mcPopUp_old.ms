--------------------------------------------------------------------------------
/* mcPopUp by Orien 2019 */
--------------------------------------------------------------------------------
Global mcPopUp 
/*
*@Created by MerlinEl 2020
*@Used Structures
	mcDotnet
	mcDialog
	mcString
	mcUIColors
*
*@Used Objects
	undefined
*
*@Usage
	Show PopUp Boxes in Max Application after Micra is Initialized !
*
*@Example	
	::mcPopUp.show ">< Is Done ><" delay:2000
	::mcPopUp.show "<< abc >>\ncde" title:"ABC:" delay:2000 pos:[90, 313]
	::mcPopUp.show "Micra instalation was Finished"
	::mcPopUp.show "Select some Objects to Continue" type:#Warning
	::mcPopUp.show "But this also aligns the label control to the centre" title:"Info:" pos:[90, 313]
	::mcPopUp.show "DotNet controls cannot only be placed inside 3ds Max Dialogs and Rollouts, but they can also be used to generate user interfaces implemented completely using DotNet Forms." title:"Info:" pos:[90, 313]
	if (::mcPopUp.show "Do you want create a 'New Scene'?." title:"Micra:" type:#YesNo) == true then (format "Accepted\n") else (format "Canceled:\n")
	
	::mcPopUp.show "Tpe new object Name" title:"Collapse stack:" type:#Input
*
*/
if isStruct mcPopUp  do mcPopUp.close()
struct MICRA_POPUP_STRUCT  (
public	
	formName,
	--define interface components
	form = dotNetObject "MaxCustomControls.MaxForm",
	titleBar = dotNetObject "Label",
	btnAccept = dotNetObject "button",
	btnCancel = dotNetObject "button",
	textLayout = dotNetObject "TableLayoutPanel",
	buttonLayout = dotNetObject "TableLayoutPanel",
	lblMsg = dotNetObject "Label",
	edtBox = dotNetObject "textbox",
	dtimer = dotnetobject "System.Timers.Timer",
	--private variables
	pos	= [0, 0],
	msg_min_size = [100, 28],
	msg_max_size = [800, 600],	
	max_center = true,
	minimized		= false, 
	bar_height		= 18,
	border_offset	= 2,
	btn_size		= 22,
	debug			= 0,
	netDMove = false,
	back_color = mcDotnet.dColor (color 0 255 0),
	add_buttons = false,
	show_modal = false,
	hidden_title = false,
	form_output = false,
	type_mode = false,
	lclick_hide = true,
private
	fn uiColor color_name = (
		
		local ui_color = mcUIColors.get color_name
		(dotNetClass "Drawing.Color").fromArgb ui_color.r ui_color.g ui_color.b
	),
	fn dPoint pos = (dotnetObject "Drawing.Point" pos.x pos.y),
	fn dRect pos size = (dotnetObject "Drawing.Rectangle" pos.x pos.y size.x size.y),
	fn dSize size = (dotNetObject "Drawing.Size" size.x size.y),
	fn dFont font:"Arial" size:12 style:"Regular" = (
		
		local f_style=execute ( "(dotNetClass \"Drawing.FontStyle\")."+style)
		dotNetObject "Drawing.Font" font size f_style
	),
	fn getMaxPos = (return windows.getWindowPos (Windows.GetMAXHWND())),
	fn getMaxCenter = (
	
		local max_pos = getMaxPos()
		return [max_pos.w/2 + max_pos.x /2, max_pos.h/2 + max_pos.y /2]
	),
public
	--Open / Close (with default setup, save position to INI)
	fn isOpen =  (iskindof form dotnetobject and form.visible),
	fn open modal: false = if iskindof form dotnetobject do (
		
		--if modal then form.ShowModal() else form.Show()
		if modal then form.ShowModal(mcMicraDialog) else form.Show(mcMicraDialog)
	),
	fn close = (if iskindof form dotnetobject do form.close()),
	fn getName = ( formName ),
	fn getPos = ( [form.location.x, form.location.y] ),
	fn getSize = ( [form.width, form.height] ),
	fn setPos pos = ( form.Location = dPoint pos ),
	fn setPosToMaxCenter = (
		
		local max_center = getMaxCenter()
		form.Location = dPoint [max_center.x - form.width / 2, max_center.y - form.height / 2]
	),
private
	--Move / Snap Dialog /
	fn onTitleBarMouseMove s a = (  --drag form
	
		local _mcs = mcPopUp --struct instance
		if _mcs.netDMove do  mcDialog.moveAndSnap _mcs.form
	),
	fn onTitleBarMouseDown s a = ( --start drag
			
		local _mcs = mcPopUp --struct instance
		_mcs.form.cursor.current = mcDotnet.cursors.Hand
		if a.Button == a.Button.left do ( --enable drag
		
			mcDialog.init _mcs.form
			_mcs.netDMove = true 
		)
	),
	fn onTitleBarMouseUp s a = (--stop drag

		local _mcs = mcPopUp --struct instance
		_mcs.netDMove = false 
		case a.Button.ToString() of (
		
			"Left"		: ()
			"Right"		: (_mcs.close())
			"Middle"	: ()
		)
	),
public
	fn onTextResize s a = (
	
		--local form_size = form.size
		local top_offset = if titleBar.visible then bar_height else 0
		local botom_offset = if add_buttons then btn_size + border_offset*3 else 0
		local gap_offset =  if titleBar.visible then border_offset*3 else border_offset*2

		form.width = textLayout.width + border_offset * 2
		form.height = textLayout.height + top_offset + gap_offset + botom_offset
		titleBar.width = form.width - border_offset * 2
		if add_buttons do (
			
			buttonLayout.Bounds = dRect [border_offset, form.height - btn_size - border_offset*3] [form.width - border_offset*2  , btn_size+4]
		)
		if max_center do setPosToMaxCenter()
		--form.location = mcDotnet.dPoint [form.location.x + form_size.width -  form.width, form.location.y + form_size.height -  form.height]
	),
private
	fn changeBackcolor s a = (s.backColor = mcPopUp.back_color), --override form backcolor
	fn onVisibleChanged s a = (
		
		format "onVisibleChanged:%\n" (s.visible)
		case s.visible of (
			
			true : (
				
				mcPopUp.onTextResize s undefined	
				if mcPopUp.type_mode do mcPopUp.edtBox.focus()	
			)
			false : (
				
				s.Enabled = false
			)
		)
	),
	fn onFormCreated s a = (
		
		--when form is open first time
	),
-- 	fn onFormActivated s a = (


-- 	),
	fn onCloseForm s a = (
		
		form.Enabled = true
		--form closed and unregistred
	),
	fn closeForm s a = (mcPopUp.close()),
	-- Custom  Functions
	fn onTimeElapsed s a = (mcPopUp.close()),
	fn onBtnAccept s a = (
		
		mcPopUp.form_output =  true
		mcPopUp.close()
	),
	fn onBtnCancel s a = (
		
		mcPopUp.form_output = false
		mcPopUp.close()
	),
	fn onType s a  = (
		
		local char_str = a.Keycode.toString()
		case char_str of (
			
			"Escape":( --Escape
			
-- 				format "Escape char:% text:%\n" char_str s.text
				mcPopUp.form_output = undefined
				mcPopUp.close()
			)
			"Return":( --Enter
			
-- 				format "Return char:% text:%\n" char_str s.text
				mcPopUp.form_output = s.text
				mcPopUp.close()
			)
			default:(
			
-- 				format "Key char:% text:%\n" char_str s.text
				if s.text.count > 0 do (
					
					s.text = mcString.filterInvalidChars s.text --remove invalid characters
					s.SelectionStart = s.text.count --move cursor at end
				)
			)
		)
	),
	-->
	
	-- main function
	fn init msg:"" title:"" pos:undefined =  (
		
		--build ui components each time
		form = dotNetObject "MaxCustomControls.MaxForm"
		titleBar = dotNetObject "Label"
		btnAccept = dotNetObject "button"
		btnCancel = dotNetObject "button"
		textLayout = dotNetObject "TableLayoutPanel"
		buttonLayout = dotNetObject "TableLayoutPanel"
		lblMsg = dotNetObject "Label"
		edtBox = dotNetObject "textbox"
		dtimer = dotnetobject "System.Timers.Timer"
		
		--format "add msg:%\n\ttitle:%\n\tpos:%\n" msg title pos
		local top_offset = if hidden_title then border_offset else bar_height + border_offset*2
		if pos == undefined do (
			
			local max_center = getMaxCenter()
			pos = [max_center.x - form.width / 2, max_center.y - form.height / 2]
		)
		form.name = form.text = formName
		form.ControlBox  = false --hide main bar
		form.ShowInTaskbar = false
		form.StartPosition = form.StartPosition.Manual
		form.Bounds = dRect pos msg_min_size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = uiColor #fore
		form.opacity = 1 ---mcUIColors.get #opacity
		--top toolbar
		titleBar.Bounds = dRect [border_offset, border_offset] [bar_height , bar_height]
		titleBar.BackColor = uiColor #back
		titleBar.ForeColor = uiColor #fore--(color 116 255 234)
		--titleBar.textAlign = lblMsg.textAlign.MiddleCenter
		titleBar.font = dFont font:"Arial" size:10 style:"Bold"
		titleBar.visible = not hidden_title
		titleBar.text = " " + title --add titlebar text	
		--bottom toolbar
		buttonLayout.BackColor = uiColor #back
		buttonLayout.visible = add_buttons
		buttonLayout.ColumnCount = 2
		--buton Accept
		btnAccept.name = "btn_icon"
		btnAccept.FlatStyle = btnAccept.FlatStyle.flat
		btnAccept.BackColor = uiColor #btn
		btnAccept.ForeColor = uiColor #fore
		btnAccept.Image = mcDotnet.getIcon 308
		btnAccept.Size = dSize [btn_size, btn_size]
		btnAccept.Dock = mcDotnet.dockStyle.Left
		--button Cancel
		btnCancel.name = "btn_close"
		btnCancel.FlatStyle = btnCancel.FlatStyle.flat
		btnCancel.BackColor = uiColor #btn
		btnCancel.ForeColor = uiColor #fore
		btnCancel.Image = mcDotnet.getIcon 309
		btnCancel.Size = dSize [btn_size, btn_size]
		btnCancel.Dock = mcDotnet.dockStyle.Right
		--Componnts Layout
		textLayout.backColor =  mcDotnet.dColor (color  0 0 255) ---uiColor #btn
		textLayout.AutoSize = true
		textLayout.backColor = uiColor #btn
		textLayout.Bounds  = dRect [border_offset,  top_offset] [10, 10]		
-- 		textLayout.RowCount = 3
		--Msg label
		lblMsg.TabIndex = 0
		lblMsg.text = msg
		lblMsg.textAlign = lblMsg.textAlign.MiddleCenter
		lblMsg.MinimumSize = dSize msg_min_size	
		lblMsg.MaximumSize = dSize msg_max_size
		lblMsg.AutoSize = true
		lblMsg.foreColor = mcDotnet.dColor (color  255 255 116)
		lblMsg.font = dFont font:"Verdana" size:12 style:"Regular"
		--Type Box
		edtBox.BackColor = uiColor #edtback
		edtBox.ForeColor = uiColor #edtfore
		edtBox.font = dFont font:"Verdana" size:12 style:"Bold"
		edtBox.Size = dSize [342, msg_min_size.y]
		edtBox.Visible = type_mode
		edtBox.Multiline = true	
		
		-- Add Events
		dotnet.addEventHandler form "VisibleChanged" onVisibleChanged
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor
		dotNet.addEventHandler titleBar   "MouseMove" onTitleBarMouseMove
		dotNet.addEventHandler titleBar   "MouseDown" onTitleBarMouseDown 
		dotNet.addEventHandler titleBar   "MouseUp" onTitleBarMouseUp
		dotNet.addEventHandler lblMsg  "MouseUp" closeForm
		dotNet.addEventHandler btnAccept  "MouseUp" onBtnAccept
		dotNet.addEventHandler btnCancel  "MouseUp" onBtnCancel
		dotNet.addEventHandler textLayout  "Resize" onTextResize
		dotnet.addeventhandler dtimer "Elapsed" onTimeElapsed
		dotnet.addEventHandler edtBox "KeyUp" onType
		
-- 		dotNet.setLifetimeControl form
-- 		dotNet.setLifetimeControl titleBar
-- 		dotNet.setLifetimeControl lblMsg
-- 		dotNet.setLifetimeControl btnAccept
-- 		dotNet.setLifetimeControl btnCancel
-- 		dotNet.setLifetimeControl textLayout
-- 		dotNet.setLifetimeControl dtimer
-- 		dotNet.setLifetimeControl edtBox
-- 	
		--Add Controls
		if type_mode then textLayout.Controls.Add(edtBox) else textLayout.Controls.Add(lblMsg)
		buttonLayout.Controls.addRange #(btnAccept, btnCancel)
		form.Controls.addRange #(buttonLayout, textLayout, titleBar)
	),
	public fn show msg title:"" type:#Default delay:0 pos:undefined crypt:false = (
	
		if isOpen() do close()
		show_modal = add_buttons = type_mode = form_output = false 
		hidden_title = title.count == 0
		lclick_hide = true
		max_center = pos == undefined
		dtimer.stop()
		dtimer.Enabled = false
		form.Enabled = true
		case type of (
			
			#Default	: (
				
				back_color = mcDotnet.dColor (color  0 255 0)
			)
			#Abort	: (
				
				back_color = mcDotnet.dColor (color  255 127.5 0)
			)
			#Warning	: (
				
				back_color = mcDotnet.dColor (color  255 0 0)
			)
			#YesNo		: (
				
				lclick_hide = false
				show_modal = true
				back_color = uiColor #fore --mcDotnet.dColor (color  255 127.5 0)
				add_buttons = true
			)
			#Input			: (
				
				show_modal = true
				back_color = mcDotnet.dColor (color  255 127.5 0)
				type_mode = true
				add_buttons = false
				edtBox.text = msg
				if crypt do (  --switch to enter text or stars

					edtBox.PasswordChar = "*"
					edtBox.MaxLength = 20
				)
			)
		)
		init msg:msg title:title pos:pos
		if delay > 0 do (
			
			dtimer.interval = delay
			dtimer.start()
		)
		open modal:show_modal
		form_output
	)
)
mcPopUp = MICRA_POPUP_STRUCT formName:"mcPopUp"


/*
		local form_size = [320, 60]
		_form_name = form_name
		local max_center = getMaxCenter() - (form_size/2)
		local form_rect = mcDotnet.dRect max_center form_size
		--load pos from ini
		if form_name != "MaxCenter" then (
			
			local fpos = execute (mcFile.readSettings Micra.UserProfile ("Properties_2/"+form_name) type:"pos")
			if classOf fpos == Point2 do form_rect = mcDotnet.dRect fpos form_size
		) 
*/


/*
	icon type:
		Asterisk 
		Error 
		Exclamation
		Hand
		Information
		None
		Question
		Stop
		Warning
local icon = (execute("(DotNetClass \"MessageBoxIcon\")." + iconType))
*/


	/*	
	-- 		dotnet.addEventHandler form "Activated" onFormActivated
-- 			dotnet.addEventHandler form "Shown" onFormCreated
-- 			dotnet.addEventHandler form "Closed" onCloseForm

fn open modal: false = if iskindof form dotnetobject do (
		
		if modal then form.ShowModal() else (
			
			local hv = DotNetObject "NativeWindow"
			hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
			form.Show(hv)
		)
-- 		form.ShowDialog()
-- 		form.ShowModal()
	),*/