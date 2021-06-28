rollout mcBitmapProjectorDialog "Bitmap Projector:" width:640 height:72
(
	struct EDGE_DATA (id, a, b,
		fn swapPoints = (
			
			local bk = a
			a = b
			b = bk
		)
	)
	GroupBox grp1 "Settings:" pos:[4,4] width:632 height:64
	label lbl1 "points density:" pos:[12,44] width:84 height:16 toolTip:"Higest value less vertices"
	spinner spn_points_density "" pos:[100,44] width:64 height:16 range:[0,100,0.1] type:#float scale:0.1 --default each cm
	label lbl2 "shape precision:" pos:[264,44] width:84 height:16 toolTip:"Lowest value better result"
	spinner spn_shape_precision "" pos:[352,44] width:72 height:16 range:[1,1e+007,100] type:#integer
	button btn_pick_image "Pick Image" pos:[8,20] width:152 height:20
	label lbl_image_name "image filename" pos:[164,22] width:468 height:16 toolTip:"Image Filename"
	button btn_project_image "Project Image" pos:[480,40] width:152 height:20
	local bitmap_mask  = undefined 
		--Euclidian distance between A and B
	fn piontsDist a b  = (  
		sqrt ( (a.x - b.x) * (a.x - b.x)  +  (a.y - b.y)  *  (a.y - b.y) )  
	)
	fn alphaCirc alp dist a b = (   
		( sqrt (alp - (dist / 2) * (dist / 2)) ) * (a - b) / dist 
	)
	fn isTooClose points_2d p1 min_dist = (
	
		if points_2d.count == 0 do return false
		for p2 in points_2d do (
			if piontsDist p1 p2 < min_dist do return true
		)			
		false
	)
	fn convert2DTo3D points_2d = (
		
		for p in points_2d collect [p.x, p.y, 0]
	)
	fn sortEdgesAsPoints darray closedShape:true = (
		
		if darray.count < 2 do return #()
		local index = 1
		local first_edge = darray[index]
		local points = #(first_edge.a, first_edge.b)
		local last_point = first_edge.b
		deleteItem darray index
		while darray.count > 0 do ( --clockwise
			
			if index > darray.count do ( --end reached (no more continuous edges was found )
				
				if closedShape do append points points[1]
				exit 
			)
			local next_edge = darray[index]
			--format "last_point:% next_edge:%\n" last_point next_edge
			 if	last_point == next_edge.a then (
				 
				append points next_edge.b
				last_point = next_edge.b
				deleteItem darray index
				index = 1 --reset 
				 
			) else if last_point == next_edge.b do (
				 
				append points next_edge.a
				last_point = next_edge.a
				deleteItem darray index
				index = 1 --reset 
			)
			index +=1
		)
		points
	)
	fn alphaShape points_2d alpha_radius = (

		local BorderEdges = #()
		local id = 1
	   -- 0. error checking, init
		if (points_2d == undefined or points_2d.count < 2)  do return (messageBox "AlphaShape needs at least 2 points" title:"Warning"; #())          
		local alpha_2 = alpha_radius * alpha_radius
	   -- 1. run through all pairs of points
		for i = 1 to points_2d.count - 1 do (
			
			for j = i + 1 to points_2d.count do (
		
				if points_2d[i] == points_2d[j] do continue --"AlphaShape needs pairwise distinct points"
				local dist = piontsDist points_2d[i] points_2d[j]                
				if dist > 2 * alpha_radius do  continue -- circle fits between points ==> p_i, p_j can't be alpha-exposed                    
				-- for clarity & brevity
				local x1 = points_2d[i].x, x2 = points_2d[j].x, y1 = points_2d[i].y, y2 = points_2d[j].y

				local mid = [(x1 + x2) / 2, (y1 + y2) / 2]

			   -- find two circles that contain p_i and p_j; note that center1 == center2 if dist == 2*alpha_radius
			   local alpha_circ1 = alphaCirc alpha_2 dist y1 y2
			   local alpha_circ2 = alphaCirc alpha_2 dist x2 x1
			   local center1 = [mid.x + alpha_circ1, mid.y + alpha_circ2]
			   local center2 = [mid.x - alpha_circ1, mid.y - alpha_circ2]

				--local center1 = [mid.x + (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (y1 - y2) / dist),  mid.y + (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (x2 - x1) / dist)]
				--local center2 = [mid.x - (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (y1 - y2) / dist),  mid.y - (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (x2 - x1) / dist)]

			   -- check if one of the circles is alpha-exposed, i.e. no other point lies in it
				local c1_empty = true, c2_empty = true
						
				for k = 1 to points_2d.count where (c1_empty or c2_empty) do (
					
					if (points_2d[k] == points_2d[i] or points_2d[k] == points_2d[j]) do continue

					if ((center1.x - points_2d[k].x) * (center1.x - points_2d[k].x) + (center1.y - points_2d[k].y) * (center1.y - points_2d[k].y) < alpha_2) do (
		
						c1_empty = false;
					)

					if ((center2.x - points_2d[k].x) * (center2.x - points_2d[k].x) + (center2.y - points_2d[k].y) * (center2.y - points_2d[k].y) < alpha_2) do (
					
						c2_empty = false;
					)                                     
				)

				if (c1_empty or c2_empty) do (
				   -- yup!
					append BorderEdges ( EDGE_DATA id points_2d[i] points_2d[j] )
					id +=1
				)
			)
		)
		BorderEdges
	)
	
	-- pick black and white image (mask) from file
	fn pickImageFromFile = (
		
		bitmap_mask = selectbitmap()		
		if bitmap_mask != undefined do (
			
			lbl_image_name.text = getfilenamefile bitmap_mask.filename
		)
	)
	
	-- pick black and white image (mask) from object material
	fn getImageFromObjectMaterial obj = (
		
		if obj == undefined or obj.material == undefined  or obj.material.diffuseMap == undefined do return false
		lbl_image_name.text =  obj.material.diffuseMap.filename
		bitmap_mask = obj.material.diffuseMap.bitmap
		
	)
	fn projectImage = (
		
		if bitmap_mask == undefined do return false
		local w=bitmap_mask.width
		local h=bitmap_mask.height
		--scan image to collect non white pixels coordinates
		local non_white_pixels_positions = #()
		for x = 1 to w do (
			for y = 1 to h do (
				--get pixel at coords
				local p = (getpixels bitmap_mask [x, y] 1)[1]
				--skip null and white pixels
				if p == undefined or p == white do continue
				--center image (inverse y and move pivot by half)
				local pos = [x - w/2, -y + h/2] 
				--skip points with min density
				if isTooClose non_white_pixels_positions pos spn_points_density.value do continue
				--add rest to array
				append non_white_pixels_positions pos
			)
		)
		format "projectImage > non_white_pixels_positions:[%/%] \n" non_white_pixels_positions.count (w*h)
		for p in non_white_pixels_positions do point pos:[p.x, p.y, 0]
		
		local edata_array = alphaShape non_white_pixels_positions spn_shape_precision.value
		local verts_pos = sortEdgesAsPoints edata_array
		verts_pos = convert2DTo3D verts_pos
		mcPoly.createPolygonObj verts_pos objName:(UniqueName "image_shape_")
	)
	on btn_pick_image pressed do getImageFromObjectMaterial selection[1]
	on btn_project_image pressed do projectImage()
)
createDialog mcBitmapProjectorDialog

--Return the distance to the nearest non-white pixel within the radius.
/*fn DistToNonWhite bm32 x y radius = (
	
	local w     = bm32.width
	local h     = bm32.height
	local minx  = int (amax (x - radius)  1)
    local maxx  = int (amin (x + radius) (w - 1))
    local miny  = int (amax (y - radius)  1)
    local maxy  = int (amin (y + radius) (h - 1))
    local dist2 = int (radius * radius + 1)

	for tx = minx to maxx do (
		for ty = miny to maxy do (
			
			local p = (getpixels bm32 [tx,ty] 1)[1]
			if p.r < 200 or p.g < 200 or p.b < 200 do (
--                 format "DistToNonWhite > pos:%\n" [x,y]
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
*/


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