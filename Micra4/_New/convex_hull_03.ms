fn getFlatPos obj min_dist = (

	local tri_mesh = snapshotAsMesh obj --snapshot as TriMesh to memory
	local verts_pos = for v in tri_mesh.verts collect (v.pos.z = 0; v.pos)
	delete tri_mesh
	--optimize positions (get only positions that are far than min_dist)
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
			if distance first_pos next_pos < min_dist then (
				
				progress_remain -= 1
				deleteItem verts_pos next_index --remove item at index 1

			) else next_index += 1	
		)
	)
	format "END with pos cnt:%\n" filter_points.count
	filter_points
)
fn convexHull points = (
	--get most left point
	local most_left =  points[1]
	for p in points do (

		if (p.x < lp.x) then ( --if is most left (teake it)
			
			most_left = p
			
		) else if (p.x == lp.x) do ( --if left is same (teake most top)
			
			if (p.y > lp.y) do most_left = p
		)
	)
	--move clockwise around the edge of the hull
	local border_points = #(most_left)
	for p1 in points do (
		--compare each point with others
		local 
		for i = 1 to points.count do (
			
				local p2 = points[i]
				if p1 == p2 do continue --skip self comparision
				local cr = cross p1 p2 
		)	
		
		
	)
)

/* 
fn GetVectorsAngle v1 v2 =( acos(dot (normalize v1) (normalize v2)))

v1 = normalize v1
	v2 = normalize v2
	axis = normalize (cross v1 v2)
	angle = acos (dot v1 v2)
*/

/*fn convexHull points = (

	local points_cnt = points.count
	local p = 1
	--First find the leftmost point
	for i = 2 to points_cnt do (
	
		if(points[i].x < points[p].x) do p = i
	)
	local start = p
	do(
		local n = -1
		for i = 1 to points_cnt do (

			--Don’t go back to the same point you came from
			if i == p do continue

			--If there is no N yet, set it to i
			if n == -1 do n = i
			local cross_p = (points[i] - points[p]) * (points[n] - points[p])

			if cross_p < 0 do (
				--As described above, set points_cnt=points
				n = i
			)
		)
		p = n
	)while(start!=p)
)*/
--collect flatten positions from object (removed all positions that are closest than min_dist)
fp = getFlatPos $ 3000
ch = convexHull fp



/*

test_points = for p in fp collect (point pos:p size:1000 wirecolor:green)
delete test_points
--find most left point
selp = selection as array
most_left = selection[1]
lp = most_left.pos
for o in selp do (

	if (o.pos.x < lp.x) then ( --if is most left (teake it)

		most_left = o
		lp = o.pos

	) else if (o.pos.x == lp.x) do ( --if left is same (teake most top)

		if (o.pos.y > lp.y) then (

			most_left = o
			lp = o.pos
		)
	)
)
select most_left
--move clockwise around the edge of the hull
--we will make cross product with each point ()
for i = 1 to selp.count-1 do (
	
	local o = selp[i]
	if o.handle = most_left.handle do continue --skip self comparision
	local v = o.pos - most_left.pos
	
)
--collect only border positions






*/