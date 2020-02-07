Global mcTemplateDialog 
/**
*@Created by MerlinEl 2019
*@Inspired by biddle
*@Example
	mcTemplateDialog.open()
	mcTemplateDialog.close()
	mcTemplateDialog.moveTo [100, 200]
	atd...
*/
if ::mcTemplateDialog != undefined do try(mcTemplateDialog.close())catch()
struct DOTNET_MAIN_STRUCT  (
	
public	
	title,
	--define interface components
	form = dotNetObject "MaxCustomControls.MaxForm",
	lblT = dotNetObject "Label",
	btnMin = dotNetObject "button",
	tlp = dotNetObject "TableLayoutPanel",
	lblMsg = dotNetObject "Label",
	--private variables
	pos				= [0, 0],
	size			= [200, 100],
	minimized		= false, 
	old_height, 
	bar_height		= 14,
	border_offset	= 2,
	btn_size		= 24,
	debug			= 0,
	netDMove = false,
	msg_min_size = [200, 80],
	msg_max_size = [800, 600],
	
public
	--Open / Close (with default setup, save position to INI)
	fn open = (if iskindof form dotnetobject do mcDotnet.dShow form),
	fn close = (if iskindof form dotnetobject do form.Close()),
	fn getName = ( title ),
	fn getPos = ( [form.location.x, form.location.y] ),
	fn getSize = ( [form.width, form.height] ),
	fn setPos pos = ( form.location = mcDotnet.dPoint pos ),
private
	--Move / Snap Dialog /
	fn onLblTMouseMove s a = (  --drag form
	
		local _mcs = mcTemplateDialog --struct instance
		if _mcs.netDMove do  mcDialog.moveAndSnap _mcs.form
	),
	fn onLblTMouseDown s a = ( --start drag
			
		local _mcs = mcTemplateDialog --struct instance
		_mcs.form.cursor.current = netCursors.Hand
		if a.Button == a.Button.left do ( --enable drag
		
			mcDialog.init _mcs.form
			_mcs.netDMove = true 
		)
	),
	fn onLblTMouseUp s a = --stop drag
	(
		local _mcs = mcTemplateDialog --struct instance
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
	-- min max form
	fn minMaxForm s a = ( -- s = Button, a = MouseEventArgs
		
		local _mcs = mcTemplateDialog --struct instance
		if _mcs.old_height == undefined do _mcs.old_height = _mcs.form.height
		local minimized = _mcs.form.height < _mcs.old_height
		--format "height old:% current:% was minimized:%\n"  _mcs.old_height _mcs.form.height minimized
		if minimized then ( --maximize
			
			s.text = "+"
			_mcs.form.height = _mcs.old_height --restore height
		) else ( --minimize
			
			s.text = "-"
			_mcs.old_height		=	_mcs.form.height --store max size
			_mcs.form.height	= _mcs.bar_height + _mcs.border_offset*2 --minimize
		)
	),		
	fn changeBackcolor s a = (s.backColor = mcDotnet.dColor (mcUIColors.get #fore)), --override form backcolor
	fn onFormCreated s a = (
		
		--format "onFormCreated > state:%\n" (s.WindowState.toString())
	),
	fn onCloseForm s a = (
		
		--format " save form:%  pos:% size:%\n" s.name (s.location.toString()) (s.size.toString())
		mcFile.saveDialogSettings s.name "Properties_2" --save form position after close
	),
	-- Custom  Functions
	fn onLblMsgTextChanged s a = (
	
		form.width = tlp.width + border_offset * 2
		form.height = tlp.height + bar_height + border_offset * 3
		btnMin.location = mcDotnet.dPoint [form.width - btnMin.width - border_offset  , border_offset]
		lblT.width = form.width - border_offset*10
	),
	public fn addText msg = (
	
		lblMsg.Text = msg
	),
	-->
	
	-- main function
	fn init  =  (
		
		--setup interface
		local form_settings = mcFile.readDialogSettings title "Properties_2" --get saved pos and size
		if form_settings != undefined do (
		
			pos = execute (form_settings.get "pos")
			--size = execute (form_settings.get "pos") --causeing trouble
		)
		--size = from_data.size (when loaded every time is les and less....????)
		--format " load form:%  pos:% size:%\n" title pos size
		
		form.name = form.text = title
		form.ControlBox  = false --hide main bar
		form.ShowInTaskbar = false
		form.StartPosition = form.StartPosition.Manual
		form.bounds = mcDotnet.dRect pos size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = mcDotnet.uiColor #fore
		form.opacity = 1 ---mcUIColors.get #opacity
		--form.TopMost = true --keep fotm upper from all toolbars
		
		--toolbar
		lblT.bounds = mcDotnet.dRect [border_offset, border_offset] [size.x - border_offset*10 , bar_height]
		lblT.BackColor = mcDotnet.uiColor #back
		lblT.ForeColor = mcDotnet.uiColor #text
		lblT.textAlign = lblMsg.textAlign.MiddleCenter
		lblT.Text = "Dialog Template v" + (mcFile.getScriptVersion "Dialog_Template") --update script title with version
		
		--min max button
		btnMin.FlatStyle = btnMin.FlatStyle.flat
		btnMin.BackColor = mcDotnet.uiColor #btn
		btnMin.ForeColor = mcDotnet.uiColor #text
		btnMin.text = "-"
		btnMin.Size = mcDotnet.dSize [btn_size, bar_height]

		--Componnts Layout
		tlp.Bounds  = mcDotnet.dRect [border_offset, bar_height + border_offset * 2] [size.x - 20, size.y - 58]
		tlp.backColor = mcDotnet.uiColor #btn
		tlp.AutoSize = true
				
		--Custom Components
		--lblMsg.Anchor = dotnet.combineEnums mcDotnet.AnchorStyles.Left mcDotnet.AnchorStyles.Right
		lblMsg.TabIndex = 0
		lblMsg.textAlign = lblMsg.textAlign.MiddleCenter
		lblMsg.Size = mcDotnet.dSize [10, 10]
		lblMsg.Location = mcDotnet.dPoint [border_offset, bar_height + border_offset * 2]
		lblMsg.MaximumSize = mcDotnet.dSize [400, 500]	--WordWrap, MultiLine 
		lblMsg.AutoSize = true
		lblMsg.foreColor = mcDotnet.dColor white
		lblMsg.font = mcDotnet.dFont font:"Arial" size:12 style:"Regular"
		lblMsg.Text = "..."
		-->
		
		-- Default Events
		dotnet.addEventHandler form "Shown" onFormCreated
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override form backcolor (without this form color is default)
		dotNet.addEventHandler btnMin "MouseClick" minMaxForm
		dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
		dotNet.addEventHandler tlp  "Resize" onLblMsgTextChanged
		-- dotNet.addEventHandler lblMsg  "TextChanged" onLblMsgTextChanged
	
		--Custom Events
		-->
		
		--Add Controls
		tlp.Controls.Add(lblMsg)
		form.controls.addRange ( #(tlp, btnMin, lblT)  )
		OK
	),
	initialized = init()  --strange think but works
)
::mcTemplateDialog = DOTNET_MAIN_STRUCT title:"mcTemplateDialog"
::mcTemplateDialog.open()
::mcTemplateDialog.addText "In this post we shall learn how to write a simple socket server in python. This has already been covered in the previous tutorial. In this post we shall learn few more things about programming server sockets like handling multiple connections with the select method."

/*
::mcTemplateDialog.addText "Text contents"
::mcTemplateDialog.addText "But this also aligns the label control to the centre"
::mcTemplateDialog.addText "DotNet controls cannot only be placed inside 3ds Max Dialogs and Rollouts, but they can also be used to generate user interfaces implemented completely using DotNet Forms."
*/



/*
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
