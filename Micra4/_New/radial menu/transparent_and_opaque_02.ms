global testRoll
try( testRoll.close(); testRoll.dispose() )catch()
(
 	fn OnFormPaint s a = (
		
		fillColor = (dotnetclass "System.Drawing.Color").fromARGB 50 100 150 200
		fillBrush = dotnetobject "System.Drawing.SolidBrush" fillColor
 		a.graphics.FillRectangle fillBrush (dotnetobject "System.Drawing.Rectangle" 50 50 100 100)
 	)
 	testRoll = dotnetobject "System.Windows.Forms.Form"
	testRoll.StartPosition = testRoll.StartPosition.Manual
 	testRoll.width = 200
 	testRoll.height = 200
	testRoll.TopMost = true
	testRoll.Location = dotnetObject "Drawing.Point" 200 300
-- 	testRoll.opacity = 0.5
-- 	showProperties testRoll
	formBackColor=(dotNetClass "system.drawing.color").fromArgb 0 255 0
 	testRoll.backColor=formBackColor
 	testRoll.TransparencyKey=formBackColor
 	
 	dotnet.addEventHandler testRoll "Paint" OnFormPaint
)	
testRoll.Show()