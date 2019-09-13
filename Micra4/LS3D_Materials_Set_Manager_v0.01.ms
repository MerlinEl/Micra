
Global materialSetManager
if materialSetManager != undefined do DestroyDialog materialSetManager
rollout materialSetManager "Material Set Manager:" width:244 height:436
(
	local settingsINI = getFilenamePath (getSourceFileName()) + "LS3D_Materials_Set_Manager.ini"
	groupBox 'grp1' "Sets:" pos:[4,4] width:236 height:428 align:#left
	button 'btn_add' "Create" pos:[8,396] width:72 height:28 align:#left
	comboBox 'cbx_sets' "" pos:[8,20] width:224 height:27 align:#left
	button 'btn_del' "Delete" pos:[84,396] width:72 height:28 align:#left
	button 'btn_apply' "Assign" pos:[160,396] width:74 height:28 align:#left
	fn getObjectIDS obj = (

		local snapNode = snapshotAsMesh obj
		local matIDs = #{}
		for f = 1 to snapNode.numFaces do
		(
			matIDs += #{getFaceMatID snapNode f}
		)
		delete snapNode
		matIDs
	)
	fn addNewSetFromSelectedObect = (
		
		local obj = selection[1]
		if classOf obj != Editable_Poly do (
			
			messageBox "Select an Editable Poly Object" title:"Aborted"
			return false
		) 		
		local new_item = cbx_sets.text
		if new_item == ""  do (
			
			messageBox "Type set Name." title:"Aborted"
			return false
		)
		if findItem cbx_sets.items new_item != 0 do (
			
			messageBox "This name already teaken. Type original set Name." title:"Aborted"
			return false
		)
		local material_ids = getObjectIDS obj
		setINISetting settingsINI "Materials_IDS" cbx_sets.text ((material_ids as Array) as String)
		format "addNewSetFromSelectedObect > name:% ids:%\n" cbx_sets.text (material_ids as Array)
		cbx_sets.items = append cbx_sets.items new_item
	)
	fn deleteSet set_index = (
		
		if cbx_sets.items.count == 0 do return false
		local selected_set = cbx_sets.selected
		if selected_set == undefined do (
			
			messageBox "Selected a set before Delete" title:"Aborted"
			return false
		)
		if not queryBox ("You are sure to delete set:"+selected_set+"?") title:"Deleting Set" do return false
		delINISetting settingsINI "Materials_IDS" selected_set	
		deleteItem cbx_sets.items set_index
		cbx_sets.items = cbx_sets.items
		if cbx_sets.items.count > 0 do cbx_sets.selection = 1
	)
	fn isSameSets bitarray_a bitarray_b = (
		
		local result_a = bitarray_a - bitarray_b	--check if a is in b
		local result_b = bitarray_b - bitarray_a --check inverse
		result_a.numberset == 0 or result_b.numberset  == 0
	)
	fn offsetMaterialsIDs obj offset:1000 = ( --incerase all materials id by 1000
	
		local all_faces = #{1..(polyop.getNumFaces obj)} 
		for f in all_faces do (
			
			local mat_id = polyOp.getFaceMatID obj f
			polyOp.setFaceMatID obj f (mat_id+offset)
		)
	)
	fn getFacesByID obj id = (
		
		local all_faces = #{1..(polyop.getNumFaces obj)} 
		local match_faces = #()
		for f in all_faces do (
			
			local mat_id = polyOp.getFaceMatID obj f
			if mat_id == id do append match_faces f
		)
		match_faces
	)
	fn replaceObjectMateriaslID obj pattern = (
		
		local id_offset = 1000
		offsetMaterialsIDs obj offset:id_offset
		for p in pattern do (
			
			local src_id = p[1]
			local trgt_id = p[2]
			local faces = getFacesByID obj (src_id + id_offset )
			polyop.setFaceMatID obj faces trgt_id	
		)
	)
	fn replaceMaterialsIdsByPattern obj current_material_ids new_material_ids pattern = (
		
		format "replaceMaterialsIdsByPattern > \n\tcurrent:%\n\tnew:%\n\tpattern:%\n" current_material_ids new_material_ids pattern	
		local replace_pattern = #()
		for i=1 to current_material_ids.count do (
			
			local current_id = current_material_ids[i]
			local id_index = findItem pattern current_id
			if id_index == 0 or id_index > new_material_ids.count do continue
			local new_id = new_material_ids[id_index]
			append replace_pattern #(current_id, new_id)
		)
		undo "Assign Material Set" on  replaceObjectMateriaslID obj replace_pattern
	)
	fn applySetToSElectedObject = (

		local obj = selection[1]
		local selected_set = cbx_sets.selected
		if selected_set == undefined do (
			
			messageBox "Selected a set before Assign to an Object" title:"Aborted"
			return false
		)
		if classOf obj != Editable_Poly do (
			
			messageBox "Select an Editable Poly Object" title:"Aborted"
			return false
		) 		
		--pick current object IDS set
		local current_material_ids = getObjectIDS obj
		--pick desired IDS set
		local new_material_ids = getINISetting settingsINI "Materials_IDS" selected_set
		new_material_ids = (execute new_material_ids) as BitArray --convert string to array
		--check if sets are identical
		format "compare sets\n\told:%\n\tnew:%\n" current_material_ids new_material_ids
		if isSameSets current_material_ids new_material_ids do (
			
			messageBox "There is nothing to change. Material Sets are identical.\nTry different one." title:"Aborted"
			return false
		)
		--now check which pattern matches current selection
		local all_sets =  getINISetting settingsINI "Materials_IDS"
		local pattern = undefined
		for s in all_sets do (
			
			local material_ids = getINISetting settingsINI "Materials_IDS" s
			local material_ids_ba = (execute material_ids) as BitArray --convert string to array
			if isSameSets current_material_ids material_ids_ba do (
			
				pattern = execute material_ids
				exit	
			)
		)
		replaceMaterialsIdsByPattern obj (current_material_ids as Array) (new_material_ids as Array) pattern
	)
	fn printSetIDS set_index = (
		
		local selected_set = cbx_sets.items[set_index]
		local material_ids = getINISetting settingsINI "Materials_IDS" cbx_sets.text
		format "printSetIDS > ids:%\n" (material_ids)
	)
	fn init = (
	
		cbx_sets.items = getINISetting settingsINI "Materials_IDS"
	)
	on btn_add pressed  do (addNewSetFromSelectedObect())
	on btn_del pressed  do (deleteSet cbx_sets.selection)
	on btn_apply pressed  do (applySetToSElectedObject())
	on cbx_sets selected sel do (printSetIDS sel)
	on cbx_sets doubleClicked sel do ()
	on materialSetManager open do (init())	
)
CreateDialog materialSetManager