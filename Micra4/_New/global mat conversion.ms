struct MATERIAL_DATA (obj, mat_id, mat_xml, mat_name, mat)
fn getObjectIDS obj = (
	
	if superClassOf obj != GeometryClass do return #{}
	local snapNode = snapshotAsMesh obj
	local mats_id = #{}	--get unique ids
	for f = 1 to snapNode.numFaces do (
		
		mats_id += #{getFaceMatID snapNode f}
	)
	delete snapNode
	mats_id
)

fn getFacesByMatID obj mat_id = (
	
	local all_faces = #{1..(polyop.getNumFaces obj)}
	for f in all_faces where polyop.getFaceMatID obj f == mat_id collect f
)

fn getMaterialXML mat = (
	
	case classOf mat of (
		
		DirectX_9_Shader : mat.name
		LS3DMaterial : filenameFromPath (mat.GetName())
		default : "uni_color_grey.xml"
	)	
)

fn getObjectMaterials obj  = (

	local mat = obj.material
	local mats_id = getObjectIDS obj
	--collect materials from ids
	local mat_data = #()
	for id in mats_id do (

		case classof mat of (
			
			Multimaterial : (
				
					for i = 1 to mat.materialList.count do (

						local current_mat = mat.materialList[i]
						local current_id    = mat.materialIDList[i]
						if  current_id != id do continue
						local data = MATERIAL_DATA obj current_id  (getMaterialXML current_mat) mat.name current_mat
						--format "%\n" data
						appendIfUnique mat_data data
					)
				)
				LS3DMaterial: (
					
					local data = MATERIAL_DATA obj id (getMaterialXML current_mat) mat.name mat	
					appendIfUnique mat_data data
				)
				DirectX_9_Shader : (
					
					local data = MATERIAL_DATA obj id (getMaterialXML current_mat) mat.name mat	
					appendIfUnique mat_data data
				)
				UndefinedClass : ()
				default: ()
		)
	)
	mat_data
)

fn isUniqueData all_data data = (
	
	for d in all_data where d.mat_id == data.mat_id and  d.mat_xml == data.mat_xml do return false
	true
)

fn getObjectsMaterials objs = (

	local all_mats_data = #()
	for o in objs do (
		
		local mat_data = getObjectMaterials o
		for data in mat_data where isUniqueData all_mats_data data  do (

			append all_mats_data data
		)
	)
	all_mats_data
)

/*
mat_data = getObjectsMaterials (selection as array) 
mat_data.count
for m in mat_data do format "%\n" m

--create case
format "fn convertOldIDStoNewIDS id = (\n"
format "\tcase id of (\n"
for m in mat_data do (
	format "\t\t%\t:\t--\t%\t%\t%\n" m.mat_id m.mat_xml	m.mat_name m.obj.name
)
format "\t)\n)\n"
*/

fn parseXmlTable xml_file = (
	
	if not (doesFileExist xml_file) do return false
	struct MAT_ITEM (key, id, sid, tile_u, tile_v, mat_xml)
	local xDoc = XMLDocument()			--Create an XMLDcoument
	xDoc.LoadXML xml_file		--Load XML from file
	local rNode = xDoc.GetRootNode()		--Get the Root Node THIS MUST BE CALLED!
	local reindex_items = (rNode.GetChildren())[1].GetChildren() --Get All Reindex Keys
	mat_items = for itm in reindex_items collect (
		
		local mat_name = trimRight (itm.GetAttribute "Comment") ".xml"
		local mat_id = execute (itm.GetAttribute "VisualMatIndex")
		local mat_sid = execute (itm.GetAttribute "SemanticMatIndex")
		local mat_tile_u = execute (itm.GetAttribute "Tile_U")
		local mat_tile_v = execute (itm.GetAttribute "Tile_V")
		local mat_xml = itm.GetAttribute "Comment"
		MAT_ITEM key:mat_name			id:mat_id		sid:mat_sid		tile_u:mat_tile_u		tile_v:mat_tile_v		mat_xml:mat_xml
	)
	mat_items
)

/*
checkMaterialLibrary $.material
*/
fn checkMaterialLibrary mat = (
	
	local cnt = 1
	format "ID:% XML:%\n" 1 "uni_color_grey.xml"
	for i=1 to mat.count do (
		
		local mat_xml = getMaterialXML mat[i]
		if mat_xml == "uni_color_grey.xml" do continue 
		format "ID:% XML:%\n" i mat_xml
		cnt += 1
	)
	format "Total Present Materials:%\n" cnt
)


fn getMaterialXMLByID mat id = (
	
	case classof mat of (
		
		Multimaterial : getMaterialXML mat[id]
		UndefinedClass : "uni_color_grey.xml"
		default: getMaterialXML mat
	)
)

fn getMaterialIDFromXML xml_data mat_xml  = (
	
	if 	mat_xml == "uni_color_grey.xml" do return 1
	for itm in xml_data where mat_xml == itm.mat_xml do return itm.id
	1
)

fn offsetMaterialsIDs obj object_ids offset:1000 = ( --incerase all materials id by 1000

	for id in object_ids do (
		
		local id_faces = getFacesByMatID obj id
		local offset_id = id+1000
		polyop.setFaceMatID obj id_faces offset_id
	)
)

fn getUniqueObjectsWithoutInstances objs = (

	local sel = #()
	for o in objs do ( 
	
		local instances = #()
		InstanceMgr.GetInstances o &instances
		local obj = instances[1]
		appendIfUnique sel obj
	)
	sel
)

--data = mat_name, mat_id, mat_xml
fn convertOldIDStoNewIDS  prog_debug:false = (

	local xml_file = (LS3DGUP.LS3DGUP.UtilsPath + "coll_bourbon_table.xml")
	local xml_data = parseXmlTable xml_file
	max modify mode
	--local mat_data = getObjectsMaterials (selection as array) 
	local sel = getUniqueObjectsWithoutInstances selection --prvent override material ID
	with redraw off for obj in sel do (
	
		if prog_debug do format "OBJ:%\n" obj.name
		local object_ids = getObjectIDS obj
		local edit_poly_mod = Edit_Poly()
		addModifier obj edit_poly_mod
		offsetMaterialsIDs obj object_ids  offset:1000 --prevent override old ids
		for id in object_ids do (
		
			local mat_xml = getMaterialXMLByID obj.material id
			local new_mat_id = getMaterialIDFromXML xml_data mat_xml
			local offset_id = id+1000
			local id_faces = getFacesByMatID obj offset_id
			if prog_debug do format "\told_id:% new_id:% offset_id:% mat_xml:%\n" id new_mat_id offset_id mat_xml
			polyop.setFaceMatID obj id_faces new_mat_id	
		)
	)
	--selection.material = ::gLS3D_TMM.correctTerrainMaterial
)
convertOldIDStoNewIDS prog_debug:true

/*
gLS3D_TMM.correctTerrainMaterial 
D:\!2k_games\scotch_dev\resources\utilities\3dsmax\ground_material
*/