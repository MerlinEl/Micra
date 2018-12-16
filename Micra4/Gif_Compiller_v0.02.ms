Global mcGifCompillerDialog
if mcGifCompillerDialog != undefined do destroyDialog mcGifCompillerDialog
rollout mcGifCompillerDialog "Untitled" width:284 height:52
(
	-->Locals DotNet 
	local picture_box = dotNetObject "System.Windows.Forms.PictureBox"
	local image_class = dotNetClass "System.Drawing.Image"
	local frame_dimension = (dotNetClass "System.Drawing.Imaging.FrameDimension") --time resolution page
	-->Locals Standart 
	local dMove = false, DmPos, jpgPlayerDialog, gifPlayerDialog, video_size, jpg_files = #(), current_img_num = 0
	local temp_save_path = Micra.RootDir + "Temp\\Grab\\" , gif_file_name = "", playing = false, feake_tmr = 0
	button btn_play "p" pos:[4,4] width:24 height:24 images:(mcCall.getIcon 170) tooltip:"Play Movie"
	button btn_stop "s" pos:[32,4] width:24 height:24 images:(mcCall.getIcon 171) tooltip:"Stop Movie"
	label lbl1 "FPS:" pos:[64,8] width:24 height:16
	spinner spn_fps "" pos:[92,8] width:44 height:16 range:[1,35,4] type:#integer scale:1
	button btn_comp "Compile" pos:[4,32] width:48 height:16
	progressBar pb_bar "ProgressBar" pos:[56,32] width:224 height:16
	button btn_prev "<" pos:[172,4] width:24 height:24 images:(mcCall.getIcon 176) toolTip:"Previous Frame"
	button btn_next ">" pos:[200,4] width:24 height:24 images:(mcCall.getIcon 177) toolTip:"Next Frame"
	button btn_del "Del" pos:[144,4] width:24 height:24 images:(mcCall.getIcon 174) toolTip:"Remove Current Frame"
	Timer tmr_fps "Timer" pos:[64,4] width:24 height:24 enabled:true interval:1000 active:false -- 1 sec
	label lbl_frame "0/0 fr" pos:[232,8] width:48 height:16
	fn showJPGDisplay pos: size: =
	(
		if jpgPlayerDialog != undefined do destroyDialog jpgPlayerDialog
		rollout jpgPlayerDialog "" 
		(
			bitmap bmp_display "" pos:[2,2] width:(size.x - 4) height:(size.y - 4)
			fn updateDisplayPos pos:undefined =
			(
				local dia_pos
				if pos != undefined
				then dia_pos = pos
				else dia_pos = GetDialogPos mcGifCompillerDialog
				
				dia_pos.y -= jpgPlayerDialog.height + 6
				setDialogPos jpgPlayerDialog dia_pos
			)
			fn updateDisplaySize img =
			(
				bmp_display.width = img.width
				bmp_display.height = img.height
				jpgPlayerDialog.width = img.width + 4
				jpgPlayerDialog.height = img.height + 4
			)
		)
		createDialog jpgPlayerDialog pos:pos width:size.x height:size.y style:#(#style_border)
	)
	fn showGIFDisplay pos: size: =
	(
		if gifPlayerDialog != undefined do destroyDialog gifPlayerDialog
		rollout gifPlayerDialog ""
		(
			local dimg
			local frame_dimension = dotNetClass "System.Drawing.Imaging.FrameDimension"
			dotNetControl win_form "System.Windows.Forms.Control" pos:[4,4] width:(111) height:(111) --"flowlayoutpanel"
			fn loadMovie fpath =
			(	
				if not doesFileExist fpath do return false
				dimg = image_class.FromFile fpath
				frames_count = dimg.GetFrameCount frame_dimension.time
				--mcsystem.Show dimg
				mcGifCompillerDialog.lbl_frame.text = "0/"+frames_count as string+"fr"
				win_form.width     = dimg.width
				win_form.height    = dimg.height
				picture_box.width  = dimg.width
				picture_box.height = dimg.height 
				picture_box.Image  = dimg
			)
			on gifPlayerDialog open do
			(
				win_form.controls.clear()
				win_form.controls.add picture_box
			)
			on gifPlayerDialog close do 
			(
				picture_box.image = undefined
				if dimg != undefined do dimg.dispose()
			)
		)
		createDialog gifPlayerDialog pos:pos width:size.x height:size.y style:#(#style_border)
	)
	fn deleteOldCapturedFiles =
	(		
		tmr_fps.active=false
		jpg_files = getFiles (temp_save_path + "*.jpg")
		for f in jpg_files do deleteFile f
		jpg_files = #()
		lbl_frame.text = "0/0 fr"
	)
	fn packImagesToAnimationGif =
	(
		if jpg_files.count == 0 do return false
		if gif_file_name == "" or temp_save_path == "" do return false
		-- -label -monitor -rotate -scale -segment -crop
		local delay = (100./spn_fps.value) as string --animation gif speed
		local app = Micra.RootDir + "App\\convert.exe "  
		--local cmd = temp_save_path + "*.jpg" + " -delay "+delay+" "+gif_file_name
		local cmd = temp_save_path + "*.jpg -layers OptimizeTransparency -delay "+delay+" "+gif_file_name --optimized identical pixels
		--format "cmd:%\n" cmd
		pb_bar.color = orange
		pb_bar.value = 80
		--Hidden
		DOSCommand (app+cmd) --convert *.jpg -delay 25 anim.gif
		pb_bar.value = 100
		messagebox "Capturing Animation is Finished!" title:" Viewport Recorder:"
		
		deleteOldCapturedFiles()
		pb_bar.value = 0

		destroyDialog jpgPlayerDialog
		--show display
		if not doesFileExist gif_file_name do return false
		local img = openBitMap gif_file_name
		close img
		local dia_pos = GetDialogPos mcGifCompillerDialog
		dia_pos.y -= img.height +4 + 6
		local dia_size =[img.width + 4,img.height + 4]
		
		showGIFDisplay pos:dia_pos size:dia_size
		gifPlayerDialog.loadMovie gif_file_name
	)
	fn loadPrevImage =
	(
		if jpg_files.count == 0 do return false 
		if current_img_num == 1 do return false
		
		current_img_num -= 1 
		local img = openBitMap jpg_files[current_img_num]
		close img
		jpgPlayerDialog.bmp_display.bitmap = img
		lbl_frame.text = current_img_num as string+"/"+jpg_files.count as string+" fr"
		pb_bar.value = 100.*current_img_num/jpg_files.count
	)
	fn stopMovie inplace:false =
	(
		tmr_fps.active=false
		if jpg_files.count == 0 do return false 
		
		if not inplace do current_img_num = 1
		local img = openBitMap jpg_files[current_img_num]
		close img
		jpgPlayerDialog.bmp_display.bitmap = img
		lbl_frame.text = current_img_num as string+"/"+jpg_files.count as string+" fr"
		btn_play.images = mcCall.getIcon 170
		pb_bar.value = 100.*current_img_num/jpg_files.count
	)
	fn playMovie =
	(
		if jpg_files.count == 0 do return false 
		if current_img_num == jpg_files.count do stopMovie()
		
		tmr_fps.interval = 1000 / spn_fps.value
		pb_bar.color = green
		playing = tmr_fps.active
		if playing 
		then (btn_play.images = mcCall.getIcon 175; tmr_fps.active=false)
		else (btn_play.images = mcCall.getIcon 170; tmr_fps.active=true)
	)
	fn loadNextImage =
	(
		if tmr_fps.active and current_img_num == jpg_files.count do (stopMovie inplace:true ; return OK)
		if jpg_files.count == 0 do return false 

		if current_img_num == jpg_files.count do return false
		current_img_num += 1 
		local img = openBitMap jpg_files[current_img_num]
		close img
		jpgPlayerDialog.bmp_display.bitmap = img
		lbl_frame.text = current_img_num as string+"/"+jpg_files.count as string+" fr"
		pb_bar.value = 100.*current_img_num/jpg_files.count
	)
	fn deleteCurrentFrame =
	(
		if jpg_files.count == 1 do return false 
		del_frame = current_img_num 
		if current_img_num == jpg_files.count 
		then loadPrevImage()
		else loadNextImage()
		deleteItem jpg_files del_frame
		lbl_frame.text = current_img_num as string+"/"+jpg_files.count as string+" fr"
	)
	on mcGifCompillerDialog rbuttonup pos do (destroyDialog mcGifCompillerDialog)
	-->MoveMode
	on mcGifCompillerDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcGifCompillerDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcGifCompillerDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialogSnap mcGifCompillerDialog DmPos
	)
	on mcGifCompillerDialog open do 
	(
		gif_file_name = mcViewportRecorderDialog.edt_path.text
		jpg_files = getFiles (temp_save_path + "*.jpg")
		
		if jpg_files.count != 0 then 
		(
			lbl_frame.text = "1/"+jpg_files.count as string+" fr"
			current_img_num = 1
			pb_bar.color = green
			pb_bar.value = 100.*current_img_num/jpg_files.count
			local img = openBitMap jpg_files[current_img_num]
			close img
			--show display
			local dia_pos = GetDialogPos mcGifCompillerDialog
			dia_pos.y -= img.height +4 + 6
			local dia_size =[img.width + 4,img.height + 4]
			showJPGDisplay pos:dia_pos size:dia_size
			jpgPlayerDialog.updateDisplaySize img
			jpgPlayerDialog.bmp_display.bitmap = img
		)
		else
		(
			messagebox "Not enough frames to edit an Animation!" title:" Viewport Recorder:"
			destroyDialog mcGifCompillerDialog
		)
	)
	on mcGifCompillerDialog close do 
	(
		mcCall.saveIniDialog "mcGifCompillerDialog" "Properties_2"
		if jpgPlayerDialog != undefined do destroyDialog jpgPlayerDialog
		if gifPlayerDialog != undefined do destroyDialog gifPlayerDialog
	)
	on mcGifCompillerDialog moved pos do (jpgPlayerDialog.updateDisplayPos pos:pos)
	on btn_play pressed   do (playMovie())
	on btn_stop pressed   do (stopMovie())
	on btn_comp pressed   do (packImagesToAnimationGif())
	on btn_prev pressed   do loadPrevImage()
	on btn_next pressed   do loadNextImage()
	on tmr_fps  tick      do loadNextImage()
	on pb_bar clicked val do 
	(
		current_img_num = (jpg_files.count/100.*val) as integer
		if current_img_num == 0 do current_img_num = 1
		stopMovie inplace:true
	)
	on btn_del pressed do deleteCurrentFrame()
)
mcCall.createIniDialog "mcGifCompillerDialog" "Properties_2"



/*
--optimize identical pixels by Gifscile
  gifsicle -O2 bunny_bgnd.gif -o bunny_bgnd_lzw_gifsicle.gif gif_anim_montage bunny_bgnd_lzw_gifsicle.gif bunny_bgnd_lzw_frames.gif

*/