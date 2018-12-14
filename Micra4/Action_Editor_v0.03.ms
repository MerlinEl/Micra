Global mcActionEditorDialog
if ::mcActionEditorDialog != undefined do try(destroyDialog mcActionEditorDialog)catch()
	
rollout mcActionEditorDialog "Action Editor:" width:772 height:224
(

	--interface components
	label 'lbl1' "Category:" pos:[12,12] width:52 height:16 align:#left
	label 'lbl3' "Icon:" pos:[708,12] width:28 height:16 align:#left
	label 'lbl4' "Description:" pos:[8,64] width:56 height:16 align:#left
	label 'lbl5' "Actions:" pos:[360,12] width:40 height:16 align:#left
	label 'lbl6' "Command:" pos:[12,39] width:52 height:16 align:#left
	
	dropdownList 'ddl_categories' "" pos:[64,8] width:220 height:21 align:#left
	dropdownList 'ddl_actions' "" pos:[404,8] width:220 height:21 align:#left
	
	button 'btn_cat_add' "+" pos:[288,8] width:22 height:22 align:#left
	button 'btn_cat_del' "-" pos:[316,8] width:22 height:22 align:#left
	button 'btn_action_add' "+" pos:[644,8] width:22 height:22 align:#left
	button 'btn_action_del' "-" pos:[672,8] width:22 height:22 align:#left
	button 'btn_icon' "" pos:[740,6] width:24 height:24 align:#left
	button 'btn_cancel' "Cancel" pos:[8,196] width:128 height:24 align:#left
	button 'btn_save' "Save" pos:[640,196] width:128 height:24 align:#left
	button 'btn_edit_function' "edit" pos:[636,36] width:64 height:22 align:#left
	button 'btn_add_function' "add" pos:[704,36] width:60 height:22 align:#left
	
	edittext 'edi_command' "" pos:[62,37] width:562 height:20 align:#left
	edittext 'edt_description' "" pos:[0,80] width:768 height:112 align:#left

	--local variables
	local icon_index = 1
	local start_switch = "standalone"
	local category_name = undefined
	local action_name =  undefined
	local button_name = undefined
	local action_ini_data = undefined
	local predefined_action_name = undefined
	local predefined_cat_name = undefined
	
	--functions
	fn closeDialog = (destroyDialog mcActionEditorDialog)
	fn saveAll = (
		
		if category_name == undefined or action_name == undefined do return false
		--save comment	
		local help_txt = edt_description.text
		format "saveAll > category:% action:% comment:%\n" category_name action_name help_txt
		setIniSetting mcActionHelpIni category_name action_name help_txt
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
		
		if not doesFileExist mcIconI do return undefined
		local img = (dotNetClass "Drawing.Image").FromFile mcIconI
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
		--local img = (dotNetClass "Drawing.Image").FromFile mcIconI --get the saved image from file as bitmap
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

		-- set global variable
		if action_ini_data != undefined do mcGM.setParam "active_icon_index" (action_ini_data.get "val")[1] --#(106, "mcAnimation.reverse 0 10" , "Reverse_Animation")
		mcFileInVersion "Icon_Maker"	--open icon editor	
	)
	
	fn editHint = (
		
		local help_txt = getIniSetting mcActionHelpIni category_name action_name
		edt_description.text = help_txt
	)
	
	fn editFunction = (
	
		if action_name != undefined do mcSystem.showActionSource action_name	
	)
	
	fn loadData = (
		
		if category_name == undefined or action_name == undefined do return false

		editHint() --load comment	
		
		action_ini_data = mcSystem.getActionByName action_name   -- mcObject(name:action_name, category:action_category, val:data_array)
		if action_ini_data != undefined do (

			icon_index = (action_ini_data.get "val")[1] --#(106, "mcAnimation.reverse 0 10" , "Reverse_Animation")
			command =  (action_ini_data.get "val")[2] --#(106, "mcAnimation.reverse 0 10" , "Reverse_Animation")
		)
		setIcon icon_index --load icon
		if command != undefined do edi_command.text = command --load function or file name
		
		format "loadData > category:% action:% icon_index:% command:%\n" category_name action_name icon_index command
	)
	
	fn getItemIndex list item_name = (
	
		return (for i = 1 to list.items.count where list.items[i] == item_name collect i)[1]
	)
	
	fn	loadActions override:true = (
	
		if category_name == undefined do return false
		local actions = getIniSetting mcActionIni category_name
		if actions.count == 0 do return false
		ddl_actions.items = actions
		--select first item or predefined item
		ddl_actions.selection = if predefined_action_name != undefined then (
			
			getItemIndex ddl_actions predefined_action_name
			
		) else (
			
			1
		)
		predefined_action_name = undefined
		action_name = ddl_actions.selected
		loadData()
	)
	
	fn loadCatalog = (
	
		local categories = getIniSetting mcActionIni
		if categories.count == 0 do return false
		ddl_categories.items = categories
		ddl_categories.selection = if predefined_cat_name != undefined then (
			
			getItemIndex ddl_categories predefined_cat_name
			
		) else (
			
			1
		)
		predefined_cat_name = undefined
		category_name = ddl_categories.selected
		loadActions()
	)
	
	fn selectItemByName list item_name = (
	
		local  item_index = (for i = 1 to list.items.count where list.items[i] == item_name collect i)[1]
		format "item:% index:%\n" item_name item_index
		if item_index != undefined do list.selection =  item_index	
	)
	
	fn init = (
		
		--get loading mode type
		start_switch = mcGM.getParam "action_editor_switch" --edit mode switch (edit, create new, standalone)
		if start_switch == undefined or  micra_button == undefined do start_switch = "standalone"
		
		--get active button name
		local micra_button = mcGM.getParam "active_button" --micra toolbar active button
		if btn != undefined do button_name = micra_button.name
			
		format "init > start in mode:% active button:%\n" start_switch button_name
		
		--int at specific mode
		case start_switch of (
		
			"edit":(
			
				local action_ini_data = mcSystem.getActionByName action_name   -- mcObject(name:action_name, category:action_category, val:data_array)
				action_name = micra_button.tag
				category_name = action_ini_data.get "category"
				predefined_cat_name = category_name
				predefined_action_name = action_name
			)
			"create":(
		
			)
			"standalone":(
	
			)
		)
		
		--load catalog, actions and data
		loadCatalog()
	)

	fn finish = (
		
		--clear global variables
		mcGM.setParam "action_editor_switch"undefined
		mcGM.setParam "active_button" undefined
	)	
	
	on mcActionEditorDialog open do init()
	on mcActionEditorDialog close do finish()
	on btn_icon pressed do editIcon()	
	on ddl_categories selected sel do (category_name = ddl_categories.selected; loadActions())
	on ddl_actions selected sel do (action_name = ddl_actions.selected; loadData())
	on btn_save pressed do saveAll()
	on btn_cancel pressed do closeDialog()
	on btn_edit_function pressed do editFunction()
)
createDialog mcActionEditorDialog
