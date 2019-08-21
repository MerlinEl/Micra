--------------
--   old   --
-------------
public fn InitConversionTable =
(
	t3BlendShaderFile = "whiskey_terrain_3blend.fx" 
	t3BlendShaderParam = #(#g_t_1stCoverTexture, #g_t_1stCoverNormalTexture, #g_t_1stCoverMGETexture, #g_t_1stCoverMaskTexture, #g_t_2ndCoverTexture, #g_t_2ndCoverNormalTexture, 
		#g_t_2ndCoverMGETexture, #g_t_2ndCoverMaskTexture, #g_t_BaseTexture, #normalMapTx, #mgeTx, #g_2ndCoverMaskUVMultiplierU, #g_2ndCoverMaskUVMultiplierV,
		#g_2ndCoverTexUVMultiplierU, #g_2ndCoverTexUVMultiplierV, #g_BaseTexUVMultiplierU, #g_BaseTexUVMultiplierV, #g_1stCoverTexUVMultiplierU, #g_1stCoverTexUVMultiplierV, #g_1stCoverMaskUVMultiplierU, 
		#g_1stCoverMaskUVMultiplierV) 
	t3BlendFusionMatParam = #("T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "T021_BlendMaskTexture", "T015_DiffuseTexture1", "T016_NormalTexture1", 
		"T017_GlossinessMetalTexture1", "T022_BlendMaskTexture1", "T018_DiffuseTexture2", "T019_NormalTexture2", "T020_GlossinessMetalTexture2", "D080_UVShiftMultiplier3", "D080_UVShiftMultiplier3",
		"D078_UVShiftMultiplier1", "D078_UVShiftMultiplier1", "D081_UVShiftMultiplier4", "D081_UVShiftMultiplier4", "D035_UVShiftMultiplier", "D035_UVShiftMultiplier", "D079_UVShiftMultiplier2",
		"D079_UVShiftMultiplier2")
	t3BlendDefaultValues = #(5, 6, 7, 5, 5, 6, 7, 5, 5, 6, 7, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2)
	
	
	local shadersCount = 6
	for index = 1 to shadersCount do  m_ShadersConversionTable[index] = sShadersConversionTable()
	m_ShadersConversionTable[1].Init "whiskey_general.fx" #(#baseColorMapTx, #normalMapTx, #mgeTx, #g_DiffScaleU, #g_DiffScaleV, #g_SpecScaleU, #g_SpecScaleV, #g_NormScaleU, #g_NormScaleV) #("T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "D425_UVScale_Diff.x", "D425_UVScale_Diff.y", "D426_UVScale_Specular.x", "D426_UVScale_Specular.y", "D427_UVScale_Normal.x", "D427_UVScale_Normal.y") #(5, 6, 7)
	--m_ShadersConversionTable[2].Init "whiskey_terrain_3blend.fx" #(#g_t_1stCoverTexture, #g_t_1stCoverNormalTexture, #g_t_1stCoverMGETexture, #g_t_1stCoverMaskTexture, #g_t_2ndCoverTexture, #g_t_2ndCoverNormalTexture, #g_t_2ndCoverMGETexture, #g_t_2ndCoverMaskTexture, #g_t_BaseTexture, #normalMapTx, #mgeTx) #("T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "T021_BlendMaskTexture", "T015_DiffuseTexture1", "T016_NormalTexture1", "T017_GlossinessMetalTexture1", "T022_BlendMaskTexture1", "T018_DiffuseTexture2", "T019_NormalTexture2", "T020_GlossinessMetalTexture2") #(5, 6, 7, 5, 5, 6, 7, 5, 5, 6, 7)
	m_ShadersConversionTable[2].Init t3BlendShaderFile t3BlendShaderParam t3BlendFusionMatParam t3BlendDefaultValues
	m_ShadersConversionTable[3].Init "whiskey_terrain_shore.fx" #(#g_t_ColorMask, #g_t_WaterLevelTexture, #g_t_WaterLevelNormalTexture, #g_t_WaterLevelMGETexture, #g_t_WaterLevelMaskTexture, #g_t_BaseGroundTexture, #normalMapTx, #mgeTx) #("T022_BlendMaskTexture1", "T015_DiffuseTexture1", "T016_NormalTexture1", "T017_GlossinessMetalTexture1", "T021_BlendMaskTexture", "T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture") #(5, 5, 6, 7, 5, 5, 6, 7)
	m_ShadersConversionTable[4].Init "whiskey_roads.fx" #(#g_LineTexture, #g_BottomTexture, #normalMapTx, #mgeTx) #("T015_DiffuseTexture1", "T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture") #(5, 5, 6, 7)
	m_ShadersConversionTable[5].Init "whiskey_facade_colored.fx" #(#g_DiffuseTexture, #normalMapTx, #mgeTx, #g_DiffScaleU, #g_DiffScaleV, #g_SpecScaleU, #g_SpecScaleV, #g_NormScaleU, #g_NormScaleV) #("T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "D425_UVScale_Diff.x", "D425_UVScale_Diff.y", "D426_UVScale_Specular.x", "D426_UVScale_Specular.y", "D427_UVScale_Normal.x", "D427_UVScale_Normal.y") #(5, 6, 7)
	m_ShadersConversionTable[6].Init "whiskey_facade_blend.fx" #(#g_DiffuseTexture, #normalMapTx, #mgeTx, #g_DiffuseTexture2, #g_NormalTexture2, #g_SpecularTexture2, #g_BlendMaskTexture, #g_DiffScaleU, #g_DiffScaleV, #g_SpecScaleU, #g_SpecScaleV, #g_NormScaleU, #g_NormScaleV) #("T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "T015_DiffuseTexture1", "T016_NormalTexture1", "T017_GlossinessMetalTexture1", "T021_BlendMaskTexture", "D425_UVScale_Diff.x", "D425_UVScale_Diff.y", "D426_UVScale_Specular.x", "D426_UVScale_Specular.y", "D427_UVScale_Normal.x", "D427_UVScale_Normal.y") #(5, 6, 7, 5, 6, 7, 5)
)


----------------
--   new    --
---------------
public fn InitConversionTable = (	

	shader_files = #()				-- names of the shaders
	shader_params = #()			--list of DX shader parameters d:\!2k_games\...\whiskey_general.fx
	fusion_mat_params = #()	--list of Engine shader parameters d:\!2k_games\...\template_general.xml
	default_values = #()			--list of default maps indexes into m_SystemMaps
	----------------------------------------------
	append shader_files "whiskey_general.fx"
	append shader_params  #(

		#baseColorMapTx, #normalMapTx, #mgeTx, #g_DiffScaleU, #g_DiffScaleV, #g_SpecScaleU, #g_SpecScaleV, #g_NormScaleU, #g_NormScaleV
	)
	append fusion_mat_params  #(

		"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "D425_UVScale_Diff.x", "D425_UVScale_Diff.y", "D426_UVScale_Specular.x", 
		"D426_UVScale_Specular.y", "D427_UVScale_Normal.x", "D427_UVScale_Normal.y"
	)
	append default_values  #(5, 6, 7)
	----------------------------------------------
	append shader_files "whiskey_terrain_3blend.fx"
	append shader_params  #(

		#g_t_1stCoverTexture, #g_t_1stCoverNormalTexture, #g_t_1stCoverMGETexture, #g_t_1stCoverMaskTexture, #g_t_2ndCoverTexture, #g_t_2ndCoverNormalTexture, 
		#g_t_2ndCoverMGETexture, #g_t_2ndCoverMaskTexture, #g_t_BaseTexture, #normalMapTx, #mgeTx, #g_2ndCoverMaskUVMultiplierU, #g_2ndCoverMaskUVMultiplierV,
		#g_2ndCoverTexUVMultiplierU, #g_2ndCoverTexUVMultiplierV, #g_BaseTexUVMultiplierU, #g_BaseTexUVMultiplierV, #g_1stCoverTexUVMultiplierU, 
		#g_1stCoverTexUVMultiplierV, #g_1stCoverMaskUVMultiplierU, #g_1stCoverMaskUVMultiplierV
	)
	append fusion_mat_params #(

		"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "T021_BlendMaskTexture", "T015_DiffuseTexture1", "T016_NormalTexture1", 
		"T017_GlossinessMetalTexture1", "T022_BlendMaskTexture1", "T018_DiffuseTexture2", "T019_NormalTexture2", "T020_GlossinessMetalTexture2", "D080_UVShiftMultiplier3", 
		"D080_UVShiftMultiplier3","D078_UVShiftMultiplier1", "D078_UVShiftMultiplier1", "D081_UVShiftMultiplier4", "D081_UVShiftMultiplier4", "D035_UVShiftMultiplier", 
		"D035_UVShiftMultiplier", "D079_UVShiftMultiplier2","D079_UVShiftMultiplier2"
	)
	append default_values #(5, 6, 7, 5, 5, 6, 7, 5, 5, 6, 7, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2)
	----------------------------------------------
	append shader_files "whiskey_terrain_shore.fx"	
	append shader_params #(

		#g_t_ColorMask, #g_t_WaterLevelTexture, #g_t_WaterLevelNormalTexture, #g_t_WaterLevelMGETexture, #g_t_WaterLevelMaskTexture, #g_t_BaseGroundTexture, 
		#normalMapTx, #mgeTx
	)
	append fusion_mat_params #(

		"T022_BlendMaskTexture1", "T015_DiffuseTexture1", "T016_NormalTexture1", "T017_GlossinessMetalTexture1", "T021_BlendMaskTexture", "T000_DiffuseTexture",
		"T001_NormalTexture", "T002_GlossinessMetalTexture"
	)
	append default_values #(5, 5, 6, 7, 5, 5, 6, 7)		
	----------------------------------------------
	append shader_files "whiskey_roads.fx"
	append shader_params	#(#g_LineTexture, #g_BottomTexture, #normalMapTx, #mgeTx)
	append fusion_mat_params	#("T015_DiffuseTexture1", "T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture")
	append default_values #(5, 5, 6, 7)
	----------------------------------------------
	append shader_files "whiskey_facade_colored.fx"
	append shader_params	#(#g_DiffuseTexture, #normalMapTx, #mgeTx, #g_DiffScaleU, #g_DiffScaleV, #g_SpecScaleU, #g_SpecScaleV, #g_NormScaleU, #g_NormScaleV)
	append fusion_mat_params #(
	
		"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "D425_UVScale_Diff.x", "D425_UVScale_Diff.y", "D426_UVScale_Specular.x", 
		"D426_UVScale_Specular.y", "D427_UVScale_Normal.x", "D427_UVScale_Normal.y"
	)
	append default_values #(5, 6, 7)
	----------------------------------------------
	append shader_files "whiskey_facade_blend.fx"
	append shader_params	#(
	
		#g_DiffuseTexture, #normalMapTx, #mgeTx, #g_DiffuseTexture2, #g_NormalTexture2, #g_SpecularTexture2, #g_BlendMaskTexture, #g_DiffScaleU, #g_DiffScaleV, 
		#g_SpecScaleU, #g_SpecScaleV, #g_NormScaleU, #g_NormScaleV
	)
	append fusion_mat_params #(
	
		"T000_DiffuseTexture", "T001_NormalTexture", "T002_GlossinessMetalTexture", "T015_DiffuseTexture1", "T016_NormalTexture1", "T017_GlossinessMetalTexture1", "T021_BlendMaskTexture", 
		"D425_UVScale_Diff.x", "D425_UVScale_Diff.y", "D426_UVScale_Specular.x", "D426_UVScale_Specular.y", "D427_UVScale_Normal.x", "D427_UVScale_Normal.y"
	)
	append default_values #(5, 6, 7, 5, 6, 7, 5)
	----------------------------------------------
	m_ShadersConversionTable = for i = 1 to shader_files.count collect (
	
		local new_table = sShadersConversionTable()
		new_table.Init shader_files[i] shader_params[i] fusion_mat_params[i] default_values[i]
		new_table
	)
)