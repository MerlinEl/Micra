--Resizable Movable Capture Frame WIP
--To move frame press Shift + LMB click on Top or Left part interface, and drag mouse
--To exit frame press RMB click on interface
--To resize press Shift + LMB on Left or Right part interface, and drag mouse 

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
	
	local vs = getViewSize()
	local ms = getMAXWindowSize()
	local mc = (ms - frame_scale)/2
	
	local t_pos = mc
	local l_pos = [0,8]+mc
	local r_pos = [frame_scale.x+8,0]+mc
	local b_pos = [8,frame_scale.y+8]+mc
	
	rollout mc2FrameLDialog "Left" 
	(
		local dMove = false, DmPos
		bitmap bmp_01 "" pos:[0,0] width:8 height:100 bitmap:(BitMap 1 1 color:green)
		on mc2FrameLDialog open do (bmp_01.height = mc2FrameLDialog.height)
		on mc2FrameLDialog rbuttonup pos   do destroyDialog mc2FrameTDialog
		-->MoveMode
		on mc2FrameLDialog lbuttondown pos do (dMove = true; DmPos = pos)
		on mc2FrameLDialog lbuttonup   pos do (dMove = false)
		on mc2FrameLDialog mouseMove   pos do 
		if dMove and keyboard.shiftPressed do 
		(
			local move_horizontal = mouse.screenpos - DmPos
			move_horizontal.y = (getDialogPos mc2FrameLDialog).y
			setDialogPos mc2FrameLDialog move_horizontal
			setDialogPos mc2FrameTDialog (mouse.screenpos - DmPos)
		)
	)
	
	
	rollout mc2FrameRDialog "Right" 
	(
		local dMove = false, DmPos
		bitmap bmp_01 "" pos:[0,0] width:8 height:100 bitmap:(BitMap 1 1 color:green)
		on mc2FrameRDialog open do (bmp_01.height = mc2FrameRDialog.height)
		on mc2FrameRDialog rbuttonup pos   do destroyDialog mc2FrameTDialog
		-->MoveMode
		on mc2FrameRDialog lbuttondown pos do (dMove = true; DmPos = pos)
		on mc2FrameRDialog lbuttonup   pos do (dMove = false)
		on mc2FrameRDialog mouseMove   pos do 
		if dMove and keyboard.shiftPressed do 
		(
			local move_horizontal = mouse.screenpos - DmPos
			move_horizontal.y = (getDialogPos mc2FrameRDialog).y
			setDialogPos mc2FrameRDialog move_horizontal
			mc2FrameTDialog.updateFramesSize (mouse.screenpos - DmPos) axis:#Right
		)
	)
	
		
	rollout mc2FrameBDialog "Bottom" 
	(
		local dMove = false, DmPos
		bitmap bmp_01 "" pos:[0,0] width:100 height:8 bitmap:(BitMap 1 1 color:green)
		on mc2FrameBDialog open do (bmp_01.width = mc2FrameBDialog.width)
		on mc2FrameBDialog rbuttonup pos   do destroyDialog mc2FrameTDialog
		-->MoveMode
		on mc2FrameBDialog lbuttondown pos do (dMove = true; DmPos = pos)
		on mc2FrameBDialog lbuttonup   pos do (dMove = false)
		on mc2FrameBDialog mouseMove   pos do 
		if dMove and keyboard.shiftPressed do 
		(
			local move_vertical = mouse.screenpos - DmPos
			move_vertical.x = (getDialogPos mc2FrameBDialog).x
			setDialogPos mc2FrameBDialog move_vertical
			mc2FrameTDialog.updateFramesSize (mouse.screenpos - DmPos) axis:#Bottom
		)
	)


	rollout mc2FrameTDialog "Top" 
	(
		local dMove = false, DmPos, ds = sysInfo.DesktopSize, fs
		bitmap bmp_01 "" pos:[0,0] width:100 height:8 bitmap:(BitMap 1 1 color:green) 
		-->Funtions
		fn moveFrameToMousePos =
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
		fn updateFramesPos pos =
		(
			setDialogPos mc2FrameRDialog [pos.x+fs.x, pos.y]
			setDialogPos mc2FrameLDialog [pos.x, pos.y+8]
			setDialogPos mc2FrameBDialog [pos.x+8, pos.y+fs.y]
			completeRedraw()
		)
		fn updateFramesSize pos axis: =
		(
			case axis of
			(
				#Bottom:
				(
					local rp = getDialogPos mc2FrameRDialog
					local si = pos.y - rp.y
					mc2FrameRDialog.height = si
					mc2FrameRDialog.bmp_01.height = si
					mc2FrameLDialog.height = si
					mc2FrameLDialog.bmp_01.height = si
					fs.y = si
				)
				#Right:
				(
					local rp = getDialogPos mc2FrameTDialog
					local si = pos.x - rp.x
					mc2FrameTDialog.width = si
					mc2FrameTDialog.bmp_01.width = si
					mc2FrameBDialog.width = si
					mc2FrameBDialog.bmp_01.width = si
					fs.x = si
				)
			)
			completeRedraw()
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
		on mc2FrameTDialog lbuttonup   pos do (dMove = false)
		on mc2FrameTDialog mouseMove   pos do (if dMove and keyboard.shiftPressed do setDialogPos mc2FrameTDialog (mouse.screenpos - DmPos))
		-->Dialog
		on mc2FrameTDialog rbuttonup pos   do destroyDialog mc2FrameTDialog
		on mc2FrameTDialog open            do
		(
			bmp_01.width = mc2FrameTDialog.width
			fs = [mc2FrameTDialog.width, (getDialogSize mc2FrameLDialog).y]
			--updateFramesPos()
		)
		on mc2FrameTDialog close do closeFrame()
		-->Actions
		on mc2FrameTDialog moved pos do updateFramesPos pos
	)
	createDialog mc2FrameLDialog pos:[l_pos.x, l_pos.y] width:l_size.x height:l_size.y style:#(#style_sysMenu)
	createDialog mc2FrameRDialog pos:[r_pos.x, r_pos.y] width:r_size.x height:r_size.y style:#(#style_sysMenu)
	createDialog mc2FrameBDialog pos:[b_pos.x, b_pos.y] width:b_size.x height:b_size.y style:#(#style_sysMenu)
	createDialog mc2FrameTDialog pos:[t_pos.x, t_pos.y] width:t_size.x height:t_size.y style:#(#style_sysMenu)
)

createCaptureFrame [280,180]