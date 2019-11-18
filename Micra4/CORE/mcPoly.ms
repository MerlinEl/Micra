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
struct FACE_DATA (index	, ed = #()	, vd = #(),
	
	fn getVertDataByGeoIndex geo_vert_index = (
		
		for d in vd where d.index == geo_vert_index do return d
		undefined
	)
)
struct VERT_DATA (index	, uvVerts = #{}) --faces = #{}, edges = #{}
struct EDGE_DATA (index, uvEdges = #{}) 	--, faces = #{}, edges = #{}
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
	fn getObjectFaces obj = (
	
		if classOf obj != Editable_Poly do return #{}
		#{1..(obj.getnumfaces())}
	),
	fn getObjectElements obj = (
	
		if classOf obj != Editable_Poly do return #()
		local all_faces = getObjectFaces obj
		local all_elements = #()
		while all_faces.numberset > 0 do (
			
			obj.SetSelection #Face #{(all_faces as array)[1]} --select next face
			obj.selectElement()
			local fsel = polyOp.getFaceSelection obj
			append all_elements fsel
			all_faces -= fsel
		)
		all_elements
	),
	fn getLongestEdge obj edges = (

		if classOf obj != Editable_Poly do return undefined
		local edge_data = #(0,0)
		for edge_index in edges do (

			local everts = polyOp.getEdgeVerts obj edge_index
			local len = distance (polyOp.getVert obj everts[1]) (polyOp.getVert obj everts[2])
			if edge_data[1] < len do (
			
				edge_data[1] = len
				edge_data[2] = edge_index
			)
		)
		edge_data[2]
	),
	fn getShortestEdge obj edges = (

		if classOf obj != Editable_Poly do return undefined
		local edge_data = #(9999999,0)
		for edge_index in edges do (

			local everts = polyOp.getEdgeVerts obj edge_index
			local len = distance (polyOp.getVert obj everts[1]) (polyOp.getVert obj everts[2])
			if edge_data[1] > len do (
			
				edge_data[1] = len
				edge_data[2] = edge_index
			)
		)
		edge_data[2]
	),
	fn removeEdges obj edges = (	

		if classOf obj != Editable_Poly do return false
		polyop.setEdgeSelection obj edges
		local deadVerts = #{}
		local verts = polyop.getVertsUsingEdge obj edges
		for v in verts do (
			
			local euVert = polyOp.getEdgesUsingVert obj #{v}
			euVert -= edges
			if (euVert.numberset == 2) or (euVert.numberset == 0) do (append deadVerts v)
		)
		polyOp.setVertSelection obj deadVerts	
		obj.remove selLevel:#edge
		obj.remove selLevel:#vertex
	),
	fn scaleEdgeTo obj edge_index val = ( -- val = 1% - 100%
	
		if classOf obj != Editable_Poly do return false
		local verts = polyOp.getEdgeVerts obj edge_index
		local p1 = polyOp.getVert obj verts[1]
		local p2 = polyOp.getVert obj verts[2]
		local center = (p1+p2)/2
		local len = distance p1 p2
		local mod_dist = len*(val/100.0) 
		local half_dist = mod_dist/2
		local v1 = normalize (p1 - center)
		local v2 = normalize (p2 - center)
		polyOp.setVert obj verts[1] (center+(v1*half_dist))
		polyOp.setVert obj verts[2] (center+(v2*half_dist))
	),
	fn setObjectId obj mat_id = (

		if classOf obj != Editable_Poly do return false
		polyop.setFaceMatID obj (getObjectFaces obj) mat_id
	),
	fn setObjectSMG obj smg_index= (

		if classOf obj != Editable_Poly do return false
		polyOp.setFaceSmoothGroup obj (getObjectFaces obj) smg_index
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
	fn isBorderEdge obj e_index = ( --if edge have one neighbour face is border edge
	
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
	fn getFaceCornerVertices obj face_index = ( --get three vertices from face (1 = corner , 2 = first handle, 3 = second handle)
	
		if not (isPoly obj) do return false
		local face_vertices = polyOp.getVertsUsingFace obj face_index
		if face_vertices.numberset == 3 do return face_vertices as array --is triangle face
		local vertex_index = (face_vertices as array)[1]
		local vetrex_edges = polyOp.getEdgesUsingVert obj vertex_index --two or more edges
		local face_edges = polyop.getEdgesUsingFace obj face_index
		local two_edges = vetrex_edges*face_edges --remove edge(s) whch is not in face
		local edges_verts = polyOp.getVertsUsingEdge obj two_edges
		edges_verts = (edges_verts - #{vertex_index}) as array
		#(vertex_index, edges_verts[1], edges_verts[2])
	),
	/**
	*@Usage	collect geometry data
	*/
	fn getGeometryData obj = (

		if classOf obj != Editable_Poly do return false
		local faces_data = #()
		for face_index = 1 to obj.faces.count do (
			
-- 			format "face:%\n" face_index	
			local face_verts = polyop.getVertsUsingFace obj face_index
			local face_edges = polyop.getEdgesUsingFace obj face_index
			local vd = for vi in face_verts collect VERT_DATA vi --(polyop.getFacesUsingVert obj vi)
			local fd  = for ei in face_edges collect EDGE_DATA ei ---(polyop.getFacesUsingEdge obj ei)
			local fd = FACE_DATA face_index fd vd
			append faces_data fd
		)
		faces_data
	),
	fn geoVertsToMapVerts geo_verts geo_data = (
		
		local uv_verts = #{}
		for v in geo_verts do (
			
			for fd in geo_data do (
				
				local vert_data = fd.getVertDataByGeoIndex v
				--format "vert_data:%\n" vert_data 
				if vert_data != undefined do uv_verts += vert_data.uvVerts
			)
		)
		uv_verts
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
	),
	/**
	*@Author	Martijn(magicm)
	*@Exceptions	negative or non-uniform objects scale
	*@Examples
		mcAction.alignPivotToObject $Box01 $Point01
		mcAction.alignPivotToObject $Box02 (matrix3 1)
	*/
	fn alignPivotToObject src_obj trg_obj = (
		
		-- Get matrix from object
		if classOf trg_obj != matrix3 then trg_obj = trg_obj.transform
		-- Store child transforms
		local ChldTms = in coordSys trg_obj ( for Chld in src_obj.children collect Chld.transform )
		-- Current offset transform matrix
		local TmScale = scaleMatrix src_obj.objectOffsetScale
		local TmRot = src_obj.objectOffsetRot as matrix3
		local TmPos = transMatrix src_obj.objectOffsetPos
		local TmOffset = TmScale * TmRot * TmPos
		-- New offset transform matrix
		TmOffset *= src_obj.transform * inverse trg_obj
		-- Apply matrix
		src_obj.transform = trg_obj
		-- Restore offsets
		src_obj.objectOffsetPos = TmOffset.translation
		src_obj.objectOffsetRot = TmOffset.rotation
		src_obj.objectOffsetScale = TmOffset.scale
		-- Restore child transforms
		for i = 1 to src_obj.children.count do src_obj.children[i].transform = ChldTms[i] * inverse trg_obj * src_obj.transform
	),
	fn alignPivotToFace obj face_index = (
	
		if classOf obj != Editable_Poly or face_index == undefined do return false  
		local face_normal = polyop.getFaceNormal obj face_index
		local face_center = polyop.getFaceCenter obj face_index
		--rotate by face normal
		local rot = (matrixFromNormal face_normal*obj.transform) as quat
		local rotValInv = inverse rot
		animate off in coordsys local obj.rotation*= rotValInv
		obj.objectoffsetrot*=RotValInv
		obj.objectoffsetpos*=RotValInv
		--move pivot ot face center
		obj.pivot = face_center
	),
	/**
	*@Usage >	sort vertices by vectors p - center
		p1 - p2 compare point A with point B
		center 	vertices center
		CW		sort order  false(couter clockwise) true(clockwise)
	*@Example
		qsort verts_pos mcPoly.sortVertsByCenter center:points_center
	*/
	/*fn sortVertsByCenter p1 p2 center:[0,0,0] vect:[0,0,0] CW:true = (

		-- format "sortVertsPos > p1:% p2:%\n" p1 p2
		local a1 = mcMath.getVectorsAngle vect (p1 - center)
		local a2 = mcMath.getVectorsAngle vect (p2 - center)
		format "\ta1:% a2:%\n" a1 a2
		case of (

		 (a1 > a2)	: (if CW then -1 else 1)
		 (a1 < a2)	: (if CW then 1 else -1)
		 default	: 0
		)
	),*/
	fn sortVertsByCenter p1 p2 center:[0,0,0] vect:[0,0,0] CW:true = ( --not works perfect but used as presort for now in City_Manager_Struct.ms

		local a1 = radToDeg ( atan2 (p1.x - center.x) (p1.y - center.y) )
		local a2 = radToDeg ( atan2 (p2.x - center.x) (p2.y - center.y) )
		a1 = mod (a1+360) 360	
		a2 = mod (a2+360) 360	
		case of (

		 (a1 > a2)	: (if CW then -1 else 1)
		 (a1 < a2)	: (if CW then 1 else -1)
		 default	: 0
		)
	),
	-------------------------------------------------------------
	-------------------------------------------------------------
	------              	CREATE   	                   ------
	-------------------------------------------------------------
	-------------------------------------------------------------
	fn createPolygonObj verts_pos obj_name = (

		local new_obj = Editable_mesh()
		undo off (
		
			convertToPoly new_obj
			for p in verts_pos do polyop.createVert new_obj p
			polyop.createPolygon new_obj (for i = 1 to verts_pos.count collect i)
			new_obj.pivot = (new_obj.min + new_obj.max) / 2 --center pivot
			new_obj.name = obj_name
		)
		update new_obj
		new_obj
	),
	/**
	*@Usage > 	detach all faces to create a new object
	*/
	fn rebuildObject obj = (   

		if (classOf obj != Editable_Poly) then (convertToPoly obj)
		local obj_name = obj.name 
		local obj_layer = obj.layer
		local obj_parent = obj.parent
		local obj_wirecolor = obj.wirecolor
		local obj_pivot = obj.pivot
		obj.name = uniqueName "Object For Delete"
		polyOp.detachFaces obj obj.faces delete:true asNode:true name:obj_name
		delete obj
		local new_obj = getNodeByName obj_name
		obj_layer.addNode new_obj
		new_obj.parent = obj_parent
		new_obj.wirecolor = obj_wirecolor
		new_obj.pivot = obj_pivot
		update new_obj
		select new_obj
		new_obj
	),
	-------------------------------------------------------------
	-------------------------------------------------------------
	------              	OTHER    	                   ------
	-------------------------------------------------------------
	-------------------------------------------------------------
	fn printGeometryData geo_data = (
	
		for fd in geo_data do (
		
			format "Face:%\n" fd.index
			for d in fd.vd do (
			
				format "\tVerts:% uvVerts:%\n" d.index d.uvVerts
			)
		)
	)
	/*<end>*/
)
--create instance
Global mcPoly = mcStructMan.instanceStructure MICRA_POLY "mcPoly"



	/*
	fn alignPivotToFace obj face_index way:#up = ( --by miauu (not works)
		  
		local c = polyop.getfacecenter obj face_index
		local n = polyop.getfacenormal obj face_index
		local ftm = translate (matrixfromnormal n) c
		case type of 
		(
			#x_up: prerotateY ftm -90
			#y_up: prerotateX ftm 90
		)

		itm = ftm*(inverse obj.transform)
		obj.transform = ftm
		obj.objectOffsetPos *= inverse itm
		obj.objectOffsetRot *= inverse itm.rotation
		obj.transform
	)
	
	fn alignPivotToSelectedFace = (
	
		local obj = (selection as array)[1]
		if obj == undefined or  classOf obj != Editable_Poly do return false
		local face_index = (polyop.getFaceSelection obj as Array)[1]	 
		if face_index == undefined do return false  
		local face_normal = in coordsys obj  (polyop.getFaceNormal obj face_index) 
		local world_up_vector = [0,0,1] 
		local right_vector = normalize (cross world_up_vector face_normal) 
		local up_vector = normalize ( cross right_vector face_normal )
		local tm = matrix3 right_vector up_vector face_normal [0,0,0] 
		local point_helper=point()
		point_helper.transform = tm
		point_helper.position = polyOp.getFaceCenter obj face_index
		mcAction.alignPivotToObject obj point_helper
		delete point_helper
	)
	*/