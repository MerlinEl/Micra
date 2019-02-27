
Global mcVertexAlphaBlendDialog
if mcVertexAlphaBlendDialog != undefined do destroyDialog mcVertexAlphaBlendDialog
rollout mcVertexAlphaBlendDialog " Vertex Alpha Blend" width:176 height:132
(
	groupBox 'grp1' "Properties:" pos:[4,4] width:164 height:120 align:#left
	
	spinner 'spn_lvl_1' "" pos:[76,26] width:84 height:16 range:[0,1,0.2] type:#float align:#left
	spinner 'spn_lvl_2' "" pos:[76,46] width:84 height:16 range:[0,1,0.5] type:#float align:#left
	spinner 'spn_lvl_3' "" pos:[76,66] width:84 height:16 range:[0,1,0.8] type:#float align:#left
	
	button 'btn_blend_sel' "Blend Selected" pos:[12,88] width:148 height:28 align:#left
	
	checkbox 'chk_lvl_1' "level_1:" pos:[16,24] width:60 height:20 align:#left checked:true
	checkbox 'chk_lvl_2' "level_2:" pos:[16,44] width:60 height:20 align:#left checked:true
	checkbox 'chk_lvl_3' "level_3:" pos:[16,64] width:60 height:20 align:#left
	fn displayAlpha obj = (

		obj.vertexColorType = #alpha
		obj.showVertexColors = true
	)
	fn growVertSel obj sel iterations = (
		
		for i = 1 to iterations do sel = polyop.getVertsUsingFace obj (polyop.getFacesUsingVert obj sel)
		return sel
	)
	fn setSelectedVerticesAlpha val = (
format "val:%\n"  val
		local obj = (selection as array)[1]
		if obj == undefined do return false
		if classOf obj != Editable_Mesh do convertToMesh obj
		local vsel = getVertSelection obj
		if (vsel as array).count == 0 do return false
		meshop.setVertAlpha obj -2 vsel val
		update obj
	)
	fn blendSelectedVerticesAlpha val_a val_b = (
	
format "val 1:% 2:%\n"  val_a val_b
		local obj = (selection as array)[1]
		if obj == undefined do return false
		if classOf obj != Editable_Poly do convertToPoly obj
		local vsel_1 = polyOp.getVertSelection obj
		if (vsel_1 as array).count == 0 do return false
		local vsel_2 = growVertSel obj vsel_1 1
		local vsel_intersection_1 = vsel_2 - vsel_1
		polyOp.setVertSelection obj (vsel_1 + vsel_2)
		convertToMesh obj
		meshop.setVertAlpha obj -2 vsel_intersection_1 val_b
		update obj
		convertToPoly obj
		displayAlpha obj
	)
	
	on chk_lvl_1 changed state do chk_lvl_1.checked = true
	on chk_lvl_2 changed state do chk_lvl_2.checked = true
	on btn_blend_sel pressed do (
		
		--suspendEditing()
		max modify mode
		 undo "Blend Vertices Alpha" on (
			 
			setSelectedVerticesAlpha spn_lvl_1.value
			blendSelectedVerticesAlpha spn_lvl_1.value spn_lvl_2.value
			if chk_lvl_3.checked do blendSelectedVerticesAlpha spn_lvl_2.value spn_lvl_3.value
		) 	
		--resumeEditing()
		subobjectLevel = 1
	)
	
	
)
CreateDialog mcVertexAlphaBlendDialog
