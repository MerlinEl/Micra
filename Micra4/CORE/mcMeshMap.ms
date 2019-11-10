--------------------------------------------------------------------------------
/* mcMeshMap by Orien 2019 */
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
struct MICRA_MESH_MAP_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Author	Bobo
	*@Modified	MerlinEl
	*@Usage	
		obj	: Editable_Mesh
		map_channel	: map channel integer
		vert_index	: vertex index
	*@Example
		mcMeshMap.getVertexUvs $ 1 20
	*/
	fn getVertexUvs obj map_channel vert_index = (

		if not (classOf obj == Editable_Mesh) do return (mcMsgList.warn "not_mesh")
		local faces = (meshOp.getFacesUsingVert obj vert_index) as array
		local mapVertices = #()
		for f in faces do (
		
			local geo_verts = getFace obj f
			local uv_verts = meshOp.getMapFace obj map_channel f
			if geo_verts.x == vert_index then theMapVert = uv_verts.x as integer
			if geo_verts.y == vert_index then theMapVert = uv_verts.y as integer
			if geo_verts.z == vert_index then theMapVert = uv_verts.z as integer
			if findItem mapVertices theMapVert  == 0 do append mapVertices theMapVert 
		) 
		return mapVertices 
	),
	/**
	*@Usage
		obj: Editable_Mesh or Editable_Poly
		faces	: faces bitarray
	*/
	fn breakFacesUvs obj faces = ( 

		if not (classOf obj == Editable_Mesh) do return (mcMsgList.warn "not_mesh")
		local faces_verts_old = meshop.getVertsUsingFace obj faces
		meshop.detachFaces obj faces
		local faces_verts_new = meshop.getVertsUsingFace obj faces
		obj.selectedVerts = face_verts_old + face_verts_new
		meshop.weldVertsByThreshold obj (faces_verts_old + faces_verts_new) 0.001
	),
	fn offsetUvs obj uvs_verts offset = (
	
		if not (classOf obj == Editable_Mesh) do return (mcMsgList.warn "not_mesh")
		for v in uvs_verts do (
		
			local map_vert_pos = meshop.getMapVert obj 1 v
			meshop.setMapVert obj 1 v (map_vert_pos + offset)
		)
		update obj
	)
	/*<end>*/
)	
 --create instance
Global mcMeshMap = mcStructMan.instanceStructure MICRA_MESH_MAP_STRUCTURE "mcMeshMap"

/*
--Split edge Mapping and move both mapping vertices toward (unfinished)
fn offsetEdgesUvs obj_mesh edges_index offset_y = (

	obj_mesh = $
	esel = getEdgeSelection obj_mesh
	efaces = meshop.getFacesUsingEdge obj_mesh esel
	evetrs = meshop.getVertsUsingEdge obj_mesh esel
	--break uvs on edge
	mcMeshMap.breakFacesUvs obj_mesh efaces
	--get verts uvs	
	vert_uvs_pairs = for v in evetrs collect (mcMeshMap.getVertexUvs obj_mesh 1 v)
	--divide uv vertices in two groups
	faces_data = for f in efaces collect #(f, meshOp.getFaceCenter obj_mesh f)

	uv_verts_a = #{}
	uv_verts_b = #{}
	for pair in vert_uvs_pairs do (

		
	)	
	--offset old uvs down
	undo "move verts uv" on mcMeshMap.offsetUvs obj_mesh uv_verts_a [0,0.2,0]
)	

face_index = 24
moveFaceUvs $ 24 [0, -0.2, 0]

meshop.getNumTVerts obj_mesh
meshop.getMapFace obj_mesh 1 #{1..3}
breakFacesUvs obj_mesh 30
meshOp.getMapFace obj_mesh 1 10
mcMeshMap.getVertexUvs $ 1 15
face_map_verts = meshop.getMapFace obj_mesh 1 face_index
meshop.getMapFace obj_mesh 1 face_index --face_map_verts
obj_mesh.selectedFaces = efaces
*/