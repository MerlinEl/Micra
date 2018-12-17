
---ACTIVE X CONTROL

fn displayVideo =
(
	if mc2DialogVideoDisplay != undefined do destroyDialog mc2DialogVideoDisplay
	rollout mc2DialogVideoDisplay "Untitled" width:288 height:214
	(
		ActiveXControl ax "{05589FA1-C356-11CE-BF01-00AA0055595A}" pos:[4,4] width:280 height:180
		on mc2DialogVideoDisplay open do
		(
			--ax.FileName  = "E:\Micra2\+\Video Help\Polygon_Paint\Polygon_Paint.gif"
			--mc2DialogVideoDisplay.ax.FileName  = "E:\Micra2\+\Video Help\Lowpolygon_Wizard\Lowpolygon_Wizard.gif"
			ax.FileName    = Mc2Path() + "Help\\blank.gif"
			ax.ShowControls = false
			ax.EnableContextMenu = false
			ax.AutoRewind = true
			ax.AutoStart = true --false--
			ax.Appearance = #amv3D --#amvFlat
			
			--ax.BorderStyle = #amvFixedSingle --#amvNone --
			--ax.EnablePositionControls = true
			--ax.EnableTracker = true
			--ax.ShowTracker = true
--showProperties ax
--showmethods ax
		)
	)
	local dia_pos = (getDialogPos mc2DialogEditMode) + [0, mc2DialogEditMode.height + 24]
	createDialog mc2DialogVideoDisplay pos:dia_pos style:#(#style_border)
)

fn loadMovie title =
(
	local movie_file = Mc2Path() +"Help\\"+ title + ".gif"
	local blank_file = Mc2Path() + "Help\\blank.gif"
	--format "Movie Path:%\n" movie_file
	if doesFileExist movie_file 
	then 
	(
		if mc2DialogVideoDisplay.ax.FileName == movie_file do return false --if is already loaded
		
		mc2DialogVideoDisplay.ax.FileName  = movie_file
		completeRedraw()
		--mc2DialogVideoDisplay.ax.Pause()
		--mc2DialogVideoDisplay.ax.Enabled = true
		--mc2DialogVideoDisplay.ax.Run() --not working
	)
	else if mc2DialogVideoDisplay.ax.FileName != blank_file do 
	(
		mc2DialogVideoDisplay.ax.FileName  = blank_file
		--mc2DialogVideoDisplay.ax.Stop()
	)
)

--DOTNET CONTROL

global mc2GifPlayerDialog2
	
	if mc2GifPlayerDialog2 != undefined do destroyDialog mc2GifPlayerDialog2
	rollout mc2GifPlayerDialog2 " Gif Browser:" width:347 height:300
	(
		local pbox
		dotNetControl win_form "System.Windows.Forms.Control" pos:[16,32] width:304 height:240--"flowlayoutpanel"
		
		on mc2GifPlayerDialog2 open do
		(
			--mc2System.show  win_form

			win_form.controls.clear()
			
			file_name = "E:\Micra2\Help\Low_Polygon_Wizard.gif"
			file_name = "E:\Micra2\Help\blank.gif"
			image_class =  dotNetClass "System.Drawing.Image"
			dotnet_bitmap = image_class.FromFile file_name
			dotnet_bitmap.tag = file_name
			pbox = dotNetObject "System.Windows.Forms.PictureBox"
			pbox.width  = dotnet_bitmap.width
			pbox.height = dotnet_bitmap.height 
			pbox.Image  = dotnet_bitmap

			--mc2System.show pbox
			win_form.controls.add pbox
			
		)
		
	)
	createdialog mc2GifPlayerDialog2
	
	
	/*
mc2GifPlayerDialog2.pbox.image.tag == dotnet_bitmap.tag
mc2System.show mc2GifPlayerDialog2.pbox.image
mc2GifPlayerDialog2.pbox.tag = "test"
mc2GifPlayerDialog2.pbox.image.tag
	*/
