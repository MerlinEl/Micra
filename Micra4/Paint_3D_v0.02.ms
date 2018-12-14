(

	global MicroPaint_CanvasRollout
	try(destroyDialog MicroPaint_CanvasRollout)catch()

	local isErasing = isDrawing = false
	local bitmapX = bitmapY = 512
	local bitmapx_1 = bitmapx-1
	local bitmapy_1 = bitmapy-1
	local temp_bitmap_filename = (getDir #preview +"/microPaint_temp.tga")
	local orig_bitmap_filename = ""
	local theCanvasBitmap = bitmap bitmapX bitmapY color:white filename:temp_bitmap_filename
	local theBackgroundBitmap = bitmap bitmapX bitmapY color:white
	local currentPos = lastPos = [0,0]
	local theChannel = 1
	local theObj = undefined
	local bary = [0,0,0]
	local faceIndex = 1


	rcMenu CanvasMenu 
	(
		subMenu "File"
		(
			menuItem new_menu "New"
			menuItem open_menu "Open..."
			menuItem save_as "Save As..."
			separator file_menu_1
			menuItem quit_tool "Quit"  
		)
		subMenu "Edit" 
		( 
			menuItem commit_menu "Commit Changes"
			separator edit_menu_1
			menuItem uv_menu "Get UV Coordinates..."
			menuItem paint3d_menu "Toggle 3D Painting..."
		)
		on commit_menu picked do copy theCanvasBitmap theBackgroundBitmap
		on uv_menu picked do MicroPaint_CanvasRollout.unwrapTexture()
		on paint3d_menu picked do MicroPaint_CanvasRollout.startPainting3D()
		 
		subMenu "Help" 
		( 
			menuItem about_tool "About MicroPaint..." 
		)
		 
		on new_menu picked do 
		(
			theBackgroundBitmap = theCanvasBitmap = bitmap bitmapX bitmapY color:MicroPaint_CanvasRollout.paperColor.color filename:temp_bitmap_filename
			MicroPaint_CanvasRollout.theCanvas.bitmap = theCanvasBitmap 
		)
		 
		on open_menu picked do 
		(
			theOpenBitmap= selectBitmap()
			if theOpenBitmap != undefined do
			(
				copy theOpenBitmap theCanvasBitmap
				copy theOpenBitmap theBackgroundBitmap 
				close theOpenBitmap
				MicroPaint_CanvasRollout.theCanvas.bitmap = theCanvasBitmap 
			)
		)
		 
		on save_as picked do
		(
			theSaveName = getSaveFileName types:"BMP (*.bmp)|*.bmp|Targa (*.tga)|*.tga|JPEG (*.jpg)|*.jpg"
			if theSaveName != undefined do
			(
				theCanvasBitmap.filename = theSaveName
				save theCanvasBitmap
				theCanvasBitmap.filename = temp_bitmap_filename
			)
		)
		on about_tool picked do messagebox "MicroPaint\nMAXScript Tutorial" title:"About..."
		on quit_tool picked do destroyDialog MicroPaint_CanvasRollout
	)
	 
	 
	fn mesh_filter obj = superclassof obj == GeometryClass and classof obj != TargetObject
	 
	rollout MicroPaint_CanvasRollout "MicroPaint"
	(
		
		bitmap theCanvas "" pos:[0,0] width:512 height:512 bitmap:theCanvasBitmap
		
		label lbl4 "Set Color:" pos:[4,518] width:52 height:16
		colorPicker inkColor "" pos:[60,518] width:22 height:16 color:(color 0 0 0) modal:false across:6
		colorPicker paperColor "" pos:[82,518] width:22 height:16 color:(color 255 255 255) modal:false
		
		checkbutton autosave "AutoSave" pos:[444,516] width:70 height:21 highlightColor:(color 255 200 200)
		checkbutton airBrush "AirBrush" pos:[516,376] width:92 height:21 highlightColor:(color 200 255 200)
		spinner AirBrushSpeed "Speed" pos:[528,428] width:73 height:16 range:[0.1,50,10] fieldwidth:30
		spinner BrushSize "Size" pos:[528,408] width:72 height:16 range:[1,50,1] type:#integer fieldwidth:40
		listbox BrushShape "" pos:[516,236] width:90 height:10 items:#("Circle", "Box", "Circle Smooth")
		 
		pickbutton pickMesh "Pick Mesh" pos:[516,452] width:94 height:30 highlightcolor:(color 200 200 255) pos:[bitmapX+5,140] filter:mesh_filter autodisplay:true
		checkbutton paint3D "3D PAINT" pos:[516,488] width:92 height:50 highlightcolor:(color 200 200 255) pos:[bitmapX+5,180]
		
		listbox lbx_layers "" pos:[516,24] width:90 height:12 items:#("Layer01", "Background")
		label lbl2 "Brushes:" pos:[516,216] width:88 height:16
		label lbl3 "Layers:" pos:[516,4] width:88 height:16
		button ckb_add_layer "+" pos:[516,188] width:36 height:21 highlightColor:(color 200 255 200)
		button ckb_del_layer "-" pos:[572,188] width:36 height:21 highlightColor:(color 200 255 200)
			
/*
		bitmap theCanvas pos:[0,0] width:bitmapX height:bitmapY bitmap:theCanvasBitmap
		colorpicker inkColor height:16 modal:false color:black across:6
		colorpicker paperColor height:16 modal:false color:white
		checkbutton autoSave "AutoSave" width:70 offset:[0,-3] highlightcolor:(color 255 200 200)
		checkbutton airBrush "AirBrush" width:70 offset:[0,-3] highlightcolor:(color 200 255 200)
		spinner AirBrushSpeed "Speed" range:[0.1,50,10] fieldwidth:30
		spinner BrushSize "Size" range:[1,50,1] type:#integer fieldwidth:40
		listbox BrushShape items:#("Circle", "Box", "Circle Smooth") pos:[bitmapX+5,0] width:90
*/
		on pickMesh picked obj do 
		(
			if obj != undefined do 
			(
				theObj = Obj
				try
				(
					case (classOf theObj.material) of
					(
						Standard:
						(
							orig_bitmap_filename = theObj.material.diffusemap.bitmap.filename
							--copyFile orig_bitmap_filename temp_bitmap_filename
							theObj.material.diffusemap.bitmap = openBitmap temp_bitmap_filename
							copy theObj.material.diffusemap.bitmap theCanvasBitmap
							copy theObj.material.diffusemap.bitmap theBackgroundBitmap 
						)
						Multimaterial:
						(
							orig_bitmap_filename = theObj.material[1].diffusemap.bitmap.filename
							theObj.material[1].diffusemap.bitmap = temp_bitmap_filename
							copy theObj.material[1].diffusemap.bitmap theCanvasBitmap
							copy theObj.material[1].diffusemap.bitmap theBackgroundBitmap 
						)
					)
					theCanvas.bitmap = theCanvasBitmap 
				)
				catch() 
			) 
		) 

		fn paintBrush pos =
		(
			if isErasing then 
			thePaintColor = (getPixels theBackgroundBitmap pos 1)[1]
			else
			thePaintColor = inkColor.color
			if thePaintColor == undefined then thePaintColor = white
			 
			case BrushShape.selection of
			(
				1: 
				( 
					if distance pos currentPos <= BrushSize.value/2 do
					setPixels theCanvasBitmap pos #(thePaintColor)
				)
				2: setPixels theCanvasBitmap pos #(thePaintColor)
				3: 
				( 
					theFactor = (distance pos currentPos) / (BrushSize.value/2.0)
					if theFactor <= 1.0 do
					(
						theFactor = sin ( 90.0 * theFactor)
						thePixels = getPixels theCanvasBitmap pos 1
						if thePixels[1] != undefined do
						(
							thePixels[1] = (thePixels[1] * theFactor) + (thePaintColor * (1.0 - theFactor))
							setPixels theCanvasBitmap pos thePixels
						)
					)
				)--end case 3
			)--end case
		)--end fn

		fn drawStroke lastPos pos drawIt: =
		(
			currentPos = lastPos
			deltaX = pos.x - lastPos.x
			deltaY = pos.y - lastPos.y
			maxSteps = amax #(abs(deltaX),abs(deltaY))
			deltaStepX = deltaX / maxSteps 
			deltaStepY = deltaY / maxSteps 
			for i = 0 to maxSteps do
			(
				if airBrush.checked then
				for b = 1 to (BrushSize.value / AirBrushSpeed.value) do
				paintBrush (currentPos + (random [-BrushSize.value/2,-BrushSize.value/2] [BrushSize.value/2,BrushSize.value/2] ))
				else
				for b = -BrushSize.value/2 to BrushSize.value/2 do
				for c = -BrushSize.value/2 to BrushSize.value/2 do
				paintBrush (currentPos + [c,b]) 
				currentPos += [deltaStepX, deltaStepY]
			)
			if drawIt== true or drawIt == unsupplied do theCanvas.bitmap = theCanvasBitmap 
		)
		 
		fn unwrapTexture =
		(
			if theObj != undefined then
			(
				theMesh = snapshotAsMesh theObj
				if meshop.getMapSupport theMesh theChannel do
				(
					faceCount = meshop.getNumMapFaces theMesh theChannel 
					for f = 1 to faceCount do
					(
						theFace = meshop.getMapFace theMesh theChannel f
						vert1= meshop.getMapVert theMesh theChannel theFace.x
						vert2= meshop.getMapVert theMesh theChannel theFace.y
						vert3= meshop.getMapVert theMesh theChannel theFace.z
						 
						drawStroke [vert1.x * bitmapx_1, bitmapy_1 - vert1.y * bitmapy_1] [vert2.x * bitmapx_1, bitmapy_1 - vert2.y * bitmapy_1] drawIt:false
						drawStroke [vert1.x * bitmapx_1, bitmapy_1 - vert1.y * bitmapy_1] [vert3.x * bitmapx_1, bitmapy_1 - vert3.y * bitmapy_1] drawIt:false
						drawStroke [vert3.x * bitmapx_1, bitmapy_1 - vert3.y * bitmapy_1] [vert2.x * bitmapx_1, bitmapy_1 - vert2.y * bitmapy_1] drawIt:false
					)
				) 
				
				theCanvas.bitmap = theCanvasBitmap 
				save theCanvasBitmap 
				if theObj.material == undefined do theObj.material = Standard()
				if theObj.material.diffusemap == undefined do
				theObj.material.diffusemap = bitmapTexture filename:temp_bitmap_filename 
				showTextureMap theObj.material true
				autoSave.checked = true
			)
		)
		 
		 
		fn StartStroke = ( thePainterInterface.undoStart() )
		fn PaintStroke = 
		(
			theMesh = theObj.mesh
			thePainterInterface.getHitFaceData &bary &faceIndex theObj 0
			theFace = meshop.getMapFace theMesh theChannel faceIndex
			vert1= meshop.getMapVert theMesh theChannel theFace.x
			vert2= meshop.getMapVert theMesh theChannel theFace.y
			vert3= meshop.getMapVert theMesh theChannel theFace.z
			thePoint = bary.x*vert1 + bary.y*vert2 + bary.z*vert3
			drawStroke [thePoint.x * bitmapx_1, bitmapy_1 - thePoint.y * bitmapy_1] [thePoint.x * bitmapx_1, bitmapy_1 - thePoint.y * bitmapy_1] 
			thePainterInterface.clearStroke()
		)
		fn EndStroke = 
		(
			thePainterInterface.undoAccept()
			if autoSave.checked do 
			(
				print theCanvasBitmap
				save theCanvasBitmap 
				try(theObj.material.diffsemap.bitmap = theCanvasBitmap)catch()
			) 
		)
		 
		fn CancelStroke = (thePainterInterface.undoCancel())
		 
		fn SystemEndPaintSession = ( paint3D.checked = false ) 
		 
		fn startPainting3D =
		(
			if thePainterInterface.InPaintMode() or theObj == undefined then 
			(
				thePainterInterface.EndPaintSession()
				paint3D.checked = false
				--return back orig material
				
				case (classOf theObj.material) of
				(
					Standard:theObj.material.diffusemap.bitmap = openBitmap orig_bitmap_filename
					Multimaterial:theObj.material[1].diffusemap.bitmap = openBitmap orig_bitmap_filename
				)
			)
			else
			(
				paint3D.checked = true
				thePainterInterface.pointGatherEnable = TRUE
				thePainterInterface.initializeNodes 0 #(theObj)
				thePainterInterface.offMeshHitType = 2
				thePainterInterface.ScriptFunctions startStroke paintStroke endStroke cancelStroke SystemEndPaintSession 
				thePainterInterface.startPaintSession()
			)
		)
		 
		on paint3D changed state do startPainting3D() 
		 
		on MicroPaint_CanvasRollout lbuttondown pos do
		(
			lastPos = pos
			isDrawing = true
			isErasing = false
			drawStroke lastPos pos
		)
		on MicroPaint_CanvasRollout rbuttondown pos do
		(
			lastPos = pos
			isErasing = isDrawing = true
			drawStroke lastPos pos
		)
		on MicroPaint_CanvasRollout lbuttonup pos do 
		(
			isErasing = isDrawing = false
			if autoSave.checked do save theCanvasBitmap 
		) 
		on MicroPaint_CanvasRollout rbuttonup pos do 
		(
			isErasing = isDrawing = false
			if autoSave.checked do save theCanvasBitmap 
		) 
		on autoSave changed state do if state do save theCanvasBitmap 
		 
		on MicroPaint_CanvasRollout mousemove pos do
		(
			if isDrawing do drawStroke lastPos pos
			lastPos = pos
		)
	)
	
	createDialog MicroPaint_CanvasRollout (bitmapx+100) (bitmapy+30) menu:CanvasMenu 
	MicroPaint_CanvasRollout.theCanvas.bitmap = theBackgroundBitmap 
	
)
	 
	 
	