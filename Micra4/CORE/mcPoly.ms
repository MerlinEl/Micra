--------------------------------------------------------------------------------
/* mcPoly by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
struct MICRA_POLY
(
	fn isClass arg obj =
	(
		case arg of
		(
			#mod     : getCommandPanelTaskMode() == #modify
			#poly    : classOf obj.baseObject == Editable_Poly
			#modpoly : modPanel.getCurrentObject() == obj.modifiers[#Edit_Poly]
			#inBase  : modPanel.getCurrentObject() == obj.baseobject
			#editable: validModifier obj Edit_Mesh
		)
	),
	fn isPoly obj =
	(
		obj != undefined and classOf obj.baseObject == Editable_Poly or 
		modPanel.getCurrentObject() != undefined and modPanel.getCurrentObject() == obj.modifiers[#Edit_Poly]
	),
	fn isInPoly =
	(
		local mod = Filters.GetModOrObj()
		getCommandPanelTaskMode() == #modify and classOf mod == Editable_Poly or classOf mod == Edit_Poly
	),
	fn isQuads obj faceSel =
	(
		if classOf obj != Editable_Poly and faceSel.count == 0 do return false
		for f in faceSel where (polyOp.getVertsUsingFace obj.baseobject f).numberSet != 4 do return false
		return true
	),
	fn intersectionExists obj =
	(
		local objBase = obj.baseobject
		local edgesBA = #{}
		local intEdges = #{}
		for i in (polyOp.getFaceSelection objBase) do
		(
			local faceEdges = polyOp.getEdgesUsingFace objBase i
			for f in faceEdges do
			(
				if (findItem edgesBA f) == 0 then
				(
					append edgesBA f
				)
				else
				(
					append intEdges f
				)
			)
		)
		intEdges
	),
	fn getEdgesFrom vert =
	(
		local edge = 1
		local step = 1 
		local edges = #{}
		while edge != 0 do 
		(
			edge = (modPanel.getCurrentObject()).GetVertexEdge vert step
			append edges edge 
			step +=1
		)
		
		return edges
	),
	fn getVertsFrom edge =
	(
		local vert = 1
		local step = 1 
		local verts = #{}
		while vert != 0 do 
		(
			vert = (modPanel.getCurrentObject()).GetEdgeVertex edge step
			append verts vert 
			step +=1
		)
		return verts
	),
	fn getEdgeLength obj edge =
	(
		local my_verts = polyOp.getVertsUsingEdge obj edge as array
		return distance (polyOp.getVert obj my_verts[1]) (polyOp.getVert obj my_verts[2])
		
	),
	--function getVectorDistance dx dy=
	--(
	--	return sqrt(dx*dx+dy*dy)
	--),
	fn get what =
	(
		local obj = selection[1]
		if obj == undefined do return #()
		local enabled = 
		(
			mcPoly.isClass #mod obj and (mcPoly.isClass #modPoly obj or mcPoly.isClass #poly obj and mcPoly.isClass #inBase obj)
		)
		local gco = modPanel.getCurrentObject()
		case what of
		(
			--VertSelection
			#vSel:   if enabled then (try (gco.getSelection #Vertex as array) catch #()) else #()
			--EdgeSelection
			#eSel:   if enabled then (try (gco.getSelection #Edge   as array) catch #()) else #()
			--FaceSelection
			#fSel:   if enabled then (try (gco.getSelection #Face   as array) catch #()) else #()
			--VertsUsingEdge
			#vuEdge: if enabled then (try((polyOp.getVertsUsingEdge obj (mcPoly.get #eSel)) as array) catch #()) else #()
			--VertexUsingFace
			#vuFace: if enabled then (try((polyOp.getVertsUsingFace obj (mcPoly.get #fSel)) as array) catch #()) else #()
			--EdgesUsingVert
			#euVert: if enabled then (try((polyOp.getEdgesUsingVert obj (mcPoly.get #vSel)) as array) catch #()) else #()
			--EdgesUsingFace
			#euFace: if enabled then (try((polyOp.getEdgesUsingFace obj (mcPoly.get #fSel)) as array) catch #()) else #()
			--FaceUsingVert
			#fuVert: if enabled then (try((polyOp.getFacesUsingVert obj (mcPoly.get #vSel)) as array) catch #()) else #()
			--FaceUsingEdge
			#fuEdge: if enabled then (try((polyOp.getFacesUsingEdge obj (mcPoly.get #eSel)) as array) catch #()) else #()
			--Selected objects
			#oSel:    selection as array
			--All objects in scene
			#obj:     objects   as array
		)
	),
	fn getHitNode =
	(
		local view_mouse_pos = mouse.pos --get current mouse pos based on active view pos
		local view_size = getViewSize() --get active viewport size
		-- if mouse is out of viewport
		if view_mouse_pos.x < 0 or view_mouse_pos.x > view_size.x or
		view_mouse_pos.y < 0 or view_mouse_pos.y > view_size.y do return undefined
		-- cast ray from mouse point in to scene
		local iray = (mapScreentoWorldRay mouse.pos) --ray <pos> <dir>
		-- get visible nodes on ray path
		local hit_nodes = for n in (intersectRayScene iray) where not n[1].isHidden collect #(n[1], n[2], distance iray.pos n[2].pos)
		if hit_nodes.count == 0 do return undefined -- if nothing found
		-- sort nodes by distance
		fn sortByHitDistance n1 n2 = if n1[3] < n2[3] then -1 else if n1[3] > n2[3] then 1 else 0 
		qsort hit_nodes sortByHitDistance
		return hit_nodes[1][1] --return node or undefined
	),
	fn getHitFace node =
	(
		if classOf node != Editable_Poly do return false
		local meshObj
		hide (meshObj = snapshot obj)
		local theRay=mapScreenToWorldRay mouse.pos
		local hitRay=intersectRayEx meshObj theRay	
		delete meshObj
		return hitRay
	)
)
--create instance
Global mcPoly = Micra.instanceStructure MICRA_POLY "mcPoly"