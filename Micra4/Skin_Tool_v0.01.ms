if mcSkinDialog != undefined do destroyDialog mcSkinDialog
rollout mcSkinDialog "Skin Tools:" width:352 height:236
(
	local stored_set_01 = #()
	local stored_set_02 = #()
	local stored_set_03 = #()
	local stored_set_04 = #()
	GroupBox grp1 "Skin:" pos:[4,4] width:344 height:228
	GroupBox grp2 "Store Bones:" pos:[12,24] width:328 height:136
	edittext edt_01 "" pos:[68,48] width:216 height:24
	edittext edt_02 "" pos:[68,76] width:216 height:24
	edittext edt_03 "" pos:[68,104] width:216 height:24
	edittext edt_04 "" pos:[68,132] width:216 height:24
	
	button btn_s01 "store" pos:[20,48] width:44 height:24
	button btn_s02 "store" pos:[20,76] width:44 height:24
	button btn_s03 "store" pos:[20,104] width:44 height:24
	button btn_s04 "store" pos:[20,132] width:44 height:24
	
	button btn_m01 "merge" pos:[288,48] width:44 height:24
	button btn_m02 "merge" pos:[288,76] width:44 height:24
	button btn_m03 "merge" pos:[288,104] width:44 height:24
	button btn_m04 "merge" pos:[288,132] width:44 height:24
	
	button btn_multi_remove "Multi Remove" pos:[16,200] width:76 height:24
	button btn_remove_all "Remove All" pos:[16,172] width:76 height:24
	
	fn collectBones edt =
	(
		local obj = selection[1]
		if obj == undefined 
		then 
		(
			eBox.text = "Undefined" 
			return #()
		)
		else
		(
			local the_skin  = obj.modifiers[#Skin]
			if the_skin == undefined do return #()
			edt.text = obj.name
			return (for i=1 to skinOps.GetNumberBones the_skin collect (skinOps.GetBoneName the_skin i 0))
		)
	)
	fn addBones stored_set =
	(
		local obj = selection[1]
		if obj == undefined and stored_set.count == 0 do return false
		local the_skin  = obj.modifiers[#Skin]
		if the_skin == undefined do return false
		for i in stored_set where getNodeByName i != undefined do skinOps.addBone the_skin (getNodeByName i) 1

	)
	fn multiRemove =
	(
		local obj = selection[1]
		if obj == undefined and obj.modifiers[#Skin] == undefined do return false
		skinOps.multiRemove obj.modifiers[#Skin]
	)
	fn removeAll =
	(
		local obj = selection[1]
		if obj == undefined and obj.modifiers[#Skin] == undefined do return false
		local the_skin  = obj.modifiers[#Skin]
		for i=skinOps.GetNumberBones the_skin to 1 by -1 do skinOps.removebone the_skin i
	)
	on btn_s01 pressed  do stored_set_01 = (collectBones edt_01)
	on btn_s02 pressed  do stored_set_02 = (collectBones edt_02)
	on btn_s03 pressed  do stored_set_03 = (collectBones edt_03)
	on btn_s04 pressed  do stored_set_04 = (collectBones edt_04)

	on btn_m01 pressed do addBones stored_set_01
	on btn_m02 pressed do addBones stored_set_02
	on btn_m03 pressed do addBones stored_set_03
	on btn_m04 pressed do addBones stored_set_04
	
	on btn_multi_remove pressed do multiRemove()
	on 	btn_remove_all  pressed do removeAll()

)
createDialog mcSkinDialog