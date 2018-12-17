   plugin simpleManipulator TestManip
   name:"TestManip"
   invisible:false
   (
   	local g = [0, 1, 0], r = [1, 0, 0]
   	on canManipulate target return classOf target == box
   	on updateGizmos do
   	(
   		this.clearGizmos()
   		--this.addGizmoText "TestText1" [0,0,0] 0 g r 
		this.addGizmoText "TestText2" [100,100,0] (gizmoUseScreenSpace + gizmoActiveViewportOnly) g r
   	)
   )
   manipulatemode=true
   
   ------------------------
   ---------------------
plugin simpleManipulator TestManip
name:"TestManip"
invisible:true
(
    local g = [0, 1, 0], r = [1, 0, 0]

    on canManipulate target return ((classOf target) == Box)

    on updateGizmos do
    (
        this.clearGizmos()

    	gw.setTransform (Matrix3 1)
        local p3TargetScreenPos = gw.transPoint node.position

        this.addGizmoText "TestText" p3TargetScreenPos (gizmoUseScreenSpace + gizmoActiveViewportOnly) g r 

        -- hack to force the gizmo update
       node.transform = node.transform
    )
)

manipulatemode = true
--------------------
-------------------

plugin simpleManipulator radiusManip
name:"RadiusManip"
invisible:true
(
	-- Create the green and red colors for the gizmo
	local g = [0, 1, 0], r = [1, 0, 0]
	-- This manipulator manipulates any node with a "radius" property
	on canManipulate target return (findItem (getPropNames target) #radius) != 0
	-- Create the manipulator gizmo.
	-- This is called initially and whenever the manipulator target changes
	on updateGizmos do
	(
	-- Clear the current gizmo cache
	this.clearGizmos()
	-- Set the radius of circle gizmo a little bigger than the target radius
	giz = manip.makeCircle [0,0,0] (target.radius * 1.01) 28
	-- Add the circle to the manipulator
	this.addGizmoShape giz 0 g r 
	-- return the ToolTip string
	return node.name + " radius = " + target.radius as string 
	)
	-- mouseMove is called on every mouse move when dragging the manip
	-- It needs to convert the mouse position 'm' into a new value for the radius
	on mouseMove m which do
	(
		
		-- Create the XY plane. 
		-- manip.makePlaneFromNormal takes a normal vector and a point
		-- and creates a plane passing through the point with the given normal
		local pl = manip.makePlaneFromNormal z_axis [0, 0, 0],
		projectedPoint = [0,0,0]
		
		-- Compute the hit-ray in local coordinates
		viewRay = this.getLocalViewRay m
		
		-- Intersect the plane with the view ray
		res = pl.intersect viewRay &projectedPoint
		
		-- If the intersection worked, set the radius
		if (res) then target.radius = (length projectedPoint) / 1.01	
	)
)



	on updateGizmos do
	(
		-- Clear the current gizmo cache
		this.clearGizmos()
		if mmesh == undefined do
		(
			local mnode = mesh vertices:#([0,0,0],[10,0,0],[0,10,0],[10,10,0]) tverts:#([0,0,0],[10,0,0],[0,10,0],[10,10,0]) faces:#([1,2,3],[2,4,3]) 
			mmesh = mnode.mesh
			buildTVFaces mmesh 
		)
		this.addGizmoMesh mmesh 0 g r
		return node.name	
	)
	
	
	
	---------------
	
	
	MasterSlider = sliderManipulator xpos:.025 ypos:.1 name:"MasterSlider"
sldrArr = #()
for i = 1 to 5 do
(
	 sldr = copy MasterSlider
	 sldr.name = "Slider_0" + (i as string)
	 sldr.ypos += (i*.075)
	 append sldrArr sldr
)
when parameters $MasterSlider changes do (
	 if $MasterSlider.value == 100.0 then (
		  for i in sldrArr do (hide i)
	 )
	 if $MasterSlider.value < 100.0 then (
		  for i in sldrArr do (unhide i)
	 )
)
callbacks.addscript #filePostOpen "sldrArr = #() for sldr in $Slider* do append sldrArr sldr; when parameters $MasterSlider changes do (if $MasterSlider.value == 100.0 then (for i in sldrArr do (hide i)) if $MasterSlider.value < 100.0 then (for i in sldrArr do (unhide i)))" id:#sldrhide persistent:true



plugin simpleManipulator EdgeLengthInfoManipulator
	name:"EdgeLength"
(
	local greenColor =  green/255.0
	local redColor =	red/255.0
	local yellowColor = yellow/255.0
	local blueColor = blue/255.0


	on canManipulateNode target return classof target == Editable_Poly or classof target == Editable_Mesh

	fn mapWorldToScreen thePoint =
	(
		thePos = thePoint * viewport.getTM()
		local screenSize = getViewSize()
		screen_origin = mapScreenToView [0,0] (thePos.z) screenSize
		end_screen = mapScreenToView screenSize (thePos.z) screenSize
		world_size = screen_origin-end_screen
		x_aspect = screenSize.x/(abs world_size.x)
		y_aspect = screenSize.y/(abs world_size.y)
		point3 ((x_aspect*(thePos.x-screen_origin.x))) ((-(y_aspect*(thePos.y-screen_origin.y)))) 0
	)
	
	on updateGizmos do
	(
		this.clearGizmos()
		case classof target of
		(
			Editable_Poly: (
				getEdgeSelMethod = polyOp.getEdgeSelection
				getVertsByEdgeMethod = polyOp.getVertsUsingEdge
				getVertMethod = polyOp.getVert
				goOn = subObjectLevel == 2 or subObjectLevel == 3
			)
			Editable_Mesh: (
				getEdgeSelMethod = getEdgeSelection
				getVertsByEdgeMethod = meshOp.getVertsUsingEdge
				getVertMethod = getVert
				goOn = subObjectLevel == 2
			)
			default: goOn = false
		)

		if goOn do
		(
			local theEdges = (getEdgeSelMethod target) as array
			local theMaxCount = amin #(theEdges.count, 500)
			local flags = gizmoActiveViewportOnly + gizmoDontHitTest + gizmoUseScreenSpace
			totalDist = 0
			for i = 1 to theEdges.count do
			(
				theEdge = theEdges[i]
				theVerts = (getVertsByEdgeMethod  target theEdge ) as array
				local v1 = in coordsys local (getVertMethod target theVerts[1])
				local v2 = in coordsys local (getVertMethod target theVerts[2])
				local w1 = (getVertMethod  target theVerts[1])
				local w2 = (getVertMethod target theVerts[2])
				if i <= theMaxCount do
				(
					local theDist = (distance v1 v2)
					totalDist += theDist 
					theString = theEdge as string + ": " + (theDist as string) + " (" + units.formatValue theDist +") "
					this.addGizmoText theString (mapWorldToScreen ((w1+w2)/2)) flags yellowColor yellowColor 
				)	
			)
			theString = "SELECTED EDGES: " + theEdges.count as string + " -- TOTAL LENGTH: " + totalDist as string + " (" + units.formatValue totalDist + ") "
			this.addGizmoText theString [5,(getViewSize()).y-10,0] flags yellowColor yellowColor 
		)	
		return ""
	)	
)		
