PlaneMap = getOpenFileName caption:"Select Map"  \ 
filename:maxfilepath \
types:"Targa (*.tga)|*.tga|Jpeg (*.jpg)|*.jpg|Tiff (*.tif)|*.tif|All (*.*)|*.*|"

if PlaneMap != undefined do
(
	pixel_array = #()
	img = openBitmap PlaneMap
	with redraw off
	(
	with undo off
		(
			for y = 0 to img.height-1 do
			(
				pixel_array = getPixels img [0,y] img.width
				for pixel = 1 to pixel_array.count do
				(
					p = converttomesh(plane widthsegs:1 lengthsegs:1 length:1 width:1)
					p.wirecolor = pixel_array[pixel]
					p.pos = [pixel,y,0]*[1,-1,1]
					
				)
			) 
		)
	)
	
	max vpt top
	max zoomext sel all
)