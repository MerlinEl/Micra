(
	try (form.close()) catch()
	
	--DotNet Components
	fn netDrSize size  = (dotNetObject "Drawing.Size" size.x size.y)
	fn netDrPoint pos  = (dotnetObject "Drawing.Point" pos.x pos.y)
	fn netDrColor clr     = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b)
	local netCursors   = (dotNetClass "Cursors")
	
	--Local Variables
	local trackbar_width = 45
	local form_bounds = 8
	local rows_columns = [6,2]
	local btn_size = 48
	local form_size = ([btn_size, btn_size] * rows_columns)+trackbar_width + form_bounds
	
	--Interface Elements
	form = dotnetobject"System.Windows.Forms.form"
	spiH = dotnetobject"System.Windows.Forms.Trackbar"
	spiV = dotnetobject"System.Windows.Forms.Trackbar"
	tlp  = dotNetObject "TableLayoutPanel"
	btn  = dotNetObject "button"

	--Interface Setup
	form.ControlBox  = false --hide main bar
	form.size = netDrSize form_size
	form.StartPosition = form.StartPosition.Manual
	form.Location = netDrPoint [ 200, 100 ]
	
	tlp.size = netDrSize (form_size - trackbar_width - form_bounds)
	tlp.backColor = netDrColor( green )
	
	
	spiH.TickStyle = spiH.TickStyle.BottomRight
	spiH.SetBounds 0 tlp.height 100 4--tlp.width 4 --pos size
	spiH.SetRange 0 10
	--spiH.size = netDrSize [tlp.width, 4]
	--spiH.Location = netDrPoint [0, tlp.height]
	--spiH.TickFrequency = 1
	--spiH.value = 0
	
	spiV.Orientation = spiV.Orientation.vertical
	spiV.TickStyle = spiV.TickStyle.TopLeft
	spiV.SetBounds tlp.width -4 4 100--tlp.height --pos size
	spiV.SetRange 0 10
	--spiV.size = netDrSize [4, tlp.height]
	--spiV.Location = netDrPoint [tlp.width, 0]
	--spiV.TickFrequency = 1
	--spiV.value = 0
	
	
	btn.size = netDrSize [trackbar_width, trackbar_width]
	btn.location = netDrPoint [tlp.width,tlp.height]
	btn.text = "Close"
	--Functions
	fn onBtnMouseUp = form.close()
	
	--Event Handlers
	dotNet.addEventHandler btn "MouseUp" onBtnMouseUp
	
	form.controls.add(tlp)
	form.controls.add(spiH)
	form.controls.add(spiV)
	form.controls.add(btn)
	form.show()
)