sps = SplineShape pos:[0,0,0] name:"temp_box_marker01"
select sps
sps.render_renderable = false
sps.render_displayRenderMesh = false



"---------------------------------------------------------------------------"
Info:$Editable_Spline:temp_box_marker01 @ [0.000000,0.000000,0.000000]
"---------------------------------------------------------------------------"
ClassOf: SplineShape
SuperClassOf: shape
No ShowClass for $Editable_Spline:temp_box_marker01 @ [0.000000,0.000000,0.000000]
No Show for $Editable_Spline:temp_box_marker01 @ [0.000000,0.000000,0.000000]
  .steps : integer
  .render_renderable(renderable) : boolean
  .render_mapcoords(mapcoords) : boolean
  .render_viewport_thickness(viewport_thickness) : float
  .render_viewport_sides(viewport_sides) : integer
  .render_viewport_angle(viewport_angle) : float
  .render_displayRenderMesh(displayRenderMesh) : boolean
  .render_useViewportSettings(useViewportSettings) : boolean
  .render_displayRenderSettings(displayRenderSettings) : boolean
  .thickness : float
  .sides : integer
  .angle : float
  .optimize : boolean
  .adaptive : boolean
  .render_viewport_length : float
  .render_viewport_width : float
  .render_viewport_angle2 : float
  .render_rectangular : boolean
  .render_viewport_rectangular : boolean
  .render_aspect_locked : boolean
  .render_viewport_aspect_locked : boolean
  .render_auto_smooth : boolean
  .realWorldMapSize : boolean
  .render_thickness
  .render_sides
  .render_angle
  .render_width
  .render_length
  .render_angle2
  .render_threshold
PROPERTIES:
No Methods for $Editable_Spline:temp_box_marker01 @ [0.000000,0.000000,0.000000]
No Events for $Editable_Spline:temp_box_marker01 @ [0.000000,0.000000,0.000000]
PropNames: #(#steps, #render_renderable, #render_mapcoords, #render_viewport_thickness, #render_viewport_sides, #render_viewport_angle, #render_displayRenderMesh, #render_useViewportSettings, #render_displayRenderSettings, #thickness, #sides, #angle, #renderable, #mapcoords, #viewport_thickness, #viewport_sides, #viewport_angle, #displayRenderMesh, #useViewportSettings, #displayRenderSettings, ...)
No Interface for $Editable_Spline:temp_box_marker01 @ [0.000000,0.000000,0.000000]
No Constructors for $Editable_Spline:temp_box_marker01 @ [0.000000,0.000000,0.000000]
No GetInterface for $Editable_Spline:temp_box_marker01 @ [0.000000,0.000000,0.000000]

fn optimizeSpline num:2 = --optimizeSpline num:2 
(
	local obj = selection[1]
	if classOf obj != SplineShape do return false
	local verts = numKnots obj 1
	--for v=1 to verts by num do deleteKnot obj 1 v
	for v=verts to 1 by (num* -1)  do deleteKnot obj 1 v
)

 optimizeSpline num:2 
-------------------

	fn drawLineBetweenTwoPoints p1 p2 =
	(
		local ss = SplineShape pos:p1
		addNewSpline ss
		addKnot ss 1 #corner #line p1
		addKnot ss 1 #corner #line p2
		updateShape ss
		return ss
	)

newSpline = drawLineBetweenTwoPoints [0,0,0] [100,0,0]
drawLineBetweenTwoPoints selection[1].pos selection[2].pos
--delete newSpline
-------------------

fn createLineFrom arr_points =
(
	local ss = SplineShape pos:arr_points[1]
	addNewSpline ss
	for i=2 to arr_points.count do
	(
	 	addKnot ss 1 #corner #line arr_points[i]
	)
	updateshape ss
)


createLineFrom arr_points




--Returns the number of knots (also known vertices or control points) in the indexed spline as an integer. 
--If the spline index is not specified, returns the number of knots in the entire shape.
numKnots $
--Returns the number of spline curves in the shape as an integer. Equivalent to <shape>.numSplines.
numSplines $
--Returns the indices of the selected splines in the shape as an array of integers.
getSplineSelection $ 
--Returns the number of line segments in the indexed spline as an integer. 
--This is the same as the number of knots for closed splines and 1 less for open splines.
numSegments $ 1
--Returns the indices of the selected segments in the specified shape spline as an array of integers.
getSegSelection $ 1 -- <shape>
getKnotSelection $ 3 -- <shape>


getSegLengths $ 1

-- Create a single cycle sinewave spline
-- Jim Hawkins www.j-hawkins.com
sinline = splineshape()
addnewspline sinline
knot_interval = 20
sine_amplitude = 100 
for x = 0 to 360 by knot_interval do
(
    y = sine_amplitude * sin(x)
    addknot sinline 1 #smooth #curve [x, y, 0]
)
updateshape sinline 


fn rebuildSpline type:#corner = --#smooth | #corner | #bezier | #bezierCorner
(
	local obj = selection[1]
	if classOf obj != SplineShape do return false
    local points_array = mcCreate.pointsFromSpline obj
	mcCreate.splineFromPoints points_array type:type
)
rebuildSpline type:#smooth



--draw a circle
circleline = splineshape()
addnewspline circleline
knot_interval = 20
circle_radius = 100 
for angle = 0 to (360 - knot_interval) by knot_interval do
(
    x = circle_radius * sin(angle)
    y = circle_radius * cos(angle) 
    addknot circleline 1 #smooth #curve [x, y, 0]
)
close circleline 1
updateshape circleline 


-- Gear spline
-- First UI Version
-- Jim Hawkins 4/5/2002

utility gear_shape "Gear Shape"
(
    button go "Start" width:120 tooltip:"Start Gear Creation"
    spinner num_teeth_spinner "Number of Teeth" range:[1,100,10] type:#integer
    spinner radius_spinner "Base Radius" range:[10,1000,100] type:#float
    spinner tooth_size_spinner "Tooth Size" range:[10,1000,40] type:#float


    ------------------------------------------------------------
    -- Creates a half sin wave with the positive peaks clipped
    -- between the angles boundaries defined by tipwidth
    -- angle is in degrees
    -- tipwidth is in degrees
    ------------------------------------------------------------
    fn gear_tooth angle tipwidth =
    (
        while angle > 360 do
        (
            angle -= 360
        )

        if angle >= (90 - tipwidth/2) then
        (
            if angle <= (90 + tipwidth/2) then
            (
                return_value = sin(90 - tipwidth/2)
            )
            else if angle > 180 then
            (
                return_value = 0
            )
            else
            (
                return_value = sin(angle)
            )
        )
        else
        (
            return_value = sin(angle)
        )
        return_value
    )

--------------------------------------------- 
-- Things happen when the button is pressed
---------------------------------------------
    on go pressed do
    (
        clearlistener()
        gearline = splineshape()
        addnewspline gearline
        base_radius = radius_spinner.value -- Get spinner value
        tooth_amplitude = tooth_size_spinner.value -- Get spinner value
        num_petals = num_teeth_spinner.value -- Get spinner value 
        knots_per_tooth = 18
        knot_interval = 360 / (num_petals * knots_per_tooth)
        if knot_interval < 1 then
        knot_interval = 1
        for angle = 0 to (360 - knot_interval) by knot_interval do
        (
            circle_radius = base_radius + tooth_amplitude * gear_tooth (angle * num_petals) 90
            x = circle_radius * sin(angle)
            y = circle_radius * cos(angle) 
            addknot gearline 1 #smooth #curve [x, y, 0]
        )
        close gearline 1
        updateshape gearline
    ) 
) 

