	fn setImageToClipboard img =
	(
		local clipboardClass = dotNetClass "Clipboard" --create a Clipboard dotNetClass
		img.makeTransparent (netDrColor white) 
		clipboardClass.setImage img --copy the image to clipboard
	)
	
	
	fn getImageFromClipboard =
	(
		local cd = (dotNetClass "Clipboard").GetDataObject()
		if cd.GetDataPresent (dotNetClass "DataFormats").Bitmap 
		then return cd.GetData (dotNetClass "DataFormats").Bitmap
		else return blankImage 240 240 black -- big image
	)
	
	fn getImageFromClipboard =
	(
		local img
		local clipboardClass = dotNetClass "Clipboard" --create a Clipboard dotNetClass
		if clipboard.ContainsImage() 
		then
		(
			local img = clipboard.getImage()
			img.makeTransparent (netDrColor white)
			return img
		)
		else return blankImage 240 240 black -- big image
	)