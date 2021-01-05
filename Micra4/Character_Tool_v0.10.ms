
-----------------------
-----------------------
--	                 --
--	Character Tools  --
--	                 --
-----------------------
-----------------------
Global mcCT_BoneArray = #()
Global mcCT_BoneRot
Global mcCT_lastRot = 0
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

if mcCharSelectDialog != undefined then destroyDialog mcCharSelectDialog

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

/* Structure */
struct mcCharTool
	(
		fn filterValidNodes arr = (for i in arr where isValidNode i collect i),
		fn getFlashIniKeys head = (getINISetting (Micra.RootDir + "Skeleton.ini") head),
		fn translateFlashKey key = (getINISetting (Micra.RootDir + "Skeleton.ini") "BonesMatchPatern" key),
		fn getBonesTree head =
		(
			--Translation from ini and create obj array
			local theArray = #()
			local flashIniKeys = mcCharTool.getFlashIniKeys head
			for k in flashIniKeys do
			(
				local boneObj = getNodeByName (getINISetting (Micra.RootDir + "Skeleton.ini") head k)
				if boneObj != undefined do append theArray boneObj
			)
		 	return theArray
		),
		fn higlightButtons num = 
		(
			local keys = mcCharTool.getFlashIniKeys "BonesMatchPatern" 
			for k in keys do mcCharSelectDialog.axFlash.TGotoFrame k num
		),
		fn getBoneFromSelItem =
		(
			local mod = modPanel.getCurrentObject()
			if classOf mod != Skin do return undefined

			local selBoneNum = skinOps.GetSelectedBone mod
			if selBoneNum > 0 do getNodeByName (skinOps.GetBoneName mod selBoneNum 0)
		),
		fn selectBoneFrom boneName =
		(
			local mod = modPanel.getCurrentObject()
			if classOf mod != Skin do return undefined
			
			local bonesCount = skinOps.GetNumberBones mod 
			for i=1 to bonesCount where 
			(
				(skinOps.GetBoneName mod i 0) == boneName
			) 
			do (skinOps.SelectBone mod i) 
		),
		
		fn zoomTo obj part = 
		(
			if not isValidNode obj do return false
			local pers =(viewPort.getType() == #view_persp_user)
			local user =(viewport.getType() == #view_iso_user)
			if not pers or not user do (viewport.setType #view_persp_user)
			--Thre is a matrix + distance for zoom out
			local tm = case part of
			(
				#Head:#((matrix3 [-1,0,0] [0,0,1] [0,1,0] [0,0,0]),6)
				#Body:#((matrix3 [-1,0,0] [0,0,1] [0,1,0] [0,0,0]),65)
				#LHand:#((matrix3 [-0.32,0.34,-0.88] [-0.94,-0.12,0.3] [0,0.93,0.36] [0,0,0]),5)
				#RHand:#((matrix3 [-0.56,-0.24,0.78] [0.82,-0.17,0.55] [0,0.96,0.23] [0,0,0]),5)
			)
			viewport.setTM tm[1]
			--tm.row4 = obj.dir
			Viewport.ZoomToBounds false (obj.min-[0,0,tm[2]]) (obj.max+[0,0,tm[2]])
		),
		
		fn setOpositeRotationInParent obj rot = 
		(
			in coordsys parent obj.rotation.x_rotation = -rot.x
			in coordsys parent obj.rotation.y_rotation = -rot.y
			in coordsys parent obj.rotation.z_rotation = rot.z
		),
		
		fn getRotationInParent obj = 
		(
			in coordsys parent [obj.rotation.x_rotation,obj.rotation.y_rotation,obj.rotation.z_rotation]
		),
		
		fn copyRotation type =
		(
			local flashIniKeys = mcCharTool.getFlashIniKeys "Mirror"
			undo "Mirror Bones" on for k in flashIniKeys do 
			(
				local LBon= getNodeByName (mcCharTool.translateFlashKey ( "fl_Left"  + k ))
				local RBon= getNodeByName (mcCharTool.translateFlashKey ( "fl_Right" + k ))

				if LBon != undefined and Rbon != undefined do
				(
					case type of
					(
						#left:
						(
								local rot = mcCharTool.getRotationInParent LBon
								mcCharTool.setOpositeRotationInParent RBon rot
						)
						#right:
						(
								local rot = mcCharTool.getRotationInParent RBon
								mcCharTool.setOpositeRotationInParent LBon rot
						)
					)
				)
			)
		),
		
		fn getBones iniKey type:undefined =
		(
			local theBone
			local boneString = getINISetting (Micra.RootDir + "Skeleton.ini") "BonesMatchPatern" iniKey
			if boneString == "" 
			then (messagebox ("Missing data: "+iniKey+" in Skeleton.ini.") title:" Micra!" ; return undefined)
			else (theBone = getNodeByName boneString)
				 
			--format "type:%\tiniKey:%\tboneString:%\n" type iniKey boneString
			case type of
			(
				"select":
				( 
					if theBone == undefined do (messagebox ("Missing bone: "+boneString) title:" Micra!" ; return undefined)
					
					if keyboard.controlPressed and not (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						local num = findItem mcCT_BoneArray theBone
						if num == 0 do append mcCT_BoneArray theBone
						mcCharSelectDialog.axFlash.TGotoFrame iniKey 1
						mcCharSelectDialog.axFlash.TCurrentFrame iniKey -- for redraw fsCommand (bug)
					)
					else 
					(
						mcCharTool.higlightButtons 0
						mcCT_BoneArray = #(theBone)
						
						mcCharSelectDialog.axFlash.TGotoFrame iniKey 1
						mcCharSelectDialog.axFlash.TCurrentFrame iniKey -- for redraw fsCommand (bug)
					) 
				)
				"unselect":
				(
					local num = findItem mcCT_BoneArray theBone
					if num != 0 do deleteItem mcCT_BoneArray num
					
					mcCharSelectDialog.axFlash.TGotoFrame iniKey 0
					mcCharSelectDialog.axFlash.TCurrentFrame iniKey -- for redraw fsCommand (bug)
				)
				"zoomFace" : 
				(
					mcCharTool.zoomTo $Head #Head
					mcCharSelectDialog.axFlash.GotoFrame 3
					mcCT_BoneArray = #(theBone)
				)
				"zoomLHand": 
				(
					mcCharTool.zoomTo $LeftHandMiddle1 #LHand
					mcCharSelectDialog.axFlash.GotoFrame 1
					mcCT_BoneArray = #(theBone)
				)
				"zoomRHand": 
				(
					mcCharTool.zoomTo $RightHandMiddle1 #RHand
					mcCharSelectDialog.axFlash.GotoFrame 2
					mcCT_BoneArray = #(theBone)
				)
				"zoomBody":
				(
					mcCharTool.zoomTo $Hips #Body
					mcCharSelectDialog.axFlash.GotoFrame 0
					mcCT_BoneArray = #(theBone)
				)
			)
			return mcCT_BoneArray
		),
		fn Execute param = 
		(
			case param of
			(
				"selectAll":
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)do return undefined
					mcCT_BoneArray = mcCharTool.getBonesTree "BonesMatchPatern"
					mcCharTool.higlightButtons 1
					select mcCT_BoneArray
				)
				"unselectAll":
				(
					mcCT_BoneArray = #()
					mcCharTool.higlightButtons 0
				)
				"hideAll":
				(
					for o in objects where classOf o == BoneGeometry do hide o
					mcCharSelectDialog.axFlash.TGotoFrame "HideUnhide" 1
					mcCharSelectDialog.axFlash.TCurrentFrame "HideUnhide" -- for redraw fsCommand (bug)
				)
				"unhideAll":
				(
					for o in objects where classOf o == BoneGeometry do unhide o
					mcCharSelectDialog.axFlash.TGotoFrame "HideUnhide" 0
					mcCharSelectDialog.axFlash.TCurrentFrame "HideUnhide" -- for redraw fsCommand (bug)
				)
				"copyLR":( mcCharTool.copyRotation #left  )
				"copyRL":( mcCharTool.copyRotation #right )
				"Exit":(DestroyDialog mcCharSelectDialog)
				"selBoneVerts":
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Select Verts By Bone" on skinOps.selectVerticesByBone (modPanel.GetcurrentObject())
					)
				)
				"excludeBoneVerts":
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Exclude Selected Verts" on skinOps.ButtonExclude (modPanel.GetcurrentObject())
					)
				)
				"scaleWeightUp":
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Scale Weights" on skinOps.ScaleWeight  (modPanel.GetcurrentObject()) 1.05
					)
				)
				"scaleWeightDown":
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Scale Weights" on skinOps.ScaleWeight  (modPanel.GetcurrentObject()) 0.95
					)
				)
				"0.0" :
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Scale Weights" on skinOps.SetWeight  (modPanel.GetcurrentObject()) 0.0
					)
				)
				"0.1" :
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Scale Weights" on skinOps.SetWeight  (modPanel.GetcurrentObject()) 0.1
					)
				)
				"0.25":
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Scale Weights" on skinOps.SetWeight  (modPanel.GetcurrentObject()) 0.25
					)
				)
				"0.5" :
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Scale Weights" on skinOps.SetWeight  (modPanel.GetcurrentObject()) 0.5
					)
				)
				"0.75":
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Scale Weights" on skinOps.SetWeight  (modPanel.GetcurrentObject()) 0.75
					)
				)
				"0.9" :
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Scale Weights" on skinOps.SetWeight  (modPanel.GetcurrentObject()) 0.9
					)
				)
				"1.0"   :
				(
					if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
					(
						undo "Scale Weights" on skinOps.SetWeight  (modPanel.GetcurrentObject()) 1.0
					)
				)
			)
		),
		fn updateSelection =
		(
			--For (Flash Bone Buttons) in (Max Bone Objects) check for Selection
			local flashIniKeys = getINISetting (Micra.RootDir + "Skeleton.ini") "BonesMatchPatern"
			for k in flashIniKeys do
			(
				local valid = false
				local boneString = (getINISetting (Micra.RootDir + "Skeleton.ini") "BonesMatchPatern" k)
				for o in objects where (o.name == boneString and o.isSelected) do (valid = true)
				if valid == true
				then (mcCharSelectDialog.axFlash.TGotoFrame k 1)
				else (mcCharSelectDialog.axFlash.TGotoFrame k 0)
			)			
		)
)

rollout mcCharSelectDialog "Character Tool v0.02" width:212 height:388
(
	/* Locals */
	local dMove = false, DmPos
	-----------------------------------------------------------------------------
	ActiveXControl axFlash "{D27CDB6E-AE6D-11CF-96B8-444553540000}" pos:[4,4] width:202 height:350
	spinner spnBend "" pos:[4,364] width:56 height:16 range:[-360,360,0] type:#integer scale:1
	checkbutton chkLibrary "Library" pos:[164,360] width:44 height:23
	radioButtons rdoAxis "" pos:[64,364] width:97 height:16 labels:#("X", "Y", "Z") columns:3
	/* Dialog */
	--ON OPEN
	on mcCharSelectDialog open do  
	(
		axFlash.movie = (Micra.RootDir + "App\\Character_Tool_Woman.swf")
		
		callbacks.addScript #SelectionSetChanged " mcCharTool.updateSelection() " id:#mcCT_Callbacks
		callbacks.addScript #sceneUndo           " mcCharTool.updateSelection() " id:#mcCT_Callbacks
		callbacks.addScript #sceneRedo           " mcCharTool.updateSelection() " id:#mcCT_Callbacks
		callbacks.addScript #nodePostDelete      " mcCharTool.updateSelection() " id:#mcCT_Callbacks
	)

	--ON Close
	on mcCharSelectDialog close do
	(
		if charPoseDialog != undefined then destroyDialog charPoseDialog
		mcFile.saveDialogSettings "mcCharSelectDialog" "Properties_2"
		callbacks.removeScripts id:#mcCT_Callbacks
		mcCT_BoneArray = Undefined
		mcPoseTool = undefined
		mcCharTool = undefined
		RollBody = undefined
		RollHead = undefined
		RollHands = undefined
		mcPT_Active = undefined
		mcPT_ThumbSize = undefined
		mcCT_BoneRot
		mcCT_lastRot
		
	)
	--ON RMB 
	on mcCharSelectDialog rbuttonup pos do (DestroyDialog mcCharSelectDialog)
	-->MoveMode
	on mcCharSelectDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcCharSelectDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcCharSelectDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcCharSelectDialog DmPos
	)
--Actions -----------------------------------------------------------------------
	on axFlash FSCommand command param do --undo "Character Tool" on
	( 
		--format "FSCommand: %\t%\n" command param

		if  command != "undefined" then
		(
			if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1) 
			then --Select bones in skin
			(
				local arr = mcCharTool.getBones command type:param
				local boneName = (getINISetting (Micra.RootDir + "Skeleton.ini") "BonesMatchPatern" command)
				mcCharTool.selectBoneFrom boneName	
			)
			else --Select bone objects
			(
				local arr = mcCharTool.getBones command type:param
				--format "array:%\n" arr
				if arr != undefined and arr.count > 0 then select (mcCharTool.filterValidNodes arr) else max select none
			)
		)
		else ( mcCharTool.Execute param )
	)
	on btnLR pressed do undo "CopyLR" on (mcCharTool.copyRotation ArmLeg #left)
	on btnRL pressed do undo "CopyRL" on (mcCharTool.copyRotation ArmLeg #right)
	on chkLibrary changed state do 
	(
		if chkLibrary.checked
		then (mcFile.fileInVersion "Character_Pose")
		else (if charPoseDialog != undefined then destroyDialog charPoseDialog)
	)
	on spnBend buttondown do
	(
		local sel = mcCharTool.getBoneFromSelItem()
		if sel != undefined and subobjectLevel == 1 do (mcCT_BoneRot = sel.transform)
	)
	on spnBend changed val do
	(
		local sel = mcCharTool.getBoneFromSelItem()
		local rotAxis = rdoAxis.state
		local rotAmount = eulerangles 0 0 0
		
		if sel != undefined and subobjectLevel == 1 do
		(
			local rotAmount = case rotAxis of
			(
				1: eulerangles (val - mcCT_lastRot) 0 0
				2: eulerangles 0 (val - mcCT_lastRot) 0
				3: eulerangles 0 0 (val - mcCT_lastRot)
			)		
			in coordsys local rotate sel rotAmount
			mcCT_lastRot = val
		)
	)
	on spnBend buttonup do
	(
		local sel = mcCharTool.getBoneFromSelItem()
		if sel != undefined and subobjectLevel == 1 do
		(
			sel.transform = mcCT_BoneRot
			spnBend.value = 0
			mcCT_lastRot = 0
		)
	)
)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
mcCall.createXMLDialog "mcCharSelectDialog" "Properties_2"
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

--**\ Created by Merlin el' 7/17/2006 2:10:25 PM /**--

/*
		--callbacks.addScript #filePostOpen        "print 2;  mcCharTool.updateSelection clean:true " id:#mcCT_Callbacks	
		--callbacks.addScript #systemPostReset     "print 3;  mcCharTool.updateSelection clean:true " id:#mcCT_Callbacks
		--callbacks.addScript #nodeHide            " mcCharTool.updateSelection() " id:#mcCT_Callbacks
		--callbacks.addScript #nodeUnhide          " mcCharTool.updateSelection() " id:#mcCT_Callbacks	
if (classOf (modPanel.getCurrentObject()) == Skin and subobjectLevel == 1)then
(
	local boneNum = skinOps.GetSelectedBone $.modifiers[#Skin]
	local boneName = skinOps.GetBoneName $.modifiers[#Skin] boneNum 0
	print bonename
	--mcCharSelectDialog.axFlash.TGotoFrame boneName 1
)
else

*/
/*
(
	local sel = selection as array
	for i=2 to sel.count-1 do
	(
		sel[i].rotation.controller = Orientation_Constraint ()
		sel[i].rotation.controller.relative = on
		sel[i].rotation.controller.weight[2] = 91
		sel[i].rotation.controller.local_world = 1
		sel[i].rotation.controller.appendTarget sel[i-1] 1
	)
	select sel[1]
)
*/
/*
viewport.getTM()
xxx.axFlash.TotalFrames
xxx.axFlash.TGotoFrame "Head" 1
xxx.axFlash.TGotoFrame "Head" 0
*/

/* --properties
  .ReadyState : integer, read-only
  .TotalFrames : integer, read-only
  .Playing : boolean
  .Quality : undefined
  .ScaleMode : undefined
  .AlignMode : undefined
  .BackgroundColor : integer
  .Loop : boolean
  .Movie : string
  .FrameNum : integer
  .WMode : string
  .SAlign : string
  .Menu : boolean
  .Base : string
  .Scale : string
  .DeviceFont : boolean
  .EmbedMovie : boolean
  .BGColor : string
  .Quality2 : string
  .SWRemote : string
  .FlashVars : string
  .AllowScriptAccess : string
  .MovieData : string
  .InlineData : undefined
  .SeamlessTabbing : boolean
  .Profile : boolean
  .ProfileAddress : string
  .ProfilePort : integer
 */
 /* -- methods
   .SetZoomRect left:integer top:integer right:integer bottom:integer
  .Zoom factor:undefined
  .Pan x:integer y:integer mode:undefined
  .Play()
  .Stop()
  .Back()
  .Forward()
  .Rewind()
  .StopPlay()
  .GotoFrame FrameNum:integer
  .CurrentFrame()
  .IsPlaying()
  .PercentLoaded()
  .FrameLoaded FrameNum:integer
  .FlashVersion()
  .LoadMovie layer:undefined url:string
  .TGotoFrame target:string FrameNum:integer
  .TGotoLabel target:string label:string
  .TCurrentFrame target:string
  .TCurrentLabel target:string
  .TPlay target:string
  .TStopPlay target:string
  .SetVariable name:string value:string
  .GetVariable name:string
  .TSetProperty target:string property:undefined value:string
  .TGetProperty target:string property:undefined
  .TCallFrame target:string FrameNum:undefined
  .TCallLabel target:string label:string
  .TSetPropertyNum target:string property:undefined value:float
  .TGetPropertyNum target:string property:undefined
  .TGetPropertyAsNumber target:string property:undefined
  .EnforceLocalSecurity()
  .CallFunction request:string
  .SetReturnValue returnValue:string
  .DisableLocalSecurity()
 */
 