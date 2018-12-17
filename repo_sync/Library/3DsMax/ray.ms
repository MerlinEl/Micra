ray <pos_point3> <dir_point3>


iray = ray <pos> <dir>
hit_nodes = for n in (intersectRayScene iray) where not n[1].isHidden collect #(n[1], n[2], distance iray.pos n[2].pos)
fn sortByHitDistance n1 n2 = if n1[3] < n2[3] then -1 else if n1[3] > n2[3] then 1 else 0 
qsort hit_nodes sortByHitDistance
hit_nodes[1] -- is closest



intersectRay <node> <ray>

r = ray [-100,5,0] (s.center-[-100,5,0])

ray <pos_point3> <dir_point3>

<node> as ray

r=ray $.pos [0,0,-1] 

--------
fn getViewDirectionRay =
(
	local coordSysTM = Inverse(getViewTM())-- so we need the inverse of this matrix
	local viewDir = -coordSysTM.row3-- The Z axis of this matrix is the view direction.
	local viewPt = coordSysTM.row4-- get the view position from this matrix
	return ray viewPt viewDir
)
--OR

mapScreenToWorldRay mouse.pos

-----------------

gw.getFocalDist()--Returns the focal distance of an active perspective view.
getCPTM() --Construction-plane-to-world transform matrix.

gw.snapPoint <pixel_coord_point2> [ snapType:<snapType_name> ] [ snapPlane:<matrix3> ]

gw.snapPoint  #inPlane

tm = Matrix3(1) --represents the XY plane
m = Point2 0 0 --screen pixel coordinates
p = gw.snapPoint m snapPlane:tm --returns the snapping point


<ray>getLocalViewRay <point2>m

-- Create the XY plane. 
-- manip.makePlaneFromNormal takes a normal vector and a point 
-- and creates a plane passing through the point with the given normal 
local pl = manip.makePlaneFromNormal z_axis [0, 0, 0], 
projectedPoint = [0,0,0] 
-- Compute the hit-ray in local coordinates 
viewRay = this.getLocalViewRay m 
-- Intersect the plane with the view ray 
res = pl.intersect viewRay &projectedPoint 



--find the point on the plane ABC which is the projection of the point D
fn pointPlaneProj pA pB pC pD = 
(
	local nABC=normalize (cross (pB-pA) (pC-pA))
	pD+((dot (pA-pD) nABC)*nABC)
)
--intersection between a line and a plane
fn planeLineIntersect planePoint planeNormal linePoint lineVector = 
(
	local lineVector=normalize lineVector
	local d1=dot (planePoint-linePoint) planeNormal
	local d2=dot lineVector planeNormal
	if abs(d2)<.0000000754 then ( if abs(d1)>.0000000754 then 0 else -1 )
		else ( linePoint + ( (d1/d2)*lineVector ) )
)

--object to object
fn find_intersection z_node node_to_z =
(
	 local testRay = ray node_to_z.pos [0,0,-1]
	 local nodeMaxZ = z_node.max.z
	 testRay.pos.z = nodeMaxZ + 0.0001 * abs nodeMaxZ
	 intersectRay z_node testRay
)


------------
--EXAMPLES--
------------
--cast rays as splines
(
	fn drawRay pointA pointB type:#corner =
	(
		local sp = SplineShape pos:pointA
		addNewSpline sp
		addKnot sp 1 type #line PointA
		addKnot sp 1 type #line PointB
		updateShape sp
	)
	tool trackIntersection
	(
		on mousePoint clickno do
		(
			if clickno == 2 do
			(
				local viewPoint_ray = mapScreentoWorldRay viewPoint
				local p1 = viewPoint_ray.pos --viewport point
				local p2 = 
				(
					local dist = distance worldPoint p1
					viewPoint_ray.dir * dist*2 + viewPoint_ray.pos --scene point
				)
				drawRay p1 p2 --a straight line from the viewport passing through scene
			)
		)
	)
	starttool trackIntersection
)

-------------------
-------------------
(
  	struct object_data (obj, ray)
  	fn getObjIntersection ray =
  	(
  		--collect all visible objects in scene
  		local objs = for o in objects where not o.isHidden collect o
  		local od = #()
  		local ray_dist	= #()
  		--collect objects shoted by ray
  		for o in objs do
  		(
  			local i = intersectRay o ray
  			if i!= undefined do 
  			(
  				od += #(object_data o i)
  				ray_dist	+= #(distance ray.pos i.pos)
  			)
  		)
  		if od.count	  == 0
  		then return undefined
  		else if od.count == 1
  		then return od[1] 
  		else --return the closest object to ray begin
  		(
  			copy_ray_dist = #()+ray_dist --4fun
  			sort copy_ray_dist
  			return od[findItem ray_dist copy_ray_dist[1]]
  		)
  	)
  	tool getObjectFromRay
  	(
  		local PaintMarker
  		on start do --create marker
  		(
  			max select none
  			PaintMarker = circle radius:10 pos:[0,0,0] wireColor:(color 80 250 80) displayRenderMesh:true name:"PaintMarker" thickness = 2
  		)
  		on mousemove clickno do
  		(
  			if clickno > 1 then --move marker ower surfaces or grid
  			(
  				local viewPoint_ray = mapScreentoWorldRay viewPoint
  				local obj_data = getObjIntersection viewPoint_ray
  				if obj_data != undefined
  				then 
  				(
  					--select obj_data.obj 
  					PaintMarker.pos = obj_data.ray.pos
  					PaintMarker.dir = obj_data.ray.dir
  					format "picked obj:%\n" obj_data
  				)
  				else 
  				(
  					--max select none
  					PaintMarker.pos = worldPoint
 					PaintMarker.dir = [0,0,-1]
  					format "picked ground:worldPoint\tray:%\n" (ray worldPoint viewPoint_ray.dir)
  				)
  				--#stop
  			)
  		)
  		on stop do
  		(
  			delete PaintMarker
  		)
  	)
  	starttool getObjectFromRay
  )
  
-------------------
-------------------

/*
fn drawLineBetweenTwoPoints pointA pointB =
(
	local ss = SplineShape pos:pointA
	addNewSpline ss
	addKnot ss 1 #corner #line PointA
	addKnot ss 1 #corner #line PointB
	updateShape ss
)

tool create
(
	local pickNum = 1
	local polyObj = selection[1]
	on mousePoint click do 
	(
		if      click == 1
		then (print "Begin")
		else if click == (pickNum += 1)
		do 
		(
			local p1 = (Inverse(getViewTM())).row4
			local p2 = worldPoint
			drawLineBetweenTwoPoints p1 p2
			completeredraw()
		)
	)
)
startTool create
*/


/*
tool create
(
	local pickNum = 1
	local polyObj = selection[1]
	on mousePoint click do 
	(
		if      click == 1
		then (print "Begin")
		else if click == (pickNum += 1)
		do 
		(
			local theDir = (mapScreenToWorldRay viewPoint).dir
			local thePos = (mapScreenToWorldRay viewPoint).pos
			local hitData = intersectRay polyObj (ray thePos theDir)
			format "hit:%\n" hitData
			if hitData != undefined do (point pos:hitData.pos)
		)
	)
)
startTool create
*/


/*
--get center and dir from two points
	if v_sel.count == 2 then
		(
		v1 = getvert selection[1] v_sel[1].index
		v2 = getvert selection[1] v_sel[2].index
		p = point position:v1
		tm = matrix3 1
		tm.row3 = normalize (v1 - v2)
		tm.row2 = [0,1,0]
		tm.row1 = normalize(cross tm.row3 tm.row2)
		tm.row2 = normalize(cross tm.row3 tm.row1)
		tm.row4 = (v1 + v2) / 2
		p.transform = tm
		)
	else
		(
		messagebox "Select 2 verts!"
		)
	)
*/
