Global mcDotnetVisualEditorDialog 
/**
*@Created by MerlinEl 2019
*@Inspired by biddle
*@Example
	mcDotnetVisualEditorDialog.open()
	mcDotnetVisualEditorDialog.close()
	mcDotnetVisualEditorDialog.moveTo [100, 200]
	atd...
*/
( --local definition space
	
	----------------------------------------------------------------------------------
	--		STRUCTURE DEFINITIONS AND FUNCTIONS		--
	----------------------------------------------------------------------------------
	struct DOTNET_MAIN_STRUCTURE  (
		
	public	
		title,
		form = dotNetObject "MaxCustomControls.Maxform",
		tlp = dotNetObject "TableLayoutPanel",
		cursor = dotnetclass "System.Windows.Forms.Cursor",
		pos					= [100, 200],
		size					= [600, 400],
		cursor_offset, --mouse pos on dialog
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
	--private
		fn changeBackcolor s a = (s.backColor = mcDotnet.dColor (mcUIColors.get #fore)), --override form backcolor
		fn onFormCreated s a = (
			
			format "onFormCreated > state:%\n" (s.WindowState.toString())
		),
		fn onCloseForm s a = (
			
			--format " save form:%  pos:% size:%\n" s.name (s.location.toString()) (s.size.toString())
			mcFile.saveDialogSettings s.name "Properties_2"
		),
		----------------------------------------------------------------------------------
		--								MAIN FUNCTIONS						--
		----------------------------------------------------------------------------------
		fn init  =  (
			
			form.name = form.text = title
			form.StartPosition = form.StartPosition.Manual
			form.bounds = mcDotnet.dRect pos size
			form.BackColor = mcDotnet.uiColor #fore
			form.opacity = 1
			form.TopMost = true --keep fotm upper from all toolbars
			
			--Componnts Layout
			tlp.Bounds  = mcDotnet.dRect [100, 200] [200, 100]
			tlp.backColor = mcDotnet.uiColor #btn
		
			--Move / Snap Dialog /
			fn onLblTMouseMove s a = (  --drag form
				
				local form = s.parent
				local mcs = form.tag.value
				if a.Button == a.Button.left do  (
					
					local clientPosition = s.parent.PointToClient mcs.cursor.Position
					clientPosition.x -= mcs.cursor_offset.x --adjust position X
					clientPosition.y -= mcs.cursor_offset.y --adjust position Y
					clientPosition.x = mcMath.roundToInt clientPosition.x 10 --round snap pos x
					clientPosition.y = mcMath.roundToInt clientPosition.y 10 --round snap pos y
					s.location = clientPosition
					mcDotnetVisualEditorDialog.form .Update()
				)
			)
			fn onLblTMouseDown s a = ( --start drag
				
				local form = s.parent
				local mcs = form.tag.value
				if a.Button == a.Button.left do ( --enable drag

					mcs.cursor_offset = a.location --Save the location of the mouse pointer relative to the top-left corner of our control
					mcs.form.cursor = mcDotnet.Cursors.Hand	--change mouse icon to hand
				)
			)
			fn onLblTMouseUp s a = ( --stop drag
				
				local form = s.parent
				local mcs = form.tag.value
				mcs.form.cursor = mcDotnet.Cursors.Arrow--change mouse icon to arrow
			)
			
			--Register Events
			dotnet.addEventHandler form "Shown" onFormCreated
			dotnet.addEventHandler form "Closed" onCloseForm
			dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override form backcolor (without this form color is default)
			dotNet.addEventHandler tlp   "MouseMove" onLblTMouseMove
			dotNet.addEventHandler tlp   "MouseDown" onLblTMouseDown 
			dotNet.addEventHandler tlp   "MouseUp" onLblTMouseUp

			--Add Controls
			form.controls.addRange ( #(tlp)  )
			this --return structure with variables and functions
		)
	)
	local mcs = DOTNET_MAIN_STRUCTURE title:"mcDotnetVisualEditorDialog"
	mcs.form.tag =  dotNetMXSValue mcs ----store structure instance inside form
	::mcDotnetVisualEditorDialog = mcs.init() --initialize form and assign structure with functions to global name
	::mcDotnetVisualEditorDialog.open()
)
