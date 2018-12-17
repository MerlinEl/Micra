--Capture Frame WIP
--To close frame
--1)press Shift (stop the frame from moving)
--2)press RMB click on frame interface (to exit frame)


Global mc2FrameTDialog
Global mc2FrameLDialog
Global mc2FrameRDialog
Global mc2FrameBDialog

fn createCaptureFrame frame_scale =
(
	if mc2FrameTDialog != undefined do destroyDialog mc2FrameTDialog
	if mc2FrameLDialog != undefined do destroyDialog mc2FrameLDialog
	if mc2FrameRDialog != undefined do destroyDialog mc2FrameRDialog
	if mc2FrameBDialog != undefined do destroyDialog mc2FrameBDialog
	
	
	local t_size = [ frame_scale.x+8, 8               ]
	local l_size = [ 8              , frame_scale.y+8 ]
	local r_size = [ 8              , frame_scale.y+8 ]
	local b_size = [ frame_scale.x+8, 8               ]
	
	
	rollout mc2FrameLDialog "Left" 
	(
		bitmap bmp_01 "" pos:[0,0] width:8 height:100 bitmap:(BitMap 1 1 color:green)
		on mc2FrameLDialog open do (bmp_01.height = mc2FrameLDialog.height)
		on mc2FrameLDialog rbuttonup pos   do destroyDialog mc2FrameTDialog
	)
	
	
	rollout mc2FrameRDialog "Right" 
	(
		bitmap bmp_01 "" pos:[0,0] width:8 height:100 bitmap:(BitMap 1 1 color:green)
		on mc2FrameRDialog open do (bmp_01.height = mc2FrameRDialog.height)
		on mc2FrameRDialog rbuttonup pos   do destroyDialog mc2FrameTDialog
	)
	
		
	rollout mc2FrameBDialog "Bottom" 
	(
		bitmap bmp_01 "" pos:[0,0] width:100 height:8 bitmap:(BitMap 1 1 color:green)
		on mc2FrameBDialog open do (bmp_01.width = mc2FrameBDialog.width)
		on mc2FrameBDialog rbuttonup pos   do destroyDialog mc2FrameTDialog
	)


	rollout mc2FrameTDialog "Top" 
	(
		local dMove = false, DmPos, ds = sysInfo.DesktopSize, fs
		bitmap bmp_01 "" pos:[0,0] width:100 height:8 bitmap:(BitMap 1 1 color:green) 
		timer tmr_01 "Timer" pos:[1,-3] width:24 height:24 interval:10 active:false
		-->Funtions
		fn updateFramesPos =
		(
			local mp = mouse.screenpos
			if mp.x + fs.x/2 < fs.x or mp.x + fs.x/2 > ds.x do return false
			if mp.y + fs.y/2 < fs.y or mp.y + fs.y/2 > ds.y do return false
			if keyboard.shiftPressed do return false
			--format "mouse pos:%\trolout size:%\n" mp rs
			
			setDialogPos mc2FrameTDialog (mp + -[fs.x,fs.y]/2)
			setDialogPos mc2FrameLDialog (mp + -[fs.x,fs.y-16]/2)
			setDialogPos mc2FrameRDialog (mp + [fs.x,-fs.y]/2)
			setDialogPos mc2FrameBDialog (mp + [-fs.x+16,fs.y]/2)
		)
		fn closeFrame =
		(
			if mc2FrameLDialog != undefined do destroyDialog mc2FrameLDialog
			if mc2FrameRDialog != undefined do destroyDialog mc2FrameRDialog
			if mc2FrameBDialog != undefined do destroyDialog mc2FrameBDialog
			if mc2FrameTDialog != undefined do destroyDialog mc2FrameTDialog
		)
		-->MoveMode
		on mc2FrameTDialog lbuttondown pos do (dMove = true; DmPos = pos)
		on mc2FrameTDialog lbuttonup   pos do (dMove = false; tmr_01.active = not tmr_01.active)
		on mc2FrameTDialog mouseMove   pos do (if dMove and keyboard.shiftPressed do setDialogPos mc2FrameTDialog (mouse.screenpos - DmPos))
		-->Dialog
		on mc2FrameTDialog rbuttonup pos   do destroyDialog mc2FrameTDialog
		on mc2FrameTDialog open            do
		(
			bmp_01.width = mc2FrameTDialog.width
			fs = [mc2FrameTDialog.width, (getDialogSize mc2FrameLDialog).y]
			updateFramesPos()
			tmr_01.active = true
		)
		on mc2FrameTDialog close do closeFrame()
		-->Actions
		on tmr_01 tick do updateFramesPos()
	)
	createDialog mc2FrameLDialog pos:[0,8] width:l_size.x height:l_size.y style:#(#style_sysMenu)
	createDialog mc2FrameRDialog pos:[frame_scale.x+8,0] width:r_size.x height:r_size.y style:#(#style_sysMenu)
	createDialog mc2FrameBDialog pos:[8,frame_scale.y+8] width:b_size.x height:b_size.y style:#(#style_sysMenu)
	createDialog mc2FrameTDialog pos:[0,0] width:t_size.x height:t_size.y style:#(#style_sysMenu)
)

--createCaptureFrame [280,180]
createCaptureFrame [256,256]
