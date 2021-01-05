Global mcCharTool
struct MICRA_CHARACTER_TOOL (
	
	fn getBoneByName boneName = (
		
		local boneString = getINISetting (Micra.RootDir + "Skeleton.ini") "BonesMatchPatern" boneName
		if boneString == "" do return undefined
		getNodeByName boneString
	),
	fn selectBone boneName = (
		
		if boneName == "none" do (
			
			max select none
			return OK
		)
		if boneName == "all" do (
			
			select (for o in objects where not o.isHidden and classOf o == Biped_Object collect o)
			return OK
		)
		local b = getBoneByName boneName
		if b == undefined then (
			
			format "Bone: [ % ] not found in Skeleton.ini or Scene!\n" boneName
			
		) else (
			
			--format "select bone: [ % ]\n" b.name
			select b
		)
	),
	fn selectSkinBone gco boneName = (
		
		if boneName == "none" or boneName == "all" do return OK
		local b = getBoneByName boneName
		if b == undefined then (
			
			format "Bone: [ % ] not found in Skeleton.ini or Scene!\n" boneName
			
		) else (
			
			--format "select skin bone: [ % ]\n" b.name
			mcCharSelectDialog.FlashPlayer.TGotoFrame boneName 1 --hilight flash bone
			local bonesCount = skinOps.GetNumberBones gco 
			local bone_index = for i=1 to bonesCount where (skinOps.GetBoneName gco i 0) == b.name do exit with i
			if classOf bone_index == Integer do skinOps.SelectBone gco bone_index
		)
	)
)
mcCharTool = MICRA_CHARACTER_TOOL()


--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

if mcCharSelectDialog != undefined then destroyDialog mcCharSelectDialog

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

rollout mcCharSelectDialog "Character Tool v0.04" width:250 height:335 (
	/* Locals */
	local dMove = false, DmPos
	-----------------------------------------------------------------------------
	ActiveXControl FlashPlayer "{D27CDB6E-AE6D-11CF-96B8-444553540000}" pos:[2,2] width:245 height:306
	spinner spnBend "" pos:[4,314] width:56 height:16 range:[-360,360,0] type:#integer scale:1
	checkbutton chkLibrary "Library" pos:[164,310] width:44 height:23
	radioButtons rdoAxis "" pos:[64,314] width:97 height:16 labels:#("X", "Y", "Z") columns:3
	fn executeFlashCommand key val = (
		
		format "executeFlashCommand > key:% val:%\n" key val
		local gco = modPanel.getCurrentObject()
		case key of (
			
			"zoom" : ""
			"setWeight" : ""
			"selBoneVerts": ""	
			"select": (
				
				if (classOf gco == Skin and subobjectLevel == 1)  
					then mcCharTool.selectSkinBone gco val 
					else mcCharTool.selectBone val
			)
		)
	)
	on mcCharSelectDialog open do  (
		
		FlashPlayer.movie = (Micra.RootDir + "App\\Character_Tool_Panda.swf")
	)
	on mcCharSelectDialog close do (
		
		mcFile.saveDialogSettings "mcCharSelectDialog" "Properties_2"
	)
	on mcCharSelectDialog rbuttonup pos do (DestroyDialog mcCharSelectDialog)
	-->MoveMode
	on mcCharSelectDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcCharSelectDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcCharSelectDialog mouseMove   pos do (
		
		if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcCharSelectDialog DmPos
	)
	--cmd_xml == "<invoke name="setWeight" returntype="xml"><arguments><string>0.0</string></arguments></invoke>"
	on FlashPlayer FlashCall cmd_xml do (
		
		format "FlashPlayer >  cmd:%\n" cmd_xml
		local xmlDoc = dotNetObject "system.xml.xmlDocument"
		xmlDoc.LoadXml cmd_xml
		--get key command
		local invoke = xmlDoc.selectsinglenode  "//invoke"
		if invoke == undefined do return false
		local key = (invoke.getattribute "name" )
		--get attribute value
		local arguments = xmlDoc.selectsinglenode  "//arguments/string"
		if arguments == undefined do return false
		local val = arguments.innertext
		executeFlashCommand key val
	)
)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
mcCall.createXMLDialog "mcCharSelectDialog" "Properties_2"
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--