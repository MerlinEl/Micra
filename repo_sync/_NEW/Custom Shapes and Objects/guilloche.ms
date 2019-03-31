plugin simpleSpline guilloche
	name:"Guilloche"
	classID:#(0x2820e52d, 0x7368795a)
	category:"Examples"
	usePBValidity:true
(
	local twoPi = double 2 * pi
	local vector3 = dotNetClass "Autodesk.Max.MaxPlus.Point3"
	local bezierShapeClass = dotNetClass "Autodesk.Max.MaxPlus.BezierShape"
	local splineKnot = dotNetClass "Autodesk.Max.MaxPlus.SplineKnot"
	local cornerKnot = (dotNetClass "Autodesk.Max.MaxPlus.SplineKnot+KnotType").CornerKnot
	local smoothKnot = (dotNetClass "Autodesk.Max.MaxPlus.SplineKnot+KnotType").AutoKnot 
	local curveLine = (dotNetClass "Autodesk.Max.MaxPlus.SplineKnot+LineType").CurveLineType
	local initialized = true

	fn vec2 x y =
		dotNetObject vector3 x y 0

	fn getSplineKnot pos inVec outVec knotType =
		dotNetObject splineKnot knotType curveLine pos inVec outVec

    parameters main rollout:params
	(
		radius default:4 type:#worldUnits animatable:true ui:spnRadius
		majorRadius default:9 type:#worldUnits animatable:true ui:spnMajorRadius
		minorRadius default:2 type:#worldUnits animatable:true ui:spnMinorRadius
		steps default:100 type:#integer animatable:true ui:spnSteps
		offset default:115 type:#float animatable:true ui:spnOffset  -- spis nez offset je to delka spline; nebo spis krok po kterym se vypocitavaji dalsi body, n'est-ce pas?
		knotType default:2 type:#radiobtnIndex ui:rbKnotType

		on radius set val do if initialized do this.rebuildShape()
		on majorRadius set val do if initialized do this.rebuildShape()
		on minorRadius set val do if initialized do this.rebuildShape()
		on steps set val do if initialized do this.rebuildShape()
		on offset set val do if initialized do this.rebuildShape()
		on knotType set val do if initialized do this.rebuildShape()

		changed default:true type:#boolean
	)

	fn makeGuilloche addNext =
	(
		local step = twoPi / steps
		local outerRadius = minorRadius + radius
		local sum = majorRadius + minorRadius
		local proportion = double sum / minorRadius
		local type = if knotType < 2 then cornerKnot else smoothKnot 

		for subStep = .0d0 to 2*pi by step do -- nutno urcit spravnou horni hranici a nejspis exitnout pres while...
		(
			local theta = subStep * offset -- jake rozmezi, aby to opsalo cely tvar a neopakovalo se???
			local pos = vec2 (sum * cos(theta) + outerRadius * cos(proportion * theta)) \
			                 (sum * sin(theta) + outerRadius * sin(proportion * theta))

			addNext (getSplineKnot pos pos pos type)
		)
	)

	fn rebuildShape =
	(
		local shapeWrapper = bezierShapeClass._CreateWrapperFromFPValue BezierShape
		shapeWrapper.NewShape()
		local spline = shapeWrapper.NewSpline()
		makeGuilloche spline.AddKnot
		shapeWrapper.UpdateSels()
		shapeWrapper.InvalidateGeomCache()
		updateShape
	)

	rollout params "Parameters"
	(
		spinner spnRadius "Radius: " range:[0, 1e9, 10] type:#worldUnits
		spinner spnMajorRadius "Major radius: " range:[-1e9,1e9,90] type:#worldUnits
		spinner spnMinorRadius "Minor radius: " range:[-1e9,1e9,20] type:#worldUnits
		spinner spnSteps "Steps:" range:[1,1e3,400] type:#integer
		spinner spnOffset "Offset: " range:[1e-9,1e9,200] --type???

		label lblVertexType "Vertex type:"
		radioButtons rbKnotType ""  offsets:#([-10, 0], [10, 0]) labels:#("Corner", "Smooth") default:2
	)

	tool create 
	(
		on mousePoint click do
		(	
			case click of
			(
				1: nodeTM.translation = worldPoint
			)
		)
		on mouseMove click do
		(	
			case click of
			(
				2: radius = (gridDist.y^2+gridDist.x^2)^.5
				3: #stop
			)
		)
	)

	on create do initialized = false
	on postCreate do initialized = true

	on buildShape do
	(
		if changed do 
		(
			rebuildShape()
			changed = false
		)
		OK
	)
)
