Global mcViewportRecorderDialog

if mcViewportRecorderDialog != undefined do destroyDialog mcViewportRecorderDialog
rollout mcViewportRecorderDialog "" width:460 height:124
(
	local save_path = "C:\\temp\\grab\\" 
	local dMove = false, DmPos, frame_number = 0 , frames_per_second = 1
	GroupBox grp1 "Viewport Recorder:" pos:[4,4] width:452 height:112
	button btn_rec "Rec" pos:[112,56] width:24 height:24
	button btn_dir "Dir..." pos:[416,28] width:32 height:20
	edittext edt_path "" pos:[44,28] width:368 height:20
	button btn_stop "Stop" pos:[140,56] width:24 height:24
	Timer tmr_rec "Timer" pos:[208,56] width:24 height:24 enabled:true interval:1000 active:false --1 sec
	label lbl_frame "Captured Frames: 0" pos:[112,88] width:116 height:14
	button btn_close "*" pos:[444,4] width:12 height:12
	button btn_crop "Crop" pos:[288,56] width:48 height:24
	spinner spn_fps "" pos:[48,96] width:56 height:16 range:[1,1000,1] type:#integer scale:1
	button btn_grab "Grab" pos:[236,56] width:48 height:24
	spinner spn_w "" pos:[48,56] width:56 height:16 range:[24,1000,280] type:#integer scale:1
	label lbl3 "Width:" pos:[12,56] width:36 height:16
	label lbl4 "FPS:" pos:[12,96] width:36 height:16
	spinner spn_h "" pos:[48,76] width:56 height:16 range:[24,1000,180] type:#integer scale:1
	label lbl5 "Height:" pos:[12,76] width:36 height:16
	label lbl6 "Path:" pos:[12,30] width:36 height:16
	button btn_clear "Clear" pos:[288,88] width:48 height:24
	button btn_comp "Compile" pos:[236,88] width:48 height:24
	button btn_play "Play" pos:[168,56] width:24 height:24
	--create a rectangle in center of active viewport
	fn displayRect =
	(
		local rect_color  = red
		local rect_size   = [spn_w.value,spn_h.value]
		local rect_center = rect_size / 2
		local vpt_center  = getViewSize() / 2
		local rect_pos = vpt_center - rect_center
		local p1 =[0           , 0          , 0] + [rect_pos.x, rect_pos.y, 0]
		local p2 =[0           , rect_size.y, 0] + [rect_pos.x, rect_pos.y, 0]
		local p3 =[rect_size.x , rect_size.y, 0] + [rect_pos.x, rect_pos.y, 0]
		local p4 =[rect_size.x , 0          , 0] + [rect_pos.x, rect_pos.y, 0]
		local updateRect = box2 p2 p4 --<upperleft_point2> <lowerRight_point2>
		updateRect.w +=2
		updateRect.h +=2
		local text_pos = [p2.x, p2.y+2, 0]
		local view_text= "Record Frame"
		--gw.clearscreen updateRect useBkg:true
		gw.hText text_pos view_text color:rect_color
		gw.hPolyline #(p1, p2, p3, p4) true rgb:#(rect_color, rect_color, rect_color, rect_color) 
		gw.enlargeUpdateRect updateRect
		gw.updateScreen()
	)
	fn deleteCapturedFiles =
	(
		if not querybox "Delete caprured files?" title:" Micra?" do return false
		
		local files = getFiles (edt_path.text + "\\*.jpg")
		for f in files do deleteFile f
		lbl_frame.text = "Captured Frames: 0"
	)
	fn cropImageToCenter img region =
	(
		format "image:%\tregion:%\n" img region
		--[ region: #(left,top,right,bottom) ] 
	)
	on mcViewportRecorderDialog rbuttonup pos do (destroyDialog mcViewportRecorderDialog)
	-->MoveMode
	on mcViewportRecorderDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcViewportRecorderDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcViewportRecorderDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialogSnap mcViewportRecorderDialog DmPos
	)
	on mcViewportRecorderDialog open do 
	(
		unregisterRedrawViewsCallback displayRect
		registerRedrawViewsCallback displayRect
		completeRedraw()
		if not doesFileExist save_path do makeDir save_path all:true
		edt_path.text = save_path
		spn_fps.value = frames_per_second 
		tmr_rec.interval = 1000 / frames_per_second
	)
	on mcViewportRecorderDialog close do
	(
		unregisterRedrawViewsCallback displayRect
		completeRedraw()
	)
	on btn_grab pressed do display (gw.getViewportDib())
	on btn_crop pressed do cropImageToCenter (gw.getViewportDib()) [spn_w.value,spn_h.value]
	on btn_close pressed do destroyDialog mcViewportRecorderDialog
	on spn_fps changed val do tmr_rec.interval = 1000 / val
	on spn_w changed val do 
	(
		completeRedraw()
		/*
		local rect_size   = [spn_w.value,spn_h.value]
		local rect_center = rect_size / 2
		local vpt_center  = getViewSize() / 2
		local rect_pos = vpt_center - rect_center
		local p2 =[0           , rect_size.y, 0] + [rect_pos.x, rect_pos.y, 0]
		local p4 =[rect_size.x , 0          , 0] + [rect_pos.x, rect_pos.y, 0]
		local updateRect = box2 p2 p4
		updateRect.w +=2
		updateRect.h +=2
		gw.clearscreen updateRect --useBkg:true
		--gw.updateScreen()
		redrawViews()
		*/
	)
	on spn_h changed val do
	(
		completeRedraw()
		--redrawViews()
	)
	--on spn_w buttonup  do completeRedraw()
	--on spn_h buttonup  do completeRedraw()
	on btn_rec pressed do
	(
		lbl_frame.text = "Captured Frames: 0"
		frame_number   = 0
		tmr_rec.active = true
	)
	on btn_stop pressed do tmr_rec.active = false
	on btn_dir  pressed do ShellLaunch edt_path.text ""
	on btn_clear pressed do deleteCapturedFiles()
	on tmr_rec tick do
	(
		local viewport_name = viewport.GetType()
		frame_number += 1
		if viewport_name == #view_persp_user do
		(
			local img = gw.getViewportDib()
			local file_name = edt_path.text + frame_number as string + ".jpg"
			img.filename = file_name
			lbl_frame.text = "Captured Frames: " + frame_number as string
			save img
		)
	)
)
createDialog mcViewportRecorderDialog style:#(#style_border)


/*
Global mcViewportRecFrameL
Global mcViewportRecFrameR
Global mcViewportRecFrameT
Global mcViewportRecFrameD

fn createFrame dsizex dsizey dname =
(
	local dpos = mouse.screenpos
	local exe ="if "+dname+" != undefined do destroyDialog " +dname+"\n"
	exe +="rollout "+dname+" \"frame\"\n"
	exe +="(\n"
	exe +="\timgTag tag_01 \" \" pos:[0,0] width:"+dsizex+" height:"+dsizey+" bitmap:(bitmap 10 10 color:green)\n"
	exe +=")\n"
	exe +="createDialog "+dname+" pos:"+dpos+" width:"+dsizex+" height:"+dsizey+" style:#(#style_sysMenu)"
	execute exe
)

createFrame "4" "200" "mcViewportRecFrameL"
destroyDialog mcViewportRecFrameL

*/