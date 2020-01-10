--------------------------------------------------------------------------------
/* mcPolyMap by Orien 2019 */
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
struct UV_ELEMENTS (faces=#{}, area=0)
struct MICRA_POLY_MAP_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn isValidMod = ( classOf (modpanel.getcurrentobject()) == Unwrap_UVW ),
	fn getNumUVChannels obj debug:false = (

		if classof obj != Editable_Poly and classof obj != PolyMeshObject do return 0
		local cnt = 0
		if debug do format "Object [ % ] Channels:\n" obj.name
		for i = 0 to (polyOp.getNumMaps obj) - 1 do (

			if polyOp.getMapSupport obj i then (
			
				if debug do format "\t%\n" i
				cnt+=1
			)
		)
		cnt
	),
	/**
	*@Example
		mcPolyMap.clearChannels $ 10
		for o in selection do mcPolyMap.clearChannels o 10
	*/
	fn clearChannels obj indexTo =
	(
		if subobjectLevel != undefined do subobjectLevel = 0; max create mode; --speed up
		if superclassof obj != GeometryClass then return false
		for i = 99 to indexTo by -1 do with redraw off (
		
			ChannelInfo.ClearChannel obj i 
		)
		maxOps.CollapseNodeTo obj 1 off
	),
	/** Not WORKS (only deleting data not channels use > clearChannels)
	*@Example
		mcPolyMap.clearMapChannels selection except:#{1..10}
	*/
	/*fn clearMapChannels objs except:#{0..10} = (

		for o in objs do (
		
			if superclassof o != GeometryClass do (
			
				format "Skip Object: [ % ]. Must be Geometry Class\n" o.name
				continue
			)
			for i = (polyOp.getNumMaps o) - 1 to 1 by -1 do ( --never delete Zero channel

				if polyOp.getMapSupport o i and (findItem except i == 0) do (

					channelInfo.ClearChannel o i
				)
			)
			maxOps.CollapseNodeTo o 1 off
		)
	),*/
	fn mapPlanar obj alignTo:#x collapseMod:true = (
		
		local mod_uvw = Uvwmap ()
		mod_uvw.maptype = case alignTo of (#x:0; #y:1; #z:2; default:0)
		mod_uvw.axis = 2
		mod_uvw.realWorldMapSize = off
		mod_uvw.utile = mod_uvw.vtile = mod_uvw.wtile =1
		mod_uvw.channel = 0
		addModifier obj mod_uvw
		if collapseMod do maxOps.CollapseNode obj off
	),
	/**
	*@Usage
		mcPolyMap.convetrSelectionTo (modpanel.getcurrentobject()) #verts
	*/
	fn convetrSelectionTo mod_uvw type = (
	
		if classOf  mod_uvw!= Unwrap_UVW do return false
		local lvl = subobjectLevel
		case type of
		(	
			#verts: (
				-- subobjectLevel = 1
				(if lvl == 3 then mod_uvw.faceToVertSelect() else if lvl == 2 do mod_uvw.edgeToVertSelect())
			)
			#edges:(
				-- subobjectLevel = 2
				(if lvl == 3 then mod_uvw.faceToEdgeSelect() else if lvl == 1 do mod_uvw.vertToEdgeSelect())
			)
			#faces:(
				-- subobjectLevel = 3
				(if lvl == 2 then mod_uvw.edgeToFaceSelect() else if lvl == 1 do mod_uvw.vertToFaceSelect())
			)
		)
	),
	fn getCurentSelectionAs mod_uvw type = ( --conver selection to desired type and return as array
		
		if classOf mod_uvw != Unwrap_UVW do return #()
		if (convetrSelectionTo mod_uvw type == false) do return #()
		case type of (
		
			#verts: mod_uvw.getSelectedVertices() as Array
			#edges: mod_uvw.getSelectedEdges() as Array
			#faces: mod_uvw.getSelectedFaces() as Array	
		)
	),
	fn getSelectedUvsBB mod_uvw = (

		if classOf mod_uvw != Unwrap_UVW do return undefined
		local sel_verts = getCurentSelectionAs mod_uvw #verts 
		local vertices_pos = for i in sel_verts collect (mod_uvw.getVertexPosition 0 i)
		-- Get left/lower limit and right/upper limit
		local min_pos = copy vertices_pos[1] 
		local max_pos = copy vertices_pos[1]
		for p in vertices_pos do (
			
			if p.x < min_pos.x do min_pos.x = p.x
			if p.y < min_pos.z do min_pos.y = p.y

			if p.x > max_pos.x do max_pos.x = p.x
			if p.y > max_pos.z do max_pos.y = p.y

		)
		if min_pos == undefined or max_pos == undefined do return undefined
		-- format "min:% max:%\n" min_pos max_pos
		mcRect min_pos max_pos
	),
	fn selectBorder = (
	
		if not (isValidMod()) do return (mcMsgList.warn "not_unwrap")
		if subobjectLevel != 2 do return false
		local gco = modpanel.getcurrentobject()
		gco.openEdgeSelect()
	),
	fn packInPlace = ( --Not used yet
	
		if not (isValidMod()) do return (mcMsgList.warn "not_unwrap")
		local gco = modpanel.getcurrentobject()
		local sel_center = gco.getSelCenter()
		local sel_faces = gco.getSelectedFaces()
		if sel_faces.numberset < 2 do return false
		local excluded_faces = #()
		for i in sel_faces do (
		
			if findItem excluded_faces i  != 0 do continue
			-- format "fcount:%\n" sel_faces.numberset
			gco.SelectFaces #{i}
			gco.selectElement()
			gco.MoveSelected (sel_center - (gco.getSelCenter()) )
			excluded_faces += gco.getSelectedFaces()
		)
	),
	fn resizeUVW mod_uvw val axis = (
	
		axis = case axis of (
		
			#x	: 1 
			#y	: 2
			#xy	: 0
		)
		mod_uvw.scaleSelectedCenter val axis
	),
	fn getElements mod_uvw faces_array = (
		
		local el = #()
		while faces_array.count != 0 do --or not keyboard.controlPressed 
		(
			local next_face = faces_array[1]
			mod_uvw.selectFaces #{next_face}
			mod_uvw.selectElement()
			local el_faces = mod_uvw.getSelectedFaces()
			local areaUVW
			mod_uvw.getArea el_faces &x &y &width &height &areaUVW &areaGeom 
			el += #(UV_ELEMENTS el_faces areaUVW) 
			faces_array = (faces_array as bitarray - el_faces) as array --remove faces from array
		)
		return el
	),
	/**
	*@Usage Split object by uv islands
	*@Example
		mcPolyMap.splitObjectByUVElements $ --> split object by uv to seprate meshes
		mcPolyMap.splitObjectByUVElements $ Expand:false -->split object by uv inside
	*/
	fn splitObjectByUVElements obj channel:1 Expand:true = (
	
		local mesh_obj = copy obj--copy the original object
		mesh_obj.name = uniquename (obj.name +"_UVsplit")
		convertToMesh mesh_obj--convert to editable mesh
		local num_faces = mesh_obj.numfaces
		while num_faces > 0 do ( --repeat until all elements have been detached

		  local face_array = #(1)--init. an array including only face 1
		  local cnt = 0--init. a counter  --repeat until the counter is higher than the faces stored in the array
		  while cnt < face_array.count do (
	
			cnt += 1 --increase the counter --get all map vertices used by the current map face in the collection array:
			local theVerts = meshop.getMapVertsUsingMapFace mesh_obj channel #(face_array[cnt])
			--get all map faces used by these map vertices - --this gives us all neighbours of the current map face
			local theFaces = meshop.getMapFacesUsingMapVert mesh_obj channel theVerts
			--make sure only unique faces are written to the array
			for f in theFaces where findItem face_array f == 0 do append face_array f
		  )--end while cnt --once all connected faces in an element are collected, --create a new empty EMesh:
		  --detach the collected faces
		  num_faces -= face_array.count --get remain faces for detach
		  local detached_faces = meshop.detachFaces mesh_obj face_array delete:true asMesh:Expand
		  if Expand do (
		  
			  local new_emesh = Editable_mesh()		
			  new_emesh.mesh = detached_faces					--Assign detached_faces to the EMesh's TriMesh
			  new_emesh.transform = obj.transform				--Copy the transformation of the original object
			  new_emesh.name = uniquename (obj.name +"_UVsplit")	--Assign a unique name based on the original one
		  )
		)--end while numfaces
		--delete the clone which has no faces at this point or
		--return new object with splited elements inside
		if Expand then delete mesh_obj else mesh_obj 
	),
	fn skewVerticesUvs mod_uvw uv_verts angle_deg = ( --TODO add parameter axis X Y

		mod_uvw.selectVertices uv_verts
		local verts_pos = for v in uv_verts collect mod_uvw.getVertexPosition 1 v
		mod_uvw.unwrap2.rotateSelectedCenter (degToRad  angle_deg)
		for i = 1 to uv_verts.numberset do (

			local vert_index = (uv_verts as array)[i]
			local new_pos = mod_uvw.getVertexPosition 1 vert_index
			new_pos.y = verts_pos[i].y
			mod_uvw.setVertexPosition 1 vert_index new_pos
		)
	),
	fn centerSelectionByOffset = (
	
		if not (isValidMod()) do return (mcMsgList.warn "not_unwrap")
		local gco = modPanel.getCurrentObject()
		local sel_center = gco.getSelCenter()
		local shift_x = int ( floor sel_center.x )
		local shift_y = int ( floor sel_center.y )
		gco.MoveSelected [-shift_x, -shift_y, 0]
	),
	/** TEST
	*@Usage	GEOMETRY DATABASE >  Remove unwrap data for each face
	*/
	fn clearUnwrapData geo_data = (
		
		local gco = modPanel.getCurrentObject()
		if classOf gco != Unwrap_UVW do return false
		for fd in geo_data do (
			
			local uv_face_verts_count = gco.numberPointsInFace fd.index
			for vetr_handle = 1 to uv_face_verts_count do (
				
				local geo_vert_index	= gco.getVertexGeomIndexFromFace	fd.index vetr_handle
				local vert_data =  fd.getVertDataByGeoIndex geo_vert_index
				vert_data.uvVerts = #{}
			)
		)
	),
	/**  TEST
	
	*@Example
		obj = $
		geo_faces = polyOp.getFaceSelection obj
		geo_data = mcPoly.getGeometryData obj faces:fsel
		mcPolyMap.collectUnwrapData obj geo_data
		
		geo_verts = polyOp.getVertSelection obj
		mcPoly.geoVertsToMapVerts geo_verts geo_data 
		print geo_data
	*/
	fn collectUnwrapData obj geo_data = (
		
		local mod_uvw = obj.modifiers[#unwrap_uvw]
		if classOf mod_uvw != Unwrap_UVW do (
		
			mod_uvw = Unwrap_UVW ()
			subobjectLevel = 0
			addModifier obj mod_uvw
		)
		for fd in geo_data do (
			
			--gather vertex UV data
			local uv_face_verts_count = mod_uvw.numberPointsInFace fd.index
			for vetr_handle = 1 to uv_face_verts_count do (
					
				local uv_vert_index	= mod_uvw.getVertexIndexFromFace		fd.index vetr_handle
				local geo_vert_index	= mod_uvw.getVertexGeomIndexFromFace	fd.index vetr_handle
				
				local vert_data =  fd.getVertDataByGeoIndex geo_vert_index
				vert_data.uvVerts += #{uv_vert_index}
			)
			--gather edges UV data --mybe later
		)
	),
	fn alignSelectionTo mod_uvw type = (
	
		if classOf  mod_uvw!= Unwrap_UVW do return false	
		local sel_center = mod_uvw.getSelCenter()
		local sel_faces = mod_uvw.getSelectedFaces()
		if sel_faces.count == 0 do return false
		local excluded_faces = #() --removed element faces
		for i in sel_faces do (
		
			if findItem excluded_faces i  != 0 do continue
			--format "fcount:%\n" sel_faces.numberset
			mod_uvw.SelectFaces #{i}
			mod_uvw.selectElement()
			local fsel = mod_uvw.getSelectedFaces()
			local pos_x, pos_y, width, height
			local the_area = mod_uvw.getArea fsel &pos_x &pos_y &width &height &area_uvw &area_geom 
			--format "pos_x:%\t pos_y:%|n" pos_x pos_y
			local new_pos = case type of
			(
				#left:([-pos_x , 0, 0])
				#right:([1-pos_x-width, 0, 0])
				#top:([0 , 1-pos_y-height, 0])
				#bottom:([0 , -pos_y, 0])
				#center:(sel_center - (mod_uvw.getSelCenter()))
			)
			mod_uvw.MoveSelected new_pos
			excluded_faces += mod_uvw.getSelectedFaces()
		)
		mod_uvw.SelectFaces sel_faces
	),
	fn stretchUvsToFitSquare mod_uvw = (

		if classOf  mod_uvw!= Unwrap_UVW do return false
		local sel_verts = getCurentSelectionAs mod_uvw #verts --this procedure also define gco and select vertices
		if sel_verts.count == 0 do return false
		local vertices_pos = for i in sel_verts collect (mod_uvw.getVertexPosition 0 i)
		-- Get left/lower limit
		local minY = minX = 999999
		for p in vertices_pos do (
			
			if p.x < minX do minX = p.x
			if p.y < minY do minY = p.y
		)--end if
		-- Move all to lower left corner of UV square	
		moveX = minX * -1
		moveY = minY * -1
		mod_uvw.moveSelectedVertices [moveX, moveY, 0]

		-- Verts have been changed so update the array
		vertices_pos = for i in sel_verts collect (mod_uvw.getVertexPosition 0 i)

		-- Get right/upper limit
		maxY = maxX = -999999
		for texVert in vertices_pos do (
			
			if texVert.x > maxX do maxX = texVert.x
			if texVert.y > maxY do maxY = texVert.y
		)--end if

		-- Stretch to upper right corner of UV square
		local scaleX = 1.0 / maxX
		local scaleY = 1.0 / maxY
		uvOrigin = [0, 0, 0]
		mod_uvw.scaleSelectedXY scaleX scaleY uvOrigin
	),
	fn stretchUvsToSquareProportionally mod_uvw move_zero:false = (
	
		if classOf mod_uvw != Unwrap_UVW do return false
		local bb = getSelectedUvsBB mod_uvw
		if bb == undefined do return false
		local ratio = 1.0 / bb.he
		resizeUVW mod_uvw ratio #x
		resizeUVW mod_uvw ratio #y
		if move_zero do (
		
			alignSelectionTo mod_uvw #left
			alignSelectionTo mod_uvw #bottom
		)
	)
	/*<end>*/
)	
 --create instance
Global mcPolyMap = mcStructMan.instanceStructure MICRA_POLY_MAP_STRUCTURE "mcPolyMap"
