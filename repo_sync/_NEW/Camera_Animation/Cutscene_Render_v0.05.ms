struct MSX_INTERFACE_MULTILISTBOX	(
	
	--variables

	
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	--------------------
	/* MultiListBox */
	--------------------
	fn getItemIndex lbx item_name = (
		
		for i = 1 to lbx.items.count do if lbx.items[i] == item_name do return i
		0
	),
	fn insertItemAt lbx item_name item_index = (
	
		insertItem item_name lbx.items item_index
		lbx.items = lbx.items
	),
	fn removeItemByName lbx item_name = (
	
		local item_index = getItemIndex lbx item_name
		if item_index > 0 do lbx.items = deleteItem lbx.items item_index
	),
	fn isSelected lbx item_name = ((for i in lbx.selection where lbx.items[i] == item_name collect i).count != 0),
	/**
	*@Usage
		move items in MultiListBox up and down
	*@Example
		mcMsxInterfaceMLB.mlbxMoveItems lbx_a #up
	*/
	fn moveItems lbx way = (
	
		local sel = lbx.selection
		if sel.count == 0 do return false
		local new_sel = #{}
		case way of (
		
			#up		: (	--Moves the selected items up one level
			
				local is_first_item_selected = findItem sel 1 --check if first item is at top
				if is_first_item_selected != 0 do deleteItem sel is_first_item_selected --remove top item from selection
				local names_to_move = for i in sel collect lbx.items[i]
				for i = 1 to names_to_move.count do ( --move selected items up
					
					local item_name = names_to_move[i]
					local item_index = (sel as Array)[i]
					removeItemByName lbx item_name
					insertItemAt lbx names_to_move[i] (item_index-1)
					append new_sel (item_index-1)
				)
			)
			#down	: (	--Moves the selected items one level down
			
				local is_last_item_selected = findItem sel sel.count --check if last item is at bottom
				if is_last_item_selected != 0 do deleteItem sel is_last_item_selected --remove bottom item from selection
				local names_to_move = for i in sel collect lbx.items[i]
				for i = names_to_move.count to 1 by -1 do ( --move selected items down
					
					local item_name = names_to_move[i]
					local item_index = (sel as Array)[i]
					removeItemByName lbx item_name
					insertItemAt lbx names_to_move[i] (item_index+1)
					append new_sel (item_index+1)
				)
			)
		)
		lbx.selection =  new_sel
	)
)	
----------------------------------------------------------------------------------------------
Global mxsImterfaceMLB = MSX_INTERFACE_MULTILISTBOX()
Global mcRelativeCameraRender
----------------------------------------------------------------------------------------------
if mcRelativeCameraRender != undefined  do try (destroyDialog mcRelativeCameraRender) catch()
rollout mcRelativeCameraRender "Cutscene Render v0.05" width:572 height:312
(
	GroupBox grp1 "Parameters:" pos:[4,4] width:564 height:300
	
	label lbl1 "Save Dir:" pos:[12,28] width:60 height:16
	label lbl2 "Save Name:" pos:[12,48] width:60 height:16
	label lbl5 "Start:" pos:[448,160] width:32 height:16
	label lbl6 "End:" pos:[448,180] width:32 height:16
	label lbl7 "Fps:" pos:[448,224] width:32 height:16
	
	button btn_list_add ">" pos:[208,96] width:28 height:22
	button btn_list_del "<" pos:[208,120] width:28 height:22
	button btn_reload_force "R" pos:[208,268] width:32 height:20 enabled:false align:#left
	button btn_clear "C" pos:[208,244] width:32 height:20 enabled:false align:#left
	button btn_render "Render" pos:[444,24] width:116 height:48
	button btn_get_dir "..." pos:[376,24] width:50 height:20
	button btn_move_up "/\\" pos:[444,96] width:28 height:22
	button btn_move_down "\\/" pos:[444,120] width:28 height:22
	
	checkButton ckb_preview "Preview" pos:[448,244] width:112 height:48 align:#left
	
	edittext edt_save_dir "" pos:[80,28] width:288 height:16
	edittext edt_file_name "" pos:[80,48] width:288 height:16

	dropdownList ddl_extensions "" pos:[376,48] width:50 height:21 items:#("png", "jpg", "tga", "tif", "bmp")
	
	multiListBox lbx_left "Scene Cameras:" pos:[16,76] width:180 height:15
	multiListBox lbx_right "Active Cameras:" pos:[252,76] width:180 height:15
	
	spinner spn_start_frame "" pos:[484,160] width:76 height:16 range:[0,10000,0] type:#integer 
	spinner spn_end_frame "" pos:[484,180] width:76 height:16 range:[0,10000,0] type:#integer
	spinner spn_framerate "" pos:[484,224] width:76 height:16 range:[0,100,0] type:#integer

	struct CAM_DATA (name, start=0, end=100, active=false)
	struct CAM_LIST (
		
		list = #(),
		autobk,
		fn getItemData item_name = (
			
			local  item = for o in list where o.name == item_name do exit with o
			if item == OK then undefined else item
		),
		fn addItems lbx names_list= (lbx.items = join lbx.items names_list), --univesral left or right list
		fn delItems lbx names_list= ( --univesral left or right list
			
			local list_names = lbx.items
			for n in names_list do (
				
				local item_index = findItem list_names n
				if item_index != undefined do (
					
					deleteitem list_names item_index
				)
			)
			lbx.items = list_names
		),
		fn moveItems lbx_a lbx_b active:false = ( --move one or more items left - right
			
			local sel_indexes =  lbx_a.selection as Array
			if sel_indexes.count == 0 do return false
			local sel_names = for i in sel_indexes collect lbx_a.items[i]
			--format "moveItems > from:% to:% sel_indexes:% sel_names:%\n" lbx_a.name lbx_b.name  sel_indexes sel_names
			for n in sel_names do (getItemData n).active = active
			delItems lbx_a sel_names
			addItems lbx_b sel_names
		),
		fn moveSelectedItems way = ( --move selected items in right box up and down
		
			::mxsImterfaceMLB.moveItems lbx_right way
		),
		fn moveItem lbx way = ( --move single item up - down
			
			
		),
		fn fillList lbx = (
			
			lbx.items  = sort (for o in list collect o.name)
		),
		fn getCurrentItem lbx = (
		
			local sel =  lbx.selection as Array
			if sel.count != 1 do return false
			lbx.items[sel[1]]
		),
		fn getActive = (for o in list where o.active collect o),
		fn importData saved_list = ( --get data from list and move active cameras to right
		
			format "importData > saved_list:%\n" saved_list
			local names_list = #()
			for o in saved_list do (
			
				local item = getItemData o.name
				if item == undefined do continue --camera is not in scene
				item.start = o.start
				item.end = o.end
				item.active = o.active
				if item.active do names_list += #(item.name)
				
			)
			addItems lbx_right names_list
			delItems lbx_left names_list
		),	
		fn toString = (
			
			local str = ""
			for o in list do str += o.name + "," + o.start as string + "," + o.end as string + "," + o.active as string + "|"
			str
		),
		fn fromString str = (
			
			local saved_list = #()
			if str == undefined do return saved_list
			local data_arr = filterString str "|"
			if classOf data_arr != Array do return saved_list
			for d in data_arr do (
				
				local arr = filterString d ","
				if classOf arr != array do continue
				saved_list += #( CAM_DATA name:arr[1] start:(execute arr[2]) end:(execute arr[3]) active:(execute arr[4]) )
			)
			saved_list
		)
	)
	----------------------------------------
	local clist = CAM_LIST()
	local active_cam = undefined
	local end_frame = 0
	local tasks_done = 0
	local timerAnim = dotNetObject "System.Windows.Forms.Timer"
	local active_cameras_data = #()
	local animating = false
	local rendering = false
	----------------------------------------
	fn initArrows = (
		
		/*struct ARROWS_ASCII  (left=11164,right=11166,up=11165, down=11167)
		--struct ARROWS_ASCII  (left=9668,right=9658,up=9651, down=9661)
		--struct ARROWS_ASCII  (left=9664,right=9654,up=9650, down=9660)
		--struct ARROWS_ASCII  (left=8672,right=8674,up=8673, down=8675)
		local  arrows = ARROWS_ASCII()
		btn_move_up.text = bit.intAsChar arrows.up
		btn_move_down.text = bit.intAsChar arrows.down
		btn_list_add.text = bit.intAsChar arrows.right
		btn_list_del.text = bit.intAsChar arrows.left*/
		local arrow_icons_i = (getDir #ui_ln) + "icons\\CAT_i.bmp"
		local arrow_icons_a = (getDir #ui_ln) + "icons\\CAT_a.bmp"
		local icons_total = 50
		if doesFileExist arrow_icons_i do (
			
			local the_buttons = #(btn_move_up, btn_move_down, btn_list_add, btn_list_del, btn_get_dir)
			local the_indexes = #(15, 16, 22, 21, 9)
			for i = 1 to the_buttons.count do (
		
				local up_index = the_indexes[i]
				local down_index = icons_total - (icons_total/2-up_index)
				the_buttons[i].Images = #(arrow_icons_i, arrow_icons_a, icons_total, up_index, down_index, 1, 1, true)
			)
		)
	)
	/**
	*Usage:
		remove app data defined by id_indexes array
	*Example 
		clearAppData #(1, 2, 3, 5, 45)
	*/
	fn clearAppData id_indexes = (
		
		for i in id_indexes do deleteAppData rootnode i
	)
	fn initCams = (

		clist.list = for c in (Cameras as array) where c.isTarget == false collect (CAM_DATA name:c.name)
		clist.fillList lbx_left
	)
	fn setActiveItemData val data_type = (
		
		local item_name = clist.getCurrentItem lbx_right
		if item_name == undefined do return false
		local item_data = clist.getItemData item_name
		case data_type of (
			
			#start_frame:item_data.start = val
			#end_frame:item_data.end = val
		)
	)
	fn getActiveItemData = (
			
		if (lbx_right.selection as array).count != 1 do return false
		local item_name = clist.getCurrentItem lbx_right
		if item_name == undefined do return false
		local item_data = clist.getItemData item_name
		spn_start_frame.value = item_data.start
		spn_end_frame.value = item_data.end
	)
	fn pickNextActiveCamera = (
		
			local o = active_cameras_data[tasks_done+1]
			if o == undefined do return false
			format  "start cam:% interval:%\n" o.name [o.start, o.end]
			sliderTime = o.start
			end_frame = o.end
			local cam =  (getNodeByName o.name)
			if cam != undefined do viewport.setCamera cam
		--activeCamera = (getNodeByName activeCam)
			format  "end cam:%\n" o.name
	)
	fn unregisterPreview = (
	
		format "undegister tasks\n"
		dotNet.removeAllEventHandlers timerAnim
		timerAnim.Stop()
		timerAnim.Dispose()
		sliderTime = 0
		ckb_preview.checked = false
	)
	fn onTick s args =
	 (
		 if not animating do (
			
			unregisterPreview()
			return false
		 )
		 
		if currentTime < end_frame then (
			
			sliderTime += 1
			
		) else if tasks_done < clist.list.count-1 then (
			
			tasks_done += 1
			pickNextActiveCamera()
		) else (
			
			tasks_done += 1
		)
		--format "preform tasks [ %  - % ] current:%\n"  0  clist.list.count tasks_done
		if tasks_done >= clist.list.count do unregisterPreview()
	 )
	fn previewAnimation state= (
		
		animating = state
		if not animating do return false
		
		tasks_done = 0
		active_cameras_data = clist.getActive()
		pickNextActiveCamera()
		timerAnim.Interval =  spn_framerate.value 
		dotNet.AddEventHandler timerAnim #tick onTick
		timerAnim.Start()
	)
	fn renderActiveCameras =  (
		
		if rendering do return false
		if lbx_right.items.count == 0 do (--nothing to render
			
			messageBox "Active Camera list is empty" title:"Render"
			return false
		) 
		if  not (doesDirectoryExist edt_save_dir.text) do  ( --dir not found
			
			messageBox ("Directory [ "+edt_save_dir.text+" ] is not exist") title:"Render"
			return false
		)
		if  edt_file_name.text == "" do  (--file name is empty
			
			messageBox "File name are not set" title:"Render"
			return false
		) 
		
		autobk = autoBackup.enabled
		autoBackup.enabled = false
		
		local renderWasCancelled = false
		for n in lbx_right.items do ( 
			
			if renderWasCancelled do (
				
				format "Render wass cancelled by user\n"
				exit
			)
			local img
			local cam = clist.getItemData n
			local current_cam = getNodeByName cam.name
			if current_cam == undefined do continue --if camera not found in scene skip it
			for f = cam.start to cam.end do (
			
				local ofile = edt_save_dir.text + "\\" + edt_file_name.text +"_f"+(f as string)+"."+(ddl_extensions.selected as string)
				format "render cam:% frame:[ % / % ] to file:%\n" n f cam.end ofile
				img = render camera:current_cam frame:f outputfile:ofile cancelled:&renderWasCancelled progressbar:true frame:#current vfb:false
				if renderWasCancelled do exit --Render wass cancelled by user
			)
		)
		rendering = false
		autoBackup.enabled = autobk
	)
	fn addItem = (clist.moveItems lbx_left lbx_right active:true)
	fn delItem = (clist.moveItems lbx_right lbx_left)
	fn getRenderDir = (
		
		local render_dir = getSavePath caption:"Get render destination directory:"
		if (render_dir != undefined) then edt_save_dir.text = render_dir
	)
	fn getSavedSettings = (
		--gather interface settings
		local render_dir			= getAppData rootnode 101 --get render path
		local file_name			= getAppData rootnode 102 --get file name
		local frame_rate 		= getAppData rootnode 103 --get frame rate
		local file_type_index	= getAppData rootnode 104 --get file type index
		--geather camers settings
		local cam_list  = getAppData rootnode 108 --get  cameras list
		--apply interface settings
		if render_dir != undefined do edt_save_dir.text	= render_dir 
		if file_name != undefined do edt_file_name.text	= file_name 
		if file_type_index != undefined do ddl_extensions.selection	= execute  file_type_index
		spn_framerate.value	= if frame_rate != undefined then  execute frame_rate else frameRate
		--restore cameras list (name, start, end, active)
		local saved_list = clist.fromString cam_list
		if saved_list.count == 0 do return false
		clist.importData saved_list --get saved data and move active cams to right
	)
	--Open - Close  (last functions)
	fn init = (
		
		initArrows()
		initCams()	
		getSavedSettings()
	)
	fn fin = (
	
		dotNet.removeAllEventHandlers timerAnim
		setAppData rootnode 101 edt_save_dir.text	--storerender path
		setAppData rootnode 102 edt_file_name.text	--store file name
		setAppData rootnode 103 (spn_framerate.value	as String)--store frame rate
		setAppData rootnode 104  (ddl_extensions.selection as String) --store file type index
		--store cameras list (name, start, end, active)
		setAppData rootnode 108 (clist.toString()) --store cameras list
	)
	--Events
	on mcRelativeCameraRender open do init()
	on mcRelativeCameraRender close do fin()
	on btn_list_add pressed do addItem()
	on btn_list_del pressed do delItem()
	on lbx_right selectionEnd  do getActiveItemData() --selectionEnd
	on spn_start_frame changed val do setActiveItemData val #start_frame
	on spn_end_frame changed val do setActiveItemData val #end_frame
	on ckb_preview changed state do previewAnimation state 
	on btn_get_dir pressed do getRenderDir()
	on btn_render pressed do renderActiveCameras()
	on btn_move_up pressed do clist.moveSelectedItems #up
	on btn_move_down pressed do clist.moveSelectedItems #down
)
CreateDialog mcRelativeCameraRender


/*
--break test2
if (keyboard.escPressed==true) then (

if queryBox "Do you want to cancel rendering ?" title:"Render" then (

exit --break loop
)	
*/
