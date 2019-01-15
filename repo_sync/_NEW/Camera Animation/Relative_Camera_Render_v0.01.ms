
Global mcRelativeCameraRender
rollout mcRelativeCameraRender "Relative Camera Render" width:588 height:312
(
	GroupBox 'grp1' "Parameters:" pos:[4,4] width:576 height:300 align:#left
	
	label 'lbl1' "Save Dir:" pos:[12,28] width:60 height:16 align:#left
	label 'lbl2' "Save Name:" pos:[12,48] width:60 height:16 align:#left
	label 'lbl5' "Start:" pos:[448,176] width:32 height:16 align:#left
	label 'lbl6' "End:" pos:[448,196] width:32 height:16 align:#left
	
	button 'btn_list_add' "?" pos:[208,96] width:32 height:20 align:#left
	button 'btn_list_del' "?" pos:[208,120] width:32 height:20 align:#left
	button 'btn_preview' "Preview" pos:[448,236] width:108 height:24 align:#left
	button 'btn_render' "Render" pos:[448,264] width:108 height:24 align:#left
	button 'btn_save_settings' "Save" pos:[448,40] width:108 height:24 align:#left
	button 'btn_get_dir' "..." pos:[376,24] width:50 height:20 align:#left
	button 'btn_load_settings' "Load" pos:[448,68] width:108 height:24 align:#left
	button 'btn_move_up' "?" pos:[444,100] width:32 height:20 align:#left
	button 'btn_move_down' "?" pos:[444,120] width:32 height:20 align:#left
	
	edittext 'edt_save_dir' "" pos:[80,28] width:288 height:16 align:#left
	edittext 'edt_file_name' "" pos:[80,48] width:288 height:16 align:#left

	dropdownList 'ddl_extensions' "" pos:[376,48] width:50 height:21 items:#("png", "jpg", "tga", "tif", "bmp") align:#left
	
	multilistbox 'lbx_left' "Scene Cameras:" pos:[16,76] width:180 height:15 align:#left
	multilistbox 'lbx_right' "Active Cameras:" pos:[252,76] width:180 height:15 align:#left
	
	spinner 'spn_start_frame' "" pos:[484,176] width:76 height:16 type:#integer align:#left 
	spinner 'spn_end_frame' "" pos:[484,196] width:76 height:16 type:#integer align:#left
	struct CAM_DATA (name, cam, start=0, end=100, active=false)
	struct CAM_LIST (
		
		list = #(),
		fn getItemData item_name = (for o in list where o.name == item_name do exit with o),
		fn addItems lbx names_list= (lbx.items = join lbx.items names_list),
		fn delItems lbx names_list= (
			
			local list_names = lbx.items
			for n in names_list do (
				
				local item_index = findItem list_names n
				if item_index != undefined do deleteitem list_names item_index
			)
			lbx.items = list_names
		),
		fn moveItems lbx_a lbx_b = ( --move one or more items left - right
			
			local sel_indexes =  lbx_a.selection as Array
			if sel_indexes.count == 0 do return false
			local sel_names = for i in sel_indexes collect lbx_a.items[i]
			--format "moveItems > from:% to:% sel_indexes:% sel_names:%\n" lbx_a.name lbx_b.name  sel_indexes sel_names
			delItems lbx_a sel_names
			addItems lbx_b sel_names
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
		)
	)
	----------------------------------------
	local clist = CAM_LIST()
	local active_cam = undefined
	local end_frame = 0
	local tasks_done = 0
	----------------------------------------
	fn init_cams = (
		
		clist.list = for c in (Cameras as array)  collect (CAM_DATA name:c.name cam:c)
		clist.fillList lbx_left
	)
	fn init = (
		
		init_cams()	
		spn_end_frame.value=100
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
			
		local item_name = clist.getCurrentItem lbx_right
		if item_name == undefined do return false
		local item_data = clist.getItemData item_name
		spn_start_frame.value = item_data.start
		spn_end_frame.value = item_data.end
	)
	fn pickNextCamera = (
		
			local o = clist.list[tasks_done+1]
			format  "start cam:% interval:%\n" o.name [o.start, o.end]
			sliderTime = o.start
			end_frame = o.end
			viewport.setCamera o.cam
			format  "end cam:%\n" o.name
	)
	fn play = (
	
		if currentTime < end_frame then (
			
			print currentTime	
			
		) else if tasks_done < clist.list.count do (
			
			tasks_done += 1
			unRegisterTimeCallback play	
			stopAnimation()
			
			pickNextCamera()
			registerTimeCallback play
			playAnimation()
		)
	)
	fn previewAnimation = (
		
		tasks_done = 0
		pickNextCamera()
		registerTimeCallback play
		playAnimation()
	)
	fn addItem = (clist.moveItems lbx_left lbx_right)
	fn delItem = (clist.moveItems lbx_right lbx_left)
	on mcRelativeCameraRender open do init()
	on btn_list_add pressed do addItem()
	on btn_list_del pressed do delItem()
	on lbx_right selectionEnd  do getActiveItemData()
	on spn_start_frame changed val do setActiveItemData val #start_frame
	on spn_end_frame changed val do setActiveItemData val #end_frame
	on btn_preview pressed do previewAnimation()
)
CreateDialog mcRelativeCameraRender


/*
	fn play = (
	
		if currentTime < end_frame then (
			
			print currentTime	
		) else (
			
			unRegisterTimeCallback play	
			stopAnimation()
		)
	)
	fn previewAnimation = (
		
		--animationRange = interval 0 100	-- set a sample animation range
		for o in clist.list do (
			
			format  "start cam:% interval:%\n" o.name [o.start, o.end]
			sliderTime = o.start
			end_frame = o.end
			registerTimeCallback play
			playAnimation()
			format  "end cam:%\n" o.name
		)
	)
*/
	--animationRange = interval 0 100	-- set a sample animation range