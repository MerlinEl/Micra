
Global mcCollisionOptimizeDialog
if mcCollisionOptimizeDialog != undefined do destroyDialog mcCollisionOptimizeDialog
rollout mcCollisionOptimizeDialog "Geometry Optimizer:" width:328 height:256
(
	local units_type = mcSystem.unitsType()
	GroupBox 'grp1' "Method 1:" pos:[0,4] width:160 height:68 align:#left
	label 'lbl5' "Limited loop by:" pos:[172,164] width:76 height:16 align:#left
	label 'lbl1' "Max length:" pos:[12,24] width:60 height:16 align:#left
	label 'lbl_units_01' "cm" pos:[136,24] width:16 height:16 align:#left
	label 'lbl11' "cm" pos:[136,220] width:16 height:16 align:#left
	label 'lbl12' "cm" pos:[136,106] width:16 height:16 align:#left
	
	button 'btn_flatten_2d' "Flatten Object by Face N" pos:[172,18] width:144 height:24 align:#left
	radioButtons 'rdo_offset_type' "" pos:[168,48] width:152 height:16 labels:#("front", "back", "mid") default:1 columns:3 align:#left
	dotNetControl btn_bounding_box  "Button" text: "Create Bounding Box" pos:[172,70] width:144 height:24 align:#left
	dotNetControl btn_bounding_plane  "Button" text: "Create Bounding Plane" pos:[172,100] width:144 height:24 align:#left
	--button 'btn_projector_2d' "Projector 2D" pos:[172,44] width:144 height:24 align:#left enabled:false

	dotNetControl btn_optimize_chamfers "Button" text: "Optimize by eRing" pos:[8,44] width:144 height:24 align:#left
	dotNetControl btn_fuse_edges "Button" text:"Fuse Edges" pos:[172,200] width:100 height:24 align:#left
	dotNetControl btn_opt_flat "Button" text:"Flatten Top" pos:[172,228] width:144 height:24 align:#left
	dotNetControl btn_unchamfer_edges "Button" text:"Unchamfer eRing" pos:[172,130] width:144 height:24 align:#left
	dotNetControl btn_sel_sim_els "Button" text:"Select Simillar Elements" pos:[8,78] width:144 height:24 align:#left
	dotNetControl 'btn_select_faces_by_normal' "Button" text:"Select Faces By Normal" pos:[8,132] width:144 height:24 align:#left
	dotNetControl 'btn_select_faces_by_thickness' "Button" text:"Select Faces By Thickness" pos:[8,192] width:144 height:24 align:#left
	
	dropDownList ddl_normal_way "" pos:[8,160] width:144 height:21 items:#("fromface", "top", "bottom", "left", "right", "front", "back") align:#left
	
	checkbox chk_wipe "wipe" pos:[280,200] width:60 height:24 align:#left checked:false --enabled:false
	

	button 'btn_opt_loop_by_n' "GO" pos:[288,160] width:28 height:24 align:#left
	spinner 'spn_chamfer_len' "" pos:[72,24] width:60 height:16 range:[0,1e+06,3] type:#float align:#left
	spinner 'spn_lop_each' "" pos:[248,164] width:34 height:16 range:[0,99,1] type:#integer align:#left
	spinner 'spn_face_thickness' "" pos:[8,220] width:120 height:16 range:[0,1e+06,5] type:#float align:#left
	spinner 'spn_area_offset' "" pos:[8,106] width:120 height:16 range:[0,1e+06,10] type:#float align:#left

	--listbox 'lbx_auto_list' "" pos:[8,124] width:144 height:9 enabled:false items:#("Fences", "Curbs") align:#left

	/*fn getTwoEdgesInLoop obj edge_index = (
		
		--get one or two neigbour faces from edge
		local edge_faces = polyop.getFacesUsingEdge obj edge_index
		--get edges used by faces
		local faces_edges = polyOp.getEdgesUsingFace obj edge_faces
		--get two  vertices from edge
		local edge_verts2x = polyop.getVertsUsingEdge obj edge_index
		--get faces from 2 verts
		local vert_faces =  polyop.getFacesUsingVert obj edge_verts2x
-- 		113 = 6 --middle OK
-- 		102 = 3 --end without face OK
-- 		101 = 4 --end with face --Need Condition
		local diff_edges = #{}
		if vert_faces.numberset == 4 then ( --chosse face which have different size of uncommon edge
			
			local f1 = (edge_faces as array)[1]
			local f2 = (edge_faces as array)[2]
			local e1 = polyOp.getEdgesUsingFace obj f1
			local e2 = polyOp.getEdgesUsingFace obj f2
			local uncommon_edges_1 = for ei in e1 where not (mcPoly.isNeigbourEdges obj ei edge_index) collect ei
			local uncommon_edges_2 = for ei in e2 where not (mcPoly.isNeigbourEdges obj ei edge_index) collect ei
			local edge_len = mcPoly.getEdgeLength obj edge_index
			local edge_1_len = mcPoly.getEdgeLength obj (uncommon_edges_1 as array)[1]
			local edge_2_len = mcPoly.getEdgeLength obj (uncommon_edges_2 as array)[1]
			if edge_len - edge_1_len < edge_len - edge_2_len then ( --face 1 edges
				
				diff_edges =  e1 - #{edge_index}
				
			) else ( --face 2 edges
				
				diff_edges = e2 - #{edge_index}
			)
			
		) else (
			
			--get edges from faces
			local vert_faces_edges = polyOp.getEdgesUsingFace obj vert_faces
			--make edges intersection
			diff_edges = vert_faces_edges - faces_edges
		)
		--collect only edges with common vertex to edge_index
		for ei in diff_edges where mcPoly.isNeigbourEdges obj ei edge_index collect ei
	)
	fn unchamferEdges obj  = (

		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly") 
		local edges_ring = polyOp.getEdgeSelection obj
		if edges_ring.numberset == 0 do return (mcMsgList.warn "not_esel")
--		for each edge in ring move vertices to middle (at local)
		local verts_for_weld = #{}
		for next_edge in edges_ring do (
			
			local neighbour_loop_edges = getTwoEdgesInLoop obj next_edge
			local edge_a = neighbour_loop_edges[1]
			local edge_b = neighbour_loop_edges[2]
			
			if 	edge_a == undefined or edge_b == undefined do continue
				
			local verts_a = polyOp.getVertsUsingEdge obj edge_a
			local verts_b = polyOp.getVertsUsingEdge obj edge_b	
			local pos_a = for v in verts_a collect polyOp.getVert obj v
			local pos_b = for v in verts_b collect polyOp.getVert obj v		
			local mid_point = mcMath.intersectionLineLine pos_a[1] pos_a[2] pos_b[1] pos_b[2]	

			local next_verts = polyOp.getVertsUsingEdge obj next_edge
			for v in next_verts do polyOp.setVert obj v mid_point
			verts_for_weld += next_verts
		)
		if verts_for_weld.numberset > 0 do (
			
			obj.weldThreshold = 0.001
			polyOp.weldVertsByThreshold obj verts_for_weld
			polyOp.setEdgeSelection obj #{}
		)
	)*/
	fn selectEachEdgeInLoop obj skip_each = (
	
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly") 
		local two_edges = polyOp.getEdgeSelection obj
		if two_edges.numberset != 2 do return (mcMsgList.warn "not_esel_2")  
		local eloop = mcPoly.getLoopBetweenTwoEdges obj two_edges skipEach:skip_each
		polyOp.setEdgeSelection obj eloop
		redrawViews()
	)
	fn optimizeEdges obj faces max_len = (
	
		obj.weldThreshold = 0.001
		polyOp.weldVertsByThreshold obj obj.verts
		local short_edges = for ei in faces where mcPoly.getEdgeLength obj ei <= max_len collect ei
		if short_edges.count > 0 do (
			
			polyOp.setEdgeSelection obj short_edges
			obj.EditablePoly.collapse #Edge
			obj.EditablePoly.deleteIsoVerts ()
			obj.EditablePoly.DeleteIsoMapVerts ()
		)
	)
	fn optimizeCurbsAndFences sel = (
	
		if sel.count == 0 do return (mcMsgList.warn "not_sel")
		local id_list = #(30, 56)
		local max_len = spn_chamfer_len.value
		if sel.count == 1 do subobjectlevel = 0
		setCommandPanelTaskMode mode:#create
		for o in selection where classOf o == Editable_Poly do (
		
			local faces = mcPoly.getFacesByIDs o id_list
			if faces.count == 0 do continue
			local fedges = polyOp.getEdgesUsingFace o faces
			optimizeEdges o fedges max_len
		)
		setCommandPanelTaskMode mode:#modify
		if sel.count == 1 do subobjectlevel = 4
	)
	fn optimizeChamfers obj = (
		
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		local sel_faces = polyOp.getFaceSelection obj
		if sel_faces.numberset == 0 do sel_faces = #{1..obj.faces.count}
		local max_len = spn_chamfer_len.value
		local fedges = polyOp.getEdgesUsingFace obj sel_faces
		subobjectlevel = 0
		setCommandPanelTaskMode mode:#create
		optimizeEdges obj fedges max_len
		setCommandPanelTaskMode mode:#modify
		subobjectlevel = 4
	)

	fn optimizeCrossroad obj = (
	
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		local vert = (polyOp.getVertSelection obj as array)[1]
		-- local vert_pos = polyOp.getVert obj vert
		if vert == undefined do return (mcMsgList.warn "not_vsel_1")
		local vert_edges = polyOp.getEdgesUsingVert obj vert
		polyOp.setEdgeSelection obj vert_edges
		obj.EditablePoly.SelectEdgeLoop ()
		vert_edges = polyOp.getEdgeSelection obj
		local vert_faces = polyOp.getFacesUsingEdge obj vert_edges
		vert_faces = mcPoly.getFacesByIDs obj #(50) faces:vert_faces
		--polyOp.setFaceSelection obj vert_faces
		--detach crossroad faces for optimize process
		polyOp.detachFaces obj vert_faces delete:true asNode:true name:"Cross_Road_Detached_Faces_For_Optimize_1"
		local road_piece_1 = getNodeByName "Cross_Road_Detached_Faces_For_Optimize_1"
		--get bigest face
		local piece_faces = #{1..road_piece_1.faces.count}
		local bigest_face = mcPoly.getLargestFace road_piece_1 piece_faces
		piece_faces -= #{bigest_face}
		--polyOp.setFaceSelection road_piece piece_faces
		polyOp.detachFaces road_piece_1 piece_faces delete:true asNode:true name:"Cross_Road_Detached_Faces_For_Optimize_2"
		local road_piece_2 = getNodeByName "Cross_Road_Detached_Faces_For_Optimize_2"
		--get initial vert
		vert = (polyOp.getVertSelection road_piece_2 as array)[1]
		--get edges for optimize
		vert_edges = polyOp.getEdgesUsingVert road_piece_2 vert
		polyOp.setEdgeSelection road_piece_2 vert_edges
		road_piece_2.EditablePoly.SelectEdgeLoop ()
		--get vert edges
		vert_edges = polyOp.getEdgeSelection road_piece_2
		--get border edges
		local border_edges = polyOp.getOpenEdges road_piece_2
		local del_edges = vert_edges - border_edges
		::mcPoly.removeEdges road_piece_2 del_edges
		--attach road_pieces back to road
		polyOp.attach road_piece_1 road_piece_2
		polyOp.attach obj road_piece_1
		obj.weldThreshold = 0.001
		polyOp.weldVertsByThreshold obj obj.verts
	)
	/**
	*Usage > Delete all faces except top
	*/
	fn optimizeFlatTop obj = (
	
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		local faces = polyOp.getFaceSelection obj
		if faces.numberset == 0 do return (mcMsgList.warn "not_fsel")
		local del_faces = #()
		for f in faces do (
		
			local n = polyOp.getFaceNormal obj f
			if n.z < 0.8 do append del_faces f
			--format "f:% n:%\n" f n
		)
		if del_faces.count > 0 do (
		
			polyOp.setFaceSelection obj del_faces
			obj.EditablePoly.delete #Face
			redrawViews()
		)
	)
	fn flttenObject obj = (
	
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		local face_index = (polyOp.getFaceSelection obj as array)[1] 
		if face_index == undefined do return (mcMsgList.warn "not_fsel_1")
		local faceNormal = in coordsys obj polyOp.getFaceNormal obj face_index
		local center = [0,0,0]
		for v in obj.verts do center += (polyOp.getVert obj v.index)
		center = center / obj.verts.count
		for v in obj.verts do (

			local planeOffset = (
			
				case rdo_offset_type.state of (
				
					1 : distance center (polyOp.getVert obj v.index)
					2 : -(distance center (polyOp.getVert obj v.index))
					3 : (distance center (polyOp.getVert obj v.index)) /2
				)
			)
			polyop.moveVertsToPlane obj #{v.index} faceNormal planeOffset
		)
	)
	fn createBoundingBox obj = (
	
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		local slev = subobjectlevel
		local fsel = mcPoly.getCurentSelectionAs obj #faces
		if (slev != 4 and slev != 5) or fsel.count == 0 do return (mcMsgList.warn "not_fsel")
		local vsel = mcPoly.getCurentSelectionAs obj #verts
		local sum = [0,0,0]
		local bmin, bmax
		for v in vsel do (
			local p = polyOp.getVert obj v --vert pos				
			sum += p
			if bmin != undefined then (
				
				bmin.x = amin #(p.x, bmin.x)
				bmin.y = amin #(p.y, bmin.y)
				bmin.z = amin #(p.z, bmin.z)

				bmax.x = amax #(p.x, bmax.x)
				bmax.y = amax #(p.y, bmax.y)
				bmax.z = amax #(p.z, bmax.z)
			)
			else bmin = copy (bmax = p)
		)
		--create bounding box at center
		local center = sum/vsel.count
		local bbox = mcPoly.createBoundingBox bmin bmax center (uniqueName "Bounding_Plane") addMaterial:false
		--from obj get material id and normal
		local bigest_face = mcPoly.getLargestFace obj fsel
		local face_mat_id = polyOp.getFaceMatID obj bigest_face
		addModifier bbox (Materialmodifier materialID:face_mat_id) 
		polyOp.attach obj bbox
		subobjectlevel = slev
	)
	fn createBoundingPlane obj = (
	
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		local slev = subobjectlevel
		local fsel = mcPoly.getCurentSelectionAs obj #faces
		if (slev != 4 and slev != 5) or fsel.count == 0 do return (mcMsgList.warn "not_fsel")
		local vsel = mcPoly.getCurentSelectionAs obj #verts
		local sum = [0,0,0]
		local bmin, bmax
		for v in vsel do (
			local p = polyOp.getVert obj v --vert pos				
			sum += p
			if bmin != undefined then (
				
				bmin.x = amin #(p.x, bmin.x)
				bmin.y = amin #(p.y, bmin.y)
				bmin.z = amin #(p.z, bmin.z)

				bmax.x = amax #(p.x, bmax.x)
				bmax.y = amax #(p.y, bmax.y)
				bmax.z = amax #(p.z, bmax.z)
			)
			else bmin = copy (bmax = p)
		)
		--create bounding box at center
		local center = sum/vsel.count
		local bbox = mcPoly.createBoundingBox bmin bmax center (uniqueName "Bounding_Plane") addMaterial:false
		--from obj get material id and normal
		local bigest_face = mcPoly.getLargestFace obj fsel
		local face_normal = polyOp.getFaceNormal obj bigest_face
		local face_mat_id = polyOp.getFaceMatID obj bigest_face
		--on bbox delete all faces except one
		local keep_face = mcPoly.getLargestFace bbox #{1..bbox.faces.count}
		local faces_to_delete = for f in bbox.faces where f.index != keep_face collect f.index
		polyop.deletefaces bbox faces_to_delete
		polyOp.setFaceMatID bbox 1 face_mat_id
		local need_to_flip = dot face_normal (polyOp.getFaceNormal bbox 1) == -1
		--format "dot:% need flip:%\n" (dot face_normal (polyOp.getFaceNormal bbox 1)) need_to_flip
		if need_to_flip do addModifier bbox (Normalmodifier flip:true)
		polyOp.attach obj bbox
		subobjectlevel = slev

		/*local bigest_face = mcPoly.getLargestFace obj fsel
		local face_normal = polyOp.getFaceNormal obj bigest_face
		local face_mat_id = polyOp.getFaceMatID obj bigest_face
		format "larget face:% normal:%\n" bigest_face face_normal
		local keep_face = 1
		local smalest_normal_angle = 9999999999
		for f in bbox.faces do (
		
			local n = polyOp.getFaceNormal obj f.index
			local a = mcMath.getVectorsAngle face_normal n limited:false
			if a < smalest_normal_angle do (
				keep_face = f.index
				smalest_normal_angle = a
			)
		)
		format "smalest angle:%\n" smalest_normal_angle
		local faces_to_delete = for f in bbox.faces where f.index != keep_face collect f.index
		polyop.deletefaces bbox faces_to_delete
		polyOp.setFaceMatID bbox 1 face_mat_id
		local need_to_flip = dot face_normal (polyOp.getFaceNormal bbox 1) == -1
		format "dot:% need flip:%\n" (dot face_normal (polyOp.getFaceNormal bbox 1)) need_to_flip
		if need_to_flip do addModifier bbox (Normalmodifier flip:true)
		polyOp.attach obj bbox
		subobjectlevel = slev*/
	)
	fn selectFacesByThickness = (
		local obj = selection[1]
		if classOf obj == editable_poly do subobjectlevel = 4
		mcPoly.selectFacesWithSmallEdge obj spn_face_thickness.value
	)
	fn init = (
	
		lbl_units_01.text = units_type
		
		mcDotnet.addButtonToolTip btn_opt_flat "Delete other faces than in top." "tltp_flatten_01"
		mcDotnet.addButtonToolTip btn_optimize_chamfers "Remove all rings which have smal length." "tltp_unchamfer_03"
		mcDotnet.addButtonToolTip btn_unchamfer_edges "Remove Chamfer and restore object volume" "tltp_unchamfer_01"
		mcDotnet.addButtonToolTip btn_fuse_edges "Connect edges and remove seam(optional)" "tltp_fuse_edges_01"
		mcDotnet.addButtonToolTip btn_select_faces_by_normal "Select faces with same normal" "tltp_fsel_by_normal_01"
		mcDotnet.addButtonToolTip btn_select_faces_by_thickness "Select faces with same edge thickness" "tltp_fsel_by_tickness_01"
		mcDotnet.addButtonToolTip btn_sel_sim_els "Select elements with simmilar volume" "tltp_fsel_by_size_01"
		mcDotnet.addButtonToolTip btn_bounding_box "Create Bounding Box from selected faces." "tltp_bb_box_01"
		mcDotnet.addButtonToolTip btn_bounding_plane "Create Bounding Plane from selected faces." "tltp_bb_plane_01"

	)
	on mcCollisionOptimizeDialog open do init()
	on btn_opt_flat click do undo label:"Optimize Flat Top " on (optimizeFlatTop (selection as array)[1])
	on btn_optimize_chamfers click  do undo label:"Optimize Chamfers" on (optimizeChamfers (selection as array)[1])
	on btn_unchamfer_edges click  do undo label:"Unchamfer Edges" on (mcPoly.unchamferEdges (selection as array)[1] (polyOp.getEdgeSelection (selection as array)[1]))
	on btn_fuse_edges click  do undo label:"Fuse Edges" on (mcPoly.fuseEdges (selection as array)[1] wipe:chk_wipe.checked)
	on btn_sel_sim_els click  do undo label:"Select simillar Elements" on (mcPoly.selectSimilarElements selection[1] offset:spn_area_offset.value)
	on btn_select_faces_by_normal click  do undo label:"Select Faces By Normal" on (mcPoly.selectFacesByAngle selection[1] ddl_normal_way.selected)
	on btn_select_faces_by_thickness click  do undo label:"Select Faces By Thickness" on selectFacesByThickness()
	on btn_bounding_box click  do undo label:"Create Bounding Plane" on createBoundingBox selection[1]
	on btn_bounding_plane click  do undo label:"Create Bounding Plane" on createBoundingPlane selection[1]
	
	on btn_flatten_2d pressed  do undo label:"Flatten Object" on flttenObject selection[1]
	on btn_projector_2d pressed  do filein (micra.RootDir + "Projector2D_v0.01.ms")
	on btn_opt_curb_and_fences pressed  do undo label:"Optimize Curbs And Fences" on (optimizeCurbsAndFences (selection as array))
	on btn_opt_loop_by_n pressed  do undo label:"Optimize Loop By 2" on (selectEachEdgeInLoop selection[1] spn_lop_each.value)

	on btn_opt_crossroad pressed  do undo label:"Optimize Cross Road " on (optimizeCrossroad selection[1])
	
)
createDialog mcCollisionOptimizeDialog

/*
obj = $
del_edges = #{4..18, 25..39}
--del_edges = polyOp.getEdgeSelection $
--polyOp.setEdgeSelection $ del_edges

for o in selection where classOf o == Editable_Poly do (

	local faces = mcPoly.getFacesByIDs o 50
	local face_verts = 
	for v = 1 to obj.verts.count do (

		local vert_edges = polyOp.getEdgesUsingVert obj v
		if vert_edges.numberset != 37 do continue
		local vert_faces = polyOp.getFacesUsingVert obj v
		polyOp.detachFaces obj vert_faces delete:true asNode:true name:"Cross_Road_Detached_Faces_For_Optimize"
		local road_piece = getNodeByName "Cross_Road_Detached_Faces_For_Optimize"
		::mcPoly.removeEdges road_piece del_edges
		--attach road_piece back to road
		polyOp.attach obj road_piece
	)
)
*/

/*
	fn unchamferEdges obj  = (

		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly") 
		local edges_ring = polyOp.getEdgeSelection obj
		if edges_ring.numberset == 0 do return (mcMsgList.warn "not_esel")
--		for each edge in ring move vertices to middle (at local)
		local verts_for_weld = #{}
		for next_edge in edges_ring do (
			
			polyOp.setEdgeSelection obj next_edge
			obj.setLoopShift 1 true false
			local edge_a = (polyOp.getEdgeSelection obj as array)[1]
			polyOp.setEdgeSelection obj next_edge
			obj.setLoopShift -1 true false
			local edge_b = (polyOp.getEdgeSelection obj as array)[1]	
			
			if 	edge_a == undefined or edge_b == undefined do continue
				
			local verts_a = polyOp.getVertsUsingEdge obj edge_a
			local verts_b = polyOp.getVertsUsingEdge obj edge_b	
			local pos_a = for v in verts_a collect polyOp.getVert obj v
			local pos_b = for v in verts_b collect polyOp.getVert obj v		
			local mid_point = mcMath.intersectionLineLine pos_a[1] pos_a[2] pos_b[1] pos_b[2]	

			local next_verts = polyOp.getVertsUsingEdge obj next_edge
			for v in next_verts do polyOp.setVert obj v mid_point
			verts_for_weld += 	next_verts
		)
		if verts_for_weld.numberset > 0 do (
			
			obj.weldThreshold = 0.001
			polyOp.weldVertsByThreshold obj verts_for_weld
			polyOp.setEdgeSelection obj #{}
		)
	)
*/