Global roadGeneratorCollisionDialog
if roadGeneratorCollisionDialog != undefined do DestroyDialog roadGeneratorCollisionDialog
rollout roadGeneratorCollisionDialog "Road Collision Generator:" width:544 height:88
(
	local title_msg = roadGeneratorCollisionDialog.title
	local generator_struct = "Road_Generator_Struct_v1.12"
	groupBox 'grp1' "Set-Up:" pos:[4,8] width:400 height:72 align:#left
	label 'lbl2' "Collision Layer:" pos:[16,36] width:76 height:16 align:#left
	editText 'edt_coll_layer' "" pos:[96,32] width:292 height:20 align:#left
	label 'lbl1' "Collision Node:" pos:[16,56] width:76 height:16 align:#left
	editText 'edt_coll_node' "" pos:[96,52] width:292 height:20 align:#left
	button 'btn_create_colls' "GENERATE" pos:[408,12] width:132 height:68 align:#left
	checkbox chk_auto "Auto" pos:[100,8] width:44 height:16 toolTip:"Work's also for multiple objects"
/*
Node naming convences
lh_02_little_italy_block_h_roads_geometry
lh_02_little_italy_block_h_roads_coll
*/
	local default_layer_name	= "lh_02_little_italy_roads_coll" 
	local default_node_name	= "lh_02_little_italy_block_h_roads_coll"
	local typed_layer_name	= default_layer_name
	local typed_node_name	= default_node_name
	local collision_wirecolor = color 176 26 26
	local materal_id_offset = 1000 --ofset all mat ID to prevent replacement
	fn matIdToSemanticId id = (
		
		case id of (

			2: 	65  --rails
			3:	52  --cobblestone
			4:	56  --crub
			5: 	50  --road
			6: 	50  --road side
			7:	50  --road tile
			8: 	53  --pavement
			9: 	53	--concrete blocks
			10: 51	--dirt road
			15: 53	--pavement
			16: 53	--pavement
			17: 53	--pavement
			22: 53	--pavement
			23: 50	--damaged road (shortcuts)
			24: 50	--asfalt road / usable for parking spots
			26: 53  --salieris backyard ground
			27:	2 	--universal concrete 1
			28:	2 	--universal concrete tiled 1
			default: 1
		)
	)
	fn runLocalScript script_name = (

		local fpath = getSourceFileName()
		local local_dir = getFilenamePath fpath
		local script_file = local_dir+script_name+".ms"
		if doesFileExist script_file then (
		
			fileIn script_file
			
		) else (
		
			messageBox ("Script ["+script_file+"] Not Found.") title:"Road Generator:"
		)
	)
	fn offsetMaterialsIDs obj offset:1000 = ( --incerase all materials id by 1000
	
		local all_faces = #{1..(polyop.getNumFaces obj)} 
		for f in all_faces do (
			
			local mat_id = polyOp.getFaceMatID obj f
			polyOp.setFaceMatID obj f (mat_id+offset)
		)
	)
	fn getObjectFaces obj = (

		#{1..(obj.getnumfaces())}
	)
	fn getObjectElements obj = (
	
		if classOf obj != Editable_Poly do return #()
		local all_faces = getObjectFaces obj
		local all_elements = #()
		while all_faces.numberset > 0 do (
			
			--if (keyboard.escPressed) do ( throw "ESCAPE PRESSED" )
			--format "all_faces.numberset:% cnt:%\n" all_faces.numberset max_cnt
			obj.SetSelection #Face #{(all_faces as array)[1]} --select next face
			obj.selectElement()
			local fsel = polyOp.getFaceSelection obj
			append all_elements fsel
			all_faces -= fsel
		)
		all_elements
	)
	fn setObjectId obj mat_id = (

		polyop.setFaceMatID obj (getObjectFaces obj) mat_id
	)
	fn setObjectSMG obj smg_index= (

		polyOp.setFaceSmoothGroup obj (getObjectFaces obj) smg_index
	)
	fn scaleEdgeTo obj edge_index val = ( -- val = 1% - 100%
	
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
	)
	fn cloneRoad obj prefix = (
		
		local new_o = copy obj
		new_o.name = uniqueName (prefix+"_"+ obj.name)
		--for c in new_o.children do c.parent = undefined --dont need (a clone have no children)
		 --delete all custom attributes
		for i = custAttributes.count new_o to 1 by -1 do custAttributes.delete new_o i
		--select new_o; custAttributes.count new_o
		new_o
	)
	fn detachRail obj faces = (
		
		--detach,  rename
		local rails_name = uniqueName (obj.name + "_rails")
		polyOp.detachFaces obj faces delete:true asNode:true name:rails_name --node:&obj_rails
		--add collision params
		getNodeByName rails_name
	)
	fn getLongestEdge obj fedges = (

		local edge_data = #(0,0)
		for edge_index in fedges do (

			local everts = polyOp.getEdgeVerts obj edge_index
			local len = distance (polyOp.getVert obj everts[1]) (polyOp.getVert obj everts[2])
			if edge_data[1] < len do (
			
				edge_data[1] = len
				edge_data[2] = edge_index
			)
		)
		edge_data[2]
	)
	fn getShortestEdge obj fedges = (

		local edge_data = #(9999999,0)
		for edge_index in fedges do (

			local everts = polyOp.getEdgeVerts obj edge_index
			local len = distance (polyOp.getVert obj everts[1]) (polyOp.getVert obj everts[2])
			if edge_data[1] > len do (
			
				edge_data[1] = len
				edge_data[2] = edge_index
			)
		)
		edge_data[2]
	)
	fn removeEdges obj fedges = (	

		polyop.setEdgeSelection obj fedges
		local deadVerts = #{}
		local verts = polyop.getVertsUsingEdge obj fedges
		for v in verts do (
			
			local euVert = polyOp.getEdgesUsingVert obj #{v}
			euVert -= fedges
			if (euVert.numberset == 2) or (euVert.numberset == 0) do (append deadVerts v)
		)
		polyOp.setVertSelection obj deadVerts	
		obj.remove selLevel:#edge
		obj.remove selLevel:#vertex
	)
	fn optimizeRails obj = (
	
		local all_elements = getObjectElements obj
		local edges_to_remove = #{}
		for el in all_elements do (
			
			--select longest edge
			local fedges = polyop.getEdgesUsingFace obj el
			local longest_edge = getLongestEdge obj fedges
			if longest_edge == 0 do continue
			polyop.setEdgeSelection obj longest_edge
			--create ring and desetect two edges at each end
			obj.SelectEdgeRing()
			obj.setRingShift -4 false false --shring ring by 4
			obj.setRingShift 2 true false --shift ring by 2
			--select loop loop
			obj.SelectEdgeLoop()
			local ring_edges = polyOp.getEdgeSelection obj
			join edges_to_remove ring_edges
		)
		--remove edges
		undo "Optimize Rails" on (
		
			removeEdges obj edges_to_remove
			setObjectSMG obj 1
		)
		true --if all is ok return true
	)
	fn skewNavmeshRailTop obj = ( --val 1% -- 100%
	
		local all_elements = getObjectElements obj
		for el in all_elements do (
		
			--select shortest edge
			local fedges = polyop.getEdgesUsingFace obj el
			local shortest_edge = getShortestEdge obj fedges
			polyOp.setEdgeSelection obj shortest_edge
			--select top edge
			obj.SelectEdgeLoop()
			obj.setLoopShift -2 true true
			obj.setLoopShift 1 true false
			--get all top edges
			obj.SelectEdgeRing()
			--scale all edges to 90 percent
			local ring_edges = polyOp.getEdgeSelection obj
			for edge_index in ring_edges do scaleEdgeTo obj edge_index 90
		)
	)
	fn generateNavmeshFromRails obj = (
	
		format "generateNavmeshFromRails > obj:%\n" obj.name
		addModifier obj (Push Push_Value:4.5)
		convertToPoly obj
		skewNavmeshRailTop obj
		setObjectId obj 50
		setObjectSMG obj 1
		local collision_layer = LayerManager.getLayerFromName edt_coll_layer.text
		collision_layer.addNode obj
		AddCustomAttributeByName obj "CollisionMesh"
		obj.'~layer' = 4
	)
	fn createRailsCollisions road_coll rail_faces export_coll_node = (
		
		local obj_rails = detachRail road_coll rail_faces
		--format "detach:\n\trails:%\n\tfrom:%\n" obj_rails.name road_coll.name
		optimizeRails obj_rails
		--generate navmesh helper
		local obj_navmesh = copy obj_rails
		generateNavmeshFromRails obj_navmesh
		--set link and collision params
		obj_navmesh.parent = export_coll_node
		obj_navmesh.wirecolor = collision_wirecolor
		--move navmesh in to road collision layer
		road_coll.layer.addNode obj_navmesh
		--attach rails back to instance
		polyOp.attach road_coll obj_rails
	)
	fn getCollisionLayer obj = (
	
		local layer_name = if chk_auto.checked then (obj.layer.name + "_coll") else edt_coll_layer.text
		local collision_layer = LayerManager.getLayerFromName layer_name --pick layer by name
		if collision_layer == undefined do collision_layer = LayerManager.newLayerFromName layer_name --create layer if not exists
		collision_layer
	)
	fn getCollisionNode geometry_obj = (
	
		local node_name = undefined
		if chk_auto.checked then (
		
			if geometry_obj.parent != undefined do (
			
				local geometry_node_name = geometry_obj.parent.name
				local suffix_geometry_index = findString geometry_node_name "_geometry"
				if suffix_geometry_index != undefined then (
				
					node_name = (subString geometry_node_name 1 suffix_geometry_index) + "coll" 	
					--format "node_name:%\n" node_name
				)
			)
		) else (
		
			node_name = edt_coll_node.text
		)
		if node_name == undefined do (
				
			format "Unable to create collision from [ % ] . Object is not linked." geometry_obj.name
			return undefined
		)
		getNodeByName node_name
	)
	fn createRoadsCollisions = (
		
		roGenStruct.All_CALLBACKS_ENABLED = false
		
		local s_mat = meditmaterials["semantic_materials"]
		escapeEnable = true 						--Progress Bar
		progressStart "Grenerating Road Collisions...."	--Progress Bar
		local sel = selection as array
		local progress_total = sel.count
		with redraw off for i=1 to sel.count do (

			if (getProgressCancel()) do exit		--Progress Bar
			local obj = sel[i]
			local collision_layer = getCollisionLayer obj
			local export_coll_node = getCollisionNode obj
			if not isValidNode export_coll_node do (
			
				format "Unable to create collision from [ % ] . Collision Node not exists.\n" obj.name
				continue
			)
			local o_instance = cloneRoad obj "coll"  --create road clone
			o_instance.wirecolor = collision_wirecolor
			o_instance.material = s_mat
			AddCustomAttributeByName o_instance "CollisionMesh"
			o_instance.parent = export_coll_node --link to export collision node
			collision_layer.addNode o_instance --add instance to collision layer
			local rail_faces = #{}
			--for whole object offset ids by 1000 to avoid replacment
			offsetMaterialsIDs o_instance offset:materal_id_offset
			for f=1 to o_instance.numFaces do ( --replace ids with semantic material
				
				local mat_id = polyop.getFaceMatID o_instance f
				local sem_id = matIdToSemanticId (mat_id - materal_id_offset)
				--format "face:% mat_id:% sem_id:%\n" f mat_id sem_id
				polyop.setFaceMatID o_instance f sem_id	
				--if face is rail add to collection
				if sem_id == 65 do rail_faces += #{f}
			)
			--detach rails to separate mesh, optimize and clone to navmesh, transform navmesh
			if rail_faces.numberSet != 0 do (
			
				createRailsCollisions o_instance rail_faces export_coll_node 
			)
			--format "Generated Collisions for:%\n" obj.name
			progressUpdate (progress_total/100.0*i) --Progress Bar
		)
		progressEnd()								--Progress Bar 
		max select none
		
		roGenStruct.All_CALLBACKS_ENABLED = true
		completeRedraw()
	)
	fn init = (
		
		if superClassOf roGenStruct != StructDef do runLocalScript generator_struct
		if superClassOf roGenStruct != StructDef do (
		
			messageBox "Collisions can't be created\n.Unable to find Road Structures." title:title_msg
			destroyDialog roadGeneratorCollisionDialog
		)
		edt_coll_layer.text = default_layer_name
		edt_coll_node.text = default_node_name
	)
	fn setAutoTraceTo state = (
		
		edt_coll_layer.enabled = not state --enable disable writing in to edit box
		edt_coll_node.enabled = not state --enable disable writing in to edit box
		case state of (
			
			true: ( --generate texts from selected node
				
				local obj = selection[1]
				if obj == undefined do return false
				local export_coll_node = getCollisionNode obj
				edt_coll_layer.text = obj.layer.name + "_coll"
				edt_coll_node.text = if export_coll_node != undefined then export_coll_node.name else "undefined"
			)
			false:( --restore previous texts
				
				edt_coll_layer.text = typed_layer_name
				edt_coll_node.text = typed_node_name
			)
		)
	)
	on roadGeneratorCollisionDialog open do init()
	on btn_create_colls pressed  do createRoadsCollisions()
	on chk_auto changed state do setAutoTraceTo state
	on edt_coll_layer changed str do typed_layer_name = str	
	on edt_coll_node changed str do typed_node_name = str
)
CreateDialog roadGeneratorCollisionDialog

/*
rails nav mesh
- clone rails optimized
- push 0.045
- select top edges ring and scale 90%
- collision + layer 4
- sem mat 50

custAttributes.count $
*/

/*
for o in selection do o.parent = $lh_02_little_italy_block_h_roads_coll
--select rails collisions
select(for o in selection where findString o.name "rails" != undefined collect o)
*/

/*
fn exclude4EndEdges obj fedges = (
	
	verts_a = polyOp.getEdgeVerts $ 47
	verts_b = polyOp.getEdgeVerts $ 885
	edges_a = polyOp.getEdgesUsingVert  $ verts_a
	edges_b = polyOp.getEdgesUsingVert  $ verts_b
	edges_a.numberSet
	edges_b.numberSet	
)*/