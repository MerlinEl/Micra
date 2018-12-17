try(destroyDialog testImgTag)catch()
 
 rollout testImgTag "Test Img Tag"
 (
	 local currentControl=undefined
	 imgTag mouseTracker "MouseTracker" \
		 height:100 width:100 bitMap:undefined
	 imgTag mouseTracker02 "MouseTracker" \
		 height:100 width:100 bitMap:undefined
	 
	 timer mouseTime interval:50
	 
	 fn createBitMap control:undefined width:0 height:0 pos:[0,0]=
	 (
		 if control!=undefined then
		 (
			 crossCol=(color 255 0 0)
			 bm=bitmap width height color:(color 255 255 255)
			 for i = 0 to width do (setPixels bm [i,pos.y] #(crossCol))
			 for i = 0 to height do (setPixels bm [pos.x,i] #(crossCol))
			 control.bitmap=bm
		 )
	 )
	 
	 on mouseTracker lbuttondown pos flag do (currentControl=mouseTracker)
	 on mouseTracker lbuttonup pos flag do (currentControl=undefined;gc light:true)
	 on mouseTracker mouseout do (currentControl=undefined;gc light:true)
	 
	 on mouseTracker02 lbuttondown pos flag do (currentControl=mouseTracker02)
	 on mouseTracker02 lbuttonup pos flag do (currentControl=undefined;gc light:true)
	 on mouseTracker02 mouseout do (currentControl=undefined;gc light:true)
	 
	 on mouseTime tick do
	 (
		 if currentControl!=undefined then
		 (
			 newPos=(mouse.screenPos-(GetDialogPos testImgTag)-currentControl.pos-[3,22])
			 createBitMap control:currentControl width:currentControl.width height:currentControl.height pos:newPos
		 )
	 )	
	 
	 on testImgTag open do
	 (
		 createBitMap control:mouseTracker width:mouseTracker.width height:mouseTracker.height
		 createBitMap control:mouseTracker02 width:mouseTracker02.width height:mouseTracker02.height
	 )
 )
 createDialog testImgTag
 