Global testRoll
try( testRoll.close(); testRoll.dispose() )catch()
(
 	fn formResized ctrl arg =
	(
		print "resized"
		print ctrl
		print arg
	)
	fn stop ctrl arg =
	(
		format "controll:%\targ:%\n" ctrl arg
		testRoll.Location =dotNetObject "System.Drawing.Point" 200 300
	)
	fn rec ctrl arg =
	(
		format "controll:%\targ:%\n" ctrl arg
		testRoll.Location =dotNetObject "System.Drawing.Point" 200 300
		mc2system.show ctrl
	)
	fn moved ctrl arg =
	(
		format "controll:%\targ:%\n" ctrl arg
		testRoll.Location =dotNetObject "System.Drawing.Point" 200 300
	)
	fn dragForm ctrl arg = 
	(
		format "controll:%\targ:%\n" ctrl arg
	)
	local color_class = (dotnetclass "System.Drawing.Color")
 	testRoll = dotnetobject "System.Windows.Forms.Form"
 	testRoll.width = 200
 	testRoll.height = 200
	testRoll.TopMost = true
  	testRoll.ShowInTaskbar  = false
	testRoll.ControlBox  = false
	testRoll.backColor= color_class.fromArgb 0 255 0 --form Back Color
 	testRoll.TransparencyKey= color_class.fromArgb 0 255 0 --form Back Color
	testRoll.opacity = 0.5
	testRoll.Location = dotNetObject "System.Drawing.Point" 200 300 -- form pos
	--testRoll.FormBorderStyle=testRoll.FormBorderStyle.Sizable --(#Fixed3D, #FixedDialog, #FixedSingle, #FixedToolWindow, #none, #Sizable, #SizableToolWindow, #value__)


	--testRoll.foreColor=formBackColor
	--.Margin : <System.Windows.Forms.Padding>
 	--showProperties testRoll
	--mc2system.show testRoll
	
	local lab = dotnetobject "System.Windows.Forms.Label"
	lab.width = 200
	lab.height = 24
	lab.text = "test text"
	lab.TextAlign = lab.TextAlign.MiddleCenter
	lab.backColor = color_class.fromARGB 128 200 200
	
	local rec_button = dotnetobject "button"
	rec_button.text="R"
	rec_button.width = 24
	rec_button.height = 24
	rec_button.location = dotNetObject "System.Drawing.Point" 1 1
	rec_button.backcolor=color_class.fromARGB 127 127 127
	
	local stop_button = dotnetobject "button"
	stop_button.text="S"
	stop_button.width = 24
	stop_button.height = 24
	--stop_button.Padding = 4
	stop_button.location = dotNetObject "System.Drawing.Point" 24 1
	stop_button.backcolor=color_class.fromARGB 127 127 127
	
	--.Location
	  --.Image : <System.Drawing.Image>
	 -- .Dock : <System.Windows.Forms.DockStyle>
	
	
	--on <control_name> DragDrop <System.Windows.Forms.DragEventArgs>e do ( ... )
  -- on <control_name> DragEnter <System.Windows.Forms.DragEventArgs>e do ( ... )
   --on <control_name> DragLeave <System.EventArgs>e do ( ... )
   --on <control_name> DragOver <System.Windows.Forms.DragEventArgs>e do ( ... )
	
	
	--mc2system.show stop_button
	
	dotNet.addEventHandler rec_button "DragEnter" dragForm
	
	dotNet.addEventHandler stop_button "MouseUp" stop
	dotNet.addEventHandler rec_button "MouseUp" rec
	dotNet.addEventHandler testRoll "SizeChanged" moved
	--dotNet.addEventHandler lab "click" formResized
	--testRoll.controls.add(lab)
	testRoll.controls.add(rec_button)
	testRoll.controls.add(stop_button)
)	
testRoll.Show()


/*
--on testRoll Closed arg do ( print "closed" )
	
	--on lab MouseClick arg do ( print arg )
	--on testRoll Click pos do ( print click )
	
on <control_name> ClientSizeChanged <System.EventArgs>e do ( ... )
	  on <control_name> KeyDown <System.Windows.Forms.KeyEventArgs>e do ( ... )
  on <control_name> KeyPress <System.Windows.Forms.KeyPressEventArgs>e do ( ... )
   on <control_name> KeyUp <System.Windows.Forms.KeyEventArgs>e do ( ... )
	   on <control_name> MaximizedBoundsChanged <System.EventArgs>e do ( ... )
   on <control_name> MaximumSizeChanged <System.EventArgs>e do ( ... )
 on <control_name> MinimumSizeChanged <System.EventArgs>e do ( ... )
 on <control_name> MouseClick <System.Windows.Forms.MouseEventArgs>e do ( ... )
 on <control_name> MouseDown <System.Windows.Forms.MouseEventArgs>e do ( ... )
    on <control_name> MouseMove <System.Windows.Forms.MouseEventArgs>e do ( ... )
   on <control_name> MouseUp <System.Windows.Forms.MouseEventArgs>e do ( ... )
   on <control_name> MouseWheel <System.Windows.Forms.MouseEventArgs>e do ( ... )
   on <control_name> Move <System.EventArgs>e do ( ... )
    on <control_name> SizeChanged <System.EventArgs>e do ( ... )
*/

/*
System.Windows.Forms.KeyEventArgs has property "Shift"... just check it:

if arg.Shift and (arg.keyCode == arg.keyCode.Enter) ...
or 
case arg.keyCode of
(
(arg.keyCode.Enter) : if arg.Shift do ...
)
*/




/*
theDialog = dotNetObject  "System.Windows.Forms.OpenFileDialog"  --create a OpenFileDialog
theDialog.title = "PLEASE Select One Or More Files" --set the title
theDialog.Multiselect = true --allow multiple files to be selected
theDialog.Filter = "HTML Files (*.html)|*.html|All Files (*.*)|*.*" --specify the filter
theDialog.FilterIndex = 2 --set the filter drop-down list to All Files
result = theDialog.showDialog() --display the dialog, get result into variable
result.ToString() --when closed, convert the result to string
result.Equals result.OK --returns TRUE if OK was pressed, FALSE otherwise
result.Equals result.Cancel --returns TRUE if Cancel was pressed, FALSE otherwise
theFilenames = theDialog.fileNames --the selected filenames will be returned as an array
*/


/*
global testRoll
try( testRoll.close(); testRoll.dispose() )catch()
(
 	fillColor = (dotnetclass "System.Drawing.Color").fromARGB 50 100 150 200
 	fillBrush = dotnetobject "System.Drawing.SolidBrush" fillColor
 	formBackColor=(dotNetClass "system.drawing.color").fromArgb 0 255 0
 	
 	fn OnFormPaint sender arg =
 	(
 		arg.graphics.FillRectangle fillBrush (dotnetobject "System.Drawing.Rectangle" 50 50 100 100)
 	)
 	
 	testRoll = dotnetobject "System.Windows.Forms.Form"
 	testRoll.width = 200
 	testRoll.height = 200
	testRoll.TopMost = true
 -- 	testRoll.opacity = 0.5
 	showProperties testRoll
 	testRoll.backColor=formBackColor
 	testRoll.TransparencyKey=formBackColor
 	
  	
 	dotnet.addEventHandler testRoll "Paint" OnFormPaint
)	
testRoll.Show()
*/