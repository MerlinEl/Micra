fn setObjectGradient c1 c2 = -- 
(
	local sel = selection as array
	if sel.count < 2 do return false
	
	stepsize_r = (c2.r - c1.r)/$.count
	stepsize_g = (c2.g - c1.g)/$.count
	stepsize_b = (c2.b - c1.b)/$.count
	
	for i=1 to sel.count do
	(
		local newColor = (color \
		((i*stepsize_r)+c1.r-stepsize_r) \
		((i*stepsize_g)+c1.g-stepsize_g) \
		((i*stepsize_b)+c1.b-stepsize_b))
		$[i].wirecolor = newColor
	)
	max select none
	completeRedraw()
)

--Icon realtime generator 24x24 pix
fn generateBoxGrid bcount:24 bsize:10 =
(
	local start_pos_tl = ((bcount/2)*bsize)-bsize/2
	local px = py = [-start_pos_tl, start_pos_tl, 0]
	local b , boxes = #()
	with redraw off undo "BoxPixel" on
	(
		for x=1 to bcount do
		(
			if b != undefined 
			then
			(
				boxes += #(b = copy b)
				px = [px.x+bsize, px.y, 0]
				b.pos = px
				b.wirecolor = white
			)
			else (boxes = #(b = box pos:px length:10 width:10 height:10 wirecolor:white name:(uniqueName "pixel3d_")))
			
			for y=2 to bcount do
			(
				boxes += #(b2 = copy b)
				py = [px.x, py.y-bsize, 0]
				b2.pos = py
				b2.wirecolor = white
			)
			py = [px.x, px.y, 0]
		)
	)
	redrawViews()
	return boxes
)
/*
generateBoxGrid bcount:24
setObjectGradient red blue
disableSceneRedraw() 
enableSceneRedraw() 
completeRedraw()
redrawViews()
*/

select (generateBoxGrid bcount:24)
setObjectGradient white blue