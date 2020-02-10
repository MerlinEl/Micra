--------------------------------------------------------------------------------
/* mcPopUp2 by Orien 2019 */
--------------------------------------------------------------------------------
Global mcPopUp2 
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
	::mcPopUp2.show ">< Is Done ><" delay:2000
	::mcPopUp2.show "<< abc >>\ncde" title:"ABC:" delay:2000 pos:[90, 313]
	::mcPopUp2.show "Micra instalation was Finished"
	::mcPopUp2.show "Select some Objects to Continue" type:#Warning
	::mcPopUp2.show "But this also aligns the label control to the centre" title:"Info:" pos:[90, 313]
	::mcPopUp2.show "DotNet controls cannot only be placed inside 3ds Max Dialogs and Rollouts, but they can also be used to generate user interfaces implemented completely using DotNet Forms." title:"Info:" pos:[90, 313]
	if (::mcPopUp2.show "Do you want create a 'New Scene'?." title:"Micra:" type:#YesNo) == true then (format "Accepted\n") else (format "Canceled:\n")
	
	::mcPopUp2.show "You are sure to collapse stack xdfsfffs\ndsfsfsfsef efefefewf f?." title:"Collapse stack:" type:#Input
*
*/
if isStruct mcPopUp2  do mcPopUp2.close()
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
	
		local hv = DotNetObject "NativeWindow"
		hv.AssignHandle (DotNetObject "System.IntPtr" (Windows.GetMaxHWND())) 
		if modal then form.ShowModal() else form.Show(hv)
	),
	fn close = (if iskindof form dotnetobject do form.hide()),
	fn getName = ( formName ),
	fn getPos = ( [form.location.x, form.location.y] ),
	fn getSize = ( [form.width, form.height] ),
	fn setPos pos = ( form.Location = dPoint pos ),
	fn hideForm = (
		
		mcPopUp2.dtimer.stop()
		mcPopUp2.dtimer.Enabled = false	
		mcPopUp2.form.Hide()
	),
	fn setPosToMaxCenter = (
		
		local max_center = getMaxCenter()
		form.Location = dPoint [max_center.x - form.width / 2, max_center.y - form.height / 2]
	),
private
	--Move / Snap Dialog /
	fn onTitleBarMouseMove s a = (  --drag form
	
		local _mcs = mcPopUp2 --struct instance
		if _mcs.netDMove do  mcDialog.moveAndSnap _mcs.form
	),
	fn onTitleBarMouseDown s a = ( --start drag
			
		local _mcs = mcPopUp2 --struct instance
		_mcs.form.cursor.current = mcDotnet.cursors.Hand
		if a.Button == a.Button.left do ( --enable drag
		
			mcDialog.init _mcs.form
			_mcs.netDMove = true 
		)
	),
	fn onTitleBarMouseUp s a = (--stop drag

		local _mcs = mcPopUp2 --struct instance
		_mcs.netDMove = false 
		case a.Button.ToString() of (
		
			"Left"		: ()
			"Right"		: (_mcs.close())
			"Middle"	: ()
		)
	),
	fn changeBackcolor s a = (s.backColor = mcPopUp2.back_color), --override form backcolor
	fn onFormCreated s a = (
		
		--format "onFormCreated > state:%\n" (s.WindowState.toString())
	),
	fn onCloseForm s a = (
		
		--form closed and unregistred
	),
	fn closeForm s a = (mcPopUp2.close()),
	-- Custom  Functions
	fn onTextResize s a = (
	
		local top_offset = if titleBar.visible then bar_height else 0
		local botom_offset = if add_buttons then btn_size + border_offset*3 else 0
		local gap_offset =  if titleBar.visible then border_offset*3 else border_offset*2
		--format "onTextResize >  top_offset:% gap_offset:%\n" top_offset gap_offset
		
		form.width = textLayout.width + border_offset * 2
		form.height = textLayout.height + top_offset + gap_offset + botom_offset
		titleBar.width = form.width - border_offset * 2
		if add_buttons do (
			
			buttonLayout.Bounds = dRect [border_offset, form.height - btn_size - border_offset*3] [form.width - border_offset*2  , btn_size+4]
		)
	),
	fn onTimeElapsed s a = (mcPopUp2.close()),
	fn onBtnAccept s a = (
		
		mcPopUp2.form_output =  true
		mcPopUp2.close()
	),
	fn onBtnCancel s a = (
		
		mcPopUp2.form_output = false
		mcPopUp2.close()
	),
	fn onType s a  = (
		
		local char_str = a.Keycode.toString()
		case char_str of (
			
			"Escape":( --Escape
			
-- 				format "Escape char:% text:%\n" char_str s.text
				mcPopUp2.form_output = undefined
				mcPopUp2.close()
			)
			"Return":( --Enter
			
-- 				format "Return char:% text:%\n" char_str s.text
				mcPopUp2.form_output = s.text
				mcPopUp2.close()
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
		form.Enabled = true
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
		-- Default Events
		dotnet.addEventHandler form "Shown" onFormCreated
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override form backcolor (without this form color is default)
		dotNet.addEventHandler titleBar   "MouseMove" onTitleBarMouseMove
		dotNet.addEventHandler titleBar   "MouseDown" onTitleBarMouseDown 
		dotNet.addEventHandler titleBar   "MouseUp" onTitleBarMouseUp
		dotNet.addEventHandler lblMsg  "MouseUp" closeForm
		
		dotNet.addEventHandler btnAccept  "MouseUp" onBtnAccept
		dotNet.addEventHandler btnCancel  "MouseUp" onBtnCancel
		
		--Custom Events
		dotNet.addEventHandler textLayout  "Resize" onTextResize
		dotnet.addeventhandler dtimer "Elapsed" onTimeElapsed
		dotnet.addEventHandler edtBox "KeyUp" onType
		-->
		
		--Add Controls
		if type_mode then textLayout.Controls.Add(edtBox) else textLayout.Controls.Add(lblMsg)
		buttonLayout.Controls.addRange #(btnAccept, btnCancel)
		form.Controls.addRange #(buttonLayout, textLayout, titleBar)

		open()
		onTextResize form undefined
		if show_modal do (
			
			form.hide()
			if type_mode do edtBox.focus()
-- 			form.TopMost = true --keep form upper from all windows dialogs
			mcPopUp2.form.ShowModal() --.ShowDialog(mcMicraDialog)
		)
-- 		form.ShowDialog()
-- 		form.ShowModal()
-- 		open modal:show_modal
	),
	public fn show msg title:"" type:#Default delay:0 pos:undefined crypt:false = (
	
		if isOpen() do close()
		show_modal = add_buttons = type_mode = false 
		hidden_title = title.count == 0
		form_output = false
		dtimer.stop()
		dtimer.Enabled = false
		case type of (
			
			#Default	: (
				
				back_color = mcDotnet.dColor (color  0 255 0)
			)
			#Warning	: (
				
				back_color = mcDotnet.dColor (color  255 0 0)
			)
			#YesNo		: (
				
				show_modal = true
				back_color = uiColor #fore --mcDotnet.dColor (color  255 127.5 0)
				add_buttons = true
			)
			#Input			: (
				
				show_modal = true
				edtBox.text = msg
				if crypt do (

					edtBox.PasswordChar = "*"
					edtBox.MaxLength = 20
				)
				back_color = mcDotnet.dColor (color  255 127.5 0)
				hidden_title = true
				type_mode = true
				add_buttons = false
			)
		)
		init msg:msg title:title pos:pos
		if delay > 0 do (
			
			dtimer.interval = delay
			dtimer.start()
		)
		form_output
	)
)
mcPopUp2 = MICRA_POPUP_STRUCT formName:"mcPopUp2"


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
