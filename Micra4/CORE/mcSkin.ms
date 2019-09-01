--------------------------------------------------------------------------------
/* mcSkin by Orien 2019 */
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
struct MICRA_SKIN_STRUCTURE	(
	
	--variables

	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn getBoneByName mod_obj name =
	(
		local bones_count = skinOps.GetNumberBones mod_obj
		local bone_names= for i=1 to bones_count collect skinOps.GetBoneName mod_obj i 0
		return (findItem bone_names "bone_body_01") -- return bone num
	),
	fn addBoneByName mod_obj name =
	(
		local root_bone = getNodeByName "bone_body_01"
		if root_bone == undefined do return 0
		skinOps.addBone mod_obj root_bone 1
		return (mcSkin.getBoneByName mod_obj "bone_body_01") -- return bone num
	),
	fn wpnSetupSkin = --WEAPONS SKIN SETUP
	(
		max modify mode
		local obj = selection[1]
		if obj == undefined do return false
		local mod_obj = modPanel.getCurrentObject()-- select multiple objects to multi unwrap
		if classof mod_obj != Skin do 
		(
			mod_obj = (Skin())
			modPanel.addModToSelection mod_obj
		)
		--enter to skin mode
		subobjectLevel = 1
		toolMode.coordsys #view
		mod_obj.filter_vertices = on --verts enabled on
		--setup skin
		mod_obj.effect = 1
		local bones_count = skinOps.GetNumberBones mod_obj
		local root_bone_num = 0
		if bones_count == 0 
		then
		(
			root_bone_num = mcSkin.addBoneByName mod_obj "bone_body_01" --if no bones assinged
			if root_bone_num == 0 do return false
		)
		else
		(
			root_bone_num = mcSkin.getBoneByName mod_obj "bone_body_01" 
			if root_bone_num == 0 do root_bone_num = mcSkin.addBoneByName mod_obj "bone_body_01"
			if root_bone_num == 0 do return false
		)
		skinOps.SelectBone mod_obj root_bone_num  --select bone 1
		max select all --select all vertices
		skinOps.setWeight mod_obj 1 --set selected verts to veight 1
		mod_obj.bone_Limit = 4
		--exit skin mode
		subobjectLevel = 0
		obj.parent = (getNodeByName "bone_body_01")
		return OK
	)
	/*<end>*/
)	
 --create instance
Global mcSkin = mcStructMan.instanceStructure MICRA_SKIN_STRUCTURE "mcSkin"
