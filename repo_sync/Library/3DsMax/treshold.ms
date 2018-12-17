		--set image to black and whitte
		fn getAlpha Image =
		(
			local w   = Image.width
			local h   = Image.height
			local img = bitmap w h
		
			for i = 0 to (w-1) do
			(
				local a = #() --alpha
				local p = getpixels Image [0,i] w --a horizontal pixel ilne
				for j = 1 to h do
				(
					a[j] = [p[j].a, p[j].a, p[j].a] as color
				)
				setpixels img [0,i] a
			)
			return img
		)
	
	--mask background color
	fn getMask Image bgColor:undefined = --#(black)
	(
		local w   = Image.width
		local h   = Image.height
		local img = bitmap w h
		if bgColor == undefined do bgColor = getpixels Image [0,0] 1
		for i = 0 to 23 do
		(
			local m = #()
			local p = getpixels Image [0,i] w
			for j = 1 to h do
			(
				if p[j].r as integer == bgColor[1].r and p[j].g as integer == bgColor[1].g and p[j].b as integer == bgColor[1].b 
				then (m[j] = [255,255,255])
				else (m[j] = [0,0,0] as color)
			)
			setpixels img [0,i] m
		)
		return img	
	)
	img = gw.getViewportDib() 
	img = getclipboardBitmap()
	display img
	img_bw = getMask img  --bgColor:blue
	img_bw = getAlpha img
	display img_bw 