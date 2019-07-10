-------------------------
-------------------------
--                     --
--  Low Polygon Wizard --
--                     --
-------------------------
-------------------------
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--

if mcLpWizardDialog != undefined then destroyDialog mcLpWizardDialog

--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
Global mcLpWizardDialog
Global lpWizardHelpDialog
Global mcDraw
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
rollout mcLpWizardDialog "" width:528 height:84
(
	--Locals:--------------------------------------------------------------------
 	local dMove = false , DmPos, drw, breakCount = 0
 	-----------------------------------------------------------------------------
	GroupBox grp_Title "" pos:[4,4] width:520 height:76
	checkbutton ckbDraw "DRAW" pos:[452,16] width:68 height:60 toolTip:"Draw Mode"
	pickbutton btnHi "Pick Hp" pos:[8,32] width:228 height:16 toolTip:"Pick Hypoly"
	pickbutton btnLo "Pick Lp" pos:[8,16] width:228 height:16 toolTip:"Pick Lowpoly"
	checkbox chkShadeHi "" pos:[240,32] width:16 height:16
	checkbox chkShadeLo "" pos:[240,16] width:16 height:16		
	label lbl1 "Vertex Creation Distance:" pos:[276,16] width:120 height:12
	label lbl2 "Pick Radius:" pos:[276,36] width:64 height:12	
	label lbl3 "Snap To Surface Offset:" pos:[276,56] width:120 height:12
	spinner spnOver "" pos:[400,16] width:48 height:16 range:[0,100,0.1] type:#float scale:0.1
	spinner spnSel  "" pos:[400,36] width:48 height:16 range:[0,100,2]   type:#float scale:0.1
	spinner spnSnap "" pos:[400,56] width:48 height:16 range:[0,100,0.2] type:#float scale:0.01
	
	button btnSelectVerts "" pos:[8,52] width:24 height:24 enabled:false images:(mcCall.getIcon 102 icon_set:#b) toolTip:"Select Verts"
	checkbutton chkCreateVerts "" pos:[32,52] width:24 height:24 enabled:false images:(mcCall.getIcon 103 icon_set:#b) toolTip:"Create Verts"
	checkbutton chkMagnet "" pos:[56,52] width:24 height:24 enabled:false images:(mcCall.getIcon 101 icon_set:#b) toolTip:"Magnet"
	button btnFlipFace "" pos:[80,52] width:24 height:24 enabled:false images:(mcCall.getIcon 104 icon_set:#b) toolTip:"Flip face"
	button btnCollapseVerts "" pos:[104,52] width:24 height:24 enabled:false images:(mcCall.getIcon 105 icon_set:#b) toolTip:"Collapse Verts"
	checkbutton chkStitchEdges "" pos:[128,52] width:24 height:24 enabled:false images:(mcCall.getIcon 106 icon_set:#b) toolTip:"Collapse Edges"
	checkbutton chkMiddleCut "" pos:[152,52] width:24 height:24 enabled:false images:(mcCall.getIcon 107 icon_set:#b) toolTip:"Cut In Middle"
	checkbutton chkSpinEdge "" pos:[176,52] width:24 height:24 enabled:false images:(mcCall.getIcon 108 icon_set:#b) toolTip:"Spin Edge"
	button btnRemIsoVerts "" pos:[200,52] width:24 height:24 enabled:false images:(mcCall.getIcon 109 icon_set:#b) toolTip:"Remove Isolated Vertices"
	checkbutton chkConnect "" pos:[224,52] width:24 height:24 enabled:false images:(mcCall.getIcon 111 icon_set:#b) toolTip:"Connect"
	button btnHelp "H" pos:[248,52] width:24 height:24 toolTip:"Help"
	-->Strucrure
	struct angleData (abs,rel)
	struct polyData
	(
		pos1,pos2,pos3,pos4,v1,v2,v3,v4,old,new,hitA,hitB,hitC
	)
	struct polyDraw
	(
		HipolyModel,LowpolyModel,HipolyModelSnp,TheViewPoint,RayP,rayInt,ActiveVertices,ActivePolygon,ActiveVert,
		DragVertStep,DragPolyStep,SpinEdgeStep,MarkVertPos,MarkVert,HitPoints,VertData,PolygonCanceled,TheNormal, SpinData, 
		TheAngle,
		--CLEAN
		fn clear =
		(
			--print "ending and clear"
			
			ckbDraw.checked = off
			breakCount = 0
			stopTool mcLpWizardDialog.lpWizardTool
			if isValidNode HipolyModelSnp do (delete HipolyModelSnp)
			if isValidNode LowpolyModel   do (update LowpolyModel ; select LowpolyModel)
			
			
			btnSelectVerts.enabled  =off
			chkCreateVerts.enabled  =off
			chkMagnet.enabled       =off
			btnFlipFace.enabled     =off
			btnCollapseVerts.enabled=off
			chkStitchEdges.enabled  =off
			chkMiddleCut.enabled    =off
			chkSpinEdge.enabled     =off
			btnRemIsoVerts.enabled  =off
			chkConnect.enabled      =off
			
			chkCreateVerts.checked  =off
			chkMagnet.checked       =off
			chkStitchEdges.checked  =off
			chkMiddleCut.checked    =off
			chkSpinEdge.checked     =off
			chkConnect.checked      =off
			
			unregisterRedrawViewsCallback drw.showCreationLine
			unregisterRedrawViewsCallback drw.showAngleInScreen
			redrawViews()
		),
		--CHECK
		fn isCorrectGeometry node =
		(
			if not isValidNode node                        do (messagebox "Not assinged or deleted object(s)."       title:" Micra!"; return false)
			if classOf node != Editable_Poly and classOf node != Editable_Mesh do (messagebox "Objects must be Editable_Poly or Editable_Mesh." title:" Micra!"; return false)
			--if (try (node.Faces.count) == 0 catch (false)) do (messagebox "One or both Objects Contain no Geometry." title:" Micra!"; return false)
			return true
		),
		fn isValidModels =
		(
			if not isCorrectGeometry drw.HipolyModel or not isCorrectGeometry drw.LowpolyModel do return false 
			if drw.HipolyModel == drw.LowpolyModel do (messagebox "Target and source object can't be identical!"                  title:" Micra!"; return false)
			return true
		),
		fn activate level =
		(
			if subObjectLevel != level do 
			(
				max modify mode
				case level of
				(
					1: subObjectLevel = 1
					2: subObjectLevel = 2
					4: subObjectLevel = 4
				)
			)
			if subObjectLevel == level then return true else return false
		),
		fn vertIsOpen obj verts_array =
		(
			local openCount = 0
			for v in verts_array do
			(
				local edges = polyOp.getEdgesUsingVert obj v
				if edges.numberset == 0 
				then
				(
					openCount += 1
				)
				else
				(
					for s in edges do if (polyOp.getFacesUsingEdge obj s).numberset == 1 do 
					(
						openCount += 1
						exit --exit edges loop level
					)
				)					
			)
			if openCount == verts_array.count 
			then (return true)--print "open" ; 
			else (return false)--print "close"; 
		),
		fn isFliped =
		(
			local v1 = RayP.dir
			local v2 = (normalize (polyOp.getFaceNormal LowpolyModel ActivePolygon))
			if (dot v1 v2) > 0 then return true else return false	
		),
		--GET
		fn getHitVert getRay:false = --this operation with mesh of (faces:15250 vertices:7627) tok 78 - 94 milisecond
		(
			--local s_t = timestamp()
			
			local vertCount = LowpolyModel.verts.count
			--RayInt = rayMeshIntersection HipolyModel (mapScreentoWorldRay theViewPoint)
			if RayInt == undefined or vertCount == 0 do return #()
			local dist = (for i=1 to vertCount collect distance (polyOp.getVert LowpolyModel i) RayInt.pos)
			local minPickDist = spnSel.value
			local minDist     = (amin dist)
			
			--local e_t = timestamp()
			--format "\nDatabase Rebuilt in: %ms.\n" (e_t-s_t)
			--format "Triangles: %  Vertices: % \n\n" LowpolyModel.numFaces LowpolyModel.numVerts 
			
			if minPickDist < minDist do (pushPrompt " The selection offset is to low."; return #())
			if getRay == true
			then (return #(findItem dist minDist, RayInt)) --get closest vert and ray
			else (return #(findItem dist minDist)) --get closest vert
		),
		fn get3PointsAngle A B C =
		(
			local V1 = B - A
			local V2 = B - C
			return acos (dot (normalize V1) (normalize V2))
		),
		fn virtualAngleSliderX A B C =	--in axis X	(product: Merlin "28.1.2007 14:50:53" )
		(
			local vBA = a - b
			local vBC = c - b  
			--find point BC projected in line BA	 
			local dt  = dot (normalize vBA) (normalize vBC)
			local D   = (b+(vBA*(dt*(length vBC/length vBA))))
			--find angle betwen two vectors DB CB
			local vBC = c - b
			local vDC = c - d
			local ang = acos (dot (normalize vBC) (normalize vDC))
			--inverse angle if point position is negative
			local vAD = d - a
			local vAB = b - a
			if (length vAB) < (length vAD) do ang = ang*-1 
			--vizualize slider
			gw.Marker A #plusSign color:green
			gw.Marker B #plusSign color:green
			gw.Marker D #diamond color:yellow
			gw.enlargeUpdateRect #whole  
			gw.updateScreen()
			return ang
		),
		fn getEdgePos edge =
		(
			local verts = polyOp.getEdgeVerts LowpolyModel edge 
			local vPos = for v in verts collect polyOp.getVert LowpolyModel v
			return ((vPos[1] + vPos[2])/2) --position of edge is a middle point teaken from two vertPos)
		),
		fn getHitEdge getRay:false = --this operation with mesh of (faces:15250 vertices:7627) tok 23 - 63 milisecond
		(	
			hide (local meshObj = snapshot LowpolyModel)
			local rayEx = (intersectRayEx meshObj RayP)
			local edge
			if rayEx != undefined do
			(
				local verts = meshop.getVertsUsingFace meshObj rayEx[2]
				local edges = polyOp.getEdgesUsingVert LowpolyModel verts as array
				local dist = (for i in edges collect distance (getEdgePos i) rayEx[1].pos)
				edge = edges[findItem dist (amin dist)] --get closest edge
			)
			delete meshObj
			if getRay == true 
			then (return #(edge, rayEx)) 
			else (return #(edge))
		),
		--OPERATION
		fn selectElement multi:off =
		(
			case subObjectLevel of --independ of subobject level
			(
				1:--vertices
				(
					pushPrompt " Selecting Verts"
					local num
					ActiveVert = getHitVert()
					if multi --multi or single selection 
					then
					(
						--print "multi"
						if (num = findItem ActiveVertices ActiveVert[1]) != 0 
						then (deleteItem ActiveVertices num; ActiveVert = #())
						else (ActiveVertices += ActiveVert)
						polyOp.setVertSelection LowpolyModel ActiveVertices
					)
					else
					(
						--print "single"
						ActiveVertices = ActiveVert
						polyOp.setVertSelection LowpolyModel ActiveVert
					)
					--format "activeVert:%\tActiveVertices:%\n" ActiveVert ActiveVertices
				)
				2:--edges
				()
				4:--faces
				()
			)
			redrawViews()
		),
		fn flipFace =
		(
			pushPrompt " Face Fliped" 
			if LowpolyModel == undefined or ActivePolygon == undefined do return false
			local verts = polyOp.getVertsUsingFace LowpolyModel ActivePolygon
			local vPos  = for v in verts collect (polyOp.getVert LowpolyModel v) --collect verts pos
			--format "vPos:%\n" vPos
			polyOp.setVertSelection LowpolyModel verts 
			polyOp.deleteFaces LowpolyModel ActivePolygon --delete old face
			
			local remainVertices = polyOp.getVertSelection LowpolyModel as array
			local newVertOrder = #()
			local found = false

			if remainVertices.count > 0 
			then
			(
				--print "append existing vertices and create rest"
				for i=vPos.count to 1 by -1 do
				(
					if remainVertices.count > 0 do
					(	
						for v=remainVertices.count to 1 by -1 do 
						(
						 	if (polyOp.getVert LowpolyModel remainVertices[v]) == vPos[i] do --if found duplicate vert append it to array
							(
								newVertOrder += #(remainVertices[v])
								deleteItem remainVertices v
								found = true
								exit --exit from this loop
							)
						)
					)
					if found then (found = false) else (newVertOrder += #(polyOp.createVert LowpolyModel vPos[i]))
				)	
			)
			else
			(
				--print "create all verts from begin"
				newVertOrder = (for i=vPos.count to 1 by -1 collect polyOp.createVert LowpolyModel vPos[i]) --get vertices in invert order
			)
			polyOp.createPolygon LowpolyModel newVertOrder --create fliped polygon
			polyOp.setVertSelection LowpolyModel #()
			update LowpolyModel
		),
		fn renumberVertsBy verts_array deleted_vert =
		(
			local renumberedVerts = #()
			for i in verts_array do
			(
				local num = i
				if i > deleted_vert	do (num -= 1)
				renumberedVerts += #( num )
			)
			return renumberedVerts 
		), 
		fn removeSegment type =
		(
			case type of
			(
				#vert:
				(
					local vert = getHitVert()
					if vert.count == 1 do 
					(
						if ActiveVertices.count != 0 do 
						(
							local num = (findItem ActiveVertices vert[1])
							if num != 0 do (deleteItem ActiveVertices num)
							local ActiveVertices = (renumberVertsBy ActiveVertices vert[1])
						)
						polyOp.setVertSelection LowpolyModel vert
						undo label:"remove vertex" on 
						(
							if not (LowpolyModel.remove selLevel:#vertex) do
							(
								polyOp.deleteVerts LowpolyModel vert
							)
						)
						polyOp.setVertSelection LowpolyModel ActiveVertices
						redrawViews()
					)
				)
				#edge:
				(
					local edge = (getHitEdge())[1]
					if edge != undefined do undo label:"remove edge" on
					(
						polyOp.setEdgeSelection LowpolyModel edge
						LowpolyModel.remove selLevel:#edge
					)
				)
				#face:
				(
					--local face = gatheringSegments #face
					--polyOp.setFaceSelection LowpolyModel face
					--LowpolyModel.remove selLevel:#face
				)
			)
			--redrawViews()
		),
		fn snapToSurface vert pos dir =
		(
			local surf_offset = spnSnap.value
			local newPos = pos + dir * surf_offset 
			polyop.setVert LowpolyModel vert newPos
		),
		fn cutEdge =
		(
			local edge = (getHitEdge())[1]
			if edge == undefined do return false
			local hitPoint = rayInt.pos -- hit in surface
			local pointDir = rayInt.dir -- dir in surface
			local newPos,newVert
			pushPrompt " Cutting Edges"
			undo label:"Cut edge" on
			(
				newVert = LowpolyModel.insertVertexInEdge edge 0.5 select:true	
			)
			if newVert == undefined do return false
			
			--append nev vert to variable
			ActiveVertices += #(newVert)
			------------------------
			--snap vert to surface--
			------------------------			
			if chkMiddleCut.checked
			then--in middle
			(
				--gathering data : get line points A B and hit point C
				local verts    = polyOp.getVertsUsingEdge LowpolyModel edge as array
				local vertPos1 = polyOp.getVert LowpolyModel verts[1] -- first  edge vert
				local vertPos2 = polyOp.getVert LowpolyModel verts[2] -- second edge vert
				local midPoint = polyOp.getVert LowpolyModel newVert  -- new    edge vert
				local fFormal  = -- faces normal
				--find point C projected in line BA
				local vBA       = (vertPos1 - midPoint)
				local vBC       = (hitPoint - midPoint)   
				local dt        = (dot (normalize vBA) (normalize vBC))
				local projPoint = (midPoint+(vBA*(dt*(length vBC/length vBA))))
				--move midPoint in pointDir for new vector length
				local len       = (length (projPoint - hitPoint))
				newPos          = (midPoint+(pointDir*len))
			)
			else--in hitPos
			(
				newPos = hitPoint
			)	
			--newPos      = (midPoint + (hitPoint - projPoint)) 
			--newPos      = (midPoint+(pointDir*len)) 
			--newPos      = (projPoint+(pointDir*(len/2)))
				
			snapToSurface newVert newPos rayInt.dir
			
			--polyop.setVert LowpolyModel newVert newPos
		),
		fn stitchEdge =
		(
			local edge = (getHitEdge())[1]
			if edge == undefined do return false
			pushPrompt " Stitch Edges" 
			local verts = polyOp.getEdgeVerts LowpolyModel edge
			undo label:"Stitch Edges" on (polyOp.collapseVerts LowpolyModel verts)
			ActiveVertices = (polyOp.getVertSelection LowpolyModel) as array
		),
		fn collapseVertices =
		(
			if ActiveVertices.count == 0 do ActiveVertices = (polyOp.getVertSelection LowpolyModel) as array
			if ActiveVertices.count == 0 do return false
			undo label:"collapse vertices" on
			(
				pushPrompt " Collapsing Verts"
				polyOp.collapseVerts LowpolyModel ActiveVertices
				polyOp.setVertSelection LowpolyModel #() 
				ActiveVertices = #()
			)
		),
		fn dragVertOnSurface vpt =
		(
			local rayEx = (intersectRayEx HipolyModelSnp (mapScreentoWorldRay vpt))
			if rayEx != undefined do
			(
				snapToSurface MarkVert rayEx[1].pos rayEx[1].dir
				--polyOp.setVert LowpolyModel MarkVert rayEx[1].pos
			)
		),
		-->Correction Rene
		--DRAG EDGE
		fn collectSpinData = 
		(
			if hitPoints.new == undefined do return false
			--print "spinning"
			TheNormal = polyOp.getFaceNormal LowpolyModel ActivePolygon
			SpinData  = (polyData hitA:hitPoints.old hitB:hitPoints.new pos3:vertData.pos3 pos4:vertData.pos4)
			--format "hitPoints.A:%\thitPoints.B:%\tvertData.pos3:%\n" hitPoints.A hitPoints.B vertData.pos3
			TheAngle  = (angleData rel:0.0 abs:(get3PointsAngle hitPoints.old hitPoints.new vertData.pos3))
		),
		fn rotateVectorByAxisAngle rotCenter thePoint rotAxis rotAngle =
		(
			local q = inverse (quat rotAngle (normalize rotAxis))
			return (((thePoint - rotCenter) * q) + rotCenter) --pointAfterRotation
		),
		fn dragEdgeOnSurface vpt =
		(
			local rayEx = (intersectRayEx HipolyModelSnp (mapScreentoWorldRay vpt))		
			if rayEx == undefined or ActiveVertices.count != 2 do return false
			HitPoints.new = rayEx[1].pos
			--calculating data for new verts pos
			if chkSpinEdge.checked and drw.SpinEdgeStep
			then --spinEdge
			(
				--if drw.DragPolyStep do manipEdgeOnSurface vpt #drag -- drag edge on surface before spin
				if spinData == undefined do return false
				local P3     = spinData.pos3
				local P4     = spinData.pos4
				local hitA   = spinData.hitA
				local hitB   = spinData.hitB
				local hitC   = hitPoints.new
				
				local scalar  = virtualAngleSliderX hitA hitB hitC
				if scalar != undefined do
				(
					--format "scallar:%\n" scalar
					vertData.pos3 = (rotateVectorByAxisAngle hitB P3 theNormal scalar)
					vertData.pos4 = (rotateVectorByAxisAngle hitB P4 theNormal scalar)
				)
				TheAngle = (angleData rel:scalar abs:(get3PointsAngle hitA hitB vertData.pos3))
			)
			else --dragEdge
			(
				VertData.pos3 = (VertData.v1 + HitPoints.new)
				VertData.pos4 = (VertData.v2 + HitPoints.new)
			)
			--moving vets to new position
			--format "ActiveVertices[1]:%\tActiveVertices[2]:%\tvertData.pos3:%\n" ActiveVertices[1] ActiveVertices[2] vertData.pos3
			with redraw off
			(
				polyOp.setVert LowpolyModel ActiveVertices[1] VertData.pos3
				polyOp.setVert LowpolyModel ActiveVertices[2] VertData.pos4
			)
		),
		fn snapInGround next:false =
		(
			--format  "ActivePolygon:%\tVertData:%\n" ActivePolygon VertData
			if ActivePolygon == undefined do return false
			if VertData.pos3 == undefiend or VertData.pos4 == undefiend do return false
			
			--print "usazeni start"
			
			TheNormal    = polyOp.getFaceNormal LowpolyModel ActivePolygon
			local P3     = vertData.pos3
			local P4     = vertData.pos4
			--make two rays from p3 p4 and incerase theirs length
			local ray1   = ray (P3+(theNormal*4)) (theNormal*-1)
			local ray2   = ray (P4+(theNormal*4)) (theNormal*-1)
			--get intersect points from obj
			local rayInt1 = intersectRay HipolyModelSnp ray1
			local rayInt2 = intersectRay HipolyModelSnp ray2
			--snap verts to intersect points
			if rayInt1 != undefined do (polyOp.setVert LowpolyModel ActiveVertices[1] rayInt1.pos)
			if rayInt2 != undefined do (polyOp.setVert LowpolyModel ActiveVertices[2] rayInt2.pos)
			
			if not next do (ActiveVertices = #(); polyOp.setVertSelection LowpolyModel #())
			--print "usazeni end"
		),
		--<
		--VIEWPORT DRAWING
		fn showCreationLine =
		(
			if not isCorrectGeometry LowpolyModel or rayInt == undefined do return false
			local vSel = polyOp.getVertSelection LowpolyModel as array
			if ActiveVertices.count != vSel.count do (ActiveVertices = vSel)
			if ActiveVertices.count < 2 do return false
			local points = for i in ActiveVertices collect (polyOp.getVert LowpolyModel i)
			gw.setTransform (Matrix3 1)
			gw.setColor #line (color 255 234 0)
			gw.Polyline points (vertIsOpen LowpolyModel ActiveVertices)--get true or false
			--if ActiveVert.count != 0 do (gw.Text rayInt.pos (ActiveVertices.count as string) color:(color 255 234 0))	
			gw.enlargeUpdateRect #whole 
			gw.updateScreen()
		),
		fn showAngleInScreen =
		(
			--format "theAngle:%\n" theAngle
			if theAngle == undefined do return false --or vertData.pos3 == undefined
			local viewText   = "[ abs:"+theAngle.abs as string+" rel:"+theAngle.rel as string+" ]"
			local textPos    = [mouse.pos.x+5,mouse.pos.y-5,0]--[TheViewPoint.x+1,TheViewPoint.y-1,0]
			local textSize   = (gw.getTextExtent viewText)+[2,2]
			local updateRect = box2 textPos.x (textPos.y-(gw.getTextExtent "X").y) textSize.x textSize.y
			--gw.clearscreen updateRect useBkg:false
			--gw.resetUpdateRect()
			gw.wText textPos viewText color:green--(color 255 234 0)
			gw.Marker vertData.pos3 #bigBox color:green
			gw.enlargeUpdateRect updateRect --#whole--
			gw.updateScreen()
		),
		--CREATE
		fn createNode =
		(
			local obj = mesh vertices:#() faces:#() name:(HipolyModel.name + "_LPW")--uniqueName 
			convertToPoly obj ; redrawViews() ; select obj ; return obj
		),
		fn createVertex =
		(
			pushPrompt " Creating verts on surface is: ON"
			if rayInt == undefined do return false 
			
			undo label:"create vertex" on
			(
				if not (activate 1) do return false -- go to subobject level 1
				local newVert = (polyOp.createVert LowpolyModel rayInt.pos)
				if classOf newVert == integer do 
				(
					ActiveVertices += #(newVert)
					snapToSurface newVert rayInt.pos rayInt.dir
					polyOp.setVertSelection LowpolyModel ActiveVertices
				)
			)
			redrawViews()	
		),
		fn createPolygonFromHitVert = 
		(
			polyOp.setVertSelection LowpolyModel #()
			local hitVert = getHitVert()
			if hitVert.count == 0 do return false
			local eVerts = polyOp.getEdgesUsingVert LowpolyModel hitVert
			if eVerts.numberset == 0 do return false
			local openEdges = #()
			for i in eVerts where (polyOp.getFacesUsingEdge LowpolyModel i).numberset == 1 do
			(
				openEdges  += #(i)
			)
			local allVerts  = for i in openEdges collect (polyOp.getVertsUsingEdge LowpolyModel i)
			if allVerts.count == 0 do (print "big error here :)"; return false) -- rene 2.7.2008
			local restVerts = ((allVerts[1] + allVerts[2]) - (allVerts[1] * allVerts[2]))as array
			local theVerts  = #(restVerts[1]) + hitVert + #(restVerts[2])

			undo label:"Create polygon" on
			(
				MarkVert       = #(polyOp.createVert LowpolyModel rayInt.pos)
				polyOp.setVertSelection LowpolyModel MarkVert
				ActiveVertices = MarkVert
				theVerts      += MarkVert
				--format "theVerts:%\tallVerts:%\trestVerts:%\n" theVerts allVerts restVerts
				polyOp.createPolygon LowpolyModel theVerts 
			)
			return true
		),
		fn createPolygonInHitEx =
		(
			polyOp.setVertSelection LowpolyModel #()
			local data         = getHitEdge getRay:true -- get hit edge and ray
			local edge         = data[1]
			local rayEx        = data[2]
			if edge == undefined or rayEx == undefined do return false
			--inicialize hit data		
			local verts = (polyOp.getVertsUsingEdge LowpolyModel edge) as array -- get two verts from hit edge 
			local vPos = for v in verts collect (polyOp.getVert LowpolyModel v)
			--create polygon
			undo label:"create poly" on
			(
				local newVert3 = (polyOp.createVert LowpolyModel vPos[2])
				local newVert4 = (polyOp.createVert LowpolyModel vPos[1])
				ActiveVertices = #(newVert3, newVert4)
				local theVerts = verts + ActiveVertices
				ActivePolygon = try (polyOp.createPolygon LowpolyModel theVerts) catch (undefined) -- create a polygon in place
				polyOp.setVertSelection LowpolyModel ActiveVertices
			)
			if ActivePolygon == undefined do return false
			--collecting data (pos and vectors)
			HitPoints     = polyData old:rayEx[1].pos -- mouse click	
			VertData.pos1 = vPos[1] -- new verts pos
			VertData.pos2 = vPos[2] -- new verts pos
			VertData.v1   = vPos[2] - hitPoints.old -- vector from mouse click
			VertData.v2   = vPos[1] - hitPoints.old -- vector from mouse click
			--format "polygon cerated:%\n" ActivePolygon
			return true
		),
		fn connectVertices =
		(				
			if ActiveVertices.count == 0 do ActiveVertices = (polyOp.getVertSelection LowpolyModel) as array
			if ActiveVertices.count == 0 do return false
			if keyboard.altPressed do return false
			if ActiveVertices.count >= 2 then 
			(
				if ActiveVertices.count > 2 and (vertIsOpen LowpolyModel ActiveVertices) then undo label:"create poly" on
				(
					pushPrompt " Polygon is Created"
					ActivePolygon  = undefined
					ActivePolygon  = (polyOp.createPolygon LowpolyModel ActiveVertices)	
					if ActivePolygon == undefined do return false
					update LowpolyModel
					--checkNormal
					if isFliped() do flipFace()
					polyOp.setVertSelection LowpolyModel #()
					ActiveVertices = #()
				)
				else undo label:"connect verts" on
				(
					pushPrompt " Connect vertices"
					local vr1, vr2
					for i in ActiveVertices do 
					(
						if vr1 == undefined then vr1 = i 
						else if vr2 == undefined do vr2 = i
						if vr1 != undefined and vr2 != undefined do
						(
							polyOp.createEdge LowpolyModel vr1 vr2
							vr1 = vr2
							vr2 = undefined
						)
					)
					polyOp.setVertSelection LowpolyModel #()
					ActiveVertices = #()
				)
			)
			redrawViews()
		),
		fn endToolAction =
		(
			connectVertices() --if chkCreateVerts.checked then 
		),
		--INITIALIZE
		fn initialize =
		(
			--Create highpoly snapshot
			if HipolyModel.isSelected do max select none
			hide (HipolyModelSnp = snapshot HipolyModel name:"Low_Polygon_Wizard_Hp_Snapshot")
			
			--Continue work on user picked lowpoly
			if LowpolyModel != undefined and isValidNode LowpolyModel then 
			(
				select LowpolyModel
			)
			else --Continue on selected model
			if (local obj = selection[1]) != undefined and obj != HipolyModel then 
			(
				if not isCorrectGeometry obj do return false
				LowpolyModel = obj; btnLo.text = LowpolyModel.name 
			) 
			else --Start a new geometry model
			(
				LowpolyModel = createNode() ; LowpolyModel.pivot = HipolyModel.pivot ; btnLo.text = "LP:" +  LowpolyModel.name
			) 
			
			--Define Variables
			ActiveVertices     = #()
			DragVertStep       = false
			DragPolyStep       = false
			SpinEdgeStep       = false
			MarkVert           = #()
			VertData           = polyData()
			PolygonCanceled    = false
			
			--Enable buttons
			btnSelectVerts.enabled  =on
			chkCreateVerts.enabled  =on
			chkMagnet.enabled       =on
			btnFlipFace.enabled     =on
			btnCollapseVerts.enabled=on
			chkStitchEdges.enabled  =on
			chkMiddleCut.enabled    =on
			chkSpinEdge.enabled     =on
			btnRemIsoVerts.enabled  =on
			chkConnect.enabled      =on
			
			registerRedrawViewsCallback showCreationLine
			
			pushPrompt "Welcome to LowPolygon Wizard Tool"
		)
	)
	----------
	-->TOOL<--
	----------
	tool lpWizardTool  --prompt:"Welcome to LowPolygon Wizard Tool" numPoints:4
	( 
		on start do
		(
			
		)
		on mousePoint clickno do
		(			
			--format "breakCount:%\n" breakCount
			--format "clickno:%\n" clickno
			--nodes check
			if drw.isValidModels() then
			(
				--collect point data
				drw.TheViewPoint = viewPoint
				drw.RayP = mapScreenToWorldRay viewPoint
				drw.rayInt = intersectRay drw.HipolyModelSnp drw.RayP	
				--Actions
				if ctrlKey and shiftKey then -- drag vert to crerate polygon
				(
					--print "drag poly vert"
					if clickno == 1 then
					(
						if drw.createPolygonFromHitVert() do
						(
							drw.dragVertStep = true
						)
					)
				)
				else if ctrlKey and altKey then	--duplicate edge to draw polygon			
				(
					--format "DragPolyStep:%\n" drw.DragPolyStep
					if not drw.DragPolyStep then
					(
						if drw.createPolygonInHitEx() do 
						(
							breakCount = 0
							drw.DragPolyStep = true
						)	
					)
				)
				else if altKey and shiftKey then --remove edge				
				(
					drw.removeSegment #edge
					breakCount = 0
					#stop
				)
				else if ctrlKey then --select more elements			
				(
					drw.selectElement multi:on
					breakCount = 0
					#stop
				)
				else if altKey then -- remove vertex
				(
					drw.removeSegment #vert
					breakCount = 0
					#stop
				)
				else if shiftKey then --cut edge
				(
					drw.cutEdge()
					breakCount = 0
					#stop
				)
				else if chkStitchEdges.checked then --stitch edges mode
				(
					drw.stitchEdge()
					breakCount = 0
					#stop
				)
				else if chkCreateVerts.checked and not drw.DragPolyStep and not (altKey or ctrlKey) then --create verts mode
				(
					drw.createVertex()
					breakCount = 0
					#stop
				)
				else if chkMagnet.checked and not drw.DragPolyStep then --magnet each time only one vertex, for now.
				(
					case clickno of
					(
						
						1: --drag start
						(
							drw.MarkVert = drw.getHitVert()
							if drw.MarkVert.count == 1 
							then --select hit vert
							(
								drw.MarkVertPos = polyOp.getVert drw.LowpolyModel drw.MarkVert[1]
								polyOp.setVertSelection drw.LowpolyModel drw.MarkVert
								drw.dragVertStep = true
							)
							else --deselect
							(
								polyOp.setVertSelection drw.LowpolyModel #()
								drw.ActiveVertices = #()
								breakCount = 0
								#stop
							)
						)
						3: --drag end
						(
							if drw.MarkVert.count == 1 do
							(
								local newPos = polyOp.getVert drw.LowpolyModel drw.MarkVert[1]
								polyOp.setVert drw.LowpolyModel drw.MarkVert drw.MarkVertPos
								undo label:"Magnet" on (polyOp.setVert drw.LowpolyModel drw.MarkVert newPos)
								polyOp.setVertSelection drw.LowpolyModel #()
								drw.ActiveVertices = #()
								drw.MarkVert       = #()
								breakCount = 0
								#stop
							)
						)
					)
				)
				else if chkSpinEdge.checked and drw.DragPolyStep then
				(
					if clickno > 3 
					then
					(
						--print "spin end"
						drw.TheAngle = undefined
						drw.SpinEdgeStep = false
						polyOp.setVertSelection drw.LowpolyModel #()
						drw.ActiveVertices = #()
						breakCount = 0
						#stop
					) 
					else 
					(
						--print "collecting spin data"
						drw.collectSpinData()
						drw.SpinEdgeStep = true
					)
				)
				else --deselect
				(
					--print "deselect"
					polyOp.setVertSelection drw.LowpolyModel #()
					drw.ActiveVertices = #()
					breakCount = 0
					#stop
				) 
			)
			else (drw.clear())--nodes check
		)

		on mouseAbort clickno do
		(
			--polygon creation canceled 
			if drw.DragPolyStep then 
			(
				drw.PolygonCanceled = true
			)
		)
		
		on mouseMove clickno do undo off
		(
			if drw.DragVertStep and not drw.DragPolyStep and not ctrlKey then 
			(
				drw.dragVertOnSurface viewPoint
			)
			else if drw.DragPolyStep then
			(
				drw.dragEdgeOnSurface viewPoint
			)
		)
		
		on stop do
		(
			--print "stop"
			--format "PolygonCanceled:%\n" drw.PolygonCanceled
			if drw.PolygonCanceled == undefined do return false --nothing happens (open close tool only)
			if drw.PolygonCanceled do --jestlize polygon neni potvrzen , smazat
			(
				polyOp.deleteVerts drw.LowpolyModel drw.ActiveVertices
				drw.ActiveVertices  = #() 
				drw.ActivePolygon   = undefined
				drw.PolygonCanceled = false
				breakCount = 0	
			)
			drw.DragPolyStep = false
			breakCount += 1
			if breakCount == 2 do drw.endToolAction()
 		)
	) 

	-->Dialog
	on mcLpWizardDialog open            do 
	(
		grp_Title.text = ("Low Polygon Wizard")
		drw            = polyDraw()
	)
	on mcLpWizardDialog close do 
	(
		drw.clear()
		mcFile.saveDialogSettings "mcLpWizardDialog" "Properties_2" 
	)
	on mcLpWizardDialog rbuttonup pos   do 
	(
		mcFile.saveDialogSettings "mcLpWizardDialog" "Properties_2"
		destroyDialog mcLpWizardDialog
	)
	-->MoveMode
	on mcLpWizardDialog lbuttondown pos do(dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcLpWizardDialog lbuttonup pos do(dMove = false; pushprompt "")
	on mcLpWizardDialog mouseMove pos do
	(
		if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcLpWizardDialog DmPos
	)
	-->Start Tool
	on ckbDraw changed state do --begin LPW Tool
	(
		if ckbDraw.checked and drw.isCorrectGeometry drw.HipolyModel do
		(
			drw.initialize()
			while ckbDraw.checked and (not keyboard.escPressed) and breakCount < 3 do
			(
				startTool mcLpWizardDialog.lpWizardTool  --[prompt:<string>] [snap:#3D|#2D] [numPoints:<number>]
			)
		)
		drw.clear()
	)
	--Models
	on btnHi picked obj do --pick hipoly model
	(
		if obj != undefined and drw.isCorrectGeometry obj do 
		(
			drw.HipolyModel = obj
			chkShadeHi.checked = obj.xray
			btnHi.text = "HP:" + obj.name
		)
	)
	on btnLo picked obj do --pick lowpoly model
	(
		if obj != undefined and drw.isCorrectGeometry obj do 
		(
			drw.LowpolyModel   = obj
			chkShadeLo.checked = obj.xray
			btnLo.text = "LP:" +  obj.name
		)
	)
	on chkShadeHi changed state do --seee trough hipoly
	(
		if drw.isCorrectGeometry drw.HipolyModel do
		(
			drw.HipolyModel.xray = chkShadeHi.checked
		) 
	)
	on chkShadeLo changed state do --see trough lowpoly
	(
		if drw.isCorrectGeometry drw.LowpolyModel do
		(
			drw.LowpolyModel.xray = chkShadeLo.checked
		) 
	)
	--Actions
	on chkCreateVerts changed state do --create vertices mode
	(
		if state
		then
		(
			pushPrompt " Creating verts on surface is: ON"
			chkConnect.checked = off
			chkMagnet.checked  = off
		)
		else
		(
			pushPrompt " Creating verts on surface is: OFF"
		)
	)
	on chkMagnet changed state do --magnet mode
	(
		if state 
		then
		(
			pushPrompt " Magnet is: ON"
			chkCreateVerts.checked = off
			chkStitchEdges.checked = off
			chkConnect.checked     = off
		)
		else
		(
			pushPrompt " Magnet is: OFF"
		)
	)
	on btnCollapseVerts pressed do -- collapse verts
	(
		pushPrompt " Collapsing Verts"
		drw.collapseVertices()
	)
	on chkStitchEdges changed state do --collapse edges mode
	(
		if state
		then
		(
			pushPrompt " StitchEdges is: ON"
			chkCreateVerts.checked = off
			chkConnect.checked     = off
			chkMagnet.checked      = off
		)
		else
		(
			pushPrompt " StitchEdges is: OFF"
		)
	)	
	on chkMiddleCut changed state do --enable cut edges in middle
	(
		if state 
		then pushPrompt " MiddleCut is: ON"
		else pushPrompt " MiddleCut is: OFF"
	)
	on btnFlipFace pressed do -- flip face normals
	(
		pushPrompt " Face Fliped"
		drw.flipFace()
	)
	on chkSpinEdge changed state do --spining edge in poly draw mode
	(	
		if state 
		then (registerRedrawViewsCallback   drw.showAngleInScreen ; pushPrompt " SpinEdge is: ON" )
		else (unregisterRedrawViewsCallback drw.showAngleInScreen ; pushPrompt " SpinEdge is: OFF")
	)
	on btnRemIsoVerts pressed do --remove isolated vertices
	(
		Try	
		(
			If SubObjectLevel == undefined then Max Modify Mode
			local A = Filters.GetModOrObj()
			A.buttonOp #RemoveIsoVerts
			drw.ActiveVertices = polyOp.getVertSelection LowpolyModel as array
		)
		Catch(MessageBox "Operation Failed" Title:"Poly Editing")
	)
	on btnSelectVerts pressed do --vertex selection mode
	(
		pushPrompt " Selecting Verts"
		chkCreateVerts.checked = off
		chkStitchEdges.checked = off
		chkConnect.checked     = off
		chkMagnet.checked      = off
	)
	/*
	on chkConnect changed state do -- connect vertices by drag
	(
		if state
		then
		(
			pushPrompt " Connect Mode is: ON"
			chkCreateVerts.checked = off
			chkStitchEdges.checked = off
			chkMagnet.checked      = off
		)
		else
		(
			pushPrompt " Connect Mode is: OFF"
		)
	)
	*/
	on btnHelp pressed do
	(
		local dPos2 = getDialogPos mcLpWizardDialog
		if lpWizardHelpDialog != undefined do destroyDialog lpWizardHelpDialog
		rollout lpWizardHelpDialog "" width:248 height:140
		(
			local dMove = false , DmPos
			groupBox grp1 "Help:" pos:[8,4] width:232 height:128
			label lbl1 "1). Select More Vertiecs: Ctrl + LMB" pos:[20,28] width:212 height:16
			label lbl2 "2). Remove Vertiecs: Alt + LMB" pos:[20,44] width:212 height:16
			label lbl3 "3). Remove Edges: Alt + Shift + LMB" pos:[20,60] width:212 height:16
			label lbl4 "5). Create New Edge: Ctrl + Alt + LMB" pos:[20,92] width:212 height:16
			label lbl5 "4). Create New Vert: Ctrl + Shift + LMB" pos:[20,76] width:212 height:16
			label lbl6 "6). Split Edges Shift + LMB" pos:[20,108] width:212 height:16
			on lpWizardHelpDialog rbuttonup   pos do destroyDialog lpWizardHelpDialog
			-->MoveMode
			on lpWizardHelpDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
			on lpWizardHelpDialog lbuttonup   pos do (dMove = false; pushprompt "")
			on lpWizardHelpDialog mouseMove   pos do
			(
				if dMove and keyboard.shiftPressed do mcDialog.snapDialog lpWizardHelpDialog DmPos
			)
		)
		createDialog lpWizardHelpDialog pos:[dPos2.x, dPos2.y + 90] style:#(#style_border)
	)
)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--
		
mcCall.createXMLDialog "mcLpWizardDialog" "Properties_2"

--oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo--
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--