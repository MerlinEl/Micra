-- Self Intersection Test for EditableMesh
-- by Christoph 'CrazyButcher' Kubisch
-- http://crazybutcher.cube3d.de
-- version 0.8
--
-- does a test if self intersection occurs in the mesh
-- the test only works based on triangle edges
-- currently only triangle meshes are supported, editable poly to come
-- 
-- an octree is used to reduce complexity
-- search for OCTREEDEPTH and change the value
-- to get better ratios

-- mod by Merlin El 2019
-- TODO 
-- need to be optimized (too slow)
-- maybe change way of check
Global mcSelfIntersectPolygonTest
Global mcForceStructRebuild = true

-- octree functions
struct OCTREE_NODE 
(
	children = #(),		-- octreeNodes
	minbb = [0,0,0],	-- pt3
	maxbb = [0,0,0],	-- pt3
	data = #()			-- user data list
)

struct SELF_INTERSECT_POLYGON_TEST (

	-- modify this value to further lower ratio
	OCTREEDEPTH = 4,
	-- function to test segment with triangle
	fn testSegmentTriangle segA segB tris0 tris1 tris2 normal =
	(
		local distA = dot (segA-tris0) normal
		local distB = dot (segB-tris0) normal
		
		-- both on same side of the plane no intersection
		if (distA < 0 and distB < 0 ) or (distA > 0 and distB > 0 ) then return false
	
		-- different sides then there is intersection compute intersection point
		local intersect = [0,0,0]
		intersect = ( (distA * segB) - (distB * segA) ) / (distA - distB)
		
		-- reduce to 2D problem check
		-- Find dominant axis to select which plane
		-- to project onto, and compute u's and v's
		local u0,u1,u2,v0,v1,v2
		local axis = 0
		
	
		if (abs(normal.x) > abs(normal.y) ) then 
		(
			if (abs(normal.x) > abs(normal.z) ) then axis = 0
			else axis = 2
		)
		else 
		(
			if (abs(normal.y) > abs(normal.z)) then axis = 1
			else axis = 2
		)
		end 
		
		case axis of 
		(
			0:
			(
				u0 = intersect.y - tris0.y
				u1 = tris1.y - tris0.y
				u2 = tris2.y - tris0.y
				v0 = intersect.z - tris0.z
				v1 = tris1.z - tris0.z
				v2 = tris2.z - tris0.z
			)
			1:
			(
				u0 = intersect.x - tris0.x
				u1 = tris1.x - tris0.x
				u2 = tris2.x - tris0.x
				v0 = intersect.z - tris0.z
				v1 = tris1.z - tris0.z
				v2 = tris2.z - tris0.z
			)
			2:
			(
				u0 = intersect.x - tris0.x
				u1 = tris1.x - tris0.x
				u2 = tris2.x - tris0.x
				v0 = intersect.y - tris0.y
				v1 = tris1.y - tris0.y
				v2 = tris2.y - tris0.y
			)
		)
	
		-- Compute denominator, check for invalid
		local temp = u1*v2-v1*u2
		if (temp > -0.00000001 and temp < 0.00000001) then return false
		else temp = 1.0 / temp
		
		-- Compute barycentric coords, checking for out-of-range
		-- at each step
		local alpha = (u0*v2-v0*u2)*temp
		if (alpha < 0) then return false
		
		local beta = (u1*v0-v1*u0)*temp
		if (beta < 0) then return false
		
		if (alpha+beta > 1) then return false
		
		return true
	),
	
	--	newOctree pt3 pt3 int
	function OctreeNew minbb maxbb depth=
	(
		local curmin
		local curmax
		local extents
		local center
		local copymin
		local copymax
		local tolerance = [1,1,1]
		node
		childnode
		
		copymin = copy minbb
		copymax = copy maxbb
		copymin -= tolerance
		copymax += tolerance
		
		extents =(copymax - copymin )/2
		center = (copymax + copymin )/2
		
		node = OCTREE_NODE minbb:copymin maxbb:copymax 
		
		node.children = #()
		if (depth > 0) then
		(
			for i = 1 to 8 do
			(
				-- create 8 children
				case i of
				(
					1:	-- -x -y -z
					(
						curmin = center - extents
						curmax = copy center
					)
					2:	-- +x -y -z
					(
						curmin = center - extents
						curmin.x = center.x
						curmax = copy center
						curmax.x += extents.x
					)
					3:	-- +x +y -z
					(
						curmin = copy center
						curmin.z -= extents.z
						curmax = center + extents
						curmax.z = center.z
					)
					4:	-- -x +y -z
					(
						curmin = center - extents
						curmin.y = center.y
						curmax = copy center
						curmax.y += extents.y
					)
					5:	-- -x -y +z
					(
						curmin = center - extents
						curmin.z = center.z
						curmax = copy center
						curmax.z += extents.z
					)
					6:	-- +x -y +z
					(
						curmin = copy center
						curmin.y -= extents.y
						curmax = copy center
						curmax.x += extents.x
						curmax.z += extents.z
					)
					7:	-- +x +y +z
					(
						curmin = copy center
						curmax = center + extents
					)
					8:	-- -x +y +z
					(
						curmin = copy center 
						curmin.x -= extents.x
						curmax = copy center
						curmax.y += extents.y
						curmax.z += extents.z
					)
				)
				childnode = OctreeNew curmin curmax (depth-1)
				append node.children childnode
			)
		)
		
		
		return node
	),
	
	-- print octree
	function OctreePrint rootnode indent =
	(
		local spaces
		local nodesbrowse
		
		spaces = ""
		for i = 1 to indent do spaces = spaces + " "
		
		format "%min:% \tmax:% \tdata: %\n" spaces rootnode.minbb rootnode.maxbb rootnode.data
		
		for nodesbrowse in rootnode.children do
		(
			OctreePrint nodesbrowse (indent+2)
		)
	),
	
	-- adds content to data list 
	function OctreeAddData rootnode minBB maxBB data =
	(
		-- check if it fits in us 
		local wasadded = false
		
		if (minBB.x < rootnode.minbb.x or minBB.y < rootnode.minbb.y or minBB.z < rootnode.minbb.z) then
			return false
		if (maxBB.x > rootnode.maxbb.x or maxBB.y > rootnode.maxbb.y or maxBB.z > rootnode.maxbb.z) then
			return false
			
		-- if yes check if it fits in one of our children
		
		for nodes in rootnode.children do
		(
			wasadded = OctreeAddData nodes minBB maxBB data
			if (wasadded) then return true
		)
		
		append rootnode.data data
		
		return true
	),
	
	-- returns all potential candidates of octree node content that fullfills
	-- min/max criteria
	function OctreeGetData	rootnode minBB maxBB =
	(
		local childlist
		
		if (minBB.x < rootnode.minbb.x or minBB.y < rootnode.minbb.y or minBB.z < rootnode.minbb.z) then
			return undefined
		if (maxBB.x > rootnode.maxbb.x or maxBB.y > rootnode.maxbb.y or maxBB.z > rootnode.maxbb.z) then
			return undefined
			
		outlist = #()
		
		for nodes in rootnode.children do
		(
			childlist = OctreeGetData nodes minBB maxBB
			if (childlist != undefined) then join outlist childlist
		)
		
		join outlist rootnode.data
		
		return outlist
	),
	
	function trisAABB tris0 tris1 tris2 curmin curmax =
	(
		curmin.x = tris0.x
		if (tris1.x < curmin.x) then curmin.x = tris1.x
		if (tris2.x < curmin.x) then curmin.x = tris2.x
		
		curmin.y = tris0.y
		if (tris1.y < curmin.y) then curmin.y = tris1.y
		if (tris2.y < curmin.y) then curmin.y = tris2.y
		
		curmin.z = tris0.z
		if (tris1.z < curmin.z) then curmin.z = tris1.z
		if (tris2.z < curmin.z) then curmin.z = tris2.z
		
		curmax.x = tris0.x
		if (tris1.x > curmax.x) then curmax.x = tris1.x
		if (tris2.x > curmax.x) then curmax.x = tris2.x
		
		curmax.y = tris0.y
		if (tris1.y > curmax.y) then curmax.y = tris1.y
		if (tris2.y > curmax.y) then curmax.y = tris2.y
		
		curmax.z = tris0.z
		if (tris1.z > curmax.z) then curmax.z = tris1.z
		if (tris2.z > curmax.z) then curmax.z = tris2.z
	),
	
	-- mesh test
	function testObj obj =
	(
		if not (classof obj == Editable_mesh or classof obj == triMesh) then return false
		
		local face_selection = #()
		local edge_selection = #()
		local verts,vertsTris,vertsTrisTest
		local intersected = false
		local tris0,tris1,tris2,segA,segB,normal,a,b,n
		local cancel = false
		local testlist
		local octree
		local curmin,curmax
		local testsCnt

		segA = x_axis
		segB = x_axis
		curmin = x_axis
		curmax = x_axis
		
		face_selection = #()
		edge_selection = #()
		progressStart (" SelfIntersectTest : "+obj.name)
		
		
		-- build octree

		octree = OctreeNew obj.min obj.max OCTREEDEPTH
		
		for face = 1 to obj.numfaces do
		(
			vertsTris = getFace obj face
			tris0 = getVert obj vertsTris.x
			tris1 = getVert obj vertsTris.y
			tris2 = getVert obj vertsTris.z
			
			trisAABB tris0 tris1 tris2 curmin curmax
			
			OctreeAddData octree curmin curmax face
		)
		
		--OctreePrint octree 0
		
		testsCnt = 0
		-- perform test
		for face = 1 to obj.numfaces do
		(
			intersected = false
			normal = getFaceNormal obj face
			vertsTris = getFace obj face
			tris0 = getVert obj vertsTris.x
			tris1 = getVert obj vertsTris.y
			tris2 = getVert obj vertsTris.z
			
			trisAABB tris0 tris1 tris2 curmin curmax
			
			progressUpdate (100.0*face/obj.numfaces)
			
			testlist = #()
			testlist = OctreeGetData octree curmin curmax
			
			for testface in testlist do
			(
				if (testface == face) then continue
				
				vertsTrisTest = getFace obj testface
				
				for edge = 1 to 3 do
				(
					case edge of
					(
						1:
						(
							a = vertsTrisTest.x
							b = vertsTrisTest.y
						)
						2:
						(
							a = vertsTrisTest.y
							b = vertsTrisTest.z
						)
						3:
						(
							a = vertsTrisTest.z
							b = vertsTrisTest.x
						)
						
					)
					
					if (a == vertsTris.x or a == vertsTris.y or a == vertsTris.z \
						or b == vertsTris.x or b == vertsTris.y or b == vertsTris.z)
						then continue
					
					segA = getVert obj a
					segB = getVert obj b
					
					intersected = testSegmentTriangle segA segB tris0 tris1 tris2 normal
					testsCnt += 1
					if (intersected) then
					(
						sel = (((testface-1)*3)+edge)
			  			append edge_selection sel
						exit
					)
				)
				if (intersected) then append face_selection testface
			)
			cancel = getProgressCancel()
			if (cancel) then exit
			if (intersected) then append face_selection face
		)
		progressEnd()
		
		setfaceselection obj face_selection
		setedgeselection obj edge_selection
		
		format "object:% \ttestratio (optimized/bruteforce): \t% (percent) \n" obj.name (100.0*testsCnt/(obj.numfaces * obj.numfaces * 3))
		
		if (face_selection.count > 0) then print "Intersection(s) found"
		else print "No intersection found"
		
		update obj
		
		gc()
	)
)
if superClassOf mcSIPTest != StructDef or mcForceStructRebuild == true do mcSIPTest = SELF_INTERSECT_POLYGON_TEST()
for o in selection do mcSIPTest.testObj o
