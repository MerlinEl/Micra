---------------------------------------------------------------------
---------------------------------------------------------------------
--  UV Strip Straightener                                          --
--  version 2.5                                                    --
---------------------------------------------------------------------
--  Simple mapping tool that 'straightens' a strip of polygons.    --
--  Unwrap UVW modifier > Edit UVWs dialog > Mapping menu          --
--  (the macro is not meant to be executed from outside the Edit   --
--  UVWs dialog but it can be from another menu in the dialog)     --
--  Works with all mappable surfaces except patch objects.         --
--  A valid strip is a selection of faces whose topology can be    --
--  seen as a series of quads, all aligned and well connected.     --
--  The tool works on the underlying trimesh topology and ignores  --
--  the current edge visibility.                                   --
--  Written and tested with max 9                                  --
---------------------------------------------------------------------
--  GARP - 2011                                                    --
---------------------------------------------------------------------
---------------------------------------------------------------------


macroScript straightenUVstrip
category:"UVW Unwrap"
internalCategory:"UVW Unwrap"
toolTip:"Straighten UV Strip"
(

	on isEnabled do
	(
		local theObj = selection[1]
		local theMod = modPanel.getCurrentObject()
		if not iskindof theMod UVWUnwrap or theMod.getTVSubObjectMode() != 3 do return false
		
		local oldState = showEndResult
		showEndResult = false
		local isClassOk = classOf theObj == editable_mesh or classOf theObj == polyMeshObject
		showEndResult = oldState	-- (or test for classOf theObj != editable_patch ?)
		isClassOk
		
	)--end on isEnabled
	
	
	on execute do
	(
		rollout rltStraightenUVstrip "Straighten UV Strip"
		(
			checkBox cbAvU "Average Us"
			checkBox cbAvV "Average Vs" across:2
			button btnOk "OK" width:90 align:#right
			checkBox cbNorm "Normalize" across:2
			button btnCancel "Cancel" width:90 align:#right
			
			local theObj
			local theMod = modPanel.getCurrentObject()
			struct stripData (bottom = #(), top = #())
			local theStrip = stripData()
			local isCancelled = false	-- see on close handler
			
			--  shorthands / optimization
			local f2v = meshOp.getMapVertsUsingMapFace
			local v2f = meshOp.getMapFacesUsingMapVert
			local getpos = meshOp.getMapVert
			local setpos = if iskindof theMod UVWUnwrap do theMod.setVertexPosition
			
			-- map channel in current unwrap modifier
			local mCh = if iskindof theMod UVWUnwrap do theMod.getMapChannel()
			
			
			fn buildStrip =
			(
				if mCh == 0 or mCh == 1 do mCh = 1 - mCh	-- legacy problem - see reference
				local fs = getFaceSelection theObj
				if fs.isEmpty do return 1
				
				-- can be quadrified
				local fCount = fs.numberSet
				if mod fCount 2 == 1 do return 2
				
				-- is (possibly) correctly welded
				local vs = f2v theObj mCh fs
				local vCount = vs.numberSet
				if vCount != fCount + 2 do return 3
				
				-- check vert-face associations
				local corners = #()
				local total = 0
				for v in vs do
				(
					local n = (v2f theObj mCh v).numberSet
					if n < 1 or 4 < n do return 4
					if n == 1 do append corners v
					total += n
				)
				if total != 3 * (vCount - 2) do return 5
				if corners.count != 2 do return 6
				
				-- get corner vert used by 1 face closest to (0,0) in current view
				local v1
				local c1 = getpos theObj mCh corners[1]
				local c2 = getpos theObj mCh corners[2]
				case theMod.getUVSpace() of
				(
					1: c1.z = c2.z = 0	--UV
					2: c1.x = c2.x = 0	--VW
					3: c1.y = c2.y = 0	--UW
				)
				if length c1 < length c2 then v1 = corners[1]
				else v1 = corners[2]
				
				-- get 2nd vert of 1st edge
				local v2
				local f = v2f theObj mCh v1
				local va = (f2v theObj mCh f - #{v1}) as array
				if (v2f theObj mCh va[1]).numberSet == 2 then v2 = va[1]
				else if (v2f theObj mCh va[2]).numberSet == 2 then v2 = va[2]
				else return 7
				
				-- build theStrip data (marching through all faces)
				local size = vCount / 2
				append theStrip.bottom v1
				append theStrip.top v2
				
				do
				(
					local f1 = v2f theObj mCh v1 * fs
					local f2 = v2f theObj mCh v2 * fs
					
					if f1.numberSet == 1 and f2.numberSet == 2 then
					(
						v1 = ((f2v theObj mCh f1 - #{v1,v2}) as array)[1]
						f2 -= f1
						v2 = ((f2v theObj mCh f2 - #{v1,v2}) as array)[1]
						append theStrip.bottom v1
						append theStrip.top v2
						fs -= f1 + f2
					)
					else if f2.numberSet == 1 and f1.numberSet == 2 then
					(
						v2 = ((f2v theObj mCh f2 - #{v1,v2}) as array)[1]
						f1 -= f2
						v1 = ((f2v theObj mCh f1 - #{v1,v2}) as array)[1]
						append theStrip.bottom v1
						append theStrip.top v2
						fs -= f1 + f2
					)
					else return 8
				)
				while not fs.isEmpty
				
				-- chech normal orientation in current view
				local p1 = getpos theObj mCh theStrip.bottom[1]
				local p2 = getpos theObj mCh theStrip.bottom[2]
				local p3 = getpos theObj mCh theStrip.top[1]
				case theMod.getUVSpace() of
				(
					1: p1.z = p2.z = p3.z = 0	--UV
					2: p1.x = p2.x = p3.x = 0	--VW
					3: p1.y = p2.y = p3.y = 0	--UW
				)
				if (cross (p2 - p1) (p3-p1)).z < 0 do swap theStrip.bottom theStrip.top
				
				return 0
				
			)--end fn buildStrip
			
			
			on btnOK pressed do
			(
				theMod.breakSelected()	-- if removed, the undo doesn't work! (?!)
				
				local oldState = showEndResult
				showEndResult = false
				
				theObj = selection[1].mesh
		
				stripOK = buildStrip()
				if stripOK != 0 then
				(
					messageBox ("Invalid Strip(" + stripOK as string + ")")
					-- need custom message table indexed by stripOk
					isCancelled = true
				)
				else
				(
					local cnt = theStrip.bottom.count
					local UVWs = #(#(),#())
					UVWs[1][cnt] = 0
					UVWs[2][cnt] = 0
					
					for i = 1 to cnt do
					(
						UVWs[1][i] = getpos theObj mCh theStrip.bottom[i]
						UVWs[2][i] = getpos theObj mCh theStrip.top[i]
					)
					
					-- accounting for current view
					local A, B, C
					local UVcenter
					case theMod.getUVSpace() of
					(
						1: (A = 1; B = 2; C = 3; UVcenter = [0,0.5,0])
						2: (A = 2; B = 3; C = 1; UVcenter = [0,0,0.5])
						3: (A = 1; B = 3; C = 2; UVcenter = [0,0,0.5])
					)
					
					local p1, p2, p3, p4
					local totalU = 0	-- cumulate Us
					local totalV = 0	-- cumulate half Vs
					
					p3 = copy UVWs[1][1]
					p4 = copy UVWs[2][1]
					p3[C] = p4[C] = 0
					UVWs[1][1][A] = UVWs[2][1][A] = 0
					UVWs[1][1][B] = -(totalV = UVWs[2][1][B] = distance p3 p4 / 2)
					
					-- align and keep approx. proportions
					for i = 2 to cnt do
					(
						p1 = p3
						p2 = p4
						p3 = copy UVWs[1][i]
						p4 = copy UVWs[2][i]
						p3[C] = p4[C] = 0
						UVWs[1][i][A] = UVWs[2][i][A] = (totalU += (distance p1 p3 + distance p2 p4) / 2)
						totalV -= UVWs[1][i][B] = -(UVWs[2][i][B] = distance p3 p4 / 2)
					)
					
					-- average lenghts
					if cbAvU.checked do
					(
						local Ustep = totalU / (cnt - 1)
						for i = 2 to cnt do
							UVWs[1][i][A] = UVWs[2][i][A] = (i - 1) * Ustep
					)
					
					-- average widths
					if cbAvV.checked do
					(
						local Vsize = totalV / cnt
						for i = 1 to cnt do
							UVWs[1][i][B] = -(UVWs[2][i][B] = Vsize)
					)
					
					-- normalize only in current view plane
					if cbNorm.checked and totalU != 0 do for i = 1 to cnt do
					(
						UVWs[1][i][A] /= totalU
						UVWs[1][i][B] /= totalU
						UVWs[2][i][A] /= totalU
						UVWs[2][i][B] /= totalU
					)
					
				
					-- dealing with dead vertices
					-- once dead verts are removed, index order is kept
					if theMod.numberVertices != vCount do
					(
						local oldVertSel = theMod.getSelectedVertices()
						local oldFaceSel = theMod.getSelectedFaces()
						theMod.selectFaces #{1..theMod.numberPolygons()}
						theMod.faceToVertSelect()
						local lookUpTable = theMod.getSelectedVertices() as array
						theMod.selectVertices oldVertSel
						theMod.selectFaces oldFaceSel
						for i = 1 to cnt do
						(
							theStrip.bottom[i] = lookUpTable[theStrip.bottom[i]]
							theStrip.top[i] = lookUpTable[theStrip.top[i]]
						)
					)
					
					-- APPLY
					for i = 1 to cnt do
					(
						setpos currentTime theStrip.bottom[i] (UVWs[1][i] + UVcenter)
						setpos currentTime theStrip.top[i] (UVWs[2][i] + UVcenter)
					)
					
				)--end else if stripOk != 0
				
				destroyDialog rltStraightenUVstrip
				showEndResult = oldState
				
			)--end on btnOK pressed
			
			
			on btnCancel pressed do
			(
				destroyDialog rltStraightenUVstrip
				
			)--end on btnCancel pressed
			
			
			on rltStraightenUVstrip close do
			(
				-- to undo theMod.breakSelected()
				if isCancelled do max undo
				
			)--end on rltStraightenUVstrip close
			
			
		)--end rollout rltStraightenUVstrip
		
		local theMod = modPanel.getCurrentObject()
		local dialogPos = [theMod.getWindowX(), theMod.getWindowY() + 42]
		createDialog rltStraightenUVstrip modal:true pos:dialogPos width:220 style:#(#style_toolwindow)
		
	)--end on execute
	
)--end macroScript
