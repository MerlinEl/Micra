rollout testImgTag "Test Img Tag" width:100 height:100
  (
  	fn boxControl control:undefined width:0 height:0 pos:[0,0]=
  	(
  		if control!=undefined then
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
  			
  		
  			SetDialogBitmap testImgTag bm
  			testImgTagVal=pos
  		)
  	)
  	
  	on testImgTag mousemove pos do	
  	(
  		
  		if keyboard.controlpressed do
  		(	
  		format "Mouse Position : %\n" pos
  		curBoxControl=testImgTag
  		circleCol=(color 200 0 0)
  		boxControl control:curBoxControl width:curBoxControl.width height:curBoxControl.height pos:Pos
  		)
  		
  	)
  
  	on testImgTag open do
  	(
  		boxControl control:testImgTag width:testImgTag.width height:testImgTag.height pos:[testImgTag.width/2,testImgTag.height/2]
  	)
  	
  )
  createdialog testimgTag
  