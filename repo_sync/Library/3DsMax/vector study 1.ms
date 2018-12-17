(
	struct EDGE_DATA (pos, r1, r2, dir, vect, len)	
	struct GEO_PAINT
	(
		source_obj, edge1, edge2, ir1, ir2, 
		markers = #(), 
		
		fn inicialize obj = (if classOf obj == editable_poly then source_obj = obj else #stop),
		fn movePointAlongVector p v val type:#positive = 
		( 
			print type
			case type	of
			(
				#negative:p - (normalize v) * val
				#positive:p + (normalize v) * val 
			)
		),
		fn reverseArray arr = (for i=arr.count to 1 by -1 collect arr[i]),
		fn getScreenRayAtNode obj = ( intersectRay obj (mapScreenToWorldRay mouse.pos) ),
		fn getRayFomPoint obj p3  =
		(
			local ir_mouse = (mapScreenToWorldRay mouse.pos)
			local r  = ray ir_mouse.pos (p3 - ir_mouse.pos)
			return (intersectRay obj r)
		),
		fn snapVertsToSurface verts = -- markers for now
		(
			for i in verts do
			(
				local pr = getRayFomPoint source_obj i.pos 
				if pr != undefined do 
				(
					i.pos = pr.pos
					i.dir = pr.dir
				)
			)
		),
		fn getEdgeDataFrom2Hits ir1 ir2 =
		(
			if ir1 == undefined or ir2 == undefined do return false
			local d = normalize (ir1.dir + ir2.dir)
			local l = distance ir1.pos ir2.pos 
			local v = ir1.pos - ir2.pos
			local p = (ir1.pos + ir2.pos)/2
			return (EDGE_DATA pos:p r1:ir1 r2:ir2 dir:d vect:v len:l)
		),
		fn getEdgeDataFrom1Hit ir =
		(
			if ir == undefined do return false
			local p1 = movePointAlongVector ir.pos edge1.vect (edge1.len/2) type:#positive
			local p2 = movePointAlongVector ir.pos edge1.vect (edge1.len/2) type:#negative
			local p2 = (ir.pos - (normalize edge1.vect) * (edge1.len/2)) --move pos2 along edge2 vector	
			local ir1 = ray p1 ir.dir
			local ir2 = ray p2 ir.dir
			local d = ir.dir
			local l = edge1.len
			local v = edge1.vect
			local p = ir.pos
			return return (EDGE_DATA pos:p r1:ir1 r2:ir2 dir:d vect:v len:l)
		),
		fn edgeSpin =
		(
			--print "edge spin"
			--format "edge1:%\nedge2:%\n" edge1 edge2
			if edge1 == undefined or edge2 == undefined do return false
			
			local mouse_hit = getScreenRayAtNode source_obj
			if mouse_hit == undefined do return false
			
			--format "mouse hit:%\n" mouse_hit
			
			local mouse_hit_normal = normalize (mouse_hit.pos - edge1.pos) 
			local new_vect1   = normalize (cross mouse_hit_normal edge1.dir)
			local v1 = edge1.len * new_vect1
			local new_p1 = edge1.pos + v1 
			local new_p2 = edge1.pos - v1 
			edge2.pos = mouse_hit.pos
			local new_vect2 = normalize (cross mouse_hit_normal mouse_hit.dir)
			local v2 =  edge2.len * new_vect2
			local new_p3 = edge2.pos + v2
			local new_p4 = edge2.pos - v2
			edge2.r1.pos = new_p3 
			edge2.r2.pos = new_p4
			edge2.vect = normalize (new_p3 - new_p4)
--markers			
markers[1].pos = new_p1
markers[2].pos = new_p2
markers[4].pos = mouse_hit.pos
markers[4].dir = mouse_hit.dir			
markers[5].pos = new_p3
markers[6].pos = new_p4

snapVertsToSurface markers
		), 
		fn edgeScale =
		(
			if edge2.pos == undefined  then return false
			local mouse_hit = getScreenRayAtNode source_obj
			if mouse_hit == undefined do return false
			local mouse_dist = distance mouse_hit.pos edge2.pos		
			local new_p1 = edge2.pos + mouse_dist * edge2.vect
			local new_p2 = edge2.pos - mouse_dist * edge2.vect
			markers[5].pos = new_p1
			markers[6].pos = new_p2
			edge2.len = distance edge2.pos markers[5].pos
		)
	)
	--Declare Structure Shortcut
	local GP = GEO_PAINT()
	
	tool pickPoints
	(		
		on start do ( GP.inicialize (selection[1]) )
		on mousePoint click do
		(
			local ir = GP.getScreenRayAtNode GP.source_obj
			if click > 1 do
			(
				
				if ir != undefined do
				(
					--edge 1
					if GP.edge1 == undefined do --create two points
					(
						print "creating first edge points"
						if GP.ir1 == undefined 
						then GP.ir1 = ir 
						else GP.ir2 = ir
--first edge points
GP.markers += #(point pos:ir.pos dir:ir.dir name:(uniqueName "hit") wirecolor:yellow)
					)
					
					if GP.ir1 != undefined and GP.ir2 != undefined do ( GP.edge1 = GP.getEdgeDataFrom2Hits GP.ir1 GP.ir2 )
					
					--edge 2
					if GP.edge1 != undefined and GP.edge2 == undefined then
					(
						print "creating second edge points"
						GP.edge2 = GP.getEdgeDataFrom1Hit ir
						
--create middle point betwen two points
GP.markers += #(point pos:GP.edge1.pos dir:GP.edge1.dir name:"Mid Point" wirecolor:red)
--create point projected from mouse pos
GP.markers += #(point pos:ir.pos dir:ir.dir name:"Mouse Pos" wirecolor:white)
--next two points and move them in mouse pos to create second line
GP.markers += #(point pos:ir.pos dir:ir.dir name:(uniqueName "hit") wirecolor:green)
GP.markers += #(point pos:ir.pos dir:ir.dir name:(uniqueName "hit") wirecolor:blue)
					)
					--finish move
					else if GP.edge2 != undefined then 
					(
						print "end this step"
					)
				)
			)
		)
		on mouseMove click do 
		( 
			 
			if GP.edge2 != undefined do 
			(
				if altKey 
				then GP.edgeScale()
				else GP.edgeSpin()
			)
		)
	)
	startTool pickPoints
)