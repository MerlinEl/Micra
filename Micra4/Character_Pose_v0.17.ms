
------------------
------------------
--	            --
--	Save  Pose  --
--	            --
------------------
------------------
Global ButtonTeleportSend
Global RollBody
Global RollHead
Global RollHands
Global mcPT_Active
Global mcPT_ThumbSize = [100,80]
--Dialog:------------------------------------------------------------------------
if mcCharPoseDialog != undefined then destroyDialog mcCharPoseDialog
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
/* Structure */
---------------------------------------------------------------------------------
struct mcPoseTool
(
	--Higlight Thumbs
	fn isActive tag = (tag == mcPT_Active),
	fn rdoHandDialog =
	(
		global rdohDialogData
		if rdohDialog != undefined then destroyDialog rdohDialog
		rollout rdohDialog "" width:140 height:80
		(
			GroupBox grp1 "Chose Hand:" pos:[4,4] width:132 height:72
			radiobuttons rdoHand "" pos:[20,24] width:104 height:16 labels:#("Left", "Right") columns:2
			button btnOK "Accept" pos:[72,48] width:56 height:20
			button btnNo "Cancel" pos:[12,48] width:56 height:20
			on btnOK pressed  do
			(
				local handPart = case rdoHand.state of
				(
					1:"HandL"
					2:"HandR"
				)
				destroyDialog rdohDialog
				rdohDialogData = handPart
			)
			on btnNo pressed do (rdohDialogData = "" ; destroyDialog rdohDialog)
		)
		createDialog rdohDialog style:#(#style_border) modal:true
		local data = rdohDialogData ; rdohDialogData = undefined
		return data
	),
	fn higlightThumb tag color force:false =
	(
		if (mcPoseTool.isActive tag and force == false) do return false

		local bmp = tag.bitmap
		local size = mcPT_ThumbSize - [1,1]
		
		for tb=0 to size.x do --top bottom
		( 
			setpixels bmp [tb,0] #(color)
			setpixels bmp [tb,size.y] #(color)
		)
		for lr=0 to size.y do --left right 
		(
			setpixels bmp [0,lr] #(color)
			setpixels bmp [size.x,lr] #(color)
		)
		tag.bitmap = bmp
	),
	fn clearSelection = (mcPT_Active.bitmap = mcPoseTool.higlightThumb mcPT_Active (color 153 153 153) force:true),
	fn savePose lbl = 
	(
		local mask = lbl[6] 
		local thePath = Micra.UserDir+"Pose"
		local iniFile = thePath + "\\" + lbl + ".ini"
		local bmpFile = thePath + "\\" + lbl + ".jpg"
		
		local theBoneArray = case mask of
		(
			"B": (mcCharTool.getBonesTree "Body")
			"H": (if (local m = mcPoseTool.rdoHandDialog()) != "" then mcCharTool.getBonesTree m else #())
			"F": (mcCharTool.getBonesTree "Face")
		)
		
		if theBoneArray.count == 0 do return false
		
		if not doesFileExist thePath do (makeDir thePath)
		if not doesFileExist iniFile then (local f = createfile iniFile) else (local f = openFile iniFile mode:"w")

		case mask of
		(
			"B":
			(
				format "[%]\n" (lbl+"Rot") to:f
				for i in theBoneArray do (format "%\t= [%, %, %]\n" i.name (in coordsys parent i.rotation.x_rotation) \
				(in coordsys parent i.rotation.y_rotation) (in coordsys parent i.rotation.z_rotation )to:f)
			)
			"H":
			(
				format "[%]\n" (lbl+"Rot") to:f
				for i in theBoneArray do (format "%\t= [%, %, %]\n" i.name (in coordsys parent i.rotation.x_rotation) \
				(in coordsys parent i.rotation.y_rotation) (in coordsys parent i.rotation.z_rotation )to:f)
			)
			"F":
			(
				format "[%]\n" (lbl+"Rot") to:f
				for i in theBoneArray do (format "%\t= [%, %, %]\n" i.name (in coordsys parent i.rotation.x_rotation) \
				(in coordsys parent i.rotation.y_rotation) (in coordsys parent i.rotation.z_rotation )to:f)
				format "[%]\n" (lbl+"Pos") to:f
				for i in theBoneArray do (format "%\t= %\n" i.name (in coordsys parent i.pos) to:f)
			)
		)
		close f

		local oldBgColor = backgroundColor
		backgroundColor = color 153 153 153
		--Render to file
		mcPT_Active.bitmap = (render outputsize:[mcPT_ThumbSize.x,mcPT_ThumbSize.y] antiAliasing:on \
		enablePixelSampler:off shadows:off quiet:on outputFile:bmpFile vfb:off) 
		
		backgroundColor = oldBgColor	
	),
	fn loadThumbs =
	(
		local bmpFiles = getFiles (Micra.UserDir+"Pose" + "\\*.jpg")
		
		if bmpFiles.count == 0 do return false
		
		for b in bmpFiles do 
		(
			local theName = mcFile.get b #name
			local mask = theName[6]
			local maskRoll = case mask of
			(
				"B":"Body" 
				"H":"Hands"
				"F":"Face"
			)
			if maskRoll == undefined do return false
			local tag = (execute("roll"+maskRoll+".tag_" + (filterString theName "_")[2])) 
			tag.bitmap = openBitMap b
		)
	),
	fn rotate boneObj rot oposite:undefined =
	(
		if oposite == undefined then
		(
			in coordsys parent boneObj.rotation.x_rotation = ((execute rot).x)
			in coordsys parent boneObj.rotation.y_rotation = ((execute rot).y)
			in coordsys parent boneObj.rotation.z_rotation = ((execute rot).z)
		)
		else
		(
			in coordsys parent boneObj.rotation.x_rotation = -((execute rot).x)
			in coordsys parent boneObj.rotation.y_rotation = -((execute rot).y)
			in coordsys parent boneObj.rotation.z_rotation = ((execute rot).z)
		)
		--format "%\t= [%, %, %]\n" boneObj.name boneObj.rotation.x_rotation boneObj.rotation.y_rotation boneObj.rotation.z_rotation
	),
	fn loadPose lbl =
	(
		local mask = lbl[6] 
		local iniFile = Micra.UserDir+"Pose" + "\\" + lbl + ".ini"
		--format "label:%\tfile:%\n" lbl iniFile
		local maskArray = case mask of
		(
			"B": #("Rot")
			"H": #("Rot")
			"F": #("Rot","Pos")
		)
		
		if not doesFileExist iniFile do return false
		
		local bones = (getINISetting iniFile (lbl+maskArray[1]))
		
		if mask == "H" do (local m = mcPoseTool.rdoHandDialog())
		
		for b in bones do
		(
			local boneObj = getNodeByName b
			--format "BoneString:%\tBoneObj:%\n" b boneObj
			if boneObj != undefined do
			(
				local theRot = (getINISetting iniFile (lbl+maskArray[1]) b)
				
				case mask of
				(
					"B": (if theRot != "" do (mcPoseTool.rotate boneObj theRot))
					"H":
					(
						if m != "" do
						(
							case m of
							(
								"HandL":
								(
									if b[1] == "L" --if ini data is from left hand 
									then (mcPoseTool.rotate boneObj theRot) 
									else 
									(
										local boneObjInv = getNodeByName ("Left"+(substring b 6 -1))
										if boneObjInv != undefined do mcPoseTool.rotate boneObjInv theRot oposite:true	
									)
								)
								"HandR":
								(
									if b[1] == "R" --if ini data is from right hand
									then (mcPoseTool.rotate boneObj theRot) 
									else 
									(
										local boneObjInv = getNodeByName ("Right"+(substring b 5 -1))
										if boneObjInv != undefined do mcPoseTool.rotate boneObjInv theRot oposite:true
									)
								)
							)
						)
					)
					"F":
					(
						local thePos = (getINISetting iniFile (lbl+maskArray[2]) b)
						if thePos != "" do (in coordsys parent boneObj.pos = (execute thePos))
						if theRot != "" do (mcPoseTool.rotate boneObj theRot)	
						--format "obj:%\tposition:%\trotation:%\n" boneObj thePos theRot	
					)
				)
			)
		)
	),
	fn deletePose lbl =
	(
		local thePath = Micra.UserDir+"Pose"
		local iniFile = thePath + "\\" + lbl + ".ini"
		local bmpFile = (thePath + "\\" + lbl + ".jpg")
 
		if doesFileExist iniFile do deleteFile iniFile
		if doesFileExist bmpFile do deleteFile bmpFile
		
		mcPT_Active.bitmap = bitmap mcPT_ThumbSize.x mcPT_ThumbSize.y color:(color 153 153 153)
	),
	fn setLabelName lbl =
	(
		ButtonTeleportSend = #("Pose Name:")
		mcFile.fileInVersion "Text_Box"
		if ButtonTeleportGet != undefined and ButtonTeleportGet != "" do 
		(
			lbl.text = ButtonTeleportGet
			setINISetting (Micra.UserDir + "User.ini") "BodyLabels" lbl.name ButtonTeleportGet
		)
		ButtonTeleportGet = undefined
		ButtonTeleportSend = undefined
	),
	fn inicializeLabels =
	(
		local lblKeys = getINISetting (Micra.UserDir + "User.ini") "BodyLabels"

		for i in lblKeys do
		(
			local mask = i[5]
			local maskRoll = case mask of
			(
				"B":"Body" 
				"H":"Hands"
				"F":"Face"
			)
			local lblData = getINISetting (Micra.UserDir + "User.ini") "BodyLabels" i
			if lblData != undefined and lblData != "" do 
			(
				(execute ("roll"+maskRoll+"." + i)).text = lblData
			)
		)
	),
	fn manageThumbnails tag lbl=
	(
		mcPoseTool.clearSelection()
		mcPT_Active = tag
		
		if keyboard.controlPressed then (mcPoseTool.savePose mcPT_Active.text)
		else if keyboard.altPressed then (mcPoseTool.deletePose mcPT_Active.text)
		else if keyboard.shiftPressed do (mcPoseTool.setLabelName lbl)
		
		mcPoseTool.higlightThumb tag red force:true
	),
	fn inicializeInterface height =
	(
		mcCharPoseDialog.subRoll.height = (height - 40)
	)
)

---------------------------------------------------------------------------------
/* Rollout */
---------------------------------------------------------------------------------
rollout mcCharPoseDialog " Save  Pose v0.1" width:146 height:388
(
	-----------------------------------------------------------------------
	/* Locals */
	-----------------------------------------------------------------------
	local dMove = false, DmPos
	local thBlank = (bitmap 100 80 color:(color 153 153 153))
	-----------------------------------------------------------------------------	
	
	button brnSettings "Human Pose Tool" pos:[22,8] width:100 height:20
	--button btnClose "x" pos:[130,8] width:14 height:14
	subrollout subRoll "" pos:[4,28] width:134 height:(388 - 30)
	----------------------------------------------------------------------------
	/* Thumbs Rollout */
	----------------------------------------------------------------------------
	fn inicializeSubrollout name thumbNums mask =
	(
		if name == "" or thumbNums == 0 do return false
		
		local newRoll = "rollout roll"+ name + " \"" + name + "\" width:368 height:1000\n"
		newRoll +="(\n"
		newRoll += "\tlocal thBlank = (bitmap 100 80 color:(color 153 153 153))\n"
		newRoll += "\tlocal mcPT_ThumbSize  = "+mcPT_ThumbSize as string+"\n"
		--Multiply items
		for n=1 to thumbNums do
		(
			local nu = mask + n as string
			--Items (rollout)
			newRoll +="\tImgTag tag_" +nu+ " \"Pose_" +nu+ "\" width:mcPT_ThumbSize.x height:mcPT_ThumbSize.y bitmap:thBlank\n"
			newRoll +="\tlabel  lbl_" +nu+ " \"Pose_" +nu+ "\" width:61 height:13\n"
			--Tags (buttons)
			newRoll +="\ton tag_"+nu+" mouseup   do (mcPoseTool.manageThumbnails tag_"+nu+" lbl_"+nu+")\n"
			newRoll +="\ton tag_"+nu+" mouseover do (mcPoseTool.higlightThumb tag_"+nu+" yellow)\n"
			newRoll +="\ton tag_"+nu+" mouseout  do (mcPoseTool.higlightThumb tag_"+nu+" (color 153 153 153))\n"
			newRoll +="\ton tag_"+nu+" dblclick  do undo \"pose\" on (mcPoseTool.loadPose mcPT_Active.text)\n"
		)
		newRoll +=")\n"
		AddSubRollout subRoll (execute newRoll)
	)
	-----------------------------------------------------------------------
	/* DialogProp */
	-----------------------------------------------------------------------
	--ON OPEN
	on mcCharPoseDialog open do
	(
		/*
		Fn Get_IniData cat_1 cat_2 item =
		(
			if ((getINISetting (mPath()+"User.ini") cat_1 item ) == "")
			then return (getINISetting (mPath()+"Micra.ini") cat_2 item)
			else return (getINISetting (mPath()+"User.ini" ) cat_1 item)
		)
		--Call: (Get_IniData "CustomMicra" "DefaultMicra" "DialogSnap") == "on" 
		*/
		local bodyCount  = execute (Get_IniData "CustomPoseTool" "DefaultPoseTool" "Body")
		local handsCount = execute (Get_IniData "CustomPoseTool" "DefaultPoseTool" "Hands")
		local faceCount  = execute (Get_IniData "CustomPoseTool" "DefaultPoseTool" "Face")
		
		inicializeSubrollout "Body" bodyCount "B"
		inicializeSubrollout "Hands" handsCount "H"
		inicializeSubrollout "Face" faceCount "F"
		
		mcPoseTool.inicializeLabels()
 		mcPoseTool.loadThumbs()
		mcPT_Active = rollBody.tag_B1; mcPoseTool.higlightThumb rollBody.tag_B1 red force:true
		mcPoseTool.inicializeInterface (mcCharPoseDialog.height)
		
		charSelectDialog.chkLibrary.checked = on
	)
	--ON Close
	on mcCharPoseDialog close do 
	(
		mcFile.saveDialogSettings "mcCharPoseDialog" "Properties_2"
		charSelectDialog.chkLibrary.checked = off
	)
	--ON RMB 
   on mcCharPoseDialog rbuttonup pos do
	(
		DestroyDialog mcCharPoseDialog
	)
	on mcCharPoseDialog resized size do
	(
		if size.x > 146 or size.x < 146 then 
		(
			destroyDialog mcCharPoseDialog
			micra.createIniDialog "mcCharPoseDialog" "#(#style_resizing)"
			mcCharPoseDialog.width = 146
		)
		else (mcPoseTool.inicializeInterface size.y)
	)
	-->MoveMode
	on mcCharPoseDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcCharPoseDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcCharPoseDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcCharPoseDialog DmPos
	)
	-----------------------------------------------------------------------
	/* Actions */
	-----------------------------------------------------------------------
	--Close Dialog
	on btnClose pressed do (DestroyDialog mcCharPoseDialog ; chkLibrary.checked == off)
	on brnSettings pressed do
	(
		if hptsDialog != undefined then destroyDialog hptsDialog
		rollout hptsDialog "Settings" width:184 height:244
		(
			local dMove = false, DmPos
			GroupBox grp1 "Help:" pos:[4,96] width:176 height:116
			label lbl_1 "1) Add New Pose : CTRL  + LMB" pos:[16,116] width:160 height:16
			label lbl_2 "2) Remove Pose  :  ALT    + LMB" pos:[16,136] width:160 height:16
			label lbl_3 "3) Load Pose       :  LMB Double" pos:[16,156] width:160 height:16
			label lbl31 "3) Put a Name     :  SHIFT + LMB" pos:[16,176] width:160 height:16
			label lbl_4 "thumbs" pos:[136,24] width:36 height:16
			label lbl_5 "thumbs" pos:[136,44] width:40 height:16
			label lbl_6 "thumbs" pos:[136,64] width:40 height:16
			
			GroupBox grp2 "Settings:" pos:[4,4] width:176 height:88
			label lb_7 "Body   :" pos:[16,24] width:40 height:16
			spinner spnBody "" pos:[56,24] width:76 height:16 range:[0,50,0] type:#integer scale:1
			label lb_8 "Hands :" pos:[16,44] width:40 height:16
			spinner spnHands "" pos:[56,44] width:76 height:16 range:[0,50,0] type:#integer scale:1
			label lb_9 "Face   :" pos:[16,64] width:40 height:16
			spinner spnFace "" pos:[56,64] width:76 height:16 range:[0,50,0] type:#integer scale:1
			button btnAccept "Accept" pos:[100,216] width:80 height:24
			button btnCancell "Cancell" pos:[4,216] width:80 height:24
			
			on hptsDialog open do
			(
				spnBody.value = execute (getIniSetting Micra.UserSettings "PoseTool" "Body")
				spnHands.value = execute (getIniSetting Micra.UserSettings "PoseTool" "Hands")
				spnFace.value = execute (getIniSetting Micra.UserSettings "PoseTool" "Face")
			)
			on hptsDialog rbuttonup pos do (DestroyDialog hptsDialog)
			-->MoveMode
			on hptsDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
			on hptsDialog lbuttonup   pos do (dMove = false; pushprompt "")
			on hptsDialog mouseMove   pos do
			(
				if dMove and keyboard.shiftPressed do mcDialog.snapDialog hptsDialog DmPos
			)
			on btnAccept pressed  do
			(
				local bodyCount  = spnBody.value
				local handsCount = spnHands.value
				local faceCount  = spnFace.value
				
				if bodyCount > 0 and handsCount > 0 and faceCount > 0 do
				(
					setINISetting (Micra.UserDir + "User.ini") "CustomPoseTool" "Body" (bodyCount as string)
					setINISetting (Micra.UserDir + "User.ini") "CustomPoseTool" "Hands" (handsCount as string)
					setINISetting (Micra.UserDir + "User.ini") "CustomPoseTool" "Face" (faceCount as string)
					DestroyDialog mcCharPoseDialog
					mcFile.fileInVersion "Character_Pose"
					DestroyDialog hptsDialog
				)
			)
			on btnCancell pressed  do (DestroyDialog hptsDialog)
		)
		createDialog hptsDialog style:#(#style_border)
	)
)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
mcCall.createXMLDialog "mcCharPoseDialog" "Properties_2" style:#(#style_resizing)
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--

--**\ Created by Merlin el' 7/20/2006 4:22:29 PM /**--
