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
struct FACE_DATA (index	, ed = #()	, vd = #(), area = 0,
	
	fn getVertDataByGeoIndex geo_vert_index = (
		
		for d in vd where d.index == geo_vert_index do return d
		undefined
	)
)
struct VERT_DATA (index	, uvVerts = #{}) --faces = #{}, edges = #{}
struct EDGE_DATA (index, uvEdges = #{}) 	--, faces = #{}, edges = #{}
/*struct EDGE_LOOP ( --inteligent loop object NOT USED FOR NOW

	obj = undefined,
	edges=#{}, 
	verts=#{},
	fn isNeigbour el = (
		
		local everts = el.verts
		local remain = everts - verts
		remain.numberset < everts.numberset
	),
	fn addToLoop el = (
		
		edges += el.edges
		verts += el.verts
	),
	fn offsetBy offset_xyz = (
	
		for v in verts do (
		
			local vpos = polyOp.getVert obj v
			vpos += offset_xyz
			polyOp.setVert obj v vpos
		)
	),
	fn selectLoop = (

		polyop.setEdgeSelection obj edges
		redrawViews()
	)
)*/
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
	fn getEdgePoints obj edge_index = (
	
		local everts = polyOp.getEdgeVerts obj edge_index
		#(polyOp.getVert obj everts[1], polyOp.getVert obj everts[2])
	),
	fn getEdgeLength obj edge_index = (
	
		local edge_points = getEdgePoints obj edge_index
		distance edge_points[1] edge_points[2]
	),
	fn getEdgeCenter obj edge_index = (
	
		local everts = polyOp.getEdgeVerts obj edge_index
		( (polyOp.getVert obj everts[1]) + (polyOp.getVert obj everts[2]) ) / 2
	),
	fn getLongestEdge obj edges = (

		if classOf obj != Editable_Poly do return undefined
		local edge_data = #(0,0)
		for edge_index in edges do (

			local len = getEdgeLength obj edge_index
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

			local len = getEdgeLength obj edge_index
			if edge_data[1] > len do (
			
				edge_data[1] = len
				edge_data[2] = edge_index
			)
		)
		edge_data[2]
	),
	/**
	*@Usage > Edge Loop Functions
		filter vert edges to return only loop edges
	*/
	fn filterEdgesInLoop obj vert_edges edge_index = (
		
		local edge_faces = polyop.getFacesUsingEdge obj edge_index
		local face_edges = polyop.getEdgesUsingFace obj edge_faces
		((vert_edges -  face_edges) as array)[1] 
	),
	/**
	*@Usage > Edge Loop Functions
	*/
	fn getNextEdgeLoop obj &next_edge &next_vert = (
		
		local edge_verts = polyop.getVertsUsingEdge obj next_edge
		next_vert    = ((edge_verts - #{next_vert}) as Array)[1]
		local vert_edges = polyop.getEdgesUsingVert obj next_vert
		next_edge = filterEdgesInLoop obj vert_edges next_edge
	),
	/**
	*@Usage > Edge Loop Functions
	*/
	fn getPrevEdgeLoop obj &prev_edge &prev_vert = (
		
		local edge_verts = polyop.getVertsUsingEdge obj prev_edge
		prev_vert    = ((edge_verts - #{prev_vert}) as Array)[1]
		local vert_edges = polyop.getEdgesUsingVert obj prev_vert
		prev_edge = filterEdgesInLoop obj vert_edges prev_edge
	),
	/**
	*@Usage > Edge Loop Functions
	*@Example
		local edge_loop = mcPoly.getEdgeLoop obj edge_index --get loop from given edge
	*/
	fn getEdgeLoop obj edge_index = (
			
		if classOf obj != Editable_Poly do return #()
		
		local prev_edge = edge_index
		local next_edge = edge_index
		
		local edge_verts = (polyop.getVertsUsingEdge obj prev_edge as array)
		next_vert  = edge_verts[1]
		prev_vert  = edge_verts[2]
		
		local eloop = #(prev_edge)
		
		--if wee still have progress in one of twoo directions (back - forward)
		while next_edge != undefined or prev_edge != undefined do ( 
			
			--forward step
			if next_edge != undefined do (
				
				getNextEdgeLoop obj &next_edge &next_vert 
				if next_edge != undefined and findItem eloop next_edge == 0 then append eloop next_edge else next_edge = undefined
			)
			--backward step
			if prev_edge != undefined do (
				
				getPrevEdgeLoop obj &prev_edge &prev_vert 
				if prev_edge != undefined and findItem eloop prev_edge == 0 then mcArray.prepend eloop prev_edge else prev_edge = undefined
			)
		)
		eloop
	),
	fn getAngleBetweenTwoEdges obj two_edges asRadians:false = (
	
		--from 2 edges get 4 vertices
		local everts_1 = polyOp.getEdgeVerts obj (two_edges as array)[1] as BitArray
		local everts_2 = polyOp.getEdgeVerts obj (two_edges as array)[2] as BitArray
		--get corner vertices and side vertices
		local center_vert = ((everts_1 * everts_2) as array)[1]  
		local side_verts  = (everts_1 + everts_2) - #{center_vert}
		--get three points
		local center_pos = polyOp.getVert obj center_vert 
		local p1 = polyOp.getVert obj (side_verts as array)[1]
		local p2 = polyOp.getVert obj (side_verts as array)[2]
		local angle_deg = mcMath.getVectorsAngle (p1 - center_pos) (p2 - center_pos)
		if asRadians then mcMath.degTorad angle_deg else angle_deg
	),
	/**
	*@Example
		obj = $
		two_edges = polyOp.getEdgeSelection obj
		eloop = mcPoly.getLoopBetweenTwoEdges obj two_edges
		polyOp.setEdgeSelection obj eloop skipEach:1
		redrawViews()
	*/
	fn getLoopBetweenTwoEdges obj two_edges skipEach:0 = (

		if classOf obj != Editable_Poly or (two_edges as array).count != 2 do return #()
		local first_edge = (two_edges as array)[1]
		local last_edge = (two_edges as array)[2]

		local first_verts = polyOp.getVertsUsingEdge obj first_edge as array
		local last_verts = polyOp.getVertsUsingEdge obj last_edge as array

		local first_pos = for v in first_verts collect polyOp.getVert obj v
		local last_pos = for v in last_verts collect polyOp.getVert obj v
		local cross_point = mcMath.intersectionLineLine first_pos[1] first_pos[2] last_pos[1] last_pos[2]

		polyOp.setEdgeSelection obj first_edge
		obj.setLoopShift 1 true false --forward loop by 1
		local last_edge_a = (polyOp.getEdgeSelection obj as array)[1]
		local dist_a = distance cross_point (mcPoly.getEdgeCenter obj last_edge_a)

		polyOp.setEdgeSelection obj first_edge
		obj.setLoopShift -1 true false --backward loop by 1
		local last_edge_b = (polyOp.getEdgeSelection obj as array)[1]
		local dist_b = distance cross_point (mcPoly.getEdgeCenter obj last_edge_b)

		polyOp.setEdgeSelection obj first_edge 
		--chosse way to follow loop
		local way = if dist_a < dist_b then 1 else -1 --forward or backward loop
		local loop_between = #(first_edge)
		local loop_in_progress = true
		while loop_in_progress and not keyboard.escpressed do (

			obj.setLoopShift way true false --add new edge to current loop
			local next_edge = (polyOp.getEdgeSelection obj as array)[1]
			--check if next loop edfe found and if wee rach last edge
			local reach_end = next_edge == last_edge or findItem loop_between next_edge > 0
			--format "reach_end:% next_edge:%\n" reach_end next_edge
			loop_in_progress = not reach_end
			append loop_between next_edge
		)
		if skipEach > 0 do (
		
			loop_between = for i = 1 to loop_between.count by (skipEach+1) collect loop_between[i]
		)
		loop_between
	),
	/**
	---------------------------TODO--> for Patcher2P_v0.05.ms 
	*@Usage > Vertex Loop Functions
	*/
	/*fn getFirstEdge obj edges vert_a vert_b = (
		
		--vector AB
		local vert_a_pos = polyop.getVert obj vert_a
		local vert_b_pos = polyop.getVert obj vert_b
		local v1 = vert_b_pos - vert_a_pos
		
		--get two border vert edges
		local vedges = polyOp.getEdgesUsingVert obj vert_a
		vedges =  edges * vedges  --remain only two border edges
		--compare angle of each edge
		vedges = vedges as array
		local v2 = getEdgeVector obj vert_a vedges[1] 
		local v3 = getEdgeVector obj vert_a vedges[2] 
		local a1 = getVectorsAngle v1 v2
		local a2 = getVectorsAngle v1 v3
		--return edge with smalest angle
		if a1 < a2 then (
		
			format "last two edges:% final edge:%\n" vedges vedges[1]
			#(vedges[1], getNextVert obj vert_a vedges[1]) 
			
		)else (
		
			format "last two edges:% final edge:%\n" vedges vedges[2]
			#(vedges[2], getNextVert obj vert_a vedges[2])
		)
	),*/
	/**
	*@Usage > Vertex Loop Functions
	*/
	/*fn getNextEdge obj edge_a vert_a edges = (
	
		local vedges = polyOp.getEdgesUsingVert obj vert_a
		vedges *= edges --remain only two border edges
		local edge_b = ((vedges - #{edge_a}) as array)[1] --remove edge_a
		local vert_b = getNextVert obj vert_a edge_b
		#( edge_b, vert_b )  
	),*/
	/**
	*@Usage > Vertex Loop Functions
	*/
	/*fn isLastEdge obj ei vi = (
	
		local verts = (polyOp.getVertsUsingEdge obj ei)	as array	
-- 			format "\tverts:% ei:% vi:%\n" verts ei vi
		verts[1] == vi or verts[2] == vi
	),*/
	/**
	*@Usage > Vertex Loop Functions
	*/
	/*fn getLoopBetweenTwoVertices obj vert_a vert_b = (
	
		local border_edges = polyOp.getOpenEdges obj --get all open edges
		local last_vert = vert_a
		local next_edge_data = getFirstEdge obj border_edges vert_a vert_b
		local loop_vertices = #(vert_a, next_edge_data[2]) --pick next vertex
		for i=1 to border_edges.count do (
		
			next_edge_data = getNextEdge obj next_edge_data[1] next_edge_data[2] border_edges
			append loop_vertices next_edge_data[2]
			if isLastEdge obj next_edge_data[1] vert_b do exit
		)
		loop_vertices
	),*/
	fn deselectObject obj = (
	
		if subobjectLevel != undefined do subobjectLevel = 0 --if is in edit mode then exit first
		deselect obj
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
		--or some day test this
		-- iFlag = bit.set 0 32 true
		-- polyOp.setVertFlags EditPoly baVertToRemove iFlag mask:iFlag undoable:true
		-- EditPoly.remove selLevel:#Vertex flag:iFlag
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
	/**
	*@Usage > create clice on face(s) by two points center and direction
	*@Example
		local fsel = polyOp.getFaceSelection obj
		mcPoly.sliceFacesBy2Points obj fsel start_point split_points
	*/
	fn sliceFacesBy2Points obj fsel start_point split_points = (
	
		if (polyOp.getFaceSelection obj).numberset == 0 do return false
		for p in split_points do (
		
			local plane_ray = (

				local center = (p + start_point) / 2 
				local dir = normalize (p - start_point) --get direction from two points
				dir = cross dir [0,0,1] --rotate dir by 90
				ray center (dir * obj.objectoffsetrot) --get plane ray
			)
			--plane pos:((start_point + p)/2) dir:plane_ray.dir
			polyop.slice obj fsel plane_ray --cut face(s) in plane ray
			fsel = polyOp.getFaceSelection obj --append new faces in to selection
		)
	),
	fn setObjectId obj mat_id = (

		if classOf obj != Editable_Poly do return false
		polyop.setFaceMatID obj (getObjectFaces obj) mat_id
	),
	fn getFacesByIDs obj id_list faces:#{} = (
	
		local faces_list = if faces.numberset != 0 then faces else #{1..obj.faces.count}
		for f in faces_list where findItem id_list (polyop.getFaceMatID obj f) > 0 collect f
	),
		/**
	*@Usage --> convert smg in to bits
	*@Example
		smgs = #{24..25, 31}
		bits = mcPoly.getBitsFromSMG smgs
		--> 1098907648
		or
		smgs = (int((pow 2 smg_index)/2)) --smg to bit conversion
	*/
	fn getBitsFromSMG smgs = (
	
		local bits = 0
		if classOf smgs != Array then (
		
			bits = bit.set 0 smgs True
			
		) else (
		
			for i in smgs do bits = bit.set bits i True
		)
		bits
	),
	/**
	*@Usage --> convert bits in to smg
	*@Example
		bits = bit.set 0 24 True 		--set 24 bit to true
		bits = bit.set bits 25 True	--append 25 bit
		bits = bit.set bits 31 True	--append 31 bit
		smgs = mcPoly.getSMGfromBits bits
		--> #{24..25, 31}
	*/
	fn getSMGfromBits bits = (

		local arr = #{}
		for i = 1 to 32 do (arr[i] = bit.get bits i)
		return arr;
	),
	/**
	*@Usage --> get smooth groups from bit
	*@Example
		bits = bit.set 0 24 True 		--set 24 bit to true
		bits = bit.set bits 25 True	--append 25 bit
		bits = bit.set bits 31 True	--append 31 bit
		faces = polyOp.getFaceSelection $
		mcPoly.setFacesSMG $ faces bits --set SMG 24, 25 and 31
	
	*/
	fn setFacesSMG obj faces smgs add:false = (

		if classOf obj != Editable_Poly do return false
		local bits = mcPoly.getBitsFromSMG smgs
		polyOp.setFaceSmoothGroup obj faces bits add:add
	),
	fn setObjectSMG obj smgs add:false = (

		if classOf obj != Editable_Poly do return false
		setFacesSMG obj (getObjectFaces obj) smgs add:add
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
	/**
	*@Example
		mcPoly.getClosestVert obj [10,10,10] 20
	*/
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
	/**
	*@Usage > when both edges have one comon vertex 
	*/
	fn isNeigbourEdges obj edge_a edge_b = (
		
		local verts_a = polyop.getVertsUsingEdge obj edge_a
		local verts_b = polyop.getVertsUsingEdge obj edge_b
		(verts_a + verts_b).numberset < verts_a.numberset + verts_b.numberset
	),
	/**
	*@Usage > when whole edge is part of a face 
	*/
	fn isEdgeInFace obj edge_index face_index  = (
		
		local faces_verts = polyOp.getVertsUsingFace obj face_index
		local edge_verts  = polyOp.getVertsUsingEdge obj edge_index
		(faces_verts - edge_verts).numberset == faces_verts.numberset - 2
	),
	/**
	*@Usage > when vertex on edge is not connected to other vertices ( ----x---- )
	*/
	fn isOrphanEdgeVert obj vert_index = (
	
		(polyOp.getEdgesUsingVert obj vert_index).numberset < 3
	),
	/* Experimental (make connection on for orphan edge verts)
	fn triangulateVerticesOnEdge obj = (

		local vsel = polyOp.getVertSelection obj
		local faces_for_triangulate = #{}
		for v in vsel where (mcPoly.isOrphanEdgeVert obj v) do (

			local vfaces = (polyOp.getFacesUsingVert obj v as array)
			faces_for_triangulate += vfaces as Bitarray
		)
		polyOp.detachFaces obj faces_for_triangulate delete:true asNode:true name:"Faces_For_Triangulate"
		local obj_tri = getNodeByName "Faces_For_Triangulate"
		local Triangulate = Turn_to_Mesh()
		addModifier obj_tri Triangulate
		Triangulate.useInvisibleEdges = off
		polyOp.attach obj obj_tri
		obj.weldThreshold = 0.001
		polyOp.weldVertsByThreshold obj obj.verts
	)*/
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
	fn getFacesNormal obj faces = ( --Average Normals
		
		local fnormal = [0,0,0]
		for f in faces do fnormal += polyop.getFaceNormal obj f
		normalize fnormal
	),
	fn getLargestFace obj = (
	
		local faces_data = #()
		for f = 1 to obj.faces.count do (
		
			append faces_data (FACE_DATA index:f area:(polyOp.getFaceArea obj f))
		)
		fn sortByArea n1 n2 = if n1.area > n2.area then -1 else if n1.area < n2.area then 1 else 0 
		qsort faces_data sortByArea
		faces_data[1].index
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
	/** TEST
	*@Usage	collect geometry data
		obj		Editable_Poly Object
		faces	add bitarray faces to spped up calculations
	*@Example 
		obj = $
		fsel = polyOp.getFaceSelection obj
		gd = mcPoly.getGeometryData obj faces:fsel
		print gd
	*/
	fn getGeometryData obj faces:#{}= (

		if classOf obj != Editable_Poly do return false
		local faces_data = #()
		if faces.numberset == 0 do faces = #{1..obj.faces.count}
		for face_index in faces do (
			
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
	/** TEST
	*@Example
		obj = $
		geo_faces = polyOp.getFaceSelection obj
		geo_data = mcPoly.getGeometryData obj faces:fsel
		mcPolyMap.collectUnwrapData obj geo_data
		
		geo_verts = polyOp.getVertSelection obj
		mcPoly.geoVertsToMapVerts geo_verts geo_data 
		print geo_data
	*/
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

			undefined : undo "Align Object To Object(s)" on (
			
				obj_src.pos = if sel.count == 1 then obj_trgt.pos else getObjectsCenter sel
			)
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
	/** NOT REALLY WORKS should be replaced with other method like "dot" and "cross" product 
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
	fn createPolygonObj verts_pos objName:"" = (
		
		if verts_pos.count < 3 do return false
		if not (mcMath.isClockwise3P verts_pos[1] verts_pos[2] verts_pos[3]) do verts_pos = reverseArray verts_pos
		format "is clockwise:%\n" (mcMath.isClockwise3P verts_pos[1] verts_pos[2] verts_pos[3])
		local new_obj = Editable_mesh()
		undo off (
		
			convertToPoly new_obj
			for p in verts_pos do polyop.createVert new_obj p
			polyop.createPolygon new_obj (for i = 1 to verts_pos.count collect i)
			new_obj.pivot = (new_obj.min + new_obj.max) / 2 --center pivot
			if objName.count > 0 do new_obj.name = objName
		)
		update new_obj
		new_obj
	),
	/**
	*@Usage > 	detach all faces to create a new object with specific properties
	*@Example
		mcPoly.rebuildObject $
		mcPoly.rebuildObject $ keepMat:false
		mcPoly.rebuildObject $ keepMat:false keepRotation:false
	*/
	fn rebuildObject obj keepMat:true keepRotation:true keepScale:true = (   

		if (classOf obj != Editable_Poly) then (convertToPoly obj)
		local obj_name = obj.name 
		local obj_layer = obj.layer
		local obj_parent = obj.parent
		local obj_wirecolor = obj.wirecolor
		local obj_pivot = obj.pivot
		local obj_material = obj.material
		obj.name = uniqueName "Object_For_Delete"
		polyOp.detachFaces obj obj.faces delete:true asNode:true name:obj_name
		delete obj
		local new_obj = getNodeByName obj_name
		obj_layer.addNode new_obj
		new_obj.parent = obj_parent
		new_obj.wirecolor = obj_wirecolor
		new_obj.pivot = obj_pivot
		if not keepMat do new_obj.material = undefined
		if not keepRotation do WorldAlignPivot new_obj
		if not keepScale do resetScale new_obj
		update new_obj
		select new_obj
		new_obj
	),
	/**
	*@Usage
		cast rays in radius to find surface point
		return Ray
	*/
	fn intersectRayInRadius src_obj trgt_obj start_pos dir rad:5 rays:5 = (
	
		local ir = undefined
		local positions = mcMath.rotatePointAroundCenter start_pos dir rad steps:rays
		for p in positions do (
		
			local ray_top_bottom = Ray p dir
			ir = (IntersectRay trgt_obj ray_top_bottom)
			if ir != undefined do exit
		)
		ir
	),
	/**
	*@Usage
		Snap each vertex from source object in to surface of target object
		src_obj		source object
		trgt_obj	target object
		dir			direction of projected ray (default Z)
		offset		distance from target object surface <--TODO if need
		mbox		true = show warnings in message box, false = in listenner
		debug		true = create points in ray path and print distances
		rad_offset	search for point in radius if not found at first hit	 
	*@Example
		mcPoly.conformToSurface $Plane001 $Sphere001 offset:2 mbox:true
		mcPoly.conformToSurface $ $arking_Temp_Surface offset:0.5 warning:true debug:true
	*/
	fn conformToSurface src_obj trgt_obj dir:[0,0,-1] offset:0 mbox:false debug:false rad_offset:0.5 = (

		if classOf src_obj != Editable_Poly or classOf trgt_obj != Editable_Poly do return (mcMsgList.warn "not_poly_2" mbox:mbox)
		local src_verts_count = polyOp.getNumVerts src_obj 
		for i=1 to src_verts_count do (
			 
			local ray_top_bottom = Ray (polyOp.getVert src_obj i) dir
			local intersection_ray = (IntersectRay trgt_obj ray_top_bottom)
			if intersection_ray == undefined do ( --try to pick surface in radius
			
				local start_pos = polyOp.getVert src_obj i
				intersection_ray = intersectRayInRadius src_obj trgt_obj start_pos dir rad:rad_offset rays:5
			)
			if intersection_ray != undefined do (

				if offset == 0 then (
				
					polyOp.setVert src_obj i intersection_ray.pos
					
				) else (
				
					local p1 = ray_top_bottom.pos
					local p2 = intersection_ray.pos 
					local v1 = normalize (p1 - p2)
					local new_pos = ((v1*offset) + p2)
					if debug do (
					
						point pos:p1 wirecolor:red
						point pos:p2 wirecolor:green
						point pos:new_pos wirecolor:blue
						format "offset:% distance:%\n" offset (distance p2 new_pos)
					)
					polyOp.setVert src_obj i new_pos
				)
			)
		)
	),
	fn unchamferEdges obj edges debug:false = (

		if (classOf obj != Editable_Poly) do return (mcMsgList.warn "not_poly") 
		if (edges.numberset == 0) do return (mcMsgList.warn "not_esel")  
		for ei in edges do (

			local edge_verts = polyOp.getVertsUsingEdge obj ei
			local edge_faces = polyOp.getFacesUsingEdge obj ei
			local verts_pos = for v in edge_verts collect polyOp.getVert obj v
			local edge_center = getEdgeCenter obj ei
			local faces_normal = getFacesNormal obj edge_faces
			local vector_lengtn = distance verts_pos[1] edge_center
			local new_point = edge_center + (faces_normal*vector_lengtn)
			if debug do point pos:new_point wirecolor:green
			for v in edge_verts do polyOp.setVert obj v new_point
		)
	),
	/**
	*@Usage Average Normals is a MAXScript that averages all the vertex normals for each selected faces, 
		so they all point the same direction. On Editable poly, select a face and run the script	
	*/
	fn averageNormals sel = (	

		if classOf sel != Array or sel.count == 0 do return (mcMsgList.warn "not_sel")
		for obj in sel where classOf obj == Editable_Poly do (
			
			local faces = if obj.count == 1 and (subobjectLevel = 4 or subobjectLevel = 5) then (
				
				polyOp.getFaceSelection obj
				
			) else (
				
				#{1..obj.faces.count}
			)
			if not faces.isEmpty do (
					
				local mody = EditNormals name:"AverageNormals" selectBy:3
				addModifier obj mody
				with redraw off for f in faces do (
					
					local normals = #{}
					mody.ConvertFaceSelection #{f} normals
					mody.Reset selection:normals node:obj
					mody.SetSelection normals
					mody.Average selection:normals node:obj
				)
			)
			collapseStack obj
			if sel.count == 1 do subobjectLevel = 4
		)
	),
	/** Not Used
	*@Usage 
		Remove edge to fix mapping and reconect edge back
	*/
	fn fixEdgeMappingFlow obj = (

		local esel = polyOp.getEdgeSelection obj 
		local everts = polyOp.getVertsUsingEdge obj esel
		obj.Remove()
		polyOp.setVertSelection obj everts
		obj.ConnectVertices()
	),
	/**
	*@Usage get sorted vertices from edges
	*/
	fn getChainVertsFromEdges obj edges =(

		local chain_edges = edges
		local esges_count = edges.numberSet
		local everts = (polyop.getVertsUsingEdge obj edges)
		local inner_verts = copy everts
		local sorted_verts = #()
		-- Sort out if it is a closed edge loop
		if (esges_count != everts.numberSet) then (
		
			-- Get chain extreme vertices
			-- The for loop runs through all selected edges, gets their vertices,
			-- then inverts their bit value in the inner_verts bitArray. Each vertex
			-- is inverted two times [true -> false -> true], with the exception
			-- of the extremes, which are inverted only once [true -> false],
			-- taking them away from the bitArray.
			-- Obtain extreme vertices by subtracting inner_verts from all
			-- everts bitArray.
			
			for iEdge in chain_edges do (
			
				local baEdgeVerts = (polyop.getVertsUsingEdge obj iEdge)
				for iVert in baEdgeVerts do
				(
					inner_verts[iVert] = not inner_verts[iVert]
				)
			)
			local baExtremeVerts = (everts - inner_verts)
			-- Choose the extreme vertex to start from to collect vertices.
			-- This determines the direction of the vertices chain collection, but
			-- since it comes from a bitArray, it's quite random.
			local iExtremeStartVert = (baExtremeVerts as Array)[1] -- or [2]
			-- Init array for vertices collection
			sorted_verts = #(iExtremeStartVert)
			-- Init current vertex index
			local iCurrentVert = iExtremeStartVert
			-- Init bitArray of processed edges to avoid walking back in the chain
			local baCrossedEdges = #{}
			-- Collect Vertices
			for i = 1 to esges_count do
			(
				-- do one step
				local baEdgesFromVert = (polyop.getEdgesUsingVert obj iCurrentVert)
				local baStepEdge = ((baEdgesFromVert * chain_edges) - baCrossedEdges)
				
				-- non linear chain error catching
				if (baStepEdge.numberSet == 1) then
				(
					baCrossedEdges += baStepEdge
			
					-- collect the vertex
					local iCurrentVert = (((polyop.getVertsUsingEdge obj baStepEdge) - (sorted_verts as BitArray)) as Array)[1]
					sorted_verts[i+1] = iCurrentVert				
				)
				else
				(
					sorted_verts = #()
					format "Edge Selection is not a linear chain.\n"
					exit
				)
			)
		) else (
			-- Choose a vertex to start the collection
			local iStartVert = (everts as Array)[1]
			-- Init array for vertices collection
			sorted_verts = #(iStartVert)
			-- Init current vertex index
			local iCurrentVert = iStartVert
			-- Init bitArray of processed edges to avoid walking back in the chain
			local iStartEdge = (((polyop.getEdgesUsingVert obj iCurrentVert) * chain_edges) as Array)[1]
			local baCrossedEdges = #{iStartEdge}
			-- Collect Vertices
			for i = 1 to (esges_count - 1) do (
			
				-- do one step
				local baEdgesFromVert = (polyop.getEdgesUsingVert obj iCurrentVert)
				local baStepEdge = ((baEdgesFromVert * chain_edges) - baCrossedEdges)
				-- non linear chain error catching
				if (baStepEdge.numberSet == 1) then (
				
					baCrossedEdges += baStepEdge
					-- collect the vertex
					local iCurrentVert = (((polyop.getVertsUsingEdge obj baStepEdge) - (sorted_verts as BitArray)) as Array)[1]
					sorted_verts[i+1] = iCurrentVert
				)
				else (
				
					sorted_verts = #()
					format "Edge Selection is not a linear chain.\n"
					exit
				)
			)	
		)
		return sorted_verts
	),
	/**
	*@Usage 
		extract face verts alpha values
	*/
	fn getObjectAlphaData obj = (

		local chnl = -2
		struct FACE_ALPHA_DATA (verts = #(), alpha_values=#())
		local faces_data = #()
		for f=1 to obj.faces.count do (

			local map_vers = polyOp.getMapFace obj chnl f
			local face_verts = (polyOp.getFaceVerts obj f) as array
			local alpha_values = for v in map_vers collect int((polyOp.getMapVert obj chnl v)[1]*100)
			--format "(%)map verts:% (%)face verts:% alpha:%\n" map_vers.count map_vers face_verts.count face_verts alpha_values
			append faces_data (FACE_ALPHA_DATA face_verts alpha_values)
		)
		faces_data
	),	
	/**
	*@Usage 
		set face verts alpha values
	*/
	fn setObjectAlphaData obj faces_data = (

		if obj.faces.count != faces_data.count do (

			format "Aborted! Objects must have identical topology.\n"
			return false
		)
		local chnl = -2
		for f=1 to obj.faces.count do with redraw off (

			local alpha_values = faces_data[f].alpha_values
			local map_vers = polyOp.getMapFace obj chnl f
			for i=1 to map_vers.count do (
				
				local col = [1,1,1] * (alpha_values[i] / 100.0)
				--format "set color:%\n" col
				polyOp.setMapVert obj chnl map_vers[i] col
			)
		)
		update obj
		convertToMesh obj
		convertToPoly obj
	),	
	/**
	*@Usage 
		fix imported geometry (from other applications) alpha map(-2)
	*/
	fn fixObjectAlphaMap objs = (
		
		--maybe later add functionality to remember vertices value by vertex pos
		for o in objs where classOf o == Editable_Poly do (
		
			local ad = getObjectAlphaData o
			polyop.defaultMapFaces o -2
			setObjectAlphaData o ad
		)
		completeRedraw()
	),
	/**
	*@Usage 
		extract face verts color values
	*/
	fn getObjectColorData obj = (

		local chnl = 0
		struct FACE_COLOR_DATA (verts = #(), color_values=#())
		local faces_data = #()
		for f=1 to obj.faces.count do (

			local map_vers = polyOp.getMapFace obj chnl f
			local face_verts = (polyOp.getFaceVerts obj f) as array
			local color_values = for v in map_vers collect (polyOp.getMapVert obj chnl v)
			append faces_data (FACE_COLOR_DATA face_verts color_values)
		)
		faces_data
	),	
	/**
	*@Usage 
		set face verts color values
	*/
	fn setObjectColorData obj faces_data = (

		if obj.faces.count != faces_data.count do (

			format "Aborted! Objects must have identical topology.\n"
			return false
		)
		local chnl = 0
		for f=1 to obj.faces.count do with redraw off (

			local color_values = faces_data[f].color_values
			local map_vers = polyOp.getMapFace obj chnl f
			for i=1 to map_vers.count do (
				
				polyOp.setMapVert obj chnl map_vers[i] color_values[i]
			)
		)
		update obj
		convertToMesh obj
		convertToPoly obj
	),	
	/**
	*@Usage 
		fix imported geometry (from other applications) color map(0)
	*/
	fn fixObjectColorMap objs = (
	
		for o in objs where classOf o == Editable_Poly do (
		
			local ad = getObjectColorData o
			polyop.defaultMapFaces o 0
			setObjectColorData o ad
		)
		completeRedraw()
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
	local faces = if obj.modifiers.count == 0 then getFaceSelection obj else (
		
		if matchPattern obj.modifiers[1].name pattern:"*Mesh*" or \
		matchPattern obj.modifiers[1].name pattern:"*Poly*" do getFaceSelection obj obj.modifiers[1]
	)
*/

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