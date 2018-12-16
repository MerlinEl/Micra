Global mcSendUVWToPsDialog

if mcSendUVWToPsDialog != undefined do destroyDialog mcSendUVWToPsDialog
rollout mcSendUVWToPsDialog "Untitled" width:148 height:172
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	-------------------------------------------------
	GroupBox grp1 "Send UVW to Photoshop:" pos:[4,5] width:140 height:163
	label lbl2 "Size:" pos:[12,28] width:36 height:16
	label lbl3 "Mode:" pos:[12,56] width:36 height:16
	button btn_print "Send" pos:[12,136] width:124 height:24
	button btn_close "*" pos:[132,4] width:12 height:12
	
	dropdownList ddl_mode "" pos:[52,52] width:80 height:21 items:#("None", "Solid", "Normal", "Shaded")
	dropdownList ddl_size "" pos:[52,24] width:80 height:21 items:#("64", "128", "256", "512", "1024", "2048", "4096")
	checkbox chk_edges "Visible Edges" pos:[12,96] width:88 height:16
	checkbox chk_seam "Seam Edges..." pos:[12,112] width:88 height:20
	colorPicker cp_seam "" pos:[104,108] width:28 height:24 color:(color 0 255 0)
	checkbox chk_sel_faces "Slected Faces" pos:[12,80] width:88 height:16
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

		local render_size =  execute ddl_size.text
		objs.renderuv_width = render_size
		objs.renderuv_height = render_size
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
		local ps=CreateOLEObject"Photoshop.Application"
		ps.Visible=true
		if doesFileExist theFileName 
		then
		(
			ps.open theFileName
			deleteFile theFileName
		)
		
		if chk_sel_faces.checked do --unhide all uvw,restore selection
		(
			objs.unhide()
			objs.selectPolygons uvwFSel
			objs.UpdateView()
			--objs.unwrap.filterSelected()
		)
		--setFocus ps --not working
		return OK
	)
	fn loadInterface =
	(
		if not doesFileExist Micra.UserSettings do return false
		local ved = getIniSetting Micra.UserSettings "RenderToTextureMod" "Visible Edges" 
		if ved  != "" do chk_edges.checked = execute ved
		local sed = getIniSetting Micra.UserSettings "RenderToTextureMod" "Seam Edges" 
		if sed  != "" do chk_seam.checked = execute sed
		local sef = getIniSetting Micra.UserSettings "RenderToTextureMod" "Slected Faces" 
		if sef  != "" do chk_sel_faces.checked = execute sef
		local sec = getIniSetting Micra.UserSettings "RenderToTextureMod" "Seam Edges Color" 
		if sec  != "" do cp_seam.color = execute sec
		local mde = getIniSetting Micra.UserSettings "RenderToTextureMod" "Mode"
		if mde  != "" do ddl_mode.selection = execute mde
		local siz = getIniSetting Micra.UserSettings "RenderToTextureMod" "Size"
		if siz  != "" do ddl_size.selection = execute siz
	)
	fn saveInterface =
	(
		if not doesFileExist Micra.UserSettings do return false
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Visible Edges" (chk_edges.checked as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Seam Edges" (chk_seam.checked as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Slected Faces" (chk_sel_faces.checked as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Seam Edges Color" (cp_seam.color as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Mode" (ddl_mode.selection as string)
		setIniSetting Micra.UserSettings "RenderToTextureMod" "Size" (ddl_size.selection as string)
	)
	-->DialogProp --------------------------------------------------------------------
	on mcSendUVWToPsDialog rbuttonup pos do (destroyDialog mcSendUVWToPsDialog)
	on mcSendUVWToPsDialog open do (loadInterface())
	on mcSendUVWToPsDialog close do 
	( 
		saveInterface()
		mcCall.saveIniDialog "mcSendUVWToPsDialog" "Properties_2"
	)
	-->MoveMode
	on mcSendUVWToPsDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcSendUVWToPsDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcSendUVWToPsDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialogSnap mcSendUVWToPsDialog DmPos
	)
	-->Actions
	on btn_print pressed  do (render_uvw_and_send_to_photoshop())
	on btn_close pressed  do (destroyDialog mcSendUVWToPsDialog)
)
mcCall.createIniDialog "mcSendUVWToPsDialog" "Properties_2"
