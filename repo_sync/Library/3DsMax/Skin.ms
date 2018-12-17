skinOps.isBoneSelected <Skin> <BoneID_integer> 
skinOps.SelectVertices <Skin> \( <vertex_integer> | <vertex_array > | <<vertex_bitarray> )
skinOps.GetVertexWeight <Skin> <vertex_integer> <vertex_bone_integer>
skinOps.GetNumberVertices <Skin>
skinOps.GetSelectedBone <Skin>
skinOps.GetNumberBones <Skin>
skinOps.GetVertexWeightBoneID <Skin> <vertex_integer> <vertex_bone_integer>
skinOps.GetVertexWeightCount <Skin> <vertex_in	teger>

skinOps.removeBone $.modifiers[#Skin] i
skinOps.GetBoneName $.modifiers[#Skin] 1 0
skinOps.GetNumberBones $.modifiers[#Skin]
skinOps.GetVertexWeight $.modifiers[#Skin] 1 1
skinOps.GetVertexWeightBoneID $.modifiers[#Skin] 50 1


(
	SoD_Skin = $.modifiers[#Skin]
	SoD_Bones = for i=1 to skinOps.GetNumberBones SoD_Skin collect (skinOps.GetBoneName SoD_Skin i 0)
	
	curSel = #()
	sb = skinops.GetSelectedBone SoD_Skin

	vertSelection = curSel as array
	ssName = SoD_Bones[sb] + ": " + (vertSelection.count as string)
	nameOK = FALSE
	nameIndex = 1		
	if Sod_SelectionSets.count > 0 do
	(
		while nameOK == FALSE do
		(
			nameOK=true
			for s=1 to Sod_SelectionSets.count do
			(
				testSSName = SoD_SelectionSets[s].name
				if (ssName == testSSName) do
				(
					ssName = SoD_Bones[sb] + " (" + (nameIndex as string) + ") : " + (vertSelection.count as string)
					nameIndex += 1
					nameOK = TRUE
					for ss=1 to Sod_SelectionSets.count do
					(
						testSSName2 = SoD_SelectionSets[ss].name
						if (ssName == testSSName2) then nameOK = FALSE
					)
					exit			
				)
			)
		)
	)
	newSelectionSet = VertSelectionSet ssName vertSelection.count curSel
	append SoD_SelectionSets newSelectionSet
	updateSSList()
)