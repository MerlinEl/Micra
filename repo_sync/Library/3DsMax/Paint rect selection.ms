rollout ccc "Untitled" width:232 height:192
(
	local myBitmap = bitmap 232 192 color:gray
	local dMove = false, dPos
	
	bitmap bmp_1 "" pos:[15,16] width:200 height:160
	
	fn mcPaintCross2 bmp pos size color =
	(

		for a=pos.x to size.x do
		for b=pos.y to size.y do 
		setpixels bmp [a,b] #(color)

	)
	
	on ccc open do
	(
		bmp_1.bitmap = myBitmap
	)
	--dialog 
	on ccc lbuttondown pos do (dMove = true; print "pressed")
	on ccc lbuttonup pos do dMove = false
	on ccc mousemove pos do 
	(
		if dMove do(
		local bmp = copy myBitmap
		mcPaintCross2 bmp pos [100,100] white
		bmp_1.bitmap = bmp
		)
	)
)
createDialog ccc 


/*
BitmapPath = (mPath()+"ColorBySat.png")
myBitmap = openBitmap BitmapPath

fn drawCross bmp pos =
(
	
)



fn mcPaintCross bmp pos size color =
(
	local start_x = pos.x-size.x/2
	local start_y = pos.y-size.y/2
	for a=start_x to start_x+size.x do setpixels bmp [a,pos.y] #(color)
	for b=start_y to start_y+size.y do setpixels bmp [pos.x,b] #(color)
)
--Call: mcPaintCross x [70,40] [20,20] red
*/