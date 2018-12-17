
if printscreenDialog != undefined do destroyDialog printscreenDialog
rollout printscreenDialog "" width:436 height:412
(
	local picture_box = dotNetObject "PictureBox"
	local draw_image  = dotNetClass  "Drawing.Image"
	local clipboard   = dotnetClass  "Clipboard"
	local send_keys   = dotnetClass  "SendKeys"
	dotNetControl win_form "System.Windows.Forms.Control" pos:[4,4] width:427 height:379
	button btn_close "Close" pos:[376,388] width:56 height:20
	button btn_print "PrintScreen" pos:[4,388] width:88 height:20
	button btn_clear "Clear" pos:[96,388] width:56 height:20
	fn printScreen todisc:false =
	(
		(dotnetClass "SendKeys").SendWait ("{PRTSC}") --gets only dotnet FORM
		--(dotnetClass "SendKeys").SendWait( "{%}  {PRTSC}" )
		--send_keys.SendWaALT  PRTSCit ("{PRTSC}") 
		--send_keys.SendWait ("{%}({PRTSC})") --gets all screens
		--send_keys.SendWait ("{ALT} +{PRTSC}") --gets active screen
		if clipboard.ContainsImage() do
		(
			local img = clipboard.getImage()
			
			if not todisc
			then
			(
				picture_box.width  = img.width
				picture_box.height = img.height 
				picture_box.image = img
			)
			else
			(
				local theFileName = GetDir #image + "\\ImageClipboard.bmp" --define a temp.file name
				img.Save theFileName
				img.dispose()
				ShellLaunch (GetDir #image) ""
			)
		)
	)
	on printscreenDialog open do
	(
		win_form.controls.clear()
		win_form.controls.add picture_box
		printScreen todisc:true--()
	)
	on btn_close pressed  do destroyDialog printscreenDialog
	on btn_print pressed  do printScreen todisc:true
	on btn_clear pressed  do picture_box.image = undefined

)
createDialog printscreenDialog style:#(#style_border)
 
 
 /*
 PrintScreen all screens
 Alt+PrintScreen screen where is mouse
 
 clip = dotnetClass "Clipboard" --System.Windows.Forms
send_keys = dotnetClass "SendKeys"
send_keys.SendWait "{PRTSC}"
--send_keys.SendWait("{%}({PRTSC})")
--send_keys.Send("{%}({PRTSC})")
clip.ContainsImage()
dotnet_img = clip.getImage()
dotnet_img.dispose()

keybd_event(VK_SNAPSHOT, Nothing, Nothing, Nothing)
(dotnetClass "KeyEventArgs")
 
keyargs_class = dotnetClass "System.Windows.Forms.KeyEventArgs"
keys_class    = dotnetClass "System.Windows.Forms.Keys"
keys_class.KeyCode == keys_class.PrintScreen
 
mes = dotnetClass "System.Windows.Forms.Message"
WParam.ToInt32 = 44 --handle PrntScr key

Bitmap = Clipboard.GetDataObject.GetData(DataFormats.Bitmap)
bmp.Save("C:\ScrnShot" & intCount & ".BMP", Imaging.ImageFormat.Bmp)

 */
 