--------------------------------------------------------------------------------
/* mcLS3D by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
	mcGM
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
struct MICRA_LS3D_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn getLs3DMaterial mat = (
	
		case classOf mat of (
		
			DirectX_9_Shader : if mat.renderMaterial != undefined then mat.renderMaterial else undefined
			LS3DMaterial : mat
			default : undefined
		)
	),
	fn getMaterialXML mat = (
	
		case classOf mat of (
		
			DirectX_9_Shader : if mat.renderMaterial != undefined then getMaterialXML mat.renderMaterial else "uni_color_grey.xml"
			LS3DMaterial : filenameFromPath (mat.GetName())
			default : "uni_color_grey.xml"
		)	
	),
	fn getDuiffuseMap mat = (
	
		case classOf mat of (
		
			DirectX_9_Shader : if mat.renderMaterial != undefined then getDuiffuseMap mat.renderMaterial else undefined
			LS3DMaterial : mat.diffuseMap
			default : mat.diffuseMap
		)
	),
	/**
	*@Example
		mcLS3D.getTextureSize $.material
		mcLS3D.getTextureSize $.material[477]
	*/
	fn getTextureSize mat = (
	
		-- format "Get Material size [ % ].\n" mat.name
		if mat == undefined or classOf mat == MultiMaterial do return undefined
		local size = undefined
		try (
		
			local diffuse_map = getDuiffuseMap mat
			if diffuse_map != undefined then ( --get bitmap size from material
			
				local bmp = diffuse_map.bitmap
				if bmp != undefined do size = [ bmp.width, bmp.height ]
				
			) else ( --get texure size from xml TODO if need
			
				local mat_xml = getMaterialXML mat
				format "xml:%\n" mat_xml
			)
		) catch (
		
			format "getTextureSize  > error okurek!!! error:%\n" (getCurrentException())
		)
		size
	)
	/*<end>*/
)	
 --create instance
Global mcLS3D = mcStructMan.instanceStructure MICRA_LS3D_STRUCTURE "mcLS3D"



	/*
		local mat_xml = correctPath (edit_path + @"materials\" + ls3d_mat.GetName())
		used_diffuse_textures = getTexturesFromMaterial mat_xml "DiffuseTexture"
		--format "getTexturesFullPath > textures:%\n" used_diffuse_textures
		for n in used_diffuse_textures collect (

			local fpath = ""
			LS3DGUP.LS3DGUP.GetFileVFSFullPath n &fpath
			fpath = correctPath( edit_path + fpath + n )
			if not (doesFileExist fpath) do (
			
				format "Unable found Texture:%\n" fpath
				continue
			)
			-- format "Texture Full Path:%\n" fpath
			fpath
		)
	
	
	
	fn getTexturesFromMaterial mat_xml tex_type = (

		local result = #()
		if not (doesFileExist mat_xml) do (
		
			format "Unable to found XML File:%\n" mat_xml
			return #()
		)
		try (
			local xDoc = XMLDocument()										--Create an XMLDcoument
			xDoc.LoadXML mat_xml												--Load XML from file
			local rNode = xDoc.GetRootNode()									--Get the Root Node THIS MUST BE CALLED!		
			local nParam = rNode.GetChild 3
			
			if (toLower(nParam.GetTag()) != "parameters") do (				--invalid Shader XML (node parameters not found)
			
				format "Node 'parameters' not found. Invalid format. Skipping:% , texture type:%\n" mat_xml tex_type
				return #()
			) 
			
			local nParamChildren = nParam.GetChildren()
			for child in nParamChildren do (
			
				local nName = child.GetChild 0
				if (toLower(nName.GetTag()) != "name") do ( --missing node name , skip
				
					format "Unable to found node 'name'. Invalid Format.Skipping:% , texture type:%\n" mat_xml tex_type
					continue
				)
				local node_name = toLower(nName.GetText())
				--format "Search str:% in NODE:%  found:%\n" tex_type node_name (findString node_name tex_type == undefined)
				if (not (isNodeType node_name tex_type)) do continue
			
				local nValue = child.GetChild 1
				local sValue = toLower (nValue.GetTag())
				local file_name = nValue.GetText()
				
				--format "check fname:%\n" file_name
				
				if (not (isTextureType file_name tex_type)) do continue
				
				if (sValue == "value") do append result file_name
				-- format "Found DIFFUSE:% at NODE:% XML PATH:%\n" (nValue.GetText()) node_name mat_xml	
			)
			
		) catch (
		
			format "Unknown error while reading material XML. Invalid format. Skipping:% , texture type: % Exception:%\n " mat_xml tex_type (getcurrentException())
		)
		result
	)
	fn getTexturesFullPath mat = (

		local ls3d_mat = case (classOf mat) of (
		
			DirectX_9_Shader	: mat.renderMaterial
			LS3DMaterial		: mat
			Default				: undefined
		)
		--format "getTexturesFullPath > mat:%\n" ls3d_mat
		if ls3d_mat == undefined do return #()
		local edit_path = LS3DGUP.LS3DGUP.EnginePath
		local mat_xml = correctPath (edit_path + @"materials\" + ls3d_mat.GetName())
		used_diffuse_textures = getTexturesFromMaterial mat_xml "DiffuseTexture"
		--format "getTexturesFullPath > textures:%\n" used_diffuse_textures
		for n in used_diffuse_textures collect (

			local fpath = ""
			LS3DGUP.LS3DGUP.GetFileVFSFullPath n &fpath
			fpath = correctPath( edit_path + fpath + n )
			if not (doesFileExist fpath) do (
			
				format "Unable found Texture:%\n" fpath
				continue
			)
			-- format "Texture Full Path:%\n" fpath
			fpath
		)
	)*/