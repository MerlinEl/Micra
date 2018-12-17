
(
	local poly_obj = selection[1]
	local the_channel = 1
	local img = poly_obj.material.diffuseMap.bitmap
	--display img
	
	for i in poly_obj.verts do 
	(
		local vert = i.index
		--get single map vertex coordinates
		local uv_coords = polyOp.getMapVert poly_obj the_channel vert
		--convert vertex coords to bitmap coords
		local texture_coords = [(uv_coords.x)*(img.width-1),img.height-(uv_coords.y)*(img.height-1)]
		--get bitmap pixel value with bitmap coords
		texture_coords.y = (texture_coords.y*.9999) + 0.00001 --jarduv hack 
		local vertColor = (getPixels img texture_coords 1)[1]
		--if vertColor == undefined do  vertColor = color 255 0 255 --out of range value (pink)
		polyop.setVertColor poly_obj 0 vert vertColor
		format "vert:%\tuv_pos:%\tcolor:%\n" vert uv_coords vertColor 
	)
	
	--addMod vertexPaint
	
)