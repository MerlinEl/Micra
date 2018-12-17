
  GLOBAL sketch3DDialog
  (
  	-----------------------------
  	struct MATH_OPERATION
  	(
  		fn roundVal val pos = ((val*pos)as integer)*(pos/(pos*pos)as float),
  		fn roundPoint3 p3 pos =[roundVal p3.x pos, roundVal p3.y pos, roundVal p3.z pos]
  	)
  	local MO = MATH_OPERATION()
  	-----------------------------
  	struct DRAW_GUIDE_LINES
  	(
  		start_point, rect_size, draw_point,
  		
  		fn drawRect  =
  		(
  			if rect_size == undefined do return false
  			
  			local col =red
  			local p1=[0,0,0] + start_point
  			local p2=[rect_size.x,0,0] + start_point
  			local p3=[rect_size.x,rect_size.y,0] + start_point
  			local p4=[0,rect_size.y,0] + start_point
  			
  			gw.setTransform (Matrix3 1)
  			
  			local p = gw.hTransPoint p1
  			gw.hMarker p #smallHollowBox color:[255,255,255]
  			
  			p = gw.hTransPoint p3
  			gw.hMarker p #smallHollowBox color:[255,255,255]
  
  			p = gw.hTransPoint p2
  			gw.htext p ("width: "+(abs rect_size.x) as string+"  ") color:yellow
  			p = gw.hTransPoint p4
  			gw.htext p ("length: "+(abs rect_size.y) as string+"  ") color:yellow
  			
  			gw.setColor #line col
  			gw.Polyline #(p1, p2, p3, p4) true rgb:#(col, col, col, col) 
  			
  			gw.enlargeUpdateRect #whole --updateRect
  			gw.updateScreen()
  		),
  		fn drawGuideLines = --cross
  		(
  			if draw_point == undefined or rect_size == undefined do return false
  			
  			gw.setTransform (Matrix3 1)
  			local cros_size = [1000, 1000] 
  
  			local p = gw.hTransPoint (draw_point+1)
  			gw.htext p ("pos: "+ draw_point as string+"  ") color:yellow
  			
  			gw.setColor #line gray
  			gw.Polyline #([-cros_size.x,0,0]+draw_point,[cros_size.x,0,0]+draw_point) false --Line X
  			gw.setColor #line gray
  			gw.Polyline #([0,-cros_size.y,0]+draw_point,[0,cros_size.y,0]+draw_point) false --Line Y
  			gw.enlargeUpdateRect #whole
  			gw.updateScreen()
  		)
  	)
  	local DGL = DRAW_GUIDE_LINES()
  	-----------------------------
  	struct CREATE_GEOMETRY
  	(
  		fn createPrimitive type pos:[0,0,0] size:[100,100,100] clr:(color 40 100 200)=
  		(
  			case type of
  			(
  				#plane:in coordsys grid plane pos:(pos + [size.x/2, size.y/2, pos.z]) length:(abs size.y) width:(abs size.x) lengthsegs:1 widthsegs:1 renderScale:1 density:1 wirecolor:clr
  				#rectangle:in coordsys grid rectangle pos:pos
  				#point:in coordsys grid point pos:pos
  				#text :in coordsys grid 
  				(
  					tsize = 1
  					text pos:pos text:"" wirecolor:yellow size:tsize
  				)
  			)
  		)
  	)
  	local CG = CREATE_GEOMETRY()
  	-----------------------------
  	local ABORT = false
  	local BUILD = false
  	-----------------------------
  	tool drawRectTool
  	(
  		local round_value = 100 , snap_value  = 10
  		--on start do ()
  		on mousePoint click do
  			case click of
  			(
  				1:	
  				(
  					DGL.start_point = MO.roundPoint3 gridPoint round_value --nodeTM.translation =
  					unregisterRedrawViewsCallback DGL.drawGuideLines
  					registerRedrawViewsCallback DGL.drawGuideLines
  					completeRedraw()
  				)
  				2: 
  				(
  					DGL.start_point = MO.roundPoint3 gridPoint round_value
  					unregisterRedrawViewsCallback DGL.drawRect
  					registerRedrawViewsCallback DGL.drawRect
  					completeRedraw()
  				)
  				3: 
  				(
  					BUILD = true
  					completeRedraw()
  					#stop
  				)
  			)
  		on mouseMove click do
  			--case click of
  			(
  					--2:
  					--(
  						DGL.rect_size = MO.roundPoint3 gridDist round_value
  						DGL.draw_point = MO.roundPoint3 gridPoint round_value
  						CompleteRedraw()
  					--)
  			)
  		on mouseAbort click do
  		(
  			unregisterRedrawViewsCallback DGL.drawGuideLines
  			unregisterRedrawViewsCallback DGL.drawRect
  			if BUILD do 
  			(
  				local p = CG.createPrimitive #plane pos:DGL.start_point size:DGL.rect_size
  				convertToPoly p
  				p.name = uniqueName "model rect base"
  				select p
  			)
  			completeRedraw()
  			ABORT = true	
  		)
  	)
  	
  	if  sketch3DDialog != undefined do destroyDialog  sketch3DDialog
  	rollout sketch3DDialog " Sketch 3D" width:76 height:452
  	(
  		groupBox grp1 "Shapes:" pos:[4,4] width:68 height:104
  		groupBox grp2 "Tools:" pos:[4,112] width:68 height:180
  		groupBox grp3 "Options:" pos:[4,296] width:68 height:152
  		checkButton ckb_plane "r" pos:[8,20] width:24 height:24 toolTip:"Rectangle"
  		button btn_extrude "e" pos:[8,128] width:24 height:24 toolTip:"Extrude"
  		on ckb_plane changed state do
  		(
  			if state do
  			(
  				ABORT = false
  				while not ABORT and not keyboard.escPressed do (startTool drawRectTool)
  				ckb_plane.checked = false
  			)
  		)
  		on btn_extrude pressed  do
  		(
  		
  		)
  	)
  	createDialog sketch3DDialog pos:[170,80] style:#(#style_toolWindow, #style_sysMenu)
  )