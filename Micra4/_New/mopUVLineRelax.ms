-------------------------------------------------
-- UV Line Relax script by Paul "MoP" Greveson
-------------------------------------------------
-- email: paul@greveson.co.uk
-- web: http://www.greveson.co.uk
-------------------------------------------------
--
-- Instructions:
--   1. Put this script in your Scripts folder
--   2. Restart 3dsmax
--   3. Look in Customizer User Interface menu
--   4. Add hotkey/menu item for UV Line Relax
--      (Look in MoP's Tools category)
--
-------------------------------------------------

macroScript mopUVLineRelax
category:"MoP's Tools"
buttonText:"UV Line Relax"
tooltip:"UV Line Relax"
(
	( mopUVLineRelaxer ( selection as array ) ).doLineRelax()
)


-- Structure for handling objects and selections to UV Line Relax
struct mopUVLineRelaxer
(
	objs = #(),
	uvLevel = undefined,
	uvMod = undefined,
	uvVertSel = #{},
	uvEdgeSel = #{},
	uvVerts, uvIndex, geoIndex, geoVerts, geoEdges, finalVerts, finalEdges, edgeLengths,
	
	
	-- Make sure we've got some objects we can work with.
	-- TODO: Consider consolidating message box errors for multiple objects instead of popping one up per object.
	fn checkSelection = (
		local result = ( objs.count > 0 )
		for obj in objs do (
			local objClass = classOf obj.baseObject
			if obj.modifiers[#unwrap_uvw] == undefined then (
				format "Error: mopUVLineRelaxer: Selected object '%' had no Unwrap UVW modifier!\n" obj.name
				result = false
			)
			else if objClass != Editable_Poly then (
				messageBox ( "Selected object '" + obj.name + "' is not an Editable Poly object!" ) \
					title:"UV Line Relax" beep:false
				result = false
			)
		)
		result
	),
	
	
	-- Get the UV modifier, but early out if in face mode, it doesn't make sense for this tool.
	-- TODO: Fix cases where we might return the wrong modifier if the object has more than one Unwrap UVW in the stack.
	fn getUVMod obj = (
		uvMod = obj.modifiers[#unwrap_uvw]
		uvLevel = subobjectLevel
		if uvLevel == 3 then (
			messageBox "Please make a selection of vertices or edges." title:"UV Line Relax" beep:false
			uvMod = undefined
		)
		uvMod
	),
	
	
	-- Reselect the initial selection.
	fn resetUVSelection = (
		uvMod.selectEdges uvEdgeSel
		uvMod.selectVertices uvVertSel
		subobjectLevel = uvLevel
	),
	
	
	-- Get current selections, convert and return the UV verts
	fn getUVVertSel = (
		local result = true
		uvVerts = #()
		uvVertSel = uvMod.getSelectedVertices()
		uvEdgeSel = uvMod.getSelectedEdges()
		if uvLevel == 2 then (
			if ( uvMod.getSelectedEdges() ).numberSet > 0 then (
				uvMod.edgeToVertSelect()
				subobjectLevel = 1
			)
		)
		uvVerts = uvMod.getSelectedVertices() as array
		if uvVerts.count < 3 then (
			resetUVSelection()
			local msg = "Please select at least "
			if uvLevel == 1 then msg += "3 UV vertices "
			else if uvLevel == 2 then msg += "2 UV edges "
			messageBox ( msg + "to form a line." ) title:"UV Line Relax" beep:false
			result = false
		)
		result
	),
	
	
	-- Map UV vertices to their geometric vertex counterparts.
	fn mapUVtoGeometry obj = (
		local result = true
		uvIndex = #()
		geoIndex = #()
		geoVerts = #()
		geoEdges = #()
		finalEdges = #()
		for i = 1 to uvVerts.count do with redraw off (
			uvMod.selectVertices ( #( uvVerts[i] ) as bitarray )
			uvIndex[i] = uvVerts[i]
			local geoVert = uvMod.getSelectedGeomVerts() as array
			local geoEdge = ( polyOp.getEdgesUsingVert obj geoVert[1] as array )
			for n in geoEdge do append geoEdges n
			append geoVerts geoVert[1]
			if findItem geoIndex geoVert[1] == 0 then (
				geoIndex[i] = geoVert[1]
			)
		)
		
		-- Get all geometric edges.
		for i in geoEdges do (
			local edgeVerts = polyOp.getEdgeVerts obj i
			if findItem geoVerts edgeVerts[1] != 0 and findItem geoVerts edgeVerts[2] != 0 then (
				if ( findItem finalEdges i == 0 ) then append finalEdges i
			)
		)
		
		-- If finalEdges is greater than uvVerts, it's "cap" geometry.
		if finalEdges.count > uvVerts.count then (
			resetUVSelection()
			messageBox "Cannot perform line relax on the selected geometry." title:"UV Line Relax" beep:false
			result = false
		)
		result
	),
	
	
	-- Get lonely vertices... so sad :(
	fn getLonelyVerts obj = (
		finalVerts = #()
		local removeVerts = #()
		for i in finalEdges do (
			local edgeVerts = polyOp.getEdgeVerts obj i
			for n = 1 to 2 do (
				if findItem finalVerts edgeVerts[n] == 0 then append finalVerts edgeVerts[n]
				else append removeVerts edgeVerts[n]
			)
		)
		
		-- Account for looped selections (2 lonely UV vertices, no lonely geometric vertices).
		if geoVerts.count != finalVerts.count then (
			local tempGeoVerts = deepCopy geoVerts
			for i in finalVerts do (
				deleteItem tempGeoVerts ( findItem tempGeoVerts i )
			)
			append finalVerts tempGeoVerts[1]
		)
		
		-- Get the start and end geometric vertices.
		local lonelyVerts = deepCopy finalVerts
		for i = 1 to removeVerts.count do (
			local test = findItem lonelyVerts removeVerts[i]
			if test != 0 then deleteItem lonelyVerts test
		)
		
		-- Account for looped selections (will only return a single lonely geometric vertex).
		if lonelyVerts.count == 1 then (
			append lonelyVerts lonelyVerts[1]
		)
		lonelyVerts
	),
	
	
	-- Sort the UV and geometry vertex and edge order
	fn orderVerts obj lonelyVerts = (
		local geoVertTest = deepCopy finalVerts
		local geoEdgeTest = deepCopy finalEdges
		local geoVertOrder = #()
		local lastVert = lonelyVerts[1]
		
		-- Get the vertex and edge order.
		edgeLengths = #()
		for i = 1 to finalEdges.count do (
			local vertEdges = polyOp.getEdgesUsingVert obj lastVert
			local del = findItem geoVertTest lastVert
			if del != 0 then deleteItem geoVertTest del
			append geoVertOrder lastVert
			local thisEdge
			for n in vertEdges do (
				if findItem geoEdgeTest n != 0 then thisEdge = n
			)
			local edgeVerts = polyOp.getVertsUsingEdge obj thisEdge as array
			
			-- Assign edge lengths.
			local d = polyop.getVert obj edgeVerts[1] - polyop.getVert obj edgeVerts[2]
			local len = sqrt ( d.x ^ 2 + d.y ^ 2 + d.z ^ 2 )
			edgeLengths[i] = len
			
			deleteItem edgeVerts ( findItem edgeVerts lastVert )
			lastVert = edgeVerts[1]
			deleteItem geoEdgeTest ( findItem geoEdgeTest thisEdge )
		)
		append geoVertOrder lastVert
		
		-- Order the UV vertices correctly.
		local uvVertOrder = #()
		for i = 1 to geoVertOrder.count - 1 do (
			local index = findItem geoIndex geoVertOrder[i]
			append uvVertOrder uvIndex[index]
			deleteItem geoIndex index
			deleteItem uvIndex index
		)
		append uvVertOrder uvIndex[1]
		uvVertOrder
	),
	
	
	-- Calculate the new UV positions, put 'em there.
	fn calculateAndMoveUVs obj uvVertOrder = (
		-- Fix start/end points for looped selections if necessary.
		uvMod.selectVertices #{ uvVertOrder[1] }
		uvMod.expandSelection()
		local check = uvMod.getSelectedVertices() as array
		if findItem check uvVertOrder[2] == 0 then (
			local end = uvVertOrder[1]
			local start = uvVertOrder[uvVertOrder.count]
			uvVertOrder[1] = start
			uvVertOrder[uvVertOrder.count] = end
		)
		
		-- Get the start and end points of the UV selection.
		local start = uvMod.getVertexPosition currentTime uvVertOrder[1]
		local end = uvMod.getVertexPosition currentTime uvVertOrder[uvVertOrder.count]
		
		-- Calculate total length
		local totalLength = 0
		for len in edgeLengths do totalLength += len
		
		-- Calculate the new positions of the UV vertices.
		local xRange = end.x - start.x
		local yRange = end.y - start.y
		local xPos = #()
		local yPos = #()
		local len = 0
		for i = 1 to edgeLengths.count do (
			len += edgeLengths[i]
			local percent = len / totalLength
			xPos[i] = start.x + xRange * percent
			yPos[i] = start.y + yRange * percent
		)
		
		-- Move the UV vertices.
		undo "UV Line Relax" on (
			for i = 1 to edgeLengths.count - 1 do with redraw off (
				uvMod.moveSelected [0.0,0.0,0.0]
				uvMod.selectVertices #{ uvVertOrder[i+1] }
				uvMod.moveX xPos[i]
				uvMod.moveY yPos[i]
			)
		)
		resetUVSelection()
	),
	
	
	-- Do the actual relaxing.
	fn doLineRelax = (
		local result = false
		if checkSelection() then (
			for obj in objs where getUVMod obj != undefined do (
				if getUVVertSel() and mapUVtoGeometry obj then (
					local lonelyVerts = getLonelyVerts obj
					if lonelyVerts.count == 2 then (
						local uvVertOrder = orderVerts obj lonelyVerts
						calculateAndMoveUVs obj uvVertOrder
						result = true
					)
					else (
						resetUVSelection()
						messageBox "Not a valid single line of UVs." title:"UV Line Relax" beep:false
					)
				)
			)
		)
		result
	)
)