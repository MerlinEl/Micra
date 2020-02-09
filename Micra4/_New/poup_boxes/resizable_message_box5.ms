Global mcPopUp 
/**
*@Created by MerlinEl 2019
*@Inspired by biddle
*@Example
	mcPopUp.open()
	mcPopUp.close()
	mcPopUp.moveTo [100, 200]
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
	tlp = dotNetObject "TableLayoutPanel",
	lblMsg = dotNetObject "Label",
	dtimer = dotnetobject "System.Timers.Timer",
	--private variables
	pos				= [0, 0],
	size			= [100, 28],
	minimized		= false, 
	bar_height		= 18,
	border_offset	= 2,
	btn_size		= 22,
	debug			= 0,
	netDMove = false,
	back_color = mcDotnet.dColor green,
	msg_min_size = [100, 28],
	msg_max_size = [800, 600],
public
	--Open / Close (with default setup, save position to INI)
	fn isOpen =  (iskindof form dotnetobject and form.visible),
	fn open = (if iskindof form dotnetobject do mcDotnet.dShow form),
	fn close = (if iskindof form dotnetobject do form.Hide()),
	fn getName = ( formName ),
	fn getPos = ( [form.location.x, form.location.y] ),
	fn getSize = ( [form.width, form.height] ),
	fn setPos pos = ( form.location = mcDotnet.dPoint pos ),
	fn hideForm = (
		
		mcPopUp.dtimer.stop()
		mcPopUp.dtimer.Enabled = false	
		mcPopUp.form.Hide()
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
				mcFile.saveDialogSettings _mcs.form.name "Properties_2" --save form position after drag
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
		
		mcFile.saveDialogSettings s.name "Properties_2" --save form position after drag
		--form closed and unregistred
	),
	fn closeForm s a = (mcPopUp.hideForm()),
	-- Custom  Functions
	fn onTextResize s a = (
	
		format "text resized:\n"
		top_offset = if titleBar.visible then bar_height else 0
		tlp.Location = mcDotnet.dPoint [border_offset, border_offset + top_offset]
		
		form.width = tlp.width + border_offset * 2
		form.height = tlp.height + top_offset + border_offset * 2 --border_offset * 3
		titleBar.width = form.width - border_offset * 2
		btnAccept.location = mcDotnet.dPoint [form.width - btnAccept.width  , form.height - btn_size]
		btnCancel.location = mcDotnet.dPoint [0  , form.height - btn_size]
	),
	public fn show msg tille:"" type:#Info delay:0 compact:false pos:undefined = (
	
		if isOpen() do hideForm()
		case type of (
			
			#Info			: (
				
				lblMsg.Text = msg
				btnAccept.visible = btnCancel.visible = false
				back_color = mcDotnet.dColor green
			)
			#Warning	: (
				
				lblMsg.Text = msg
				btnAccept.visible = btnCancel.visible = false
				back_color = mcDotnet.dColor red
			)
			#OK			: (
				
				lblMsg.Text = msg
			)
			#YesNo		: (
				
				lblMsg.Text = msg
				btnAccept.visible = true
				btnCancel.visible = true
			)
			#Type			: (
				
			)
		)
		titleBar.visible = not compact
		if not compact do titleBar.Text = " " + tille --add titlebar text
		onTextResize form undefined	
		open()
		
		if delay > 0 do (
			
			dtimer.stop()
			dtimer.Enabled = false
			dtimer.interval = delay
			dtimer.start()
		)
	),
	fn onTimeElapsed s a = (mcPopUp.hideForm()),
	fn onBtnAccept s a = (
		
		mcPopUp.hideForm()
	),
	fn onBtnCancel s a = (
		
		mcPopUp.hideForm()
	),
	-->
	
	-- main function
	fn init  =  (
		
		--setup interface
		local form_settings = mcFile.readDialogSettings formName "Properties_2" --get saved pos and size
		if form_settings != undefined do (
		
			pos = execute (form_settings.get "pos")
			--size = execute (form_settings.get "pos") --causeing trouble
		)
		--size = from_data.size (when loaded every time is les and less....????)
		--format " load form:%  pos:% size:%\n" formName pos size
		
		form.name = form.text = formName
		form.ControlBox  = false --hide main bar
		form.ShowInTaskbar = false
		form.StartPosition = form.StartPosition.Manual
		form.bounds = mcDotnet.dRect pos size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = mcDotnet.uiColor #fore
		form.opacity = 1 ---mcUIColors.get #opacity
		--form.TopMost = true --keep fotm upper from all toolbars
		
		--toolbar
		titleBar.Size = mcDotnet.dSize [bar_height , bar_height]
		titleBar.BackColor = mcDotnet.uiColor #back
		titleBar.ForeColor = mcDotnet.dColor (color 116 255 234)
		--titleBar.textAlign = lblMsg.textAlign.MiddleCenter
		titleBar.font = mcDotnet.dFont font:"Arial" size:10 style:"Bold"
		
		--OK buton
		btnAccept.name = "btn_icon"
		btnAccept.FlatStyle = btnAccept.FlatStyle.flat
		btnAccept.BackColor = mcDotnet.uiColor #btn
		btnAccept.ForeColor = mcDotnet.uiColor #fore
		btnAccept.Image = mcCall.getIconDn 308
		btnAccept.Size = mcDotnet.dSize [btn_size, btn_size]
		
		--Close button
		btnCancel.name = "btn_close"
		btnCancel.FlatStyle = btnCancel.FlatStyle.flat
		btnCancel.BackColor = mcDotnet.uiColor #btn
		btnCancel.ForeColor = mcDotnet.uiColor #fore
		btnCancel.Image = mcCall.getIconDn 309
		btnCancel.Size = mcDotnet.dSize [btn_size, btn_size]

		--Componnts Layout
		tlp.backColor = mcDotnet.uiColor #btn
		tlp.AutoSize = true
		tlp.Bounds  = mcDotnet.dRect [border_offset,  border_offset] [10, 10]		
		--Custom Components
		lblMsg.TabIndex = 0
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
		dotNet.addEventHandler tlp  "Resize" onTextResize
		dotnet.addeventhandler dtimer "Elapsed" onTimeElapsed
		-- dotNet.addEventHandler lblMsg  "TextChanged" onLblMsgTextChanged
		-->
		
		--Add Controls
		tlp.Controls.Add(lblMsg)
		form.controls.addRange (#(btnAccept, btnCancel, tlp, titleBar))
		OK
	),
	initialized = init()  --strange think but works
)
--init
::mcPopUp = DOTNET_MAIN_STRUCT formName:"mcPopUp"


--call
(
	/*
	::mcPopUp.show "<< abc >>\ncde" type:#Info delay:2000 compact:true
	::mcPopUp.show "Micra instalation was Finished" type:#Info delay:2000 compact:true
	::mcPopUp.show "Select some Objects to Continue" type:#Warning delay:2000 compact:true
	::mcPopUp.show "But this also aligns the label control to the centre" type:#Info pos:[90, 313]
	
	*/
	::mcPopUp.show "In this post we shall learn how to write a simple socket server in python. This has already been covered in the previous tutorial. In this post we shall learn few more things about programming server sockets like handling multiple connections with the select method." \
	title:"Micra Update:" type:#Warning
)

/*
::mcPopUp.show "Text contents"
::mcPopUp.show "But this also aligns the label control to the centre"
::mcPopUp.show "DotNet controls cannot only be placed inside 3ds Max Dialogs and Rollouts, but they can also be used to generate user interfaces implemented completely using DotNet Forms."
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
		--lblMsg.Anchor = dotnet.combineEnums mcDotnet.AnchorStyles.Left mcDotnet.AnchorStyles.Right
		--tlp.Anchor = dotnet.combineEnums mcDotnet.AnchorStyles.Top mcDotnet.AnchorStyles.Left
		-- tlp.Margin = mcDotnet.dPadding 8 8 8 8--border_offset border_offset border_offset border_offset
		
			-- form.width = tlp.width + border_offset * 2
		-- form.height = tlp.height + bar_height + border_offset * 2
		
		-- local text_size = mcDotnet.TextRenderer.MeasureText s.text s.Font
		-- local ratio_x = text_size.width / msg_max_size.x
		-- format "ratio:%\n" ratio_x
		-- tlp.width = text_size.width / ratio_x
		-- tlp.height = text_size.height * (ratio_x+1)
		-- form.width = tlp.width = s.width
		-- form.height = tlp.height = s.height
		
		local text_size = mcDotnet.TextRenderer.MeasureText s.text s.Font
		if (s.Width < msg_max_width) then (

			s.Width =  text_size.Width
			
		) else (
		
			s.Width = msg_max_width 
			s.Height = text_size.Height
		)
*/
