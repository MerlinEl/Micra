w=h=24

fn getImageRegion img w h pos =
(
	img = gw.getViewportDib()
	icon = bitmap w h
	region = (for i = 0 to (h-1) collect getPixels img [pos.x,pos.y+i] (w-1))
	for i = 1 to h do setPixels icon  [0,i] region[i]
	icon
)


