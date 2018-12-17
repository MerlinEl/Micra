	fn mcCreateColorCheckbutton size type =
	(
		bgColor = (colorMan.getColor #background)*255
		hiColor = (colorMan.getColor #hilight)*255
		shColor = (colorMan.getColor #shadow)*255
		pbColor = (colorMan.getColor #pressedButton)*255
	
		w=size.x
		h=size.y
	
		case type of
		(
			#up:
			(
			 print "up"
			)		
			#chk:	
			(	
				MyTestBitmap = (bitmap size.x size.y color:bgColor)
				--wertical lines
				for i=0 to h-1 do 
				(
					setpixels MyTestBitmap [0,i] #(hiColor) --left (light) 
					setpixels MyTestBitmap [w-1,i] #(shColor) --right (dark)
				)
				--horizontal lines
				for i=0 to w-1 do 
				(
					setpixels MyTestBitmap [i,0] #(hiColor) --top (light) 
					setpixels MyTestBitmap [i,h-1] #(shColor) --bottom (dark)
				)
				--create empty inside rect
				for i=4 to 11 do
				(
					--horizontal lines
					setpixels MyTestBitmap [i,3] #(color 170 20 35) --left (light)
					setpixels MyTestBitmap [i,12] #(color 170 20 35) --left (light)
					--wertical lines
					setpixels MyTestBitmap [3,i] #(color 170 20 35) --left (light)
					setpixels MyTestBitmap [12,i] #(color 170 20 35) --left (light)	
				)
				--create full inside rect
				for i=5 to 10 do
				(
					--horizontal lines
					setpixels MyTestBitmap [i,5] #(red) --left (light)
					setpixels MyTestBitmap [i,6] #(red) --left (light)
					setpixels MyTestBitmap [i,7] #(red) --left (light)
					setpixels MyTestBitmap [i,8] #(red) --left (light)
					setpixels MyTestBitmap [i,9] #(red) --left (light)
					setpixels MyTestBitmap [i,10] #(red) --left (light)
				)
			)
			#down:
			(
				MyTestBitmap = (bitmap size.x size.y color:pbColor)
				--wertical lines
				for i=0 to h-1 do 
				(
					setpixels MyTestBitmap [0,i] #(shColor) --left (light) 
					setpixels MyTestBitmap [w-1,i] #(hiColor) --right (dark)
				)
				--horizontal lines
				for i=0 to w-1 do 
				(
					setpixels MyTestBitmap [i,0] #(shColor) --top (light) 
					setpixels MyTestBitmap [i,h-1] #(hiColor) --bottom (dark)
				)
			)
		)--case type
		--return MyTestBitmap
		display MyTestBitmap
	)--fn
	
	mcCreateColorCheckbutton [16,16] #chk