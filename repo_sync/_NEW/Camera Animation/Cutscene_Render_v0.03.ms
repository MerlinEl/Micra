--fix store load data
--fix preview on off
--render cancell is ok
Global mcRelativeCameraRender
if mcRelativeCameraRender != undefined  do try (destroyDialog mcRelativeCameraRender) catch()
rollout mcRelativeCameraRender "Cutscene Render v0.03" width:572 height:312
(
	GroupBox grp1 "Parameters:" pos:[4,4] width:564 height:300
	
	label lbl1 "Save Dir:" pos:[12,28] width:60 height:16
	label lbl2 "Save Name:" pos:[12,48] width:60 height:16
	label lbl5 "Start:" pos:[448,160] width:32 height:16
	label lbl6 "End:" pos:[448,180] width:32 height:16
	label lbl7 "Fps:" pos:[448,224] width:32 height:16
	
	button btn_list_add "?" pos:[208,96] width:32 height:20
	button btn_list_del "?" pos:[208,120] width:32 height:20
	button btn_reload_force "R" pos:[208,268] width:32 height:20 enabled:false align:#left
	button btn_clear "C" pos:[208,244] width:32 height:20 enabled:false align:#left
	button btn_render "Render" pos:[444,24] width:116 height:48
	button btn_get_dir "..." pos:[376,24] width:50 height:20
	button btn_move_up "?" pos:[444,100] width:32 height:20 enabled:false
	button btn_move_down "?" pos:[444,120] width:32 height:20 enabled:false
	
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
		fn getNewCams = (
			
			local new_cam_list = for c in (Cameras as array)  where getItemData c.name == undefined  and c.isTarget == false collect c.name
			--format "new_cam_list:%\n" new_cam_list
			for n in new_cam_list do (
				
				list += 	#(CAM_DATA name:n)
			)
			lbx_left.items = join lbx_left.items new_cam_list
		),
		fn validateCams = (
			
			--remove deleted cameras from left  lbx
			local deleted_camera_names_left = for n in lbx_left.items where getNodeByName n == undefined collect n
			if deleted_camera_names_left.count > 0  do delItems lbx_left deleted_camera_names_left
			--remove deleted cameras from right  lbx
			local deleted_camera_names_right = for n in lbx_right.items where getNodeByName n == undefined collect n
			if deleted_camera_names_right.count > 0  do delItems lbx_right deleted_camera_names_right
			--remove deleted cameras from data list
			local deleted_camera_names = join deleted_camera_names_left deleted_camera_names_right
			local remain_data = for o in list where findItem deleted_camera_names o.name == undefined collect o
			list = remain_data
		),
		fn toString = (
			
			local str = ""
			for o in list do str += o.name + "," + o.start as string + "," + o.end as string + "," + o.active as string + "|"
			str
		),
		fn fromString str = (
			
				local all_data = filterString str "|"
				local left_list = #()
				local right_list =#()
				list = for d in all_data collect (
					
					local arr = filterString d ","
					local cam = CAM_DATA name:arr[1] start:(execute arr[2]) end:(execute arr[3]) active:(execute arr[4])
					--format "cam data:%\n" cam
					if cam.active then append right_list cam.name else append left_list cam.name
					cam
				)
				lbx_left.items = left_list
				lbx_right.items = right_list
		)
	)
	----------------------------------------
	local clist = CAM_LIST()
	local active_cam = undefined
	local end_frame = 0
	local tasks_done = 0
	local timerAnim = dotNetObject "System.Windows.Forms.Timer"
	local active_cameras_data = #()
	local preview_active = false
	----------------------------------------
	fn initArrows = (
		
		struct ARROWS_ASCII  (left=11164,right=11166,up=11165, down=11167)
		local  arrows = ARROWS_ASCII()
		btn_move_up.text = bit. intAsChar arrows.up
		btn_move_down.text = bit. intAsChar arrows.down
		btn_list_add.text = bit. intAsChar arrows.right
		btn_list_del.text = bit. intAsChar arrows.left
	)
	fn initCams = (

		if clist.list.count != 0 do return false --check if clist is fil already (got data from store)
		clist.list = for c in (Cameras as array)  where c.isTarget == false collect (CAM_DATA name:c.name)
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
	)
	fn onTick s args =
	 (
		 if not preview_active do (
			
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
		if tasks_done >= clist.list.count	do unregisterPreview()
	 )
	fn previewAnimation state= (
		
		preview_active = state
		if not preview_active do return false
		
		tasks_done = 0
		active_cameras_data = clist.getActive()
		pickNextActiveCamera()
		timerAnim.Interval =  spn_framerate.value 
		dotNet.AddEventHandler timerAnim #tick onTick
		timerAnim.Start()
	)
	fn renderActiveCameras =  (
		
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
		autoBackup.enabled = autobk
	)
	fn addItem = (clist.moveItems lbx_left lbx_right active:true)
	fn delItem = (clist.moveItems lbx_right lbx_left)
	fn getRenderDir = (
		
		local render_dir = getSavePath()
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
		if cam_list != undefined do clist.fromString cam_list
		--add new cameras if exists
		clist.getNewCams()
		--delete cameras if not exists
		clist.validateCams()
	)
	--Open - Close  (last functions)
	fn init = (
		
		initArrows()
		getSavedSettings()
		initCams()	
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
)
CreateDialog mcRelativeCameraRender


/*
--break test2
if (keyboard.escPressed==true) then (

if queryBox "Do you want to cancel rendering ?" title:"Render" then (

exit --break loop
)	
)
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