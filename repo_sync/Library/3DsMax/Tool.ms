
on start do <expr>
--Called when the tool starts.
on stop do <expr>
--Called when the tool ends.
on freeMove do <expr>
--Called when the mouse moves prior to the first click.
on mousePoint <arg> do <expr>
--Called for each mouse click, parameter arg contains the number of the click.
on mouseMove <arg> do <expr>
--Called when the mouse moves anytime after the first click.
on mouseAbort <arg> do <expr>
--Called when the user right-clicks to cancel or presses the ESC key.


viewPoint Point2--The current mouse position in viewport pixel coordinates.

worldPoint Point3--The current mouse position projected on the active grid in world coordinates.

worldDist Point3--The distance in X, Y, and Z from the previous click point to the current click point in world coordinates.

worldAngle Point3--The angles around the world X, Y, and Z axes from the previous click point to the current click point in world coordinates.

gridPoint Point3--The current mouse position projected on the active grid in the coordinate system of the active grid. If the active grid is the home grid, the coordinate system is the home grid plane active in the current viewport (that is, the construction plane). See the discussion of grid versus world values below.

gridDist Point3--The distance in X, Y, and Z from the previous click point to the current click point in the coordinate system of the active grid. If the active grid is the home grid, the coordinate system is the home grid plane active in the current viewport (that is, the construction plane). See the discussion of grid versus world values below.

gridAngle Point3--The angles around the world X, Y, and Z axes from the previous click point to the current click point in the coordinate system of the active grid. If the active grid is the home grid, the coordinate system is the home grid plane active in the current viewport (that is, the construction plane). See the discussion of grid versus world values below.

shiftKey Boolean--true if SHIFT key was down.
ctrlKey Boolean--true if CTRL key was down.
altKey Boolean--true if ALT key was down.
lButton Boolean--true if left mouse button was down.
mButton Boolean--true if middle mouse button was down.
rButton Boolean--true if right mouse button was down.

--When a create mouse tool is used in a level 5 scripted plug-in, an additional local variable is accessible:
nodeTM Matrix3
--Provides read/write access to the transform of the node currently being created. This value is in the current grid coordinate system.




tool create
(
	local startPoint, delegate
	--on start do ()
	on mousePoint click do
		case click of
		(
			1: 
			(
				startPoint = nodeTM.translation = gridPoint
				delegate = rectangle pos:startPoint
			)
			3: #stop
		)
	on mouseMove click do
		case click of
		(
			2: 
			(
				delegate.width= abs gridDist.x
				delegate.length= abs gridDist.y
				nodeTM.translation = startpoint + gridDist/2.
			)
			3: delegate.corner_radius = amax 0 -gridDist.x
		)

)
startTool create

--------------

--------------
p = pickPoint()
	case of
		(
	(p == undefined): print "escaped" -- user pressed escape
	(p == #rightClick): print "rclick" -- user clicked RMB
	(classOf p == Point3): print "" -- user entered a point
	(classOf p == String): print "" -- user keyed a non-point
	)
--------------
-------------------------------------------
tool create_prim
(
on mousePoint clickno do
	(
	if clickno == 1 then (print "start:")
	else if clickno == 2 then (s = sphere pos:worldPoint)
	else if clickno == 3 then (c = cylinder pos:worldPoint)
	else if clickno == 4 then (p = pyramid pos:worldPoint)
	else if clickno == 5 then (b = box pos:worldPoint)
	else #stop
	)
)
startTool create_prim prompt:"Hello!"
-------------------------------------------
-------------------------------------------
tool create_prim
(
on mousePoint clickno do
	(
	if clickno == 1 then (print "start:")
	else if clickno == 2 then (sphere pos:worldPoint)
	else if clickno == 3 then (cylinder pos:worldPoint)
	else if clickno == 4 then (pyramid pos:worldPoint)
	else if clickno == 5 then (box pos:worldPoint)
	else #stop
	)
)
startTool create_prim prompt:"Hello!"
-------------------------------------------
-------------------------------------------
tool three_lights
(
	local key, fill, back, targ
	on mousePoint click do coordsys grid
	(
		if click == 1 then -- create key, back & fill lights at mousedown
		(
			targ=targetobject pos:gridPoint
			key = targetspot pos:gridPoint name:"key" target:targ
			back = targetspot pos:gridPoint name:"back" target:targ
			fill = targetspot pos:gridPoint name:"fill" target:targ
		)
		if click == 3 then #stop
	)
	on mouseMove click do
	(
		if click == 2 then -- drag out & round on x-y plane
		(
			coordsys grid key.pos = gridPoint
			coordsys targ back.pos = - key.pos
			local p = if shiftKey then 90 else -90
			coordsys targ fill.pos = key.pos * ((eulerangles 0 0 p) as quat)
		)
		else if click == 3 then -- drag up to elevate lights
		(
			in coordsys targ
			(
				local Z = gridDist.z
				key.pos.z = Z
				back.pos.z = Z * 1.5
				fill.pos.z = Z * 0.5
			)
		)
	)
)
starttool three_lights