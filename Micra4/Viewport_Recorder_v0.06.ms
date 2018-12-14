Global mcViewportRecorderDialog

if mcViewportRecorderDialog != undefined do destroyDialog mcViewportRecorderDialog
rollout mcViewportRecorderDialog "" width:316 height:124
(
	local temp_save_path = mcPath() + "Temp\\Grab\\"
	local dMove = false, DmPos, frame_number = 0, captured_frames = #()
	local recording = false , paused = false
	GroupBox grp1 "Viewport Recorder:" pos:[4,4] width:308 height:116
	button btn_rec "Rec" pos:[12,80] width:24 height:24 images:(mcCall.getIcon 172) tooltip:"Start Record"
	button btn_dir "Dir..." pos:[280,26] width:24 height:24 images:(mcCall.getIcon 173) tooltip:"Save File As..."
	edittext edt_path "" pos:[46,28] width:228 height:20
	button btn_stop "Stop" pos:[40,80] width:24 height:24 images:(mcCall.getIcon 171) tooltip:"Stop Record"
	Timer tmr_rec "Timer" pos:[280,80] width:24 height:24 enabled:true interval:1000 active:false -- 1 sec
	label lbl_frame "Captured Frames: 0" pos:[136,84] width:116 height:14
	button btn_close "*" pos:[300,4] width:12 height:12
	--button btn_crop "Crop" pos:[288,56] width:48 height:24
	spinner spn_fps "" pos:[248,56] width:56 height:16 range:[1,35,4] type:#integer scale:1 
	spinner spn_w "" pos:[48,56] width:56 height:16 range:[24,1000,280] type:#integer scale:1
	label lbl3 "Width:" pos:[12,56] width:36 height:16
	label lbl4 "FPS:" pos:[212,56] width:36 height:16 
	spinner spn_h "" pos:[148,56] width:56 height:16 range:[24,1000,180] type:#integer scale:1
	label lbl5 "Height:" pos:[112,56] width:36 height:16
	label lbl6 "Path:" pos:[12,30] width:36 height:16 
	--button btn_play "Play" pos:[68,80] width:24 height:24 images:(mcCall.getIcon 178) tooltip:"Edit Movie"
	progressBar pb_bar "ProgressBar" pos:[12,108] width:292 height:8 color:green 
	fn displayRect =
	(
		local rect_color  = red
		local view_text   = "Rec"
		local view_size   = getViewSize()
		local rect_size   = (gw.getTextExtent view_text)+4
		rect_size.x += 10
		local rect_offset = [view_size.x - rect_size.x - 8, view_size.y - rect_size.y - 8, 0]
		local p1 =[0           , 0          , 0] + rect_offset
		local p2 =[0           , rect_size.y, 0] + rect_offset
		local p3 =[rect_size.x , rect_size.y, 0] + rect_offset
		local p4 =[rect_size.x , 0          , 0] + rect_offset
		local updateRect = box2 p2 p4 --<upperleft_point2> <lowerRight_point2>
		updateRect.w +=2
		updateRect.h +=2
		rect_offset.x += 2
		--gw.clearscreen updateRect useBkg:true
		gw.hText rect_offset view_text color:rect_color
		gw.hPolyline #(p1, p2, p3, p4) true rgb:#(rect_color, rect_color, rect_color, rect_color) 
		gw.enlargeUpdateRect updateRect
		gw.updateScreen()
	)
	fn resizeBitmap img size =
	(
		local new_img = bitmap size.x size.y
		copy img new_img
		return new_img
	)
	fn cropImageToCenter img region =
	(
		format "image:%\tregion:%\n" img region
		--[ region: #(left,top,right,bottom) ] 
		
		--bitmap_obj     = (dotNetObject "System.Drawing.Bitmap" dotnet_bitmap.width dotnet_bitmap.height) --Create new bitmap object
		--graphics_class = (dotNetClass "System.Drawing.Graphics").fromImage bitmap_obj --Create new Graphics object
		--rect           = (dotNetClass "System.Drawing.Rectangle").FromLTRB 0 0 dotnet_bitmap.width dotnet_bitmap.height --left top right bottom
		--.DrawImageUnscaledAndClipped dotnet_bitmap rect
		graphics_class.dispose() --gc
		--return bitmap_obj
	)
	fn CropImage OriginalImage TopLeft BottomRight = --dotnet
	(
		btmCropped  = (dotNetObject "Drawing.Bitmap" (BottomRight.Y - TopLeft.Y) (BottomRight.X - TopLeft.X)) --Create new bitmap object
		grpOriginal = (dotNetClass "Drawing.Graphics").fromImage btmCropped --Create new Graphics object
		
		newRect = dotnetObject "Drawing.rectangle" 0  0  btmCropped.Width  btmCropped.Height
		graphicsUnit = dotNetClass "Drawing.GraphicsUnit"
		grpOriginal.DrawImage OriginalImage newRect TopLeft.X TopLeft.Y btmCropped.Width btmCropped.Height graphicsUnit.Pixel
		
		Return btmCropped
	)
	fn customGifSavePath =
	(
		local gif_file_name = getSaveFileName caption:"Save Gif Animation File..." types:"CompuServe (*.gif)|*.gif"
		if gif_file_name != undefined do edt_path.text = gif_file_name
	)
	fn captureFrames frame =
	(
		local img = try gw.getViewportDib() catch (undefined)
		if img == undefined do (tmr_rec.active = false ; return false)
		local new_img = resizeBitmap img [spn_w.value,spn_h.value]
		lbl_frame.text = "Captured Frames: " + frame as string
		captured_frames += #(new_img)
	)
	fn saveCapturedFrames =
	(	
		if captured_frames.count > 2 
		then 
		(
			for i = 1 to captured_frames.count do 
			(
				local val_str = if i < 10 then "0"+ i as string else i as string
				local file_name = temp_save_path + val_str + ".jpg"
				captured_frames[i].filename = file_name
				save captured_frames[i]
				close captured_frames[i]
				pb_bar.value = 100.*i/captured_frames.count
			)
			pb_bar.value = 0
			mcfileInVersion "Gif_Compiller"
		)
		else 
		(
			messagebox "Not enough frames to save an Animation!" title:" Viewport Recorder:"
		)
	)
	fn playGifAnimation file_path =
	(
		if not doesFileExist file_path do return false
		messagebox file_path
	)
	on mcViewportRecorderDialog rbuttonup pos do (destroyDialog mcViewportRecorderDialog)
	-->MoveMode
	on mcViewportRecorderDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcViewportRecorderDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcViewportRecorderDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do 
		(
			if mcDialogSnappingEnabled 
			then mcDialogSnap mcViewportRecorderDialog DmPos
			else setDialogPos mcViewportRecorderDialog (mouse.screenpos - DmPos)
		)
	)
	on mcViewportRecorderDialog open do 
	(
		if not doesFileExist temp_save_path do makeDir temp_save_path all:true
		if doesFileExist temp_save_path do
		(
			edt_path.text = mcPath() + "Help\\temp.gif"
		)
	)
	on mcViewportRecorderDialog close do
	(
		unregisterRedrawViewsCallback displayRect
		mcCall.saveIniDialog "mcViewportRecorderDialog" "Properties_2"
		completeRedraw()
	)
	--on btn_browse pressed do if doesFileExist temp_save_path do ShellLaunch temp_save_path ""
	on btn_close pressed do destroyDialog mcViewportRecorderDialog
	on spn_fps changed val do tmr_rec.interval = 1000 / val
	on btn_comp pressed do packImagesInToGif()
	on btn_rec pressed do
	(
		if doesFileExist temp_save_path and not recording 
		then
		(
			recording = true
			try ( for i in (getFiles (temp_save_path + "*.jpg")) do deleteFile i) catch()
			btn_rec.images = mcCall.getIcon 178
			unregisterRedrawViewsCallback displayRect
			registerRedrawViewsCallback displayRect
			if not paused do
			(
				lbl_frame.text = "Captured Frames: 0"
				captured_frames = #()
			)
			tmr_rec.interval = 1000 / spn_fps.value
			tmr_rec.active = true
			pb_bar.value = 0
			completeRedraw()
			--format "timer interval:%\tspinner value:%\n" tmr_rec.interval spn_fps.value
		)
		else
		(
			btn_rec.images = mcCall.getIcon 179
			tmr_rec.active = false
			recording = false
			paused = true
		)
	)
	on btn_stop pressed do 
	(
		unregisterRedrawViewsCallback displayRect
		frame_number   = 0
		tmr_rec.active = false
		btn_rec.images = mcCall.getIcon 172
		recording = false
	
		if querybox "Do you wish to save Captured Frames?" title:" Viewport Recorder:" and doesFileExist temp_save_path 
		then (saveCapturedFrames())
		else (lbl_frame.text = "Captured Frames: 0")
		captured_frames = #()
		completeRedraw()
	)
	on btn_dir pressed do customGifSavePath()
	on tmr_rec tick do captureFrames (frame_number += 1)
	on btn_play pressed do
	(
		local jpg_files = getFiles (temp_save_path + "*.jpg")
		if jpg_files.count != 0 do mcfileInVersion "Gif_Compiller"
		--mcGifCompillerDialog.temp_save_path = temp_save_path
		--mcGifCompillerDialog.gif_file_name  = edt_path.text
		--playGifAnimation edt_path.text
	)
)
--createDialog mcViewportRecorderDialog pos:[176,88] style:#(#style_border)
mcCall.createIniDialog "mcViewportRecorderDialog" "Properties_2"

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

			--local bat_file = temp_save_path + "gifsicle.bat"
			--createFile

local exe = (app_path +"gifsicle.exe")
local cmd = (" -d="+fps+"  "+temp_save_path+"*.gif > "+edt_path.text)
format "exe:%\tcmd:%\n" exe cmd
ShellLaunch exe cmd
ShellLaunch "E:\Micra3\\App\gifsicle.exe" "-d=25  E:\Micra3\\Temp\Grab\*.gif > E:\Micra3\Help\my_grab_file.gif"
ShellLaunch "E:\Micra3\\App\gifsicle" "-d=25 E:\Micra3\\Temp\Grab\*.gif > E:\Micra3\Help\my_grab_file.gif"
E:\Micra3\\App\gifsicle.exe	-d=25  E:\Micra3\\Temp\Grab\*.gif > E:\Micra3\Help\my_grab_file.gif --DOS WORKS
jpg2gif -k -a *.jpg
gifsicle -d=25 C:\temp\grab\*.* > C:\temp\grab\Anim\anim.gif
		
*/