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
rollout mcRepairDialog "" width:324 height:156
(
	-------------------------------------------------------------------------
	local n, p, s, tmp, sel,oName_1, cfgPath, AutExe, f
	local ver = mcFile.getScriptVersion "Repair_Object" 
	local dMove = false, DmPos
	-------------------------------------------------------------------------
	GroupBox 'grp_1' "" pos:[4,4] width:316 height:148 align:#left
	radiobuttons 'rdo_1' "" pos:[16,40] width:126 height:80 labels:#("Standart Micra Repair", "Export/Import", "Merge to New Scene", "Fix Lod Object", "Fix Color and Alpha") default:1 columns:1 align:#left
	button 'btn_1' "Cancel" pos:[12,124] width:60 height:20 align:#left 
	button 'btn_2' "Accept" pos:[252,124] width:60 height:20 align:#left
	GroupBox 'grp2' "Chose Type:" pos:[12,20] width:140 height:100 align:#left
	GroupBox 'grp3' "Custom:" pos:[160,20] width:148 height:100 align:#left
	checkbox 'chkSaveLinks' "Save Links" pos:[172,40] width:100 height:16 checked:true align:#left
	checkbox 'chkSaveWire' "Save Wirecolor" pos:[172,56] width:100 height:16 align:#left
	checkbox 'chkSaveLayer' "Save Layer" pos:[172,72] width:100 height:16 checked:true align:#left
	radioButtons 'rdo_export_import' "" pos:[172,92] width:100 height:16 enabled:true labels:#("OBJ", "FBX") default:1 columns:2 align:#left toolTip:"Import - Export method"
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
	fn selLocked = (
		
		local selectionlock = false
		local sel = selection as array
		clearselection()
		if selection.count != 0 then selectionlock = true else selectionlock = false
		select sel
		selectionlock
	)
	fn repairStandard = with redraw off (
	
		if selLocked()  do (max spacebar) --unlock selection to prevent endless loop
		local n, p, s, w, c, oldSel = $selection as array, newSel = #()
		local links_data, node_layer , gHead = false
		for o in oldSel do (
		
			if (gHead = (isGroupHead o)) do exit
		)
		if not gHead then ( --undo "Repair Geometry" on 
	
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
			::mcPopUp.show "Object(s) is Fixed." delay:2000
			true
			
		) else (
		
			DestroyDialog mcRepairDialog
			::mcPopUp.show "Groups is not allowed" type:#Warning delay:2000
		)
	)
	fn getObjectsSettings objs = (
	
		--TODO
		--MAYBE ITS TIME TO BUILD A SMART DICTIONARY WITH SEARCH ITEM FUNCTIONALITY
		--store links(parents) and layer and object name  
		struct OBJECT_IMPEXP_DATA (obj_name, parent_name, layer_name, wire_color, obj_pivot)
		local objs_data = for o in objs collect (
				
			local parent_name = if o.parent != undefined do o.parent.name				
			OBJECT_IMPEXP_DATA o.name parent_name o.layer.name o.wirecolor o.pos
		)
		objs_data
	)
	fn resoreObjectsSettings objs data type:#OBJ= (
	
		
			case type of (
			
				#OBJ : (
				
					for o in objs do o.name = substring o.name 4 -1 --delete 'ojb' from names (objBox01)
				)
				#FBX : 					
				--import fixed objects
				for o in objs do ( --return original names back (get objects by position and faces.count ?)
				
					--find same object in saved database
					--assing old name back
				)
			
			)
	
			--TODO
			--MAYBE ITS TIME TO BUILD A SMART DICTIONARY WITH SEARCH ITEM FUNCTIONALITY
			--restore links, layers, wirecolor (match by object name)
			-- fn getItemByName data obj_name = (
				
				-- for d in data where d.obj_name == obj_name do exit with d
			-- )
			-- fn linkToParent obj parent_name = (
			
				-- local obj_parent = getNodeByName parent_name
				-- obj.parent = obj_parent
			-- )
			-- fn moveToLayer obj layer_name = (
			
				-- local obj_layer = LayerManager.getLayerFromName layer_name
				-- if obj_layer != undefined do obj_layer.addnode obj
			-- )
			-- for o in selection do (
			
				-- local od = getItemByName objs_data o.name
				-- if not (isStruct od) do continue
				-- if chkSaveLinks.checked do linkToParent o od.parent_name
				-- if chkSaveLayer.checked do moveToLayer o od.layer_name
				-- if chkSaveWire.checked do o.wirecolor = od.wire_color
				-- obj.pivot = od.obj_pivot
			-- )
			
		::mcPopUp.show "Export/Import is finished Succesfully." delay:3000
		max zoomext sel
	)
	fn repairExportImport = (
	
		if (::mcPopUp.show "This Operation is not undoable.\nDo you want Export/Import Selected object(s) ?" title:"Repair:" type:#YesNo) == true then (
			
			local import_export_dir = GetDir #import + "\\"
			local objs = selection as array
			local objs_data = getObjectsSettings objs
			
			DestroyDialog mcRepairDialog
			case rdo_export_import.state of (
				
				1: try (
					--Configurate max2obj.cfg (permanently save obj export settings)
					local cfgPath = (GetDir #plugcfg +"\max2obj.cfg")
					if doesFileExist cfgPath do deleteFile cfgPath
					local f = createFile cfgPath
					AutExe = "\n" 
					AutExe += "[Max2Obj] \n"
					AutExe += "GroupFrom=0 \n" + "Materials=1 \n" + "MtlCreate=0 \n" + "Rotate=0 \n"
					AutExe += "Texture=1 \n" + "Normals=1 \n" + "Smooth=1 \n" + "Facetype=2 \n"
					AutExe += "Scale=1.000000 \n" + "Digits=12 \n" + "Compress=0 \n" + "Relative=0 \n"
					format AutExe to:f
					close f			
					--Export and Import
					exportFile (import_export_dir+"mRepair.obj") #noPrompt selectedOnly:true 
					delete objs
					importFile (import_export_dir+"mRepair.obj") #noPrompt
					objs = selection as array --recollect imported objects
					convertToPoly objs
					resoreObjectsSettings objs objs_data type:#OBJ
					true
							
				) catch (::mcPopUp.show "Repair Failed > method:OBJ." type:#Warning delay:4000)
				
				2: try (
					
					--export bad objects
					mcFile.exportFBX objs import_export_dir "mRepair" ignoreLinks:true
					delete objs --delete bad objects
					mcFile.importFBX import_export_dir "mRepair"
					objs = selection as array --recollect imported objects
					convertToPoly objs
					resoreObjectsSettings objs objs_data type:#FBX
					true
					
				) catch  (::mcPopUp.show "Repair Failed > method:FBX." type:#Warning delay:4000)
			)

		) else (
		
			::mcPopUp.show "Repair Canceled." type:#Abort delay:2000
		)
	)
	fn repairToNewScene = (
	
		if (::mcPopUp.show "This Operation is not undoable.\nDo you want move Selected object(s) in to New Scene ?" title:"Repair:" type:#YesNo) == true then (
		
			local tmp = ((GetDir #export) + "\mRepair.max")
			local sel = selection as array
			saveNodes sel tmp--save selection
			resetMaxFile #noPrompt
			mergeMAXFile tmp #useSceneMtlDups #mergeDups #select --merge
			max zoomext sel
			DestroyDialog mcRepairDialog
			::mcPopUp.show "Object(s) was moved." delay:2000
			true
		) else (
		
			DestroyDialog mcRepairDialog
			::mcPopUp.show "Repair Canceled." type:#Abort delay:2000
		)
	)
	fn repairLode = (

		try (
		
			mcStructMan.import "mcLodes" "mcLodes" dir:#Core force:false 
			mcLodes.repairLodObject()
			DestroyDialog mcRepairDialog
			::mcPopUp.show "Lodes was Fixed." delay:2000
			true
			
		) catch (
		
			false
		)
	)
	fn fixVertexAlphaAndColor = (
		
		mcPoly.fixObjectAlphaMap (selection as array)
		mcPoly.fixObjectColorMap (selection as array)
		DestroyDialog mcRepairDialog
		::mcPopUp.show "Alpha and Color was Fixed." delay:2000
		true	
	)
	fn repairObjects = (
	
		if selection.count == 0 do (
		
			DestroyDialog mcRepairDialog
			::mcPopUp.show "Aborted! Select some object(s) first." type:#Warning delay:2000
			return false
		)
		local success = case rdo_1.state of  (
		
			1 : repairStandard()
			2 : repairExportImport()
			3 : repairToNewScene()
			4 : repairLode()
			5 : fixVertexAlphaAndColor()
		)
		if success == true do clearUndoBuffer() --delete undo states
	)
	on mcRepairDialog open do (
	
		grp_1.text = " Repair Object v"+ver
		chkSaveLinks.checked = (mcFile.readSettings Micra.UserSettings "Settings/SaveLinks" == "on")
		chkSaveWire.checked  = (mcFile.readSettings Micra.UserSettings "Settings/SaveWirecolor" == "on")
		chkSaveLayer.checked  = (mcFile.readSettings Micra.UserSettings "Settings/SaveLayer" == "on")
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
	on btn_2 pressed           do (repairObjects())
		
	on chkSaveLinks changed state do  mcFile.saveSettings Micra.UserSettings "Settings/SaveLinks" (if chkSaveLinks.checked then "on" else "off")
	on chkSaveWire changed state do mcFile.saveSettings Micra.UserSettings "Settings/SaveWirecolor" (if chkSaveWire.checked then "on" else "off")
	on chkSaveLayer changed state do mcFile.saveSettings Micra.UserSettings "Settings/SaveLayer" (if chkSaveLayer.checked then "on" else "off")
)
----------------------------------------------------------------------------
mcCall.createXMLDialog "mcRepairDialog" "Properties_2"  modal:true 
----------------------------------------------------------------------------

--Repair_Object.ms
