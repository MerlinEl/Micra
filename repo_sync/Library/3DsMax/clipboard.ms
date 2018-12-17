setImage = setclipboardBitmap anim_bmp
returnImage = getclipboardBitmap()
display returnImage 



	fn grabImage s =
	(
		local img = gw.getViewportDib() 
		local new_img = bitmap picture_size picture_size
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
		copy img new_img
		setclipboardBitmap new_img
		s.image = if clipboardClass.containsimage() then clipboardClass.getImage()
	)
	
	
	fn getTextFromClipboard =
	(
		local clipboardClass = dotNetClass "System.Windows.Forms.Clipboard"
		local txt = if clipboardClass.containstext() then clipboardClass.getText() else ""
		txt
	)
	
	
	