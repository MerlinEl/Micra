--------------------------------------------------------------------------------
/* mcBiped by Orien 2019 */
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
--struct BONE_TM (dir, )
struct POSE_DATA (bone_name, bone_rotation)
struct MICRA_BIPED_STRUCTURE	(
	
	--variables
	pose = #(),
	
	--functions
	fn getSource = getSourceFileName(), --get path of this script

	fn copyTransform = (
		
		--bonesTm = for o in selection collect 
	),
	fn pasteTransform = (
		--.transform.rotation
		--Insert Code Here...
-- 		biped.getTransform <biped_node> (#pos | #rotation | #scale) [limb:<biped_node>] 	 
-- 		biped.setTransform <biped_node> #pos <point3> <bool_setkey> [limb:<biped_node>] 	
-- 		biped.setKey <biped_node> copyHor:<bool_setHoriz> copyVer:<bool> copyTrn:<bool> 
-- 		biped.setSelectedKey <bipedCtrl> 
	),
	fn copyPose = (
-- 		format "Copy pose (%)data.\n" selection.count
		pose = for o in selection where (classOf o == Biped_Object) collect (POSE_DATA o.name (biped.getTransform o #rotation))
	),
	fn pastePose = (
-- 		format "Paste pose (%)data.\n" pose.count
		for d in pose do (
		
			local o = getNodeByName d.bone_name
			if o == undefined do continue   
			biped.setTransform o #rotation d.bone_rotation true
		)
	),
	--remove bones which have less weight than given treeshold
	fn optimizeBones weightThresh: 0.0001= (

		local objs = selection as array
		for obj in objs do (
			select obj
			for m in obj.modifiers where classof m == Skin do (
				modPanel.setCurrentObject m
				local vertCount = skinOps.GetNumberVertices m
				local bonesCount = skinOps.GetNumberBones m
				local unusedBones = #{1..bonesCount}
				
				for v = 1 to vertCount do (
					local vertWeightCount = skinOps.GetVertexWeightCount m v
					
					for i = 1 to vertWeightCount do (
						local weight = skinOps.GetVertexWeight m v i
						if weight >= weightThresh then (
							local boneID = skinOps.GetVertexWeightBoneID m v i
							unusedBones[boneID] = false
						)
					)
				)
				for i = bonesCount to 1 by -1 where unusedBones[i] do (
					skinOps.SelectBone m i
					skinOps.RemoveBone m
				)
				format "% Bones where removed from %.%" unusedBones.numberSet obj.name m.name
			)
		)
	),
	fn removeAllBones obj = ( --not used
		
		if obj == undefined do return false
		max modify mode
		local skinMod = obj.modifiers[#Skin]
		if classOf skinMod != Skin do return false
		while (skinOps.GetNumberBones skinMod) > 0 do (
			
			skinOps.SelectBone skinMod 1
			skinOps.RemoveBone skinMod 1
		)
	),
	fn getSkinBones obj  = ( 

		if obj == undefined do return false
		max modify mode
		local skinMod = obj.modifiers[#Skin]
		if classOf skinMod != Skin do return false
		--modPanel.setCurrentObject obj.modifiers[#Skin]
		for i=1 to (skinOps.GetNumberBones skinMod) collect (skinOps.GetBoneName skinMod i 0)
	),
	fn setSkinBones obj boneNames  = ( 

		if obj == undefined do return false
		max modify mode
		local skinMod = obj.modifiers[#Skin]
		--clear modifier if exists
		if classOf skinMod == Skin do deleteModifier obj skinMod
		--add new skin modifier
		skinMod =  Skin()
		addModifier obj skinMod
		--fill skin with bones
		for i=1 to boneNames.count do (
			
			local b = getNodeByName boneNames[i]
			if b != undefined do skinOps.AddBone skinMod b i
		)
	),
	fn loadSkinBonesFromFile obj fname = (
		
		local boneNames  = (dotnetClass "System.IO.File").ReadAllLines fname
		setSkinBones obj boneNames
	),
	fn saveSkinBonesToFile obj fname = (
		
		local boneNames = getSkinBones obj
		(dotnetclass "System.IO.File").WriteAllLines fname boneNames
	),
	/*
	Copyright 2015, Michael Lawler
	Email: archangel35757@yahoo.com
	Mod: MerlinEl 2020
	Email: merlin_el@hotmail.com
	*/
	fn saveSkinDataToFile obj fname = (

		if obj == undefined do return false
		max modify mode
		local skinMod = obj.modifiers[#Skin]
		if classOf skinMod != Skin do return false
		local numBones = skinOps.GetNumberBones skinMod
		if numBones > 0 do skinOps.saveEnvelope skinMod fname	
		
		--save envelope data to file
		/*local fname
		if asBinary == 1 then (
			--binary file type
			fname = maxFilePath + (getFilenameFile maxFileName) + "_" + obj.name + ".env"
			print fname to:Listener
			skinOps.saveEnvelope skinMod fname
		) else (
			--ASCII file type
			fname = maxFilePath + (getFilenameFile maxFileName) + "_" + obj.name + ".envASCII"
			print fname to:Listener
			skinOps.saveEnvelopeAsASCII skinMod fname				
		)*/
	),
	fn loadSkinDataFromFile obj fname = (
		
		if obj == undefined do return false
		max modify mode
		local skinMod = obj.modifiers[#Skin]
		if classOf skinMod != Skin do return false
		local numBones = skinOps.GetNumberBones skinMod
		if numBones > 0 do skinOps.loadEnvelope skinMod fname
		
		--get the envelope filename for this object
		/*local fname
		if asBinary == 1 then (
			--binary file type
			local binFilename = maxFilePath + (getFilenameFile maxFileName) + "_" + obj.name + ".env"
			print binFilename to:Listener
			if not doesFileExist fname do return false
			skinOps.loadEnvelope skinMod fname
		) else (
			--ASCII file type
			local fname = maxFilePath + (getFilenameFile maxFileName) + "_" + obj.name + ".envASCII"
			print fname to:Listener
			if not doesFileExist fname do return false
			skinOps.loadEnvelopeAsASCII skinMod fname				
		)*/
	),
	fn saveSkinData = (
		if $ == undefined do return false
		local fname = getSaveFileName caption: " Chose Save Skin Data File..." filename:(maxFilePath+$.name+ ".env") types:"Enviroment files (*.env)|*.env"
		if  fname != undefined do (
			
			saveSkinBonesToFile $ (replace fname (findString fname "env") 3 "bon")
			if not Keyboard.altPressed do saveSkinDataToFile $ fname
			messageBox "Saved"
		)
	),
	fn loadSkinData = (
		if $ == undefined do return false
		local fname = getOpenFileName caption: " Chose Load Skin Data File..." filename:(maxFilePath+$.name+ ".env") types:"Enviroment files (*.env)|*.env"
		if  fname != undefined  and doesFileExist fname do (
			
			loadSkinBonesFromFile $ (replace fname (findString fname "env") 3 "bon")
			if not Keyboard.altPressed do loadSkinDataFromFile $ fname
			messageBox "Loaded"
		)
	),
	fn mirrorSelectedBoneVerts = (
		
		local obj = selection[1]
		if obj == undefined do return false
		max modify mode
		local skinMod = obj.modifiers[#Skin]
		if classOf skinMod != Skin do return false
		skinOps.selectVerticesByBone skinMod --OK
		skinOps.mirrorPaste skinMod --not works
		--skinOps.updateMirror skinMod --not works
	)
	/*<end>*/
)	
 --create instance
Global mcBiped = mcStructMan.instanceStructure MICRA_BIPED_STRUCTURE "mcBiped"


/*
	fn saveSkinBones = (
		if $ == undefined do return false
		local fname = getSaveFileName caption: " Chose Save Skin Bones File..." filename:(maxFilePath+$.name+ ".bns") types:"Enviroment files (*.env)|*.env"
		if  fname != undefined do saveSkinBonesToFile $ fname
	),
	fn loadSkinBones = (
		if $ == undefined do return false
		local fname = getOpenFileName caption: " Chose Load Skin Bones File..." filename:(maxFilePath+$.name+ ".bns") types:"Enviroment files (*.env)|*.env"
		if  fname != undefined  and doesFileExist fname do loadSkinBonesFromFile $ fname
	),




numBones = skinOps.GetNumberBones skinMod
sel_bone_index = skinOps.GetSelectedBone skinMod
skinOps.isBoneSelected skinMod 1

mirrorPaste
selectMirrorBones
copyWeights
skinOps.getSelectedBonePropEnvelopeVisible
skinOps.getSelectedBonePropRelative


getSelectedGizmoType
SelectVertices
GetListIDByBoneID
isRigidVertex
pasteToBone
mirrorPasteBone
updateMirror


fn copyPostures begin end = (
	
	local biped_ctrl = $[1].controller
	sliderTime = begin
	for i = 1 to (end-begin) do (
		
		biped.copyPosture biped_ctrl #posture true true true --(#posture | #pose | #track) <bool_horiz> <bool_vert> <bool_turn> 
		local pos_count = biped.numCopies biped_ctrl #posture
		local str_name = formattedPrint i format:"04d" --free Avguard Extensions. to get zerobased numbers
		biped.setCopyName biped_ctrl #posture pos_count str_name
		format "copy posture at frame:%\n" i
		--goto next frame
		sliderTime = begin+i
	)
)

fn pastePostures = (

	local biped_ctrl = $[1].controller
	local pos_count = biped.numCopies biped_ctrl #posture
	for i = 1 to pos_count	do (
	
		local string_name = biped.getCopyName biped_ctrl #posture i
		biped.pastePosture biped_ctrl #posture true string_name 
		format "paste posture:%\n" i
		--goto next frame
		sliderTime = i
	)
)

--copyPostures 111 146 --select all bones first 
pastePostures() --select all bones and enable autokey first
*/