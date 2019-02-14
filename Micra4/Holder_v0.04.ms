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
	btnThumb = dotNetObject "button",
	--private variables
	picture_size    = 128,
	bar_height		= 14,
	border_offset	= 2,
	pos					= [0, 0],
	size					= [picture_size + border_offset * 2, picture_size + bar_height + border_offset * 2],
	start_mouse_pos, --mouse pos on dialog
	minimized		= false, 
	old_height, 
	btn_size			= 24,
	debug				= 0,
	objects_names = #(),
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
		mcFile.saveDialogSettings s.name "Properties_2"
	),
	-- Custom  Functions
	fn grabImage = (
	
		local img = gw.getViewportDib() 
		local new_img = bitmap picture_size picture_size
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
		copy img new_img
		setclipboardBitmap new_img
		if clipboardClass.containsimage() 
		then clipboardClass.getImage() 
		else dotNetObject "System.Drawing.Bitmap" picture_size picture_size
	),
	/*fn getThumbnail = (
		--store selection
		local vis_obj   = for o in selection where not o.isHidden collect o
		local sel_obj   = #(), unsel_obj = #(), frez_obj  = #()
		for o in vis_obj do (
		
			if o.isFrozen   then frez_obj += #(o)
			else if o.isSelected then sel_obj  += #(o) 
			else unsel_obj += #(o)
		)
		max unfreeze all
		--collect non xray objects and make them transparent
		local xray_objs = #()
		for i in (unsel_obj + frez_obj) where not i.xray do
		(
			i.xray = true
			xray_objs += #(i)
		)
		-----------------------
		redrawviews()
		local img = grabImage()
		-----------------------
		--restore selection and xray and frozen objects
		if xray_objs.count != 0 do for i in xray_objs do i.xray = false
		select frez_obj
		max freeze selection
		select sel_obj
		return img
	),*/
	fn holdSelection s sel = (valid_nodes = for o in selection collect o.name),
	fn fetchSelection s a = (
	
		local valid_nodes = #()
		for n in objects_names do(

			local obj = getNodeByName n
			if obj != undefined do valid_nodes += #(obj)
		)
		select valid_nodes
		max zoomext sel
	),
	fn zoomSelection s a = (
		print "double"
	),
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
		lblT.Text = "Dialog Template v" + (mcFile.getScriptVersion "Dialog_Template") --update script title with version
		
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
		btnThumb.bounds = mcDotnet.dRect [border_offset, border_offset + bar_height] [picture_size, picture_size]
		btnThumb.image = grabImage()
		
		-- Default Events
		dotnet.addEventHandler form "Shown" onFormCreated
		dotnet.addEventHandler form "Closed" onCloseForm
		dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override form backcolor (without this form color is default)
		dotNet.addEventHandler btnMin "MouseClick" minMaxForm
		dotNet.addEventHandler lblT   "MouseMove" onLblTMouseMove
		dotNet.addEventHandler lblT   "MouseDown" onLblTMouseDown 
		dotNet.addEventHandler lblT   "MouseUp" onLblTMouseUp
	
		--Custom Events
		dotnet.addEventHandler btnThumb "MouseUp" fetchSelection
		
		--Add Controls
		form.controls.addRange ( #(btnThumb, tlp, btnMin, lblT)  )
		OK
	),
	initialized = init()  --strange think but works
)
::mcTemplateDialog = DOTNET_MAIN_STRUCT title:"mcTemplateDialog"
::mcTemplateDialog.open()
