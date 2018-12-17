rollout PaintButtonTest "Button Test" width:208 height:120
(
	ImgTag itg_1 "Bitmap" pos:[20,24] width:76 height:56
	ImgTag itg_2 "Bitmap" pos:[72,88] width:24 height:24
	button btn_1 "Button" pos:[112,24] width:76 height:56
	button btn_2 "btn" pos:[112,88] width:24 height:24
	label lbl_1 "ImgTag:" pos:[20,4] width:72 height:16
	label lbl_2 "Button:" pos:[112,4] width:72 height:16
	fn mcCreateSimpleButton size type =
	(
		local bgColor = (colorMan.getColor #background)*255
		local hiColor = (colorMan.getColor #hilight)*255
		local shColor = (colorMan.getColor #shadow)*255
		local pbColor = (colorMan.getColor #pressedButton)*255
		
		local colorArray = case type of
		(
			#up: #(bgColor, hiColor, shColor)
			#down: #(pbColor, shColor, hiColor)
		)	
				
		BitmapButton = (bitmap size.x size.y color:colorArray[1])
		--wertical edges
		for i=0 to size.y-1 do 
		(
			setpixels BitmapButton [0,i] #(colorArray[2]) --left (light) 
			setpixels BitmapButton [size.x-1,i] #(colorArray[3]) --right (dark)
		)
		--horizontal edges
		for i=0 to size.x-1 do 
		(
			setpixels BitmapButton [i,0] #(colorArray[2]) --top (light) 
			setpixels BitmapButton [i,size.y-1] #(colorArray[3]) --bottom (dark)
		)
		return BitmapButton
	)

	fn mcInicializeButtons =
	(
		local i1=mcCreateSimpleButton [76,56] #up
		local i2=mcCreateSimpleButton [24,24] #up
		PaintButtonTest.itg_1.bitmap = i1
		PaintButtonTest.itg_2.bitmap = i2
	
	)
	on PaintButtonTest open do ( mcInicializeButtons() )
	on itg_1 mousedown do itg_1.bitmap = mcCreateSimpleButton [76,56] #down
	on itg_1 mouseup do itg_1.bitmap = mcCreateSimpleButton [76,56] #up
	on itg_1 mouseout do itg_1.bitmap = mcCreateSimpleButton [76,56] #up
	--on <ImgTag> mouseover do <expr>
	on itg_2 mousedown do itg_2.bitmap = mcCreateSimpleButton [24,24] #down
	on itg_2 mouseup do itg_2.bitmap = mcCreateSimpleButton [24,24] #up
	on itg_2 mouseout do itg_2.bitmap = mcCreateSimpleButton [24,24] #up
)
createdialog PaintButtonTest




