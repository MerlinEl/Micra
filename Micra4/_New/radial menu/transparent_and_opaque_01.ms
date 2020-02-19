fn paintLabel sender arg=
(
	g=arg.graphics
	c=(dotNetClass "system.drawing.color").fromArgb 150 0 0 0
	b=dotNetObject "system.drawing.solidBrush" c
	rec=dotNetObject "system.drawing.rectangle" 10 10 50 50
	g.FillRectangle b rec
)
fn onFormPaint s a = (s.backColor = (dotNetClass "Drawing.Color").fromArgb 0 50 50)

fo=dotNetObject "form"
fo.AllowTransparency = true
fo.TransparencyKey =  (dotNetClass "Drawing.Color").fromArgb 0 50 50

lb02=dotNetObject "label"
lb02.backColor=(dotNetClass "system.drawing.color").fromArgb 255 0 0 0
lb02.backColor=lb02.backColor.transparent
lb02.bounds=(dotNetObject "system.drawing.rectangle" 50 50 100 100)
dotNet.addEventHandler lb02 "Paint" paintLabel
dotNet.addEventHandler fo "Paint" onFormPaint	
lb01=dotNetObject "label"
lb01.backColor=(dotNetClass "system.drawing.color").fromArgb 255 255 0 0
lb01.bounds=(dotNetObject "system.drawing.rectangle" 0 0 100 100)

-- lb01.parent = fo

-- Add the controls and set the parent after adding them. 
fo.controls.add lb02
fo.controls.add lb01
lb02.parent=lb01

fo.show()