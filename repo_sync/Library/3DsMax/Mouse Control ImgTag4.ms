rollout testImgTag "Test Img Tag" width:220
(
	local curBoxControl=undefined
	local curSliderControlX=undefined
	local curSliderControlY=undefined
	local boxControlItVal=[0,0]
	
	local crossCol=(color 255 0 0)
	local circleCol=(color 0 0 100)
	local bgCol=(color 100 100 100) 
	local gridCol=(color 120 120 120) 
	local gridSpace=25
	
	imgTag boxControlIt "MouseTracker" \
		height:100 width:100 bitMap:undefined
	
	timer mouseTime interval:1
	
	
	fn boxControl control:undefined width:0 height:0 pos:[0,0]=
	(
		if control!=undefined then
		(
			
			local bm=bitmap width height color:bgCol
			for h = 0 to height by gridSpace do
			(
				for i = 0 to width do (setPixels bm [i,h] #(gridCol))
			)
			for w = 0 to width by gridSpace do
			(
				for i = 0 to height do (setPixels bm [w,i] #(gridCol))
			)
			for i = 0 to width do (setPixels bm [i,pos.y] #(crossCol))
			for i = 0 to height do (setPixels bm [pos.x,i] #(crossCol))
			
			r=10
			j=pos.x
			k=pos.y
			for i = 1 to 360 by 5 do
			(
				x=r*cos i + j
				y=r*sin i + k
				setPixels bm [x,y] #(circleCol)
			)
			
			control.bitmap=bm
			boxControlItVal=pos
		)
	)
	
	local rcMenuCon=undefined
	fn conMenus con:undefined=
	(
		rcMenu menu
		(
			menuItem reset "Reset"
			menuItem resetX "Reset X"
			menuItem resetY "Reset Y"
			
			on reset picked do
			(
				boxControlItVal=[rcMenuCon.width/2,rcMenuCon.height/2]
				boxControl control:rcMenuCon width:rcMenuCon.width height:rcMenuCon.height pos:boxControlItVal
			)
			on resetX picked do
			(
				boxControlItVal=[boxControlIt.width/2,boxControlItVal.y]
				boxControl control:rcMenuCon width:rcMenuCon.width height:rcMenuCon.height pos:boxControlItVal
			)
			on resetY picked do
			(
				boxControlItVal=[boxControlItVal.x,rcMenuCon.height/2]
				boxControl control:rcMenuCon width:rcMenuCon.width height:rcMenuCon.height pos:boxControlItVal
			)
		)
		rcMenuCon=con
		menu
	)
	 
	local testMouseOut=false
	on boxControlIt lbuttondown pos flag do 
	(
		testMouseOut=true
		curBoxControl=boxControlIt
		circleCol=(color 200 0 0)
	)
	on boxControlIt lbuttonup pos flag do 
	(
		print "mouseUp"
		testMouseOut=false
		circleCol=(color 0 0 100)
		dPos=mouse.screenPos-(GetDialogPos testImgTag)-[3,22]
		newPos=dPos-boxControlIt.pos
		boxControl control:boxControlIt width:boxControlIt.width height:boxControlIt.height pos:newPos
		curBoxControl=undefined
		gc light:true
	)
	on boxControlIt mouseout do 
	(
		if testMouseOut then
		(
			circleCol=(color 0 0 100)
			dPos=mouse.screenPos-(GetDialogPos testImgTag)-[3,22]
			newPos=dPos-boxControlIt.pos
			boxControl control:boxControlIt width:boxControlIt.width height:boxControlIt.height pos:newPos
		)
		curBoxControl=undefined
		gc light:true
	)
	on boxControlIt rbuttonDown do
	(
		PopupMenu (conMenus con:boxControlIt)
	)
	 
	on mouseTime tick do
	(
		dPos=mouse.screenPos-(GetDialogPos testImgTag)-[3,22]
		if curBoxControl!=undefined then
		(
			newPos=dPos-curBoxControl.pos
			boxControl control:curBoxControl width:curBoxControl.width height:curBoxControl.height pos:newPos
		)
	)	
	 
	on testImgTag open do
	(
		boxControl control:boxControlIt width:boxControlIt.width height:boxControlIt.height pos:[boxControlIt.width/2,boxControlIt.height/2]
	)
)
createDialog testImgTag