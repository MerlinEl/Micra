try(destroyDialog testImgTag)catch()
 
rollout testImgTag "Test Img Tag"
(
	local curBoxControl=undefined
	local curSliderControlX=undefined
	local curSliderControlY=undefined
	local boxControlItVal=[0,0]
	
	imgTag boxControlIt "MouseTracker" \
		height:100 width:100 bitMap:undefined
	imgTag sliderControlItY "MouseTracker" \
		height:100 width:15 bitMap:undefined offset:[105,-105]
	imgTag sliderControlItX "MouseTracker" \
		height:15 width:100 bitMap:undefined
	 
	timer mouseTime interval:50
	 
	fn boxControl control:undefined width:0 height:0 pos:[0,0]=
	(
		if control!=undefined then
		(
			crossCol=(color 255 0 0)
			bm=bitmap width height color:(color 255 255 255)
			for i = 0 to width do (setPixels bm [i,pos.y] #(crossCol))
			for i = 0 to height do (setPixels bm [pos.x,i] #(crossCol))
			control.bitmap=bm
			boxControlItVal=pos
		)
	)
	fn sliderControl control:undefined width:0 height:0 pos:[0,0] axis:#x=
	(
		if control!=undefined then
		(
			col=(color 50 50 255)
			bm=bitmap width height color:(color 220 220 220)
			case axis of
			(
				#x:
				(
					for h = 0 to height do
					(
						for i = 0 to pos.x do
						(
							 setPixels bm [i,h] #(col)
						)
						for i = 0 to width by 10 do
						(
							curCol=(getPixels bm [i,h] 1)[1]
							if curCol!=undefined then
							(
								curCol.v+=100
								setPixels bm [i,h] #(curCol)
							)
						)
					)

				)
				#y:
				(
					for w = 0 to width do
					(
						for i = height to pos.y by-1 do
						(
							 setPixels bm [w,i] #(col)
						)
						for i = 0 to height by 10 do
						(
							curCol=(getPixels bm [w,i] 1)[1]
							if curCol!=undefined then
							(
								curCol.v+=100
								setPixels bm [w,i] #(curCol)
							)
						)
					)
				)
			)
			control.bitmap=bm
		)
	)
	
	fn conMenus=
	(
		rcMenu menu
		(
			menuItem reset "Reset"
			menuItem resetX "Reset X"
			menuItem resetY "Reset Y"
			
			on reset picked do
			(
				boxControlItVal=[boxControlIt.width/2,boxControlIt.height/2]
				boxControl control:boxControlIt width:boxControlIt.width height:boxControlIt.height pos:boxControlItVal
				sliderControl control:sliderControlItX width:sliderControlItX.width height:sliderControlItX.height pos:boxControlItVal axis:#x
				sliderControl control:sliderControlItY width:sliderControlItY.width height:sliderControlItY.height pos:boxControlItVal axis:#y
			)
			on resetX picked do
			(
				boxControlItVal=[boxControlIt.width/2,boxControlItVal.y]
				boxControl control:boxControlIt width:boxControlIt.width height:boxControlIt.height pos:boxControlItVal
				sliderControl control:sliderControlItX width:sliderControlItX.width height:sliderControlItX.height pos:boxControlItVal axis:#x
			)
			on resetY picked do
			(
				boxControlItVal=[boxControlItVal.x,boxControlIt.height/2]
				boxControl control:boxControlIt width:boxControlIt.width height:boxControlIt.height pos:boxControlItVal
				sliderControl control:sliderControlItY width:sliderControlItY.width height:sliderControlItY.height pos:boxControlItVal axis:#y
			)
		)
	)
	 
	on boxControlIt lbuttondown pos flag do (curBoxControl=boxControlIt)
	on boxControlIt lbuttonup pos flag do (curBoxControl=undefined;gc light:true)
	on boxControlIt mouseout do (curBoxControl=undefined;gc light:true)
	on boxControlIt rbuttonDown do
	(
		PopupMenu (conMenus())
	)
	 
	on sliderControlItX lbuttondown pos flag do (curSliderControlX=sliderControlItX)
	on sliderControlItX lbuttonup pos flag do (curSliderControlX=undefined;gc light:true)
	on sliderControlItX mouseout do (curSliderControlX=undefined;gc light:true)
	 
	on sliderControlItY lbuttondown pos flag do (curSliderControlY=sliderControlItY)
	on sliderControlItY lbuttonup pos flag do (curSliderControlY=undefined;gc light:true)
	on sliderControlItY mouseout do (curSliderControlY=undefined;gc light:true)
	 
	on mouseTime tick do
	(
		dPos=mouse.screenPos-(GetDialogPos testImgTag)
		if curBoxControl!=undefined then
		(
			newPos=dPos-curBoxControl.pos-[3,22]
			boxControl control:curBoxControl width:curBoxControl.width height:curBoxControl.height pos:newPos
			sliderControl control:sliderControlItX width:sliderControlItX.width height:sliderControlItX.height pos:newPos axis:#x
			sliderControl control:sliderControlItY width:sliderControlItY.width height:sliderControlItY.height pos:newPos axis:#y			
		)
		if curSliderControlX!=undefined then
		(
			newPos=dPos-curSliderControlX.pos-[3,22]
			sliderControl control:curSliderControlX width:curSliderControlX.width height:curSliderControlX.height pos:newPos axis:#x
			boxControl control:boxControlIt width:boxControlIt.width height:boxControlIt.height pos:[newPos.x,boxControlItVal.y]
		)
		if curSliderControlY!=undefined then
		(
			newPos=dPos-curSliderControlY.pos-[3,22]
			sliderControl control:curSliderControlY width:curSliderControlY.width height:curSliderControlY.height pos:newPos axis:#y
			boxControl control:boxControlIt width:boxControlIt.width height:boxControlIt.height pos:[boxControlItVal.x,newPos.y]
		)
	)	
	 
	on testImgTag open do
	(
		boxControl control:boxControlIt width:boxControlIt.width height:boxControlIt.height pos:[boxControlIt.width/2,boxControlIt.height/2]
		sliderControl control:sliderControlItX width:sliderControlItX.width height:sliderControlItX.height pos:[sliderControlItX.width/2,sliderControlItX.height/2] axis:#x
		sliderControl control:sliderControlItY width:sliderControlItY.width height:sliderControlItY.height pos:[sliderControlItY.width/2,sliderControlItY.height/2] axis:#y
	)
)
createDialog testImgTag
 