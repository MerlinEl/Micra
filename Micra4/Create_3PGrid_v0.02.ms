--2012

(	
	struct pointdata (pos, txt, col)
	global ThreePtGridMarkers = #()	-- viewport marker list
	
	-- callback function that draws all viewport markers found in ThreePtGridMarkers
	fn drawMarkers = 
	(
		gw.setTransform(Matrix3 1)
		for i in ThreePtGridMarkers do 
		(
			local p = gw.hTransPoint i.pos
			gw.hText p i.txt color:i.col
			gw.hMarker p #smallHollowBox color:[255,255,255]
		)
		if ThreePtGridMarkers.count > 1 then 
		(
			gw.SetColor #line [255,255,0]
			gw.hPolyline #(gw.hTransPoint ThreePtGridMarkers[1].pos, gw.hTransPoint ThreePtGridMarkers[2].pos) false
		)
		if ThreePtGridMarkers.count > 2 then
		(
			gw.SetColor #line [0,255,255]
			gw.hPolyline #(gw.hTransPoint ThreePtGridMarkers[1].pos, gw.hTransPoint ThreePtGridMarkers[3].pos) false
		)
		gw.enlargeUpdateRect #whole
		gw.updateScreen()
	)
		
	fn localMatrix p1 p2 p3 =
	(
		v1 = normalize (p2 - p1)
		v3 = normalize (cross v1 (normalize (p3 - p1)))
		v2 = normalize (cross v3 v1)
		return matrix3 v1 v2 v3 p1
	)
	local p1, p2, p3, p4
	local canceled = true
	local oldSnapMode = snapMode.active
	snapMode.active = true

	ThreePtGridMarkers = #()
	unregisterRedrawViewsCallback drawMarkers
	registerRedrawViewsCallback drawMarkers

	if (classOf (p1 = pickPoint prompt:"Pick 1st source point" snap:#3D) == Point3)
	then
	(
		append ThreePtGridMarkers (pointdata pos:p1 txt:"Point A1" col:[255,0,0])
		if (classOf (p2 = pickPoint prompt:"Pick 2nd source point" snap:#3D rubberBand:p1) == Point3) 
		then
		(
			append ThreePtGridMarkers (pointdata pos:p2 txt:"Point A2" col:[0,255,0])
			if (classOf (p3 = pickPoint prompt:"Pick 3rd source point" snap:#3D rubberBand:p2) == Point3)
			then
			(
				append ThreePtGridMarkers (pointdata pos:p3 txt:"Point A3" col:[0,0,255])
				
				if ThreePtGridMarkers.count == 3 do
				(
					local tm = localMatrix p1 p2 p3
					local space    = getGridSpacing()
					local lines    = getGridMajorLines()
					local gname    = uniqueName "Grid_3P_"
					local new_grid
					undo label:"Create 3P Grid" on new_grid = grid length:150 width:150 grid:space transform:tm name:gname wirecolor:black --isSelected:on
					Try (ActiveGrid = new_grid) Catch()
					Toolmode.coordsys #Grid -- change view coordinates to grid
				)
				unregisterRedrawViewsCallback drawMarkers
			)else canceled = true
		)else canceled = true
	)else canceled = true
	
	if canceled do unregisterRedrawViewsCallback drawMarkers
	snapMode.active = oldSnapMode	
)

-- old way
/*

(
	
	--Locals
	local MeshObj = undefined
	local clicknum = 0
	local points = #()
	
	--Functions
	
	function getClosestVert obj face hit =
    (
        local closest_vert = 0
        local shortest_dist = 1e6
        local dist = 0
    
        local face_verts = meshOp.getVertsUsingFace obj face

        for v in face_verts do
        (
            dist = distance (getVert obj v) hit
    
            if (dist < shortest_dist) then
            (
                shortest_dist = dist
                closest_vert = v
            )
        )
        return closest_vert
    )
	
	function showHint &meshobj &vert =
    (
        gw.setTransform (matrix3 1)
        gw.wText [mouse.pos.x +7, mouse.pos.y +20, 0] ("Pick Point:" + (clicknum +1) as string) color:green
        gw.enlargeUpdateRect #whole
        gw.updateScreen()
    )
	
	function regshowHint = showHint &meshobj &vert
	
	fn localMatrix p1 p2 p3 = 
	(
		local v1 = normalize (p2 - p1)
		local v3 = normalize (cross v1 (normalize (p3 - p1)))
		local v2 = normalize (cross v3 v1)
		return matrix3 v1 v2 v3 ((p1+p2+p3)/3)
	)
	
	fn createGrid3P p1 p2 p3 =
	(
		local tm       = localMatrix p1 p2 p3
		local space    = getGridSpacing()
		local lines    = getGridMajorLines()
		local gname    = uniqueName "Grid_3P_"
		
		local new_grid = grid length:150 width:150 grid:space transform:tm name:gname wirecolor:black --isSelected:on
		Try (ActiveGrid = new_grid) Catch()
		Toolmode.coordsys #Grid -- change view coordinates to grid
	)
	
	function pick3P msg ir obj faceNum shift ctrl alt =
    (
		case msg of
        (
			#freeMove:
            (
				completeRedraw()
				#continue
            )

			#mousePoint:
            (
				if ir != undefined and clicknum < 3 do
                (
				    clicknum += 1
					
					local vert = getClosestVert obj faceNum ir.pos
					if vert != undefined do 
					(
						local vert_pos = getVert obj vert
						points += #(point pos:vert_pos wirecolor:white)
					)
                )
				
				if clicknum == 3 
				then 
				(
					if points.count == 3 do ( createGrid3P points[1].pos points[2].pos points[3].pos )	
					#stop
				)
				else #continue
           )
           #mouseMove :( #continue )
           #mouseAbort:(   #stop   )
        )
    )
	
	--Run	
	if selection.count == 1 and classOf selection[1] == Editable_Poly then
	(
		local obj = selection[1]
		if keyboard.controlPressed and subobjectlevel == 4
		then --create grid from face
		(
			--get two neighbours edges from face
			local fsel = (polyop.getfaceselection obj as array)[1]
			local fnormal = polyop.getfacenormal obj fsel
			local vert = (polyop.getVertsUsingFace obj fsel as array)[1]
			local vedges = polyop.getEdgesUsingVert obj vert
		--get edges verts
		local edges_verts = #()
		for i in vedges do 
		(
			local verts = for v in (polyOP.getVertsUsingEdge obj i) collect polyOP.getVert obj v
			append edges_verts verts 
		)
			--format "verts:%\n" edges_verts
			local p1 = edges_verts[1][1]
			local p2 = edges_verts[1][2]
			local p3 = edges_verts[2][1]
			local p4 = edges_verts[2][2]
			local v1 = normalize (p2 - p1)
			local v2 = normalize (p3 - p4)
			local v3 = normalize (cross v2 v1)
			local tm = matrix3 v1 v2 v3 ((p1+p2+p3+p4)/4)
			local space    = getGridSpacing()
			local lines    = getGridMajorLines()
			local gname    = uniqueName "Grid_3P_"
		
			local new_grid = grid length:150 width:150 grid:space transform:tm name:gname wirecolor:black --isSelected:on
			Try (ActiveGrid = new_grid) Catch()
			Toolmode.coordsys #Grid -- change view coordinates to grid
		)
		else
		(
			MeshObj = snapshot obj
			hide MeshObj
			registerRedrawViewsCallback regshowHint
			
			mouseTrack on:MeshObj snap:#3D trackCallback:pick3P
			
			unRegisterRedrawViewsCallback regshowHint
			if isValidNode IntersectOjb  do delete IntersectOjb
			delete points
		)
		completeRedraw()
	)
	else
    (
       messageBox " Select an Editable Poly object." title:"Micra III:"
    )
)
*/