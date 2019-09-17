
Global materialDataManagerDialog
if materialDataManagerDialog != undefined do destroyDialog materialDataManagerDialog
rollout materialDataManagerDialog "Material Data Manager:" width:524 height:720
(
	combobox 'cbx1' "Materials" pos:[240,28] width:272 height:50 align:#left
	bitmap 'bmp_mat_preview' "Bitmap" pos:[12,28] width:224 height:224 align:#left
	button 'btn_add_mat' "Add New Material" pos:[12,384] width:108 height:28 align:#left
	spinner 'spn_target_id' "" pos:[172,392] width:60 height:16 range:[0,100,1] type:#integer scale:1 align:#left
	GroupBox 'grp1' "Setup:" pos:[4,4] width:516 height:712 align:#left
	button 'btn_load_mat_lib' "Load" pos:[12,300] width:100 height:28 align:#left
	dropdownList 'ddl_mat_lib' "Mat lib" pos:[12,256] width:224 height:40 align:#left
	button 'btn_save_mat_lib' "Save" pos:[136,300] width:100 height:28 align:#left
	label 'lbl1' "Mat ID:" pos:[128,388] width:40 height:20 align:#left
	button 'btn_get_mat' "Get Material From Selection" pos:[12,352] width:106 height:28 align:#left
	button 'btn_convert_sel' "Convert Selection To New MatLib" pos:[12,528] width:220 height:28 align:#left
	label 'lbl_mat_name' "..." pos:[124,356] width:108 height:20 align:#left
	local picked_mat = undefined
	fn getMaterialFromSelection = ( --only single object or single face
		
		local obj = selection[1]
-- 		format "getMaterialFromSelection > obj:%\n" obj
		if subobjectLevel == 4 or subObjectLevel == 5 then (
			
			if superClassOf obj != GeometryClass do return undefined
			local face_index = (polyop.getFaceSelection obj as Array)[1]
			if face_index == undefined do return undefined
			local mat_id = polyop.getFaceMatID obj face_index
			obj.material[mat_id]
			
		) else (
			
			obj.material
		)
	)
	on btn_add_mat pressed do
	(
	
	)
	on btn_load_mat_lib pressed do
		(
		
	)
	on ddl_mat_lib selected sel do
	(
		
		)
	on btn_save_mat_lib pressed do
	(

	)
	on btn_get_mat pressed do
	(
				picked_mat = getMaterialFromSelection()
		format "pm:%\n" picked_mat
		if picked_mat != undefined do lbl_mat_name.text = picked_mat.name
		)
	on btn_convert_sel pressed do
	(
		
		)
)
createDialog materialDataManagerDialog


/*
loadMaterialLibrary <filename_string> 
saveMaterialLibrary <filename_string> 
getMatLibFileName() 
for mat in sceneMaterials do (

	local matlib = materialLibrary mat
	local filepath = @"C:\matlibs" + "\\" + mat.name + ".mat"
	saveTempMaterialLibrary matlib filepath
)

fn getMaterialFromSelection obj =(

)

fn addMateialToMatLib mat_lib 
*/