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
	/**
	*@Usage
		mcPolyMap.convetrSelectionTo #verts
	*/
	fn convetrSelectionTo type = (
	
		if not (isValidMod()) do return (mcMsgList.warn "not_unwrap")
		local lvl = subobjectLevel
		local gco = modpanel.getcurrentobject()
		case type of
		(	
			#verts: (
				subobjectLevel = 1
				(if lvl == 3 then gco.faceToVertSelect() else if lvl == 2 do gco.edgeToVertSelect())
			)
			#edges:(
				subobjectLevel = 2
				(if lvl == 3 then gco.faceToEdgeSelect() else if lvl == 1 do gco.vertToEdgeSelect())
			)
			#faces:(
				subobjectLevel = 3
				(if lvl == 2 then gco.edgeToFaceSelect() else if lvl == 1 do gco.vertToFaceSelect())
			)
		)
	),
	fn getCurentSelectionAs type = ( --conver selection to desired type and return as array
		
		if not (isValidMod()) do return (mcMsgList.warn "not_unwrap")
		if (convetrSelectionTo type == false) do return #()
		local gco = modpanel.getcurrentobject()
		case type of (
		
			#verts: gco.getSelectedVertices() as Array
			#edges: gco.getSelectedEdges() as Array
			#faces: gco.getSelectedFaces() as Array	
		)
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
	fn skewVerticesUvs mod_uvw uv_verts angle_deg = (

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
	/**
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
	fn collectUnwrapData geo_data = (
		
		local gco = modPanel.getCurrentObject()
		if classOf gco != Unwrap_UVW do return false
		for fd in geo_data do (
			
			--gather vertex UV data
			local uv_face_verts_count = gco.numberPointsInFace fd.index
			for vetr_handle = 1 to uv_face_verts_count do (
					
				local uv_vert_index	= gco.getVertexIndexFromFace				fd.index vetr_handle
				local geo_vert_index	= gco.getVertexGeomIndexFromFace	fd.index vetr_handle
				
				local vert_data =  fd.getVertDataByGeoIndex geo_vert_index
				vert_data.uvVerts += #{uv_vert_index}
			)
			--gather edges UV data --mybe later
		)
	)
	/*<end>*/
)	
 --create instance
Global mcPolyMap = mcStructMan.instanceStructure MICRA_POLY_MAP_STRUCTURE "mcPolyMap"
