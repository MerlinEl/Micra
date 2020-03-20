if mcProjector2DDialog != undefined do DestroyDialog mcProjector2DDialog
rollout mcProjector2DDialog "Geometry Projector 2D:" width:180 height:160
(
	struct EDGE_DATA (id, a, b,
		fn swapPoints = (
			
			local bk = a
			a = b
			b = bk
		)
	)
	GroupBox 'grp1' "Settings:" pos:[4,4] width:172 height:68 align:#left
	label 'lbl1' "scanner density:" pos:[12,28] width:84 height:16 align:#left
	spinner 'spn_scan_density' "" pos:[100,28] width:72 height:16 range:[1,1e+07,1000] type:#integer align:#left
	label 'lbl2' "shape precision:" pos:[12,48] width:84 height:16 align:#left
	spinner 'spn_shape_precision' "" pos:[100,48] width:72 height:16 range:[1,1e+07,10000] type:#integer align:#left
	button 'btn_build_shape' "Build Shape" pos:[4,96] width:172 height:28 align:#left
	checkbox 'chk_debug' "debug mode" pos:[8,76] width:164 height:16 align:#left
	button 'btn_build_geom' "Build Geometry" pos:[4,128] width:172 height:28 align:#left
	fn getFlattenPoints obj density = (

	local tri_mesh = snapshotAsMesh obj --snapshot as TriMesh to memory
	local verts_pos = for v in tri_mesh.verts collect (v.pos.z = 0; v.pos)
	delete tri_mesh
	--optimize positions (get only positions that are far than density)
	format "START with pos cnt:%\n" verts_pos.count
	local filter_points = #()
	local progress_remain = verts_pos.count
	while verts_pos.count > 0 and progress_remain > 0 do (  --progress while not reach end
			
			progress_remain -= 1
			local first_pos = verts_pos[1] --pick first(next) item at index 1
			append filter_points first_pos
			deleteItem verts_pos 1 --remove item at index 1
			local next_index = 1
			while next_index <= verts_pos.count do ( --compare first_pos with all others

				local next_pos = verts_pos[next_index]
				if distance first_pos next_pos < density then (
					
					progress_remain -= 1
					deleteItem verts_pos next_index --remove item at index 1

				) else next_index += 1	
			)
		)
		format "END with pos cnt:%\n" filter_points.count
		filter_points
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
	--Euclidian distance between A and B
	fn piontsDist a b  = (  
		sqrt ( 
			(a.x - b.x) * (a.x - b.x)  +  (a.y - b.y)  *  (a.y - b.y) 
		)  
	)
	fn sqrtCirc alp dist a b = (  
		sqrt ( 
			( alp - (dist / 2) * (dist / 2) )  *  (a - b) / dist
		)  
	)
	fn alphaShape points alpha_radius = (

		local BorderEdges = #()
		local id = 1
	   -- 0. error checking, init
		if (points == undefined or points.count < 2)  do return (messageBox "AlphaShape needs at least 2 points" title:"Warning"; #())          
		local alpha_2 = alpha_radius * alpha_radius
	   -- 1. run through all pairs of points
		for i = 1 to points.count - 1 do (
			
			for j = i + 1 to points.count do (
		
				if points[i] == points[j] do continue --"AlphaShape needs pairwise distinct points"
				local dist = piontsDist points[i] points[j]                
				if dist > 2 * alpha_radius do  continue -- circle fits between points ==> p_i, p_j can't be alpha-exposed                    
				-- for clarity & brevity
				local x1 = points[i].x, x2 = points[j].x, y1 = points[i].y, y2 = points[j].y

				local mid = [(x1 + x2) / 2, (y1 + y2) / 2]

			   -- find two circles that contain p_i and p_j; note that center1 == center2 if dist == 2*alpha_radius
				local center1 = [mid.x + (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (y1 - y2) / dist),  mid.y + (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (x2 - x1) / dist)]
				local center2 = [mid.x - (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (y1 - y2) / dist),  mid.y - (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (x2 - x1) / dist)]

			   -- check if one of the circles is alpha-exposed, i.e. no other point lies in it
				local c1_empty = true, c2_empty = true
						
				for k = 1 to points.count where (c1_empty or c2_empty) do (
					
					if (points[k] == points[i] or points[k] == points[j]) do continue

					if ((center1.x - points[k].x) * (center1.x - points[k].x) + (center1.y - points[k].y) * (center1.y - points[k].y) < alpha_2) do (
		
						c1_empty = false;
					)

					if ((center2.x - points[k].x) * (center2.x - points[k].x) + (center2.y - points[k].y) * (center2.y - points[k].y) < alpha_2) do (
					
						c2_empty = false;
					)                                     
				)

				if (c1_empty or c2_empty) do (
				   -- yup!
					append BorderEdges ( EDGE_DATA id points[i] points[j] )
					id +=1
				)
			)
		)
		BorderEdges
	)
	fn projectObjs objs type:#shape = (
		
		local debug = chk_debug.checked
		for o in objs do (
			
			local fp = getFlattenPoints o spn_scan_density.value
			if debug do test_points = for p in fp collect (point pos:p size:2 wirecolor:green)
			local edata_array = alphaShape fp spn_shape_precision.value
			local verts_pos = sortEdgesAsPoints edata_array
			local new_name = o.name + "_ocplane"
			local new_o = case type of (
				
				#shape	: mcSpline.splinesFromPoints verts_pos	shpName:new_name
				#geom	: mcPoly.createPolygonObj verts_pos objName:new_name
			)
			if new_o != undefined do (

				new_o.parent = o.parent --copy linkage
				select new_o
			)
		)
	)
	on btn_build_shape pressed do projectObjs (selection as array) type:#shape
	on btn_build_geom pressed do projectObjs (selection as array)  type:#geom
)
createDialog mcProjector2DDialog