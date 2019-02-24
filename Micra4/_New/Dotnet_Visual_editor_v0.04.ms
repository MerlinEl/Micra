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
		tlp1 = dotNetObject "TableLayoutPanel",
		tlp2 = dotNetObject "TableLayoutPanel",
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
		--Move / Snap Dialog /
		fn onLblTMouseMove s a = (  --drag form
				
			local form = s.parent
			local mcs = form.tag.value
			if a.Button == a.Button.left do  (
				
				local clientPosition = s.parent.PointToClient mcs.cursor.Position
				clientPosition.x -= mcs.cursor_offset.x --adjust position X
				clientPosition.y -= mcs.cursor_offset.y --adjust position Y
				clientPosition.x = mcMath.roundToInt clientPosition.x 10 --round snap pos x 10 == grid size
				clientPosition.y = mcMath.roundToInt clientPosition.y 10 --round snap pos y
				s.location = clientPosition
				mcDotnetVisualEditorDialog.form .Update()
			)
		),
		fn onLblTMouseDown s a = ( --start drag
			
			local form = s.parent
			local mcs = form.tag.value
			if a.Button == a.Button.left do ( --enable drag

				mcs.cursor_offset = a.location --Save the location of the mouse pointer relative to the top-left corner of our control
				mcs.form.cursor = mcDotnet.Cursors.Hand	--change mouse icon to hand
			)
		),
		fn onLblTMouseUp s a = ( --stop drag
			
			local form = s.parent
			local mcs = form.tag.value
			mcs.form.cursor = mcDotnet.Cursors.Arrow--change mouse icon to arrow
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
			tlp1.Bounds  = mcDotnet.dRect [50, 100] [200, 100]
			tlp1.backColor = mcDotnet.uiColor #btn
		
			tlp2.Bounds  = mcDotnet.dRect [300, 100] [100, 50]
			tlp2.backColor = mcDotnet.uiColor #btn
			
			--Register Events
			dotnet.addEventHandler form "Shown" onFormCreated
			dotnet.addEventHandler form "Closed" onCloseForm
			dotnet.AddEventHandler form "BackColorChanged" changeBackcolor --override form backcolor (without this form color is default)
			
			dotNet.addEventHandler tlp1   "MouseMove" onLblTMouseMove
			dotNet.addEventHandler tlp1   "MouseDown" onLblTMouseDown 
			dotNet.addEventHandler tlp1   "MouseUp" onLblTMouseUp

			dotNet.addEventHandler tlp2   "MouseMove" onLblTMouseMove
			dotNet.addEventHandler tlp2   "MouseDown" onLblTMouseDown 
			dotNet.addEventHandler tlp2   "MouseUp" onLblTMouseUp

			--Add Controls
			form.controls.addRange ( #(tlp1, tlp2)  )
			this --return structure with variables and functions
		)
	)
	local mcs = DOTNET_MAIN_STRUCTURE title:"mcDotnetVisualEditorDialog"
	mcs.form.tag =  dotNetMXSValue mcs ----store structure instance inside form
	::mcDotnetVisualEditorDialog = mcs.init() --initialize form and assign structure with functions to global name
	::mcDotnetVisualEditorDialog.open()
)

/*
Label lab = new Label();

.Anchor : <System.Windows.Forms.AnchorStyles>

float width = 1024;
float height = 768;
var brush = new SolidBrush(Color.Black);
var image = new Bitmap(file);
float scale = Math.Min(width / image.Width, height / image.Height);
var bmp = new Bitmap((int)width, (int)height);
var graph = Graphics.FromImage(bmp);

// uncomment for higher quality output
//graph.InterpolationMode = InterpolationMode.High;
//graph.CompositingQuality = CompositingQuality.HighQuality;
//graph.SmoothingMode = SmoothingMode.AntiAlias;

var scaleWidth = (int)(image.Width * scale);
var scaleHeight = (int)(image.Height * scale);

graph.FillRectangle(brush, new RectangleF(0, 0, width, height));
graph.DrawImage(image, ((int)width - scaleWidth)/2, ((int)height - scaleHeight)/2, scaleWidth, scaleHeight);

*/