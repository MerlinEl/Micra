Global mcActionEditorDialog
if ::mcActionEditorDialog != undefined do try(destroyDialog mcActionEditorDialog)catch()
	
rollout mcActionEditorDialog "Action Editor:" width:772 height:224 (

	--interface components
	label 'lbl1' "Category:" pos:[12,12] width:52 height:16 align:#left
	label 'lbl3' "Icon:" pos:[708,12] width:28 height:16 align:#left
	label 'lbl4' "Description:" pos:[8,64] width:56 height:16 align:#left
	label 'lbl5' "Actions:" pos:[360,12] width:40 height:16 align:#left
	
	dropdownList 'ddl_categories' "" pos:[64,8] width:220 height:21 align:#left
	dropdownList 'ddl_actions' "" pos:[404,8] width:220 height:21 align:#left
	
	button 'btn_cat_add' "+" pos:[288,8] width:22 height:22 align:#left
	button 'btn_cat_del' "-" pos:[316,8] width:22 height:22 align:#left
	button 'btn_action_add' "+" pos:[644,8] width:22 height:22 align:#left
	button 'btn_action_del' "-" pos:[672,8] width:22 height:22 align:#left
	button 'btn_icon' "" pos:[740,6] width:24 height:24 align:#left
	button 'btn_cancel' "Cancel" pos:[8,196] width:128 height:24 align:#left
	button 'btn_save' "Save" pos:[640,196] width:128 height:24 align:#left
	button 'btn_edit_function' "edit" pos:[624,36] width:68 height:22 align:#left
	button 'btn_add_function' "add" pos:[696,36] width:68 height:22 align:#left
	radioButtons 'rdo_function' "" pos:[8,40] width:209 height:16 labels:#("Function Name", "File Name") columns:2 align:#left
	
	edittext 'edt_function' "" pos:[220,36] width:396 height:20 align:#left
	edittext 'edt_description' "" pos:[0,80] width:768 height:112 align:#left

	--local variables
	local icon_index = 1
	local start_switch = "standalone"
	local category_name = undefined
	local action_name =  undefined
	local button_name = undefined
	local action_ini_data = undefined
	
	--functions
	fn closeDialog = (destroyDialog mcActionEditorDialog)
	fn saveAll = (
		
		if category_name == undefined or action_name == undefined do return false
		--save comment	
		local help_txt = edt_description.text
		format "saveAll > category:% action:% comment:%\n" category_name action_name help_txt
		setIniSetting Micra.ActionsHelpIni category_name action_name help_txt
		--save icon index
		
		--save function name or filein name
	)
	fn createNewImage w h clr transparent:false =(
		
		local img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		local g  = (dotNetClass "Drawing.Graphics").fromImage img --Create new Graphics object
		local brush = dotNetObject "drawing.SolidBrush" (netDrColor clr)
		g.FillRectangle brush 0 0 w h
		g.dispose()
		if transparent do img.makeTransparent()
		img
	)
	
	fn getIconsFromFile  = (
		
		if not doesFileExist Micra.IconI do return undefined
		local img = (dotNetClass "Drawing.Image").FromFile Micra.IconI
		local w = img.width, h = img.height
		local new_img = (dotNetObject "Drawing.Bitmap" w h) --Create new bitmap object
		--new_img.ColorDepth = icon.ColorDepth.Depth24Bit
		local g  = (dotNetClass "Drawing.Graphics").fromImage new_img --Create new Graphics object
		local rect = netDrRect [0, 0] [w, h]
		g.DrawImage img rect --0 0 w h (dotNetClass "Drawing.GraphicsUnit").Pixel	
		img.dispose()
		g.dispose()
		return new_img
	)
	
	fn getIconByIndex icon_index = (
		
		local icons_image = getIconsFromFile()
		if icons_image == undefined do return undefined
		if icon_index <= 1 do return createNewImage 24 24 black
		--local img = (dotNetClass "Drawing.Image").FromFile Micra.IconI --get the saved image from file as bitmap
		local icons_img_size = [icons_image.width, icons_image.height]
		local icons_count  = (icons_img_size/24)
		icon_index -= 1

		local X = (mod icon_index icons_count.x)
		local Y = (icon_index / icons_count.y) as integer
		local pix_x = X * 24
		local pix_y = Y * 24
		local pos = [pix_x, pix_y]
		
		local new_image = (dotNetObject "Drawing.Bitmap" 24 24) --Create new bitmap object
		--new_image.ColorDepth = new_image.ColorDepth.Depth24Bit
		local g = (dotNetClass "Drawing.Graphics").fromImage new_image --Create new Graphics object
		local newRect = netDrRect [0, 0] [24, 24]  --adjust new_image offset X in button 
		g.DrawImage icons_image newRect pos.x pos.y 24 24 (dotNetClass "Drawing.GraphicsUnit").Pixel	
		--img.dispose()
		new_image.MakeTransparent (netDrColor black) --(color 75 75 75)) --gray
		return new_image
	)
	
	fn setIcon icon_index = (
		
		format "set icon index:%\n" index
		local icon_image = getIconByIndex icon_index
		if icon_image == undefined do return false
		local clipboardClass = dotNetClass "Clipboard" --create a Clipboard dotNetClass
		clipboardClass.setImage icon_image --copy the image to clipboard
		icon_image = getClipboardBitmap() 
		btn_icon.images = #(icon_image, undefined, 1,1,1,1,1 )
	)
	
	fn editIcon = (
	
		local btn = mcGM.getParam "active_button" --micra toolbar active button
		if btn != undefined do (
			
			local action_name =  btn.tag
			local action_ini_data = mcSystem.getActionByName action_name  -- mcObject(name:action_name, category:action_category, val:data_array)
			
			format "action_ini_data:%\n" action_ini_data
			
			-- set global variable
			if action_ini_data != undefined do mcGM.setParam "active_icon_index" (action_ini_data.get "val")[1] --#(106, "mcAnimation.reverse 0 10" , "Reverse_Animation")
		)
		Micra.fileInVersion "Icon_Maker"	--open icon editor	
	)
	
	fn editHint = (
		
		if category_name == undefined or action_name == undefined do return false
		local help_txt = getIniSetting Micra.ActionsHelpIni category_name action_name
		edt_description.text = help_txt
	)
	
	fn getIconIniIndex = (
		
		if action_name == undefined do return 1
		local action_ini_data = mcSystem.getActionByName action_name   -- mcObject(name:action_name, category:action_category, val:data_array)
		if action_ini_data != undefined then icon_index = (action_ini_data.get "val")[1] else return 1
	)
	
	fn loadData override:true = (
		
		format "loadData > category:% action:% icon_index:%\n" category_name action_name icon_index  
				
		--mcSystem.showActionSource action_name --#(106, "mcAnimation.reverse 0 10" , "Reverse_Animation")
			
		--load function or file name
		edt_function.text = 
		--load icon
		setIcon icon_index
		
		--load comment
		editHint()
	)
	
	fn	loadActions override:true = (
	
		if category_name == undefined do return false
		local actions = getIniSetting Micra.ActionsIni category_name
		if actions.count == 0 do return false
		ddl_actions.items = actions
		ddl_actions.selection = 1
	)
	
	fn loadCatalog = (
	
		local categories = getIniSetting Micra.ActionsIni
		if categories.count == 0 do return false
		ddl_categories.items = categories
		ddl_categories.selection = 1
	)
	
	fn selectItemByName list item_name = (
	
		local  item_index = (for i = 1 to list.items.count where list.items[i] == item_name collect i)[1]
		format "item:% index:%\n" item_name item_index
		if item_index != undefined do list.selection =  item_index	
	)
	
	fn init = (
		
		start_switch = mcGM.getParam "action_editor_switch" --edit mode switch (edit, create new, standalone)
		local micra_button = mcGM.getParam "active_button" --micra toolbar active button
		if start_switch == undefined or  micra_button == undefined do start_switch = "standalone"
		
		format "init > start in mode:%\n" start_switch
		
		if start_switch == "standalone" then (
			
			loadCatalog()
			category_name = ddl_categories.selected  as String
			loadActions()
			action_name = ddl_actions.selected as String
			loadData()
			
		) else (
			
			button_name = micra_button.name
			local action_name = micra_button.tag
			action_ini_data = mcSystem.getActionByName action_name   -- mcObject(name:action_name, category:action_category, val:data_array)
			if action_ini_data != undefined do (
				
				icon_index = (action_ini_data.get "val")[1]
				category_name =  action_ini_data.get "category"
				
				loadCatalog()	
				selectItemByName ddl_categories category_name
				loadActions()	
				selectItemByName ddl_actions action_name
				loadData()
			)
		)
	)

	fn finish = (
		
		--clear global variables
		mcGM.setParam "action_editor_switch"undefined
		mcGM.setParam "active_button" undefined
	)	
	
	on mcActionEditorDialog open do init()
	on mcActionEditorDialog close do finish()
	on btn_icon pressed do editIcon()	
	on ddl_categories selected sel do (
		
		category_name = ddl_categories.selected  as String
		loadActions()
		action_name = ddl_actions.selected as String
		icon_index = getIconIniIndex()
		loadData()
	)
	on ddl_actions selected sel do (
		
		action_name = ddl_actions.selected as String
		icon_index = getIconIniIndex()
		loadData()
	)
	on btn_save pressed do saveAll()
	on btn_cancel pressed do closeDialog()
)
createDialog mcActionEditorDialog
