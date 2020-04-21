--------------------------------------------------------------------------------
/* gCityManager by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct sCityManager	(
	
	--variables
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn parseXmlTable xml_file = (
		
		if not (doesFileExist xml_file) do return false
		struct ID_DATA (id, sid)
		local xDoc = XMLDocument()			--Create an XMLDcoument
		xDoc.LoadXML xml_file				--Load XML from file
		local rNode = xDoc.GetRootNode()		--Get the Root Node THIS MUST BE CALLED!
		local reindex_items = (rNode.GetChildren())[1].GetChildren() --Get All Reindex Keys
		for itm in reindex_items collect (
			
			local mat_id = execute (itm.GetAttribute "VisualMatIndex")
			local mat_sid = execute (itm.GetAttribute "SemanticMatIndex")
			ID_DATA id:mat_id sid:mat_sid
		)
	),
	fn getObjectIDS obj = (
	
		local mats_id = #{}
		local all_faces = #{1..(polyop.getNumFaces obj)}
		for f in all_faces do (
			
			mats_id += #{polyop.getFaceMatID obj f}	--get unique ids
		)
		mats_id
	),
	fn getFacesByMatID obj mat_id = (
		
		local all_faces = #{1..(polyop.getNumFaces obj)}
		for f in all_faces where polyop.getFaceMatID obj f == mat_id collect f
	),
	fn offsetMaterialsIDs obj object_ids offset:1000 = ( --incerase all materials id by 1000

		for id in object_ids do (
			
			local id_faces = getFacesByMatID obj id
			local offset_id = id+1000
			polyop.setFaceMatID obj id_faces offset_id
		)
	),
	fn getSIDByID xml_data id = (
	
		for itm in xml_data where itm.id == id do return itm.sid
		1 -- else retrun unihard
	),
	/**
	*@Usage > clone an object as new geometry with rotation 
	*/
	fn cloneObject obj suffix = (
		
		if superClassOf obj != GeometryClass do return undefined
		local obj_rotation = mcTransform.getRotation obj --store original object rotation
		local obj_material = obj.material
		obj.material = undefined --remove material (snapshot obj with material generate bad geometry)
		mcTransform.setRotation obj [0,0,0] --reset rotation of clone object
		local tri_mesh = snapshotAsMesh obj --snapshot as TriMesh to memory
		local new_o = Editable_mesh() --create an empty EMesh
		new_o.mesh = tri_mesh --assign TriMesh value to the EMesh
		convertTo new_o Editable_Poly --collapse to EPoly
		delete tri_mesh --free up memory
		new_o.name = obj.name +"_"+ suffix
		new_o.pivot = obj.pivot
		mcTransform.setRotation new_o obj_rotation
		mcTransform.setRotation obj obj_rotation --return original object rotation back
		obj.material = obj_material --return material back
		new_o
	),
	fn getCollisionLayer obj = (
	
		local layer_name = obj.layer.name + "_coll"
		mcMax.getetOrCreateLayer layer_name
	),
	fn getCollisionNode obj = (
	
		local node_name
		if obj.parent != undefined then (
		
			local geometry_node_name = obj.parent.name
			local suffix_geometry_index = findString geometry_node_name "_geometry"
			if suffix_geometry_index != undefined then (
			
				node_name = (subString geometry_node_name 1 suffix_geometry_index) + "coll" 	
				
			) else (
				
				--format "Unable to create collision from [ % ]. Export Node has invalid name [ % ].\n" obj.name obj.parent.name
				gProgLog.msg ("Unable to create collision from [ "+obj.name+" ]. Export Node has invalid name [ "+obj.parent.name+" ].") ty:"error"
				return undefined
			)
		)  else (
			
			-- format "Unable to create collision from [ % ]. Object is not linked to Export Node.\n" obj.name
			gProgLog.msg ("Unable to create collision from [ "+obj.name+" ]. Object is not linked to Export Node.") ty:"error"
			return undefined
		)
		local coll_export_node = getNodeByName node_name
		if coll_export_node == undefined then (
			
			-- format "Unable to create collision from [ % ]. Missing collision node [ % ].\n" obj.name node_name
			gProgLog.msg ("Unable to create collision from [ "+obj.name+" ]. Missing collision node [ "+node_name+" ].") ty:"error"
			undefined
		) else (
			
			coll_export_node
		)
	),
	fn createStairsCollision verts_pos mat_id coll_index coll_layer coll_node mat obj_name= (
	
		new_obj = mcPoly.createPolygonObj verts_pos objName:obj_name
		undo off (
		
			--set material ID
			for f=1 to new_obj.numFaces do ( polyOp.setFaceMatID new_obj f mat_id )
			--add semantic material	
			new_obj.material = mat
			--add collision prameter (Data Manager)
			AddCustomAttributeByName new_obj "CollisionMesh"
			new_obj.'~layer' = coll_index
			coll_layer.addNode new_obj --ad to coll laer
			new_obj.parent = coll_node -- link to coll node
		)
		new_obj
	),
	fn createCarAndPlayerCollisions twoNodes:true = (

		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		local esel = polyOp.getEdgeSelection obj as Array
		if esel.count != 2 do return false
			
		local coll_layer = getCollisionLayer obj
		local coll_export_node = if twoNodes then getCollisionNode obj else obj
		local s_mat = currentMaterialLibrary["semantic_materials"]
		if s_mat == undefined do return (mcMsgList.warn "not_semat")
		if coll_export_node == undefined do return false
		
		SuspendEditing()
		local player_coll = #()
		with redraw off  try(
		
			local esel = polyOp.getEdgeSelection obj
			/*local everts_a = polyOp.getVertsUsingEdge obj (esel as array)[1]
			local everts_b = polyOp.getVertsUsingEdge obj (esel as array)[2]*/
			local everts = polyOp.getVertsUsingEdge obj esel
			local verts_pos = for v in everts collect (polyOp.getVert obj v) 
			local points_center = mcMath.getPointsCenter verts_pos
			--point size:10 pos:points_center wirecolor:red
			local first_v = verts_pos[1] - points_center 
			--presort vertices by center (not works perfect, TODO fix it)
			qsort verts_pos mcPoly.sortVertsByCenter center:points_center p:first_v CW:false
			--FLIP > check if both vectors directing in same way (if not switch)
			local v1 = verts_pos[1] - verts_pos[2]
			local v2 = verts_pos[4] - verts_pos[3]
			--format "dot:%\n" (dot v1 v2)
			if (dot v1 v2) < 0 then ( --swap verts pos in edge
				
				local v = verts_pos[1]
				verts_pos[1] = verts_pos[2]
				verts_pos[2] = v
			)
			--CW to CCV > always sort vertices by CCW
			local normal_angle = cross (verts_pos[1] - verts_pos[2]) (verts_pos[3] - verts_pos[2])
			if normal_angle.z > 0 do verts_pos = mcArray.reverseArray verts_pos
			--format "normal:%\n"	normal_angle
			--visualize + info
			/*local vcolors = #(red, green, blue, yellow)
			local scolors = #("red", "green", "blue", "yellow")
			for i=1 to verts_pos.count do (

				local p1 = verts_pos[i]
				local p2 = if i < verts_pos.count then verts_pos[i+1] else verts_pos[1] --next or first
				local v1 = p1 - points_center
				local v2 = p2 - points_center
				ang = mcMath.getVectorsAngle first_v v1
				format "vectors % - % angle:%\n" scolors[1] scolors[i] ang 

				local te = text size:20 kerning:0 leading:0 pos:p1 wirecolor:vcolors[i]
				te.text = i as string
				te.rotation.x_rotation += 90
				te.rotation.z_rotation -= 90
				mcSpline.drawArrow points_center p1 head_size:4 clr:vcolors[i]
			)*/
			subobjectLevel = 0 --exit from current selection
			local player_name = uniqueName (obj.name+"_stairs_player_coll_")
			local car_name = uniqueName (obj.name+"_stairs_car_coll_")
			player_coll = createStairsCollision verts_pos 100 7  coll_layer coll_export_node s_mat player_name --player
			local car_coll 	= createStairsCollision verts_pos 100 29 coll_layer coll_export_node s_mat car_name	--car

		) catch (ResumeEditing())
		ResumeEditing()
		select player_coll
	),
	fn selectVisibleNodesByName node_name = (
		
		local objs = (for o in objects where not o.isHidden and findString o.name node_name != undefined collect o)
		if objs.count != 0 do select objs
	),
	fn rebuildObject obj = (   

		if (classOf obj != Editable_Poly) then (convertToPoly obj)
		local obj_name = obj.name 
		local obj_layer = obj.layer
		local obj_parent = obj.parent
		local obj_wirecolor = obj.wirecolor
		local obj_pivot = obj.pivot
		local obj_material = obj.material
		obj.name = uniqueName "Object For Delete"
		polyOp.detachFaces obj obj.faces delete:true asNode:true name:obj_name
		select obj --prevent error msg
		if (LS3DGUP.LODU.GetNumLODs()) != 0 do (LS3DGUP.LODU.DestroySet())
		delete obj
		local new_obj = getNodeByName obj_name
		obj_layer.addNode new_obj
		new_obj.parent = obj_parent
		new_obj.wirecolor = obj_wirecolor
		new_obj.pivot = obj_pivot
		new_obj.material = obj_material
		update new_obj
		select new_obj
		new_obj
	),
	fn filterObjectsInstances objs = (
	
		local instanced_collisions_handles = #()
		local unique_instance_objs = #()
		for o in objs do (
		
			if findItem instanced_collisions_handles o.handle do continue --skip object instances
			--check if object is instanced
			local object_instances = #()
			InstanceMgr.GetInstances o &object_instances
			if object_instances.count > 1 do for oi in object_instances do append instanced_collisions_handles oi.handle
			append unique_instance_objs o
		)
		unique_instance_objs
	),
	fn destroyLodsInSelection = (

		local sel = selection as array
		max select none
		for o in sel where superClassOf o == GeometryClass do (

			select o 
			if (LS3DGUP.LODU.GetNumLODs()) != 0 do LS3DGUP.LODU.DestroySet()
		)
	),
	fn addTerrainLodes2AndFixPivot objs = (
	
		if objs.count == 0 do return (mcMsgList.warn "not_sel")
		local geo_objs = for o in objs where findString o.name "lod0" != undefined collect o
		local failed_atempts = 0
		for o in geo_objs do (

			local lod2_name = substituteString (toLower o.name) "lod0" "lod2"
			--format "lod 0:% 2:%\n" o.name lod2_name
			local lod2_obj = getNodeByName lod2_name
			if classOf lod2_obj != Editable_Poly do (

				format "Skip object:% without lod2\n" o.name
				continue
			)
			o.pivot = (o.min + o.max) / 2 --center pivot
			lod2_obj = rebuildObject lod2_obj
			lod2_obj.pivot = o.pivot --copy pivot from orig obj
			--add lod2
			try (
				format "Progress object:% with lod2\n" o.name
				select o
				if (LS3DGUP.LODU.GetNumLODs()) != 0 do (LS3DGUP.LODU.DestroySet())
				LS3DGUP.LODU.CreateSet()
				LS3DGUP.LODU.AddNodesToSet #(lod2_obj)
				LS3DGUP.LODU.SetSelectedLOD 0
				LS3DGUP.LODU.SetDistance 250
			) catch (
			
				failed_atempts += 1
			)
		)
		if failed_atempts > 0 do MessageBox "Some Lods was not aded. See trace log for more details." title:"Warning"
	),
	fn addLodesCustom = (
	

	)
	/*<end>*/
)	
 --create instance
Global gCityManager = mcStructMan.instanceStructure sCityManager "gCityManager"

/*
for o in selection do format "%\n" (o.'~layer')
select (for o in selection where (o.'~layer') == 29 collect o)
select (for o in objects where findString o.name "lod2" != undefined collect o)
*/

/*
obj = $
esel = polyOp.getEdgeSelection obj as Array
everts_a = (polyOp.getVertsUsingEdge obj esel[1] as Array)
everts_b = (polyOp.getVertsUsingEdge obj esel[2] as Array)
vert_1 = polyOp.getVert obj everts_b[2]
vert_2 = polyOp.getVert obj everts_b[1]
vert_3 = polyOp.getVert obj everts_a[2]
vert_4 = polyOp.getVert obj everts_a[1]
v1 = vert_1 - vert_2
v2 = vert_2 - vert_3
--check if both vectors directing in same way
if (dot v1 v2) < 0 then (
	--swap vertices
	v = everts_b[1]
	everts_b[1] = everts_b[2]
	everts_b[2] = v
	vert_1 = polyOp.getVert obj everts_b[2]
	vert_2 = polyOp.getVert obj everts_b[1]
	v1 = vert_1 - vert_2
	v2 = vert_2 - vert_3
) 
--now is both paralel vectors directing in same way
dot v1 v2
verts_pos = #(everts_b[2], everts_b[1], everts_a[2], everts_a[1])

polyop.createPolygon $ verts_pos
update $

v3 = vert_2 - vert_3
cross v1 v3

*/
