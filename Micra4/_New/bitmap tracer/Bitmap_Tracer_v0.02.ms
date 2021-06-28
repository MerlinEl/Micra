--Return the distance to the nearest non-white pixel within the radius.
fn DistToNonWhite bm32 x y radius = (
	
	local w     = bm32.width
	local h     = bm32.height
	local minx  = int (amax (x - radius)  1)
    local maxx  = int (amin (x + radius) (w - 1))
    local miny  = int (amax (y - radius)  1)
    local maxy  = int (amin (y + radius) (h - 1))
    local dist2 = int (radius * radius + 1)

	for tx = minx to maxx do (
		for ty = miny to maxy do (
			
			local p = (getpixels bm32 [0,tx] 1)[1]
			if p.r < 200 or p.g < 200 or p.b < 200 do (
                
				local dx = int (tx - x)
                local dy = int (ty - y)
                local test_dist2 = int (dx * dx + dy * dy)
                if test_dist2 < dist2  do dist2 = test_dist2
			)
		)
		return Sqrt(dist2) as float
	)
)

--Make an outline image.
fn MakeOutline bm32 min_radius max_radius = (	
	
	local w=bm32.width
	local h=bm32.height
    --Make the result bitmap.
    local new_bm = Bitmap w h color:green
	for x = 1 to w do (
        for y = 1 to h do (
            
			local dist = DistToNonWhite bm32 x y max_radius
			format "check pixel:% dist:%\n" [x,y] dist
            if dist > min_radius and dist < max_radius do (
                local a = 255
                if dist - min_radius < 1 then ( 
                   
				   a = int(255 * (dist - min_radius))
		
                ) else if max_radius - dist < 1 do (
                    
					a = int(255 * (max_radius - dist))
				)
-- 				format "set pixels to:%\n" [x,y]
                SetPixels new_bm [x, y] #(color 255 0 0 a, olor 255 0 0 a, color 255 0 0 a)
            )
        )
    )
    return new_bm
)

fn BitmapTrace = (
	
	-- pick black and white image (mask)
	local bm32 = selectbitmap()	
	if bm32 == undefined do return false
	local bname = getfilenamefile bm32.filename
	format "BitmapTrace > bitmap:% \n"  bname
	local min_radius = 1;
	local max_radius = 4;
	local new_bm32 = MakeOutline bm32 min_radius max_radius
	display new_bm32
)

BitmapTrace()



/*
fn DistToNonWhite bm32 x y radius = (
	
	local w=bm32.width
	local h=bm32.height
	local minx =  int (amax (x - radius)  0)
    local maxx = int (amin (x + radius) (w - 1))
    local miny = int (amax (y - radius)  0)
    local maxy = int (amin (y + radius) (h - 1))
    local dist2 = int (radius * radius + 1)

	for tx = 0 to h-1 do (
		local pixels = getpixels bm32 [0,tx] w
		for ty = 0 to w-1 do (
			
			local p = pixels[ty+1]
			if p.r < 200 or p.g < 200 or p.b < 200 do (
                
				local dx = int (tx - x)
                local dy = int (ty - y)
                local test_dist2 = int (dx * dx + dy * dy)
                if test_dist2 < dist2  do dist2 = test_dist2
			)
		)
		return Sqrt(dist2) as float
	)
)
*/