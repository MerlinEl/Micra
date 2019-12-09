----------------------------------------------------------
--  Import External Structures (if need)  --
----------------------------------------------------------
mcStructMan.import "mcLS3DMaterialManagerStruct" "LS3D_Material_Manager_Struct" dir:#Root force:true debug:true

--Rollout
Global mcShaderManagerDialog
if mcShaderManagerDialog != undefined do destroyDialog mcShaderManagerDialog
rollout mcShaderManagerDialog "LS3D Shader Manager:" width:680 height:732
(
	local default_dir = @"d:\!2k_games\scotch_dev\edit\materials\city\lost_heaven\terrain\ground\"
	local file_list = #()
	local file_names = #()
	combobox 'cbx_shders_list' "Shaders" pos:[8,16] width:328 height:49 align:#left
	combobox 'cbx_params_list' "Parameters" pos:[340,16] width:328 height:49 align:#left
	GroupBox 'grp1' "" pos:[4,4] width:672 height:724 align:#left
	button 'btn_Copy' "Copy" pos:[472,692] width:60 height:24 align:#left
	button 'btn_paste' "Paste" pos:[540,692] width:60 height:24 align:#left
	button 'btn_browse_dir' "Dir..." pos:[8,692] width:52 height:24 align:#left
	label 'lbl_dir_path' "..." pos:[64,696] width:404 height:20 align:#left
	button 'btn_save' "Save" pos:[608,692] width:60 height:24 align:#left
	fn readShader xml = (
		
		
	)
	fn loadShaderData sel_index = (
		
			format "sel:% f:%\n" sel_index file_names[sel_index]
	)
	fn init = (
		
		lbl_dir_path.text = default_dir
		file_list = getFiles (default_dir + "*.xml")
		file_names = for f in file_list collect getFilenameFile f 
		cbx_shders_list.items = file_names
	)
	on cbx_shders_list selected sel_index do loadShaderData sel_index
	on btn_copy pressed  do ()
	on btn_paste pressed  do ()
	on btn_browse_dir pressed   do  ()
	on mcShaderManagerDialog open do init()
)
createDialog mcShaderManagerDialog


/*
mat_file = @"d:\!2k_games\scotch_dev\edit\materials\city\lost_heaven\terrain\ground\lh_mountains_rock_grass_dgrass_cs_west_f_v1.xml"
gLS3DTempMaterialLibrary.GetMaterialParamsFromMaterialXML mat_file &materialData 
materialData.textureParameters
fullPath = ""
LS3DGUP.LS3DGUP.GetFileVFSFullPath "uni_color_black.dds" &fullPath
*/