/*macroScript Convex_Hull_Tool
	category:"DragAndDrop"
	toolTip:""
(*/
	-- Close the window if it is open
	try (destroyDialog ::rol_Convex_Tool_Panel) catch()

	-- Function to make sure we only have exactly one object selected
	fn check_Single_Mesh selected =
	(
		selected = selection as array
		if selected.count == 1 then
		(
			return True
		)
		else 
		(
			return False
		)
	)

	-- Loads all settings to a rollout that must be passed in
	fn load_Defaults rollout_To_Update =
	(
		settings_Array = #()
		-- I would normally put this file in a path relative to the max envrnment variable, but I'm not sure what max version you will be using
		prefs_File = openFile "c:\3dsmax convex tool\convex_hull_tool_settings.txt"
		if prefs_File != undefined then
		(
			while not eof prefs_File do
			(
				-- Each line in the file is one setting in the array.
				input_Data = readLine prefs_File
				append settings_Array input_Data
			)
			close prefs_File
		)
		-- File doesn't exist so make up default defaults
		else 
		(
			settings_Array = #("64", "1.0", "0", "True", "True")
		)
		-- Assign each value to the rollout
		rollout_To_Update.num_Verts_Spinner.value = settings_Array[1] as integer
		rollout_To_Update.scale_Spinner.value = settings_Array[2] as float
		rollout_To_Update.border_Spinner.value = settings_Array[3] as float
		rollout_To_Update.unreal_Names.checked = settings_Array[4] as booleanClass
		rollout_To_Update.delete_Old_Hull.checked = settings_Array[5] as booleanClass
	)

	-- Function to save the settings to a file
	fn save_Defaults settings_Array =
	(
		prefs_File_Path = "c:\\3dsmax convex tool\\convex_hull_tool_settings.txt"
		-- If the file or path doesn't exist we have to make it and close IO stream before we can write.
		if doesFileExist prefs_File_Path == False then
		(
			makeDir "c:\\3dsmax convex tool\\"
			prefs_File = createFile prefs_File_Path
			close prefs_File
		)
		prefs_File = openFile prefs_File_Path mode:"w"
		
		for setting_String in settings_Array do
		(
			print setting_String to:prefs_File
		)		
		close prefs_File
	)

	-- Function to make a new convex hull
	fn create_Convex_Hull selected_Mesh int_num_Verts float_Scale border_Scale as_Unreal_Collision delete_Old = 
	(
		-- First, delete old hull (or name it as a copy, depending on setting)
		if delete_Old == True then
		(
			hull_name = selected_Mesh.name + " hull"
			ucx_name = "UCX_" + selected_Mesh.name
			old_hull = getnodebyname hull_name
			if old_hull != undefined then 
			(
				delete old_hull
			)
			old_hull = getnodebyname ucx_name
			if old_hull != undefined then
			(
				delete old_hull
			)
		)
		-- If we uncheck the "delete old hull" checkbox we will make copies of the hulls
		else
		(
			hull_name = selected_Mesh.name + " hull"
			ucx_name = "UCX_" + selected_Mesh.name
			old_hull = getnodebyname hull_name
			if old_hull != undefined then 
			(
				old_hull.name = old_hull.name + "_copy"
			)
			old_hull = getnodebyname ucx_name
			if old_hull != undefined then 
			(
				old_hull.name = old_hull.name + "_copy"
			)
		)
		
		-- MassFX is able to generate the convex hull.  Here we add the modifier
		Mass_FX_Modifier = MassFX_RBody()
		addModifier selected_Mesh Mass_FX_Modifier
		
		-- Assign the max vert and buffer value from the spinner to the modifier
		Mass_FX_Modifier.meshVerticesLimit = int_num_Verts
		Mass_FX_Modifier.meshInflation = border_Scale
		
		-- Now extract the mesh and delete the modifier
		Mass_FX_Modifier.RBMeshCustomNodeExtract 1
		deleteModifier selected_Mesh 1
		
		-- Scale the hull
		hull = getnodebyname hull_name
		hull.pivot = hull.center
		hull.scale = [float_Scale,float_Scale,float_Scale]
		
		-- Name the hull UCX_ selectedmesh if it is for an unreal collision box.
		if as_Unreal_Collision == True then
		(
			hull.name = ucx_name
		)
		
		return hull.name
	)

	-- Set up the UI, button commands and load defaults.
	rollout rol_Convex_Tool_Panel "Convex Hull Tool"
	(
		group "Build Convex Hull:"
	    (
			spinner num_Verts_Spinner "Max vertex count:" range:[1,1000, 64] type:#integer
			spinner scale_Spinner "Scale multiplier:" range:[0.1,1000, 1]
			spinner border_Spinner "Add buffer size:" range:[-1000,1000, 0]
			checkbox unreal_Names "Use Unreal collision names (UCX_)" checked:True
			checkbox delete_Old_Hull "Delete old hulls for object on create" checked:True
			button build_Hull_Button "Build convex hull for selected mesh" width:200 height:18		
			button set_Scale_Button "Update scale on last created hull" width:200 height:18
			button update_Hull_Button "Update vertex count and settings on hull" width:200 height:18
			editText last_Hull_Name "Last created hull: " text:"none" readOnly:True
	    )
		button set_Defaults_Button "Save settings as default" width:130 height:18 across: 2
		button close_Button "Close" width:80 height:18
		
		-- Build the hull, Check to make sure we have exactly one object selected
	    on build_Hull_Button pressed do
	    (
			if check_Single_Mesh $ == True then
			(
				last_Hull_Name.text = create_Convex_Hull $ num_Verts_Spinner.value scale_Spinner.value border_Spinner.value unreal_Names.checked delete_Old_Hull.checked
			)
			else
			(
				messageBox "You must select exactly one object to make a hull."
			)
	    )
		
		-- Updates just the scale on the last hull.
		-- To update anything else you would just leave delete flag on and re-create the hull
		on set_Scale_Button pressed do
		(
			if last_Hull_Name.text == "none" then 
			(
				messageBox "Make a hull first."
			)
			else
			(
				last_Hull = getnodebyname last_Hull_Name.text
				last_Hull.pivot = last_Hull.center
				last_Hull.scale = [scale_Spinner.value, scale_Spinner.value, scale_Spinner.value]
			)
		)
		
		-- Updates the vertex count and all other settings on a previously created hull regardless of selection
		on update_Hull_Button pressed do
		(
			if last_Hull_Name.text == "none" then 
			(
				messageBox "Make a hull first."
			)
			else
			(
				if findstring last_Hull_Name.text "UCX_" != undefined then
				(
					object_Name = substring last_Hull_Name.text 5 -1
				)
				else
				(
					name_len = last_Hull_Name.text.count - 5
					object_Name = substring last_Hull_Name.text 1 name_len
				)
				original_Object = getnodebyname object_Name 
				last_Hull_Name.text = create_Convex_Hull original_Object num_Verts_Spinner.value scale_Spinner.value border_Spinner.value unreal_Names.checked True
			)
		)
		
		-- Close the window
		on close_Button pressed do
		(
			destroyDialog ::rol_Convex_Tool_Panel
		)
		
		-- Build an array for the settings and pass it into the save function.
		on set_Defaults_Button pressed do
		(
			input_Array = #()
			input_Array = append input_Array num_Verts_Spinner.value
			input_Array = append input_Array scale_Spinner.value
			input_Array = append input_Array border_Spinner.value
			input_Array = append input_Array unreal_Names.checked
			input_Array = append input_Array delete_Old_Hull.checked
		
			save_Defaults input_Array
			messageBox "Settings Updated."
		)
	)

	-- Make the rollout window
	createDialog rol_Convex_Tool_Panel height:250 width:250 pos:[150,200]
	
	-- Call the function to load the saved settings from the file (if it exists) and update the UI with defaults
	load_Defaults rol_Convex_Tool_Panel

--)
