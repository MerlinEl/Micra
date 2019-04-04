--------------------------------------------------------------------------------
/* mcMaterial by Orien 2019 */
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
struct MICRA_NEW_STRUCTURE	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Usage > switch between standard and normalmap tester material
	*@Example
		mcMaterial.normalmapTesterToggle tile_uv:[4, 4]
	*/
	fn normalmapTesterToggle tile_uv:[1, 1]= (

		local obj = (selection as array)[1]
		local nm_image = micra.rootDir+"Img\\test_coin_01.dds"
		if obj == undefined or not (doesFileExist nm_image) do return false
		local mat_id = "saved_material_"+obj.name
		local saved_material = ::mcGM.getParam mat_id --read data by ID
		if saved_material != undefined then ( --restore saved material

			obj.material = saved_material
			enableHardwareMaterial obj.material false
			showHWTextureMap obj.material false
			::mcGM.setParam mat_id undefined
			return OK
		) --else apply normal map tester
		::mcGM.setParam mat_id obj.material --store current material under ID
		local nm_texture = Bitmaptexture fileName:nm_image
		local bump_mat = Normal_Bump name:"MC_MATERIAL_TESTER_NORMALBUMP"
		bump_mat.normal_map = nm_texture
		bump_mat.normal_map.coords.U_Tiling = tile_uv[1]
		bump_mat.normal_map.coords.V_Tiling = tile_uv[2]
		local standard_mat = StandardMaterial name:"MC_MATERIAL_TESTER_STANDARD"
		standard_mat.bumpMap = bump_mat
		standard_mat.showInViewport = on
		obj.material = standard_mat
		enableHardwareMaterial obj.material true
		showHWTextureMap obj.material true
	)
	/*<end>*/
)	
 --create instance
Global mcMaterial = mcStructMan.instanceStructure MICRA_NEW_STRUCTURE "mcMaterial"
