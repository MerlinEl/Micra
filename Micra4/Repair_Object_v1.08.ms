------------------------
------------------------
--                    --
--    Repair_Object   --
--                    --
------------------------
------------------------
----------------------------------------------------------------------------
if mcRepairDialog != undefined do DestroyDialog mcRepairDialog
----------------------------------------------------------------------------
rollout mcRepairDialog "" width:332 height:128
(
	-------------------------------------------------------------------------
	local n, p, s, tmp, sel,oName_1, cfgPath, AutExe, f
	local ver = getIniSetting mcDefaultINI "Version" "Repair_Object" 
	local dMove = false, DmPos
	-------------------------------------------------------------------------
	GroupBox grp_1 "" pos:[4,4] width:324 height:120
	radiobuttons rdo_1 "" pos:[20,40] width:126 height:48 labels:#("Standart Micra Repair", "Export/Import", "Merge to New Scene") default:1 columns:1
	button btn_1 "Cancel" pos:[12,96] width:60 height:20 
	button btn_2 "Accept" pos:[260,96] width:60 height:20
	GroupBox grp2 "Chose Type:" pos:[12,20] width:152 height:72
	GroupBox grp3 "Standart Custom:" pos:[168,20] width:152 height:72
	checkbox chkSaveLinks "Save Links" pos:[180,40] width:100 height:16 checked:true
	checkbox chkSaveWire "Save Wirecolor" pos:[180,56] width:100 height:16
	checkbox chkSaveLayer "Save Layer" pos:[180,72] width:100 height:16 checked:true
	fn saveLinks nodes =
	(
		if nodes.count == 0 do return #()
		struct tree (nodeName,parentName)
		local data =#()
		for n in nodes do
		(
			local p = if n.parent == undefined then "" else n.parent.name
			append data (tree n.name p)
		)
		return data
	)
	fn loadLinks data =
	(
		if data.count == 0 do return OK
		for d in data do
		(
			local n=getNodeByName d.nodeName
			local p=getNodeByName d.parentName
			if n == undefined do continue
			if d.nodeName == "" then
				n.parent = undefined
			else
				n.parent = if p == undefined then undefined else p
		)
	)
	on mcRepairDialog open          do 
	(
		grp_1.text = " Repair Object v"+ver
		--chkSaveLinks.checked = execute (Get_IniData "CustomMicra" "DefaultMicra" "SaveLinks")
		--chkSaveWire.checked  = execute (Get_IniData "CustomMicra" "DefaultMicra" "SaveWirecolor")
	)
	on mcRepairDialog rbuttonup pos do (DestroyDialog mcRepairDialog)
		-->MoveMode
	on mcRepairDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcRepairDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcRepairDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do 
		(
			setDialogPos mcRepairDialog (mouse.screenpos - DmPos)
		)
	)
	on btn_1 pressed           do (DestroyDialog mcRepairDialog)		
	on btn_2 pressed           do 
	(--btn_2
		if (rdo_1.state == 1) then
		(
			if (selection.count != 0) then
			(
				local n, p, s, w, c, oldSel = $selection as array, newSel = #()
				local links_data, node_layer , gHead = false
				for o in oldSel do
				(
					if (gHead = (isGroupHead o)) do exit
				)
				if not gHead then --undo "Repair Geometry" on 
				(
					if chkSaveLinks.checked do (links_data = saveLinks oldSel)
					
					for o in oldSel do
					(
						if validModifier o Edit_Mesh and not superClassOf o == shape then
						(
							try 
							(
								if chkSaveLayer.checked do (node_layer = o.INodeLayerProperties.layer)
								CollapseStack o
								
									n=o.name ; p=o.pivot ; w=o.wirecolor; s=sphere()
									
									convertTo s PolyMeshObject ; polyOp.attach s o; polyOp.deleteFaces s (polyOp.getElementsUsingFace s 1)
									
									s.name=n ; s.pivot=p ;if chkSaveWire.checked do (s.wirecolor = w); ResetXForm s; newSel+= s
									
								CollapseStack s
								if chkSaveLayer.checked do (node_layer.addnode s) -- return node back to her layer
							)
							catch ( messagebox "Operation is Failed." title:"Micra III!")
						) else if superClassOf o == shape do
						try
						(
							print "repair shape";
							n=o.name ; w=o.wirecolor; c=circle();
							c.rotation = o.rotation; c.pos = o.pos;
							convertTo c SplineShape; addAndWeld c o 0.0; 
							open c 1; deleteSpline c 1; updateshape c;
							c.name=n ;if chkSaveWire.checked do (c.wirecolor = w); newSel+= c
							--redrawViews()
						)
						catch ( messagebox "Operation is Failed." title:"Micra III!")
					)
					if chkSaveLinks.checked do (loadLinks links_data)
					select newSel
					DestroyDialog mcRepairDialog
					mcCall.popUp ">< Is Done ><" 2
				)
				else (mcCall.displayMsg "Groups is not allowed" green)
			)
			else (mcCall.displayMsg "Select some object." green)  
		)
		else if (rdo_1.state == 2 and selection.count != 0) then
		(
			try 
				(
					--Configurate max2obj.cfg
					cfgPath = (GetDir #plugcfg +"\max2obj.cfg")
					if doesFileExist cfgPath do deleteFile cfgPath
					f = createFile cfgPath
					AutExe = "\n" 
					AutExe += "[Max2Obj] \n"
					AutExe += "GroupFrom=0 \n" + "Materials=1 \n" + "MtlCreate=0 \n" + "Rotate=0 \n"
					AutExe += "Texture=1 \n" + "Normals=1 \n" + "Smooth=1 \n" + "Facetype=2 \n"
					AutExe += "Scale=1.000000 \n" + "Digits=12 \n" + "Compress=0 \n" + "Relative=0 \n"
					format AutExe to:f
					close f
					
					local importDir = GetDir #import + "\\"
					--Export and Import
					exportFile (importDir+"mRepair.obj") #noPrompt selectedOnly:true 
					delete $
					importFile (importDir+"mRepair.obj") #noPrompt
					convertToPoly $
					max zoomext sel
					for o in selection do o.name = substring o.name 4 -1 --delete 'ojb' from names (objBox01)
					DestroyDialog mcRepairDialog
					mcCall.displayMsg "Import/Expotr is finished Succesfully." green
						
				)
			catch (print "reimport failed")
		)
		else if (rdo_1.state == 3 and selection.count != 0) then
		(
			if (queryBox "Do you want create a 'New Scene'?" title: "Micra") == true do
			(
				tmp = ((GetDir #export) + "\mRepair.max")
				sel = $selection as array
				saveNodes sel tmp--save selection
				resetMaxFile #noPrompt
				mergeMAXFile tmp #useSceneMtlDups #mergeDups #select --merge
				max zoomext sel
				DestroyDialog mcRepairDialog
				mcCall.displayMsg "Operation is finished." green
			)
		)	
		
		else (mcCall.displayMsg "You must selct some object." green)
		--delete undo states
		clearUndoBuffer()
	)--btn_2
		
	on chkSaveLinks changed state do
	(
		if chkSaveLinks.checked
		then setIniSetting mcUserINI "Settings" "SaveLinks" "on"
		else setIniSetting mcUserINI "Settings" "SaveLinks" "off"
	)
	on chkSaveWire changed state do
	(
		if chkSaveWire.checked
		then setIniSetting mcUserINI "Settings" "SaveWirecolor" "on"
		else setIniSetting mcUserINI "Settings" "SaveWirecolor" "off"
	)
)
----------------------------------------------------------------------------
mcCall.createIniDialog "mcRepairDialog" "Properties_2"  modal:true 
----------------------------------------------------------------------------

--Repair_Object.ms
