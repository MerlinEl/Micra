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
struct DOTNET_MAIN_STRUCT  (
	
public	
	title,
	--define interface components
	form = dotNetObject "MaxCustomControls.MaxForm",
	lblT = dotNetObject "label",
	btnMin = dotNetObject "button",
	tlp = dotNetObject "TableLayoutPanel",
	--private variables
	pos					= [0, 0],
	size					= [320, 220],
	start_mouse_pos, --mouse pos on dialog
	minimized		= false, 
	old_height, 
	bar_height		= 14,
	border_offset	= 2,
	btn_size			= 24,
	debug				= 0,
public
	--Open / Close (with default setup, save position to INI)
	fn open = (if iskindof form dotnetobject do mcDotnet.dShow form),
	fn close = (if iskindof form dotnetobject do form.Close()),
	fn getName = ( title ),
	fn getPos = ( [form.location.x, form.location.y] ),
	fn getSize = ( [form.width, form.height] ),
private
	--Move / Snap Dialog /
	fn onLblTMouseMove s a = (  --drag form
	
		local _mcs = mcTemplateDialog --struct instance
		if a.Button == a.Button.left do  mcDialog.snapForm _mcs.form _mcs.start_mouse_pos
	),
	fn onLblTMouseDown s a = ( --start drag
			
		local _mcs = mcTemplateDialog --struct instance
		_mcs.form.cursor.current = netCursors.Hand
		if a.Button == a.Button.left do ( --enable drag
			_mcs.start_mouse_pos = [_mcs.form.MousePosition.x, _mcs.form.MousePosition.y] - [_mcs.form.left, _mcs.form.top]  
		)
	),
	fn onLblTMouseUp s a = (
		
		if a.Button == a.Button.right then mcTemplateDialog.close()
	), --stop drag or close
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
		mcFile.saveIniDialog s.name "Properties_2"
	),
	-- Custom  Functions
	-->
	
	-- main function
	fn init  =  (
		
		--setup interface
		local from_data = mcFile.loadIniDialog title "Properties_2" --get saved pos and size
		if from_data != undefined do (
			
			pos = from_data.pos
			--size = from_data.size (when loaded every time is les and less....????)
		)
		--format " load form:%  pos:% size:%\n" title pos size
		
		form.name = form.text = title
		form.ControlBox  = false --hide main bar
		form.ShowInTaskbar = false
		form.StartPosition = form.StartPosition.Manual
		form.bounds = mcDotnet.dRect pos size
		form.FormBorderStyle = form.FormBorderStyle.none
		form.BackColor = mcDotnet.uiColor #fore
		form.opacity = 1 ---mcUIColors.get #opacity
		
		--toolbar
		lblT.bounds = mcDotnet.dRect [border_offset, border_offset] [size.x - border_offset*10 , bar_height]
		lblT.BackColor = mcDotnet.uiColor #back
		lblT.ForeColor = mcDotnet.uiColor #text
		lblT.Text = "Dialog Template v" + (Micra.getScriptVersion "Dialog_Template") --update script title with version
		
		--min max button
		btnMin.FlatStyle = btnMin.FlatStyle.flat
		btnMin.BackColor = mcDotnet.uiColor #btn
		btnMin.ForeColor = mcDotnet.uiColor #text
		btnMin.text = "-"
		btnMin.Bounds = mcDotnet.dRect [size.x - (btnMin.width /2) - (border_offset*2) - 1 , border_offset] [btn_size, bar_height]
		
		--Componnts Layout
		tlp.Bounds  = mcDotnet.dRect [border_offset, bar_height + border_offset * 2] [size.x - 20, size.y - 58]
		tlp.backColor = mcDotnet.uiColor #btn
		
		--Custom Components
		-->
		
		-- Default Events
		dotnet.addEventHandler form "Shown" onFormCreated
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override form backcolor (without this form color is default)
		dotNet.addEventHandler btnMin "MouseClick" minMaxForm
		dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
	
		--Custom Events
		-->
		
		--Add Controls
		form.controls.addRange ( #(tlp, btnMin, lblT)  )
		OK
	),
	initialized = init()  --strange think but works
)
::mcTemplateDialog = DOTNET_MAIN_STRUCT title:"mcTemplateDialog"
::mcTemplateDialog.open()