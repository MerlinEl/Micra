try(destroyDialog testR)catch()
rollout testR "Test"
(
	local col=dotNetClass "system.drawing.color"
	local bgm=dotNetObject "system.drawing.bitMap" ((getDir #UI)+"\\\Icons\penProductions\\joyStick80Sq.bmp")
	local targetBm=dotNetObject "system.drawing.bitMap" ((getDir #UI)+"\\\Icons\penProductions\\target.bmp")
	local targRad=targetBm.width/2
	local rec=dotNetObject "System.Drawing.Rectangle" 10 10 20 20
	
	dotNetControl picBox "system.windows.forms.pictureBox" width:81 height:81
	
	fn drawTarget control paintArg bg target=
	(
		if rec.x<-targRad then rec.x= -targRad
		if rec.x>bg.width-targRad then rec.x=bg.width-targRad
		if rec.y<-targRad then rec.y=-targRad
		if rec.y>bg.height-targRad then rec.y=bg.height-targRad
		
		graphics=paintArg.graphics
		paintArg.dispose()
		Graphics.DrawImage target rec
	)
	
	on picBox mouseMove arg do
	(
		if arg.button==arg.button.left then
		(
			rec.x=arg.x-targRad
			rec.y=arg.y-targRad
			picBox.Invalidate()
		)
	)
	on picBox mouseUp arg do
	(
	)
	
	on picBox paint senderArg paintArg do
	(
		drawTarget senderArg paintArg bgm targetBm
	)
	
	on testR open do
	(
		targetBm.makeTransparent()
		picBox.backGroundImage=copy bgm
		rec.x=bgm.width/2-targRad
		rec.y=bgm.height/2-targRad

	)
	on testR close do
	(
		bgm.dispose()
		targetBm.dispose()
	)
)
createDialog testR
clearListener()