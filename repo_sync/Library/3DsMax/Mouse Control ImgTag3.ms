try (destroyDialog joyStick) catch ()
 
 rollout joyStick "JoyStick"
 (
 -- Local Variable Declerations
 ------------------------------------------
 
 	local upColor = black
 	local downColor = yellow
 	local dim = 200
 	local joyDim = 10
 	local activateJS = false
 	local joyBitmap = bitmap joyDim joyDim color:upColor
 	local joyBitmapMask = bitmap joyDim joyDim color:black
 	local mouseLBState = false
 	local mouseOffset = [0,0]
 	local spinnerSize = 60
 	local joyStickPos = [dim / 2,dim / 2]
 	local signState = false
 
 -- User Interface
 ------------------------------------------
 
 	-- Build the static Cross
 	groupBox gb1 "" pos:[0, - 6] width:(dim/2) height:(dim/2 + 6)
 	groupBox gb2 "" pos:[(dim/2), - 6] width:(dim/2) height:(dim/2 + 6)
 	groupBox gb3 "" pos:[0,(dim/2) - 6] width:(dim/2) height:(dim/2 + 6)
 	groupBox gb4 "" pos:[(dim/2),(dim/2) - 6] width:(dim/2) height:(dim/2 + 6)
 	
 	-- Adds the Values to the Cross
 	label lbA "1" pos:[dim / 2 - 9,2]
 	label lbB "-1" pos:[dim / 2 - 12,dim - 15]
 	label lbC "-1" pos:[2,dim / 2 - 16]
 	label lbD "1" pos:[dim - 10,dim / 2 - 16]
 	label lbSignature "" pos:[5,5]
 
 	
 	-- Build the dynamic Cross
 	groupBox gbVer "" pos:[0,(dim - joyDim)/ 2] width:(dim * 3) height:(dim * 3)
 	groupBox gbHor "" pos:[dim / 2 ,-10] width:(dim * 3) height:(dim * 3)
 	
 	-- X and Y spinners
 	spinner spX "X:" pos:[10,dim + 4] width:spinnerSize scale:0.001 range:[-1,1,0]
 	spinner spY "Y:" pos:[dim - spinnerSize - 5,dim + 4] width:spinnerSize scale:0.001 range:[-1,1,0]
 	
 	-- The JoyStick
 	checkButton cbJoy "" width:joyDim height:joyDim pos:[(dim - joyDim)/2,(dim - joyDim)/2] 
 		images:#(joyBitmap,joyBitmapMask,1,1,2,1,1) highlightColor:downColor
 	
 -- Functions
 ------------------------------------------
 	
 	fn posToVal posX posY =
 	(
 		[2 * posX / dim - 1 , 1 - 2 * posY / dim]
 	)
 	
 	fn ValToPos valX valY = 
 	(
 		[dim * (valX + 1) / 2 , (1 - valY) * dim / 2]
 	)
 	
 	fn controlTarget pos =
 	(
 		if selection.count == 1 do (
 			$.pos.x = pos.x * 100
 			$.pos.y = pos.y * 100
 		)
 	)
 	
 	fn updateJS mPos =
 	(
 		if mPos.y > dim do mPos.y = dim
 		if activateJS then (
 			joyStickPos = mPos
 			gbVer.pos.y = mPos.y - joyDim/2
 			gbHor.pos.x = mPos.x
 			local newPos = posToVal mPos.x mPos.y
 			spX.value = newPos.x
 			spY.value = newPos.y
 			spX.pos *= 1
 			spY.pos *= 1
 			cbJoy.pos = joyStickPos - [joyDim/2,joyDim/2]
 			controlTarget newPos
 		) else (
 			if mouseLBState then SetDialogPos joyStick (mouse.screenPos - mouseOffset)
 		)
 	)
 	
 	fn updateSpinner axis valX valY =
 	(
 		if axis < 3 do joyStickPos.x = (ValToPos valX valY).x
 		if axis > 1 do joyStickPos.y = (ValToPos valX valY).y
 		gbVer.pos.y = joyStickPos.y - joyDim/2
 		gbHor.pos.x = joyStickPos.x
 		spX.pos.y = spY.pos.y = dim + 4
 		spY.pos.x = dim - 18
 		cbJoy.pos = joyStickPos - [joyDim/2,joyDim/2]
 		controlTarget (posToVal joyStickPos.x joyStickPos.y)
 	)
 	
 	fn reSizeDialog pos =
 	(
 		dim = (pos.x + pos.y - 24) / 2
 		joyStick.width = dim
 		joyStick.height = dim + 24
 		
 		gb1.width = gb2.width = gb3.width = gb4.width = dim/2
 		gb1.height = gb2.height = gb3.height = gb4.height = dim/2 + 6
 		gb2.pos = [(dim/2), - 6]
 		gb3.pos = [0,(dim/2) - 6]
 		gb4.pos = [(dim/2),(dim/2) - 6]
 		
 		lbA.pos = [dim / 2 - 9,2]
 		lbB.pos = [dim / 2 - 12,dim - 15]
 		lbC.pos = [2,dim / 2 - 16]
 		lbD.pos = [dim - 10,dim / 2 - 16]
 		
 		gbVer.width = gbVer.height = gbHor.width = gbHor.height = (dim * 3)
 		
 		updateSpinner 2 spX.value spY.value
 	)
 	
 	fn signature state =
 	(
 		if keyboard.altPressed and keyboard.controlPressed do signState = not signState
 		lbSignature.caption = if signState then "Matan Halberstadt" else ""
 		lbSignature.pos = [5,5]
 	)
 	
 	fn openDialog =
 	(
 		createDialog joyStick width:dim height:(dim + 24) style:#(#style_sunkenedge, #style_resizing) 
 		SetDialogPos joyStick (mouse.screenPos - [dim/2,dim/2])
 	)
 	
 	fn init =
 	(
 		
 	)
 
 	fn done =
 	(
 		gc light:true
 	)
 
 -- Event Handlers
 ------------------------------------------
 
 	on cbJoy changed state do (
 		activateJS = state
 		signature state
 	)
 	on joyStick mouseMove pos do updateJS pos
 	on joyStick rbuttonup pos do destroyDialog joyStick
 	on joyStick lbuttondown pos do (
 		mouseLBState = true
 		mouseOffset = pos
 	)
 	on joyStick lbuttonup pos do mouseLBState = false
 	on spX changed val do updateSpinner 1 val 0
 	on spY changed val do updateSpinner 3 0 val
 	on joyStick resized pos do reSizeDialog pos
 	on joyStick open do init()
 	on joyStick close do done()
 
 ) -- end of rollout
 
 joyStick.openDialog()