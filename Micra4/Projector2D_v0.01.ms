if mcProjector2DDialog != undefined do DestroyDialog mcProjector2DDialog
rollout mcProjector2DDialog "Projector 2D:" width:180 height:184
(
	struct EDGE_DATA (id, a, b,
		fn swapPoints = (
			
			local bk = a
			a = b
			b = bk
		)
	)
	local project_normal = [0,0,1] --default Z
	local project_pos = [0,0,0] --0
	GroupBox 'grp1' "Settings:" pos:[4,4] width:172 height:68 align:#left
	label 'lbl1' "max verts distance:" pos:[12,28] width:104 height:16 toolTip:"Higest value less vertices" align:#left
	spinner 'spn_max_verts_dist' "" pos:[120,28] width:52 height:16 range:[1,1e+07,30] type:#integer align:#left
	label 'lbl2' "border scan precision:" pos:[12,48] width:104 height:16 toolTip:"Lowest value better result" align:#left
	spinner 'spn_shape_precision' "" pos:[120,48] width:52 height:16 range:[1,1e+07,1000] type:#integer align:#left
	checkbox 'chk_debug' "debug" pos:[128,0] width:48 height:16 align:#left
	button 'btn_build_geom' "Build Plane" pos:[4,148] width:72 height:28 align:#left
	button 'btn_flip_normals' "flip " pos:[124,152] width:52 height:20 toolTip:"Flip Normals" align:#left
	label 'lbl9' "normals:" pos:[80,153] width:40 height:16 align:#left
	button 'btn_pick_normal' "Pick Face" pos:[4,76] width:172 height:24 align:#left
	label 'lbl_normal' "normal: [0, 0, 1]" pos:[6,106] width:172 height:16 align:#left
	label 'lbl_pos' "pos:[0, 0, 0]" pos:[6,126] width:172 height:16 align:#left
	fn setRandomWirecolor objs = (
	
		for o in objs do o.wirecolor = color (random 0 255) (random 0 255) (random 0 255)
	)
	fn pickNormal obj = (
		if classOf obj != Editable_Poly do return false
		local fsel = mcPoly.get #fsel
		if fsel.count == 0 do return false
		project_normal	= polyOp.getFaceNormal obj fsel[1]
		project_pos		= polyOp.getFaceCenter obj fsel[1]
		lbl_normal.text = "normal:" + project_normal as string
		lbl_pos.text = "pos:" + project_pos as string
	)
	fn flipNormals objs = (
		
		local normalMod = normalModifier()
		normalMod.flip = true	
		addModifier objs normalMod
		convertToPoly objs
	)

	fn addSweepMod sp_path sp_profile btm_offset = (

		local sweep_mod = sweep ()
		addModifier sp_path sweep_mod ui:on
		sweep_mod.CustomShape = 1
		sweep_mod.shapes[1] = sp_profile.baseObject
		sweep_mod.MirrorXZPlane = off
		sweep_mod.MirrorXYPlane = off
		sweep_mod.XOffset = 0
		sweep_mod.yOffset = btm_offset
		sweep_mod.angle = 0
		sweep_mod.PivotAlignment = 5
		sweep_mod.GenerateMappingCoords = on
		sweep_mod.realWorldMapSize = on
	)
	fn createBorderFromSpline verts_pos new_name = (
		
		local sps  = mcSpline.splinesFromPoints verts_pos shpName:new_name
		local line_width = spn_line_width.value
		--fn create profile
		local sp_profile = mcSpline.drawLineBetweenTwoPoints [0, 0, 0] [-line_width, 0, 0]
		--create mesh from spline
		addSweepMod sps sp_profile 0
		convertToPoly sps --convert to poly
		delete sp_profile --delete use line
		getNodeByName new_name
	)
	/*fn flttenObject obj = (
	
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		local face_index = (polyOp.getFaceSelection obj as array)[1] 
		if face_index == undefined do return (mcMsgList.warn "not_fsel_1")
		local faceNormal = in coordsys obj polyOp.getFaceNormal obj face_index
		local center = [0,0,0]
		for v in obj.verts do center += (polyOp.getVert obj v.index)
		center = center / obj.verts.count
		for v in obj.verts do (

			local planeOffset = (
			
				case rdo_offset_type.state of (
				
					1 : distance center (polyOp.getVert obj v.index)
					2 : -(distance center (polyOp.getVert obj v.index))
					3 : (distance center (polyOp.getVert obj v.index)) /2
				)
			)
			polyop.moveVertsToPlane obj #{v.index} faceNormal planeOffset
		)
	)*/
	fn getFlattenPoints obj density = (

		local tri_mesh = snapshotAsMesh obj --snapshot as TriMesh to memory
		local verts_pos = (
			if project_normal == [0, 0, 1] then (
			
				for v in tri_mesh.verts collect (v.pos.z = 0; v.pos) --drop vertices on floor and colect pos
				
			) else (
				--drop vertices to plane by project_normal and project_pos
				--local offset = distance obj.pos project_pos
				meshop.moveVertsToPlane tri_mesh tri_mesh.verts project_normal 0
				for v in tri_mesh.verts collect v.pos
			)
		)
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
		sqrt ( (a.x - b.x) * (a.x - b.x)  +  (a.y - b.y)  *  (a.y - b.y) )  
	)
	fn alphaCirc alp dist a b = (   
		( sqrt (alp - (dist / 2) * (dist / 2)) ) * (a - b) / dist 
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
			   local alpha_circ1 = alphaCirc alpha_2 dist y1 y2
			   local alpha_circ2 = alphaCirc alpha_2 dist x2 x1
			   local center1 = [mid.x + alpha_circ1, mid.y + alpha_circ2]
			   local center2 = [mid.x - alpha_circ1, mid.y - alpha_circ2]

				--local center1 = [mid.x + (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (y1 - y2) / dist),  mid.y + (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (x2 - x1) / dist)]
				--local center2 = [mid.x - (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (y1 - y2) / dist),  mid.y - (sqrt (alpha_2 - (dist / 2) * (dist / 2)) * (x2 - x1) / dist)]

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
	fn projectObjs objs = (
		
		local debug = chk_debug.checked
		for o in objs do (
			
			local fp = getFlattenPoints o spn_max_verts_dist.value
			if debug do test_points = for p in fp collect (point pos:p size:2 wirecolor:green)
			local edata_array = alphaShape fp spn_shape_precision.value
			local verts_pos = sortEdgesAsPoints edata_array
			local new_name = o.name + "_projection2D"
			local new_o = mcPoly.createPolygonObj verts_pos objName:new_name
			new_o.pos = o.pos
		)
	)
	on btn_build_geom pressed do projectObjs (selection as array)
	on btn_flip_normals pressed do undo "Flip Normals" on flipNormals (selection as array)
	on btn_pick_normal pressed do pickNormal (selection as array)[1]
)
createDialog mcProjector2DDialog

/*
avgPos = [0,0,0]
for s in selection do avgPos = avgPos + s.pos
avgPos = avgPos / selection.count

faceNormalArray = #()
for s in selection do
(
	faceNormal = in coordsys s polyOp.getFaceNormal s 1
	append faceNormalArray faceNormal
)
facesVector = [0,0,0]
for s = 1 to selection.count do facesVector = facesVector + faceNormalArray[s]
facesVector = facesVector / selection.count

connectVector = normalize (selection[selection.count].pos - selection[1].pos)

rightVector = normalize (cross facesVector connectVector) 
upVector = normalize (cross rightVector connectVector)
theMatrix = matrix3 rightVector upVector connectVector avgPos

for s in selection do
(
	for v = 1 to s.numVerts do
	(
		thePos = in coordSys theMatrix polyOp.getVert s v
		in coordSys theMatrix polyOp.setVert s v [thePos.x, 0, thePos.z]
	)
)

*/