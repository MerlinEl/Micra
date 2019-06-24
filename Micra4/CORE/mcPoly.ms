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
	fn getSource = getSourceFileName(), --get path of this script
	-------------------------------------------------------------
	-------------------------------------------------------------
	------              		GET    	                   ------
	-------------------------------------------------------------
	-------------------------------------------------------------
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
	fn get what = (
	
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
	fn getEdgesFrom vert = (
	
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
	fn getClosestVert obj_poly pos maxDist:undefined = (
	
		local vert, dist = if maxDist != undefined then maxDist else 1e9
		local d, obj_mesh = snapshotasmesh obj_poly
		local verts = #{1..obj_mesh.numverts}
		for v in verts where (d = distance (getvert obj_mesh v) pos) < dist do (
			
			vert = v
			dist = d
		)
		#(vert, dist)
	),
	fn isBorderEdge obj e_index = (
	
		local efaces = polyop.getFacesUsingEdge obj e_index
		efaces.numberset == 1
	),
	fn getBorderEdgesFromVertex obj v_index = (
		
		local edges = polyop.getEdgesUsingVert obj v_index
		for ei in edges where isBorderEdge obj ei collect ei	
	),
	fn getEdgeLength poly_obj edge_index = (
		
        local edge_verts = polyOp.getEdgeVerts poly_obj edge_index
        local verts_pos = for v in edge_verts collect polyOp.getVert poly_obj v
        return (distance verts_pos[1] verts_pos[2])
    ),
	--function getVectorDistance dx dy=
	--(
	--	return sqrt(dx*dx+dy*dy)
	--),
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
	),
	fn getObjectsCenter sel = (
	
		local center = [0,0,0] 
		for o in sel do center += o.pos
		center /= sel.count
		center
	),
	fn getVertsCenter obj verts = (
	
		local center = [0,0,0]
		for v in verts do center += polyop.getVert obj v
		center /= (verts as array).count
		center
	),
	fn getFacesCenter obj faces = (
		
		local center = [0,0,0]
		for f in faces do center += polyop.getFaceCenter obj f
		center /= (faces as array).count
		center
	),
	-------------------------------------------------------------
	-------------------------------------------------------------
	------              		SET    	                   ------
	-------------------------------------------------------------
	-------------------------------------------------------------
	fn alignObjectToTwoPoints obj p1 p2 = (
	
		local dir = normalize (p2 - p1)
		local tm = matrixFromNormal dir
		tm.row4 = (p1 + p2) / 2
		obj.transform = tm 
	),
	fn alignObjectToSelection obj_src = (

		local sel = selection as array
		local obj_trgt = sel[1]
		if obj_trgt == undefined do return false
		case subObjectLevel of (

			0: undo "Align Object To Object(s)" on (
			
				obj_src.pos = if sel.count == 1 then obj_trgt.pos else getObjectsCenter sel
			)
			1: undo "Align Object To Vertex(s)" on (
			
				obj_src.pos = getVertsCenter obj_trgt (polyOp.getVertSelection obj_trgt) 
			)
			2: (
				local obj_trgt = (selection as Array)[1]
				if classOf obj_trgt != Editable_Poly do return false
				local edges = (polyOp.getEdgeSelection obj_trgt) as Array
				if edges.count == 0 do return false
				local everts = (polyOp.getVertsUsingEdge obj_trgt edges[1]) as Array
				local p1 = polyOp.getVert obj_trgt everts[1]
				local p2 = polyOp.getVert obj_trgt everts[2]
				undo "Align Object To Edge" on alignObjectToTwoPoints obj_src p1 p2
			)
			4: undo "Align Object To Face(s)" on (
			
				obj_src.pos = getFacesCenter obj_trgt (polyOp.getFaceSelection obj_trgt) 
			)
			5: undo "Align Object To Face(s)" on (
			
				obj_src.pos = getFacesCenter obj_trgt (polyOp.getFaceSelection obj_trgt) 
			)
		)
	),
	fn selectSimilarFacesByNormal = (
	
		--Select similar faces by normal
		local obj = (selection as array)[1]
		if obj == undefined do return false
		local sel_faces = polyOp.getFaceSelection obj
		local n1 = polyOp.getFaceNormal obj (sel_faces as array)[1]
		local faces_by_normal = #()
		for f=1 to polyop.getNumFaces obj do(

			local n2 = polyOp.getFaceNormal obj f
			local normals_angle = acos(dot n1 n2)-- get the angle between the vectors
			if normals_angle < 2 do faces_by_normal += #(f)
		)
		polyOp.setFaceSelection obj faces_by_normal
	),
	/**
	*@Example 
		roGenStruct.rotateVerticesAroundPoint $ (polyop.getVertSelection $) 20
	*/
	fn rotateVerticesAroundPoint obj verts axis deg center:undefined = (
		
		--if center is not defined, calculate vertex center
		if center == undefined do getVertsCenter obj verts
		local tm = obj.transform --get the node's TM 
		tm.row4 = center  --move the TM to the center
		local rot_mat = ( --roatate TM around axis
		
			case axis of (
				#X: rotateXMatrix deg
				#Y: rotateYMatrix deg
				#Z: rotateZMatrix deg
			) 
		) * tm
		for v in verts do  ( --use TM for each vertex
		
			in coordsys tm vertex_position = (polyop.getVert obj v) 
			polyop.setVert obj v (vertex_position * rot_mat ) 
		)
	),
	fn rotateFacesAroundPoint obj faces axis deg center:undefined = (
	
		--if center is not defined, calculate vertex center
		if center == undefined do getFacesCenter obj faces
		local fverts = polyOp.getVertsUsingFace obj faces
		
		--rotate faces along axis
		for v in fverts do
		(
			local vpos = polyOp.getVert obj v
			local v1 = vpos - center
			local v2 = v1 * ( case axis of (
			
					#X:(quat deg [1,0,0])
					#Y:(quat deg [0,1,0])
					#Z:(quat deg [0,0,1])
				)
			)
			local v3 = v2 + center
			polyOp.setVert obj v v3
		)
	)
	/*<end>*/
)
--create instance
Global mcPoly = mcStructMan.instanceStructure MICRA_POLY "mcPoly"