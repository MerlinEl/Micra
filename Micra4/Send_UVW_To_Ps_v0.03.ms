Global mcSendUVWToPsDialog

if mcSendUVWToPsDialog != undefined do destroyDialog mcSendUVWToPsDialog
rollout mcSendUVWToPsDialog "Untitled" width:148 height:212
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	-------------------------------------------------
	GroupBox 'grp1' "Send UVW to Photoshop:" pos:[4,5] width:140 height:203 align:#left
		
	label 'lbl_size_x' "Size X:" pos:[12,28] width:36 height:16 align:#left
	label 'lbl3' "Mode:" pos:[12,100] width:36 height:16 align:#left
	label 'lbl_size_y' "Size Y:" pos:[12,52] width:36 height:16 align:#left

	dropdownList 'ddl_mode' "" pos:[52,96] width:80 height:21 items:#("None", "Solid", "Normal", "Shaded") align:#left
	dropdownList 'ddl_size_x' "" pos:[52,24] width:80 height:21 items:#("64", "128", "256", "512", "1024", "2048", "4096") align:#left
	dropdownList 'ddl_size_y' "" pos:[52,48] width:80 height:21 items:#("64", "128", "256", "512", "1024", "2048", "4096") align:#left

	button 'btn_print' "Send" pos:[12,180] width:124 height:24 align:#left
	button 'btn_close' "*" pos:[132,4] width:12 height:12 align:#left

	checkbox 'chk_edges' "Visible Edges" pos:[12,140] width:88 height:16 align:#left
	checkbox 'chk_seam' "Seam Edges..." pos:[12,156] width:88 height:20 align:#left
	checkbox 'chk_sel_faces' "Slected Faces" pos:[12,124] width:88 height:16 align:#left
	
	colorPicker 'cp_seam' "" pos:[104,152] width:28 height:24 color:(color 0 255 0) align:#left
	
	--> Functions 
	fn render_uvw_and_send_to_photoshop = 
	(
		local objs = modPanel.getCurrentObject()-- select multiple objects to multi unwrap
		if classof objs != Unwrap_UVW do return false
		
		if chk_sel_faces.checked do --hide unselected faces in uvw
		(
			local uvwFSel = objs.getSelectedPolygons()
			max select invert
			objs.hide()
			objs.UpdateView()
			--objs.unwrap.filterSelected()
		)

		objs.renderuv_width = execute ddl_size_x.text
		objs.renderuv_height = execute ddl_size_y.text
		objs.renderuv_fillmode = ddl_mode.selection-1
		objs.renderuv_showoverlap = false
		objs.renderuv_visibleedges = chk_edges.checked
		objs.renderuv_seamedges    = chk_seam.checked
		objs.renderuv_seamColor = cp_seam.color
		objs.renderuv_fillColor = color 255 255 255
		objs.renderuv_showframebuffer = false
	
		--render uvw to temp folder
		local tmp = Micra.RootDir+"Temp"
		if not (makeDir tmp all:true) do return false
		local theFileName = tmp + "\\_render_UVW_Selection.png" --define a temp.file name
		objs.unwrap5.renderUV theFileName --save UV layout to the temp folder
		objs.renderuv_showframebuffer = false --reset defaults
		--open in photoshop and delete
		local app=CreateOLEObject"Photoshop.Application"
		
		if doesFileExist theFileName 
		then
		(
			app.open theFileName
			deleteFile theFileName
		)
		
		if chk_sel_faces.checked do --unhide all uvw,restore selection
		(
			objs.unhide()
			objs.selectPolygons uvwFSel
			objs.UpdateView()
			--objs.unwrap.filterSelected()
		)
		--create black background
	/*	local doc = app.activeDocument
		local layer = doc.layers.getByName ("Layer 0")
		layer.duplicate() --duplicates the "Layer 0"
		layer.name = "Background" --renames the duplicated layer
		local first_layer = doc.layers.getByName ("Layer 0 copy")
		first_layer.name = "UVW_Mapping"
		doc.activeLayer = doc.layers.getByName ("Background") --selects the Background layer
		local clr =CreateOLEObject"Photoshop.SolidColor"
		clr.rgb.red = 0
		clr.rgb.green = 0
		clr.rgb.blue = 0
		doc.selection.fill clr*/
		
		local doc = app.activeDocument
		local first_layer = doc.layers.getByName ("Layer 0")
		first_layer.name = "UVW_Mapping"
		local clr =CreateOLEObject"Photoshop.SolidColor"
		clr.rgb.red = 0
		clr.rgb.green = 0
		clr.rgb.blue = 0
		local doc = app.activeDocument
		local bg_layer = doc.artLayers.add()
		bg_layer.name = "Background"
		doc.selection.fill clr
		struct ELEMENT_PLACEMENT (
			
			PLACEAFTER = 1,
			PLACEATEND = 3,
			PLACEBEFORE = 2
		)
		local ElementPlacement = ELEMENT_PLACEMENT()
		first_layer.move bg_layer ElementPlacement.PLACEATEND
		--show Photoshop
		app.Visible=true
		app.bringToFront()
		return OK
	)
	fn loadInterface =
	(
		if not doesFileExist Micra.UserSettings do return false
		local ved = mcFile.readSettings Micra.UserSettings "RenderToTextureMod/Visible_Edges"
		if ved  != "" do chk_edges.checked = execute ved
		local sed = mcFile.readSettings Micra.UserSettings "RenderToTextureMod/Seam_Edges"
		if sed  != "" do chk_seam.checked = execute sed
		local sef = mcFile.readSettings Micra.UserSettings "RenderToTextureMod/Slected_Faces"
		if sef  != "" do chk_sel_faces.checked = execute sef
		local sec = mcFile.readSettings Micra.UserSettings "RenderToTextureMod/Seam_Edges_Color" 
		if sec  != "" do cp_seam.color = execute sec
		local mde = mcFile.readSettings Micra.UserSettings "RenderToTextureMod/Mode"
		if mde  != "" do ddl_mode.selection = execute mde
		local sizx = mcFile.readSettings Micra.UserSettings "RenderToTextureMod/Size_X"
		if sizx  != "" do ddl_size_x.selection = execute sizx
		local sizy = mcFile.readSettings Micra.UserSettings "RenderToTextureMod/Size_Y"
		if sizy  != "" do ddl_size_y.selection = execute sizy	
	)
	fn saveInterface =
	(
		if not doesFileExist Micra.UserSettings do return false
		mcFile.saveSettings Micra.UserSettings "RenderToTextureMod/Visible_Edges" (chk_edges.checked as string)
		mcFile.saveSettings Micra.UserSettings "RenderToTextureMod/Seam_Edges" (chk_seam.checked as string)
		mcFile.saveSettings Micra.UserSettings "RenderToTextureMod/Slected_Faces" (chk_sel_faces.checked as string)
		mcFile.saveSettings Micra.UserSettings "RenderToTextureMod/Seam_Edges_Color" (cp_seam.color as string)
		mcFile.saveSettings Micra.UserSettings "RenderToTextureMod/Mode" (ddl_mode.selection as string)
		mcFile.saveSettings Micra.UserSettings "RenderToTextureMod/Size_X" (ddl_size_x.selection as string)
		mcFile.saveSettings Micra.UserSettings "RenderToTextureMod/Size_Y" (ddl_size_y.selection as string)
	)
	-->DialogProp --------------------------------------------------------------------
	on mcSendUVWToPsDialog rbuttonup pos do (destroyDialog mcSendUVWToPsDialog)
	on mcSendUVWToPsDialog open do (loadInterface())
	on mcSendUVWToPsDialog close do 
	( 
		saveInterface()
		mcFile.saveDialogSettings "mcSendUVWToPsDialog" "Properties_2"
	)
	-->MoveMode
	on mcSendUVWToPsDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcSendUVWToPsDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcSendUVWToPsDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcSendUVWToPsDialog DmPos
	)
	-->Actions
	on btn_print pressed  do (render_uvw_and_send_to_photoshop())
	on btn_close pressed  do (destroyDialog mcSendUVWToPsDialog)
)
mcCall.createXMLDialog "mcSendUVWToPsDialog" "Properties_2"



/*

		--photoshop include javascript in presests folder
		--app.doaction "Action Name" "Action Set"
		local first_layer = doc.layers.getByName  ("Layer 0")
		format "fla:%\n" first_layer
		bg_layer.move first_layer "PLACEBEFORE"
		--global lset = doc.layers.count
		--global lset = doc.layerSets.count
		
		--bg_layer.move doc.layerSets[0] "PLACEBEFORE"
		--newLayerSetRef.move(layerRef, ElementPlacement.PLACEAFTER);
		
		---doc.artLayers[0].move(docRef.artLayers[docRef.artLayers.length-1], ElementPlacement.PLACEBEFORE);
		
		bg_layer.move first_layer "PLACEBEFORE"
		
		--docRef.artLayers[0].move(docRef.artLayers[docRef.artLayers.length-1], ElementPlacement.PLACEBEFORE);
*/