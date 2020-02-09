Global mcPopUp 
/**
*@Created by MerlinEl 2019
*@Inspired by biddle
*@Example
	mcPopUp.open()
	mcPopUp.close()
	mcPopUp.setPos [100, 200]
	icons 
		? = 306
		! = 307
		ok = 308
		x = 309
	atd...
*/
if isStruct mcPopUp  do mcPopUp.close()
struct DOTNET_MAIN_STRUCT  (
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
	back_color = mcDotnet.dColor green,
	add_buttons = false,
	show_modal = false,
	form_output = undefined,
public
	--Open / Close (with default setup, save position to INI)
	fn isOpen =  (iskindof form dotnetobject and form.visible),
	fn open modal: false = if iskindof form dotnetobject do (
	
		local hv = mcDotnet.maxHW ()
		if modal then form.ShowModal() else form.Show(hv)
	),
	fn close = (if iskindof form dotnetobject do form.Hide()),
	fn getName = ( formName ),
	fn getPos = ( [form.location.x, form.location.y] ),
	fn getSize = ( [form.width, form.height] ),
	fn setPos pos = ( form.Location = mcDotnet.dPoint pos ),
	fn hideForm = (
		
		mcPopUp.dtimer.stop()
		mcPopUp.dtimer.Enabled = false	
		mcPopUp.form.Hide()
	),
	fn centerForm = (
		
		local max_center = mcSystem.getMaxCenter()
		form.Location = mcDotnet.dPoint [max_center.x - form.width / 2, max_center.y - form.height / 2]
	),
private
	--Move / Snap Dialog /
	fn onTitleBarMouseMove s a = (  --drag form
	
		local _mcs = mcPopUp --struct instance
		if _mcs.netDMove do  mcDialog.moveAndSnap _mcs.form
	),
	fn onTitleBarMouseDown s a = ( --start drag
			
		local _mcs = mcPopUp --struct instance
		_mcs.form.cursor.current = netCursors.Hand
		if a.Button == a.Button.left do ( --enable drag
		
			mcDialog.init _mcs.form
			_mcs.netDMove = true 
		)
	),
	fn onTitleBarMouseUp s a = (--stop drag

		local _mcs = mcPopUp --struct instance
		_mcs.netDMove = false 
		case a.Button.ToString() of (
		
			"Left"	: (
				--format " save form:%  pos:% size:%\n" form.name (form.location.toString()) (form.size.toString())
-- 				mcFile.saveDialogSettings _mcs.form.name "Properties_2" --save form position after drag
			)
			"Right"	: (
			
				_mcs.form.close()
			)
			"Middle"	: (
			

			)
		)
	),
	fn changeBackcolor s a = (s.backColor = mcPopUp.back_color), --override form backcolor
	fn onFormCreated s a = (
		
		--format "onFormCreated > state:%\n" (s.WindowState.toString())
	),
	fn onCloseForm s a = (
		
-- 		mcFile.saveDialogSettings s.name "Properties_2" --save form position after drag
		--form closed and unregistred
	),
	fn closeForm s a = (mcPopUp.hideForm()),
	-- Custom  Functions
	fn onTextResize s a = (
	
			format "titleBar:%\n" titleBar
		local top_offset = if titleBar.visible then bar_height else 0
		local botom_offset = if add_buttons then btn_size + border_offset*3 else 0
		local gap_offset =  if titleBar.visible then border_offset*3 else border_offset*2
		format "onTextResize >  top_offset:% gap_offset:%\n" top_offset gap_offset
		
		form.width = textLayout.width + border_offset * 2
		form.height = textLayout.height + top_offset + gap_offset + botom_offset
		titleBar.width = form.width - border_offset * 2
		if add_buttons do (
			
			buttonLayout.Bounds = mcDotnet.dRect [border_offset, form.height - btn_size - border_offset*3] [form.width - border_offset*2  , btn_size+4]
		)
	),
	fn onTimeElapsed s a = (mcPopUp.hideForm()),
	fn onBtnAccept s a = (
		
		form_output =  true
		mcPopUp.hideForm()
	),
	fn onBtnCancel s a = (
		
		form_output = false
		mcPopUp.hideForm()
	),
	-->
	
	-- main function
	fn init msg:"" title:"" compact:false pos:undefined =  (
		
		format "add msg:%\n\ttitle:%\n\tpos:%\n" msg title pos
		local top_offset = if compact then border_offset else bar_height + border_offset*2
		if pos == undefined do (
			
			local max_center = mcSystem.getMaxCenter()
			pos = [max_center.x - form.width / 2, max_center.y - form.height / 2]
		)
		form.name = form.text = formName
		form.ControlBox  = false --hide main bar
		form.ShowInTaskbar = false
		form.StartPosition = form.StartPosition.Manual
		form.Location = mcDotnet.dPoint pos
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = mcDotnet.uiColor #fore
		form.opacity = 1 ---mcUIColors.get #opacity
		--top toolbar
		titleBar.Bounds = mcDotnet.dRect [border_offset, border_offset] [bar_height , bar_height]
		titleBar.BackColor = mcDotnet.uiColor #back
		titleBar.ForeColor = mcDotnet.uiColor #fore--(color 116 255 234)
		--titleBar.textAlign = lblMsg.textAlign.MiddleCenter
		titleBar.font = mcDotnet.dFont font:"Arial" size:10 style:"Bold"
		titleBar.visible = not compact
		titleBar.text = " " + title --add titlebar text	
		--bottom toolbar
		buttonLayout.BackColor = mcDotnet.uiColor #back
		buttonLayout.visible = add_buttons
		buttonLayout.ColumnCount = 2
		--buton Accept
		btnAccept.name = "btn_icon"
		btnAccept.FlatStyle = btnAccept.FlatStyle.flat
		btnAccept.BackColor = mcDotnet.uiColor #btn
		btnAccept.ForeColor = mcDotnet.uiColor #fore
		btnAccept.Image = mcCall.getIconDn 308
		btnAccept.Size = mcDotnet.dSize [btn_size, btn_size]
		btnAccept.Dock = mcDotnet.DockStyle.Left
		--button Cancel
		btnCancel.name = "btn_close"
		btnCancel.FlatStyle = btnCancel.FlatStyle.flat
		btnCancel.BackColor = mcDotnet.uiColor #btn
		btnCancel.ForeColor = mcDotnet.uiColor #fore
		btnCancel.Image = mcCall.getIconDn 309
		btnCancel.Size = mcDotnet.dSize [btn_size, btn_size]
		btnCancel.Dock = mcDotnet.DockStyle.Right
		--Componnts Layout
		textLayout.backColor =  mcDotnet.dcolor blue ---mcDotnet.uiColor #btn
		textLayout.AutoSize = true
		textLayout.backColor = mcDotnet.uiColor #btn
		textLayout.Bounds  = mcDotnet.dRect [border_offset,  top_offset] [10, 10]		
-- 		textLayout.RowCount = 3
		--Custom Components
		lblMsg.TabIndex = 0
		lblMsg.text = msg
		lblMsg.textAlign = lblMsg.textAlign.MiddleCenter
		lblMsg.MinimumSize = mcDotnet.dSize msg_min_size	
		lblMsg.MaximumSize = mcDotnet.dSize msg_max_size
		lblMsg.AutoSize = true
		lblMsg.foreColor = mcDotnet.dColor (color 255 255 116)
		lblMsg.font = mcDotnet.dFont font:"Verdana" size:12 style:"Regular"
		-->
		
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
		-- dotNet.addEventHandler lblMsg  "TextChanged" onLblMsgTextChanged
		-->
		
		--Add Controls
		textLayout.Controls.Add(lblMsg)
		buttonLayout.Controls.addRange #(btnAccept, btnCancel)
		form.Controls.addRange #(buttonLayout, textLayout, titleBar)

		open()
		onTextResize form undefined
		if show_modal do (
			
			form.hide()
-- 			form.TopMost = true --keep form upper from all toolbars
			mcPopUp.form.ShowDialog() --.ShowDialog(mcMicraDialog)
		)
-- 		form.ShowDialog()
-- 		form.ShowModal()
-- 		open modal:show_modal
	),
	public fn show msg title:"" type:#Success delay:0 compact:false pos:undefined = (
	
		if isOpen() do hideForm()
		show_modal = add_buttons = false 
		case type of (
			
			#Success	: (
				
				back_color = mcDotnet.dColor green
			)
			#Warning	: (
				
				back_color = mcDotnet.dColor red
			)
			#YesNo		: (
				
				show_modal = true
				back_color = mcDotnet.uiColor #fore --mcDotnet.dColor orange
				add_buttons = true
			)
			#Type			: (
				
				show_modal = true
				back_color = mcDotnet.dColor orange
				add_buttons = true
			)
		)
		init msg:msg title:title compact:compact pos:pos
		if delay > 0 do (
			
			dtimer.stop()
			dtimer.Enabled = false
			dtimer.interval = delay
			dtimer.start()
		)
		form_output
	)
)
--init
::mcPopUp = DOTNET_MAIN_STRUCT formName:"mcPopUp"


--call
(
	/*
	::mcPopUp.show "<< abc >>\ncde" title:"ABC:" type:#Info delay:2000 pos:[90, 313]
	::mcPopUp.show "Micra instalation was Finished" type:#Info compact:true
	::mcPopUp.show "Select some Objects to Continue" type:#Warning  compact:true
	::mcPopUp.show "But this also aligns the label control to the centre" title:"Info:" type:#Success pos:[90, 313]
	::mcPopUp.show "DotNet controls cannot only be placed inside 3ds Max Dialogs and Rollouts, but they can also be used to generate user interfaces implemented completely using DotNet Forms." title:"Info:" type:#Success pos:[90, 313]
	::mcPopUp.show "You are sure to collapse stack?." title:"Collapse stack:" type:#YesNo
	::mcPopUp.show "You are sure to collapse stack?." title:"Collapse stack:" type:#YesNo pos:[90, 313]
	*/

-- 	result = ::mcPopUp.show "You are sure to collapse stack xdfsfffs\ndsfsfsfsef efefefewf f?." title:"Collapse stack:" type:#YesNo
-- 	format "result:%\n" result
-- 	::mcPopUp.show "You are sure to collapse stack xdfsfffs\ndsfsfsfsef efefefewf f?." title:"Collapse stack:" type:#Type
	::mcPopUp.show "You are sure to collapse stack xdfsfffs\ndsfsfsfsef efefefewf f?." title:"Collapse stack:" type:#Success
)



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
