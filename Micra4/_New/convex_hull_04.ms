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

struct EDGE_DATA (id, a, b,
	fn swapPoints = (
		
		local bk = a
		a = b
		b = bk
	)
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
fp = getFlattenPoints $ 1000
test_points = for p in fp collect (point pos:p size:2 wirecolor:green)
edata_array = alphaShape fp 10000 --100
verts_pos = sortEdgesAsPoints edata_array
mcSpline.splinesFromPoints verts_pos
--for d in edata_array do mcSpline.splinesFromPoints  #(d.a, d.b)

		/*
		if fe.a == ne.a or fe.b == ne.a then (
			
			if points.count == 0 do points = #(fe.a, fe.b)
			append points fe.b
			fe = ne
			deleteItem darray index
			index = 1 --reset 
			
		) else if	 fe.b == ne.b or fe.a == ne.b do (
			
			if points.count == 0 do points = #(fe.b, fe.a)
			append points fe.a
			fe = ne
			deleteItem darray index
			index = 1 --reset 
		)*/
/*
ix = 1
mcSpline.splinesFromPoints  #(edata_array[ix].a, edata_array[ix].b)
for d in edata_array do mcSpline.splinesFromPoints  #(d.a, d.b)*/
--Sort vertex method
/*
verts_pos = #()
for d in edata_array do (appendIfUnique verts_pos d.a; appendIfUnique pos_arr d.b)
points_center = mcMath.getPointsCenter verts_pos
qsort verts_pos mcPoly.sortVertsByCenter center:points_center
mcSpline.splinesFromPoints verts_pos
*/

--Attach spline and weld method
/*shape_lines = #()
for d in edata_array do append shape_lines (mcSpline.splinesFromPoints  #(d.a, d.b))
select shape_lines
sh = shape_lines[1]
fn addShape sp1 sp2 weldThreshold: 0.001= if iskindof sp1 SplineShape and iskindof sp2 SplineShape do (
 	convertToSplineShape sp1 -- to make it undoable
 	convertToSplineShape sp2
 	addAndWeld sp1 sp2 weldThreshold
 	sp1
)
for i = 2 to shape_lines.count do addShape sh shape_lines[i] weldThreshold:4
--polyOp.createPolygon $ #(177, 145, 146, 178)

*/



/*
fn compareInt i1 i2 values: = values[i1] - values[i2]  
fn comparePoint3_Z i1 i2 values: =
(
	v1 = values[i1]
	v2 = values[i2]
	if v1.z > v2.z then 1 else if v1.z < v2.z then -1 else 0
)
-- sorts verts along the z axis of sorttm    
fn sortPoints points = (

	local sorttm = (MatrixFromNormal [0,0,1])
	sorttm.translation = [0,0,0] -- zero out the translation
	local isorttm = inverse sorttm
-- collect the vert positions        
	
	local verts = for p in points collect p * isorttm
	local indices  = #{1..points.count} as array  
	local vertorder = #{1..points.count} as array
	
-- sort the new indices        
	
	qsort vertorder comparePoint3_Z values:verts
	qsort indices compareInt values:vertorder  -- "reverse" sort to get the new indexing
	
-- sort the actual verts restore them     
	verts = for v = 1 to verts.count collect verts[vertorder[v]] *= sorttm 
)
*/
