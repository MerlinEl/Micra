plugin simpleSpline pulleyBelt
	name:"Pulley Belt"
	classID:#(0x2820e52d, 0x26a35901)
	category:"Examples"
	usePBValidity:true
(
	local kappa = 4 * (sqrt 2 - 1)/3
	local bezierShapeClass = dotNetClass "Autodesk.Max.MaxPlus.BezierShape"
	local splineKnot = dotNetClass "Autodesk.Max.MaxPlus.SplineKnot"

	local vector3 = dotNetClass "Autodesk.Max.MaxPlus.Point3"
	local bezierKnot = (dotNetClass "Autodesk.Max.MaxPlus.SplineKnot+KnotType").BezierKnot 
	local curveLine = (dotNetClass "Autodesk.Max.MaxPlus.SplineKnot+LineType").CurveLineType
	local initialized = true

	fn vec3 x y z =
		dotNetObject vector3 x y z

	fn getSplineKnot pos inVec outVec =
		dotNetObject splineKnot bezierKnot curveLine pos inVec outVec

	fn getPointPlaneProjection pos pTM =
		pos + dot (pTM.translation - pos) pTM.row3 * pTM.row3

	fn getExternalHomotheticCenter radius1 radius2 dist =
		dist / (1 - radius2 / radius1)

	fn adjustBy angle =
		if angle < 90 then 0 else 0.23 * (angle - 90)/90.

    parameters main rollout:params
	(
		radius1 default:5 type:#worldUnits animatable:true ui:spnRadius1
		radius2 default:0 type:#worldUnits animatable:true ui:spnRadius2
		width default:1e-9 type:#worldUnits animatable:true ui:spnWidth

		on radius1 set val do if initialized do this.rebuildShape()
		on radius2 set val do if initialized do this.rebuildShape()
		on width set val do if initialized do this.rebuildShape()

		changed default:true type:#boolean invisibleInTV:true
	)

	fn orient &nodeTM pos =
	(
		local projPos = getPointPlaneProjection pos nodeTM
		local x = normalize (projPos - nodeTM.translation)
		local y = cross nodeTM.row3 x 
		nodeTM = matrix3 x y (cross x y) nodeTM.translation
		projPos
	)

	fn makeRoundedTrapezoid addNext =
	(
		local crossDist = getExternalHomotheticCenter radius1 radius2 width
		local angle = asin (radius1 / crossDist) + 90
		local bez1 = angle * kappa / 90 + adjustBy angle
		local bez2 = (180 - angle) * kappa / 90 + adjustBy (180 - angle)
		local tanX = radius1 / crossDist
		local tanY = (1 - tanX^2)^.5

		addNext (getSplineKnot (vec3 -radius1 0 0) \
		                       (vec3 -radius1 (-bez1 * radius1) 0) \
		                       (vec3 -radius1 (bez1 * radius1) 0))
		addNext (getSplineKnot (vec3 (radius1 * tanX) (radius1 * tanY) 0) \
		                       (vec3 (radius1 * (tanX - bez1 * tanY)) (radius1 * (tanY + bez1 * tanX)) 0) \
		                       (vec3 (radius1 * tanX + width / 5 * tanY) (radius1 * tanY - width / 5 * tanX) 0))
		addNext (getSplineKnot (vec3 (width + radius2 * tanX) (radius2 * tanY) 0) \
		                       (vec3 (width + radius2 * tanX - width / 5 * tanY) (radius2 * tanY + width / 5 * tanX) 0) \
		                       (vec3 (width + radius2 * (tanX + bez2 * tanY)) (radius2 * (tanY - bez2 * tanX)) 0))
		addNext (getSplineKnot (vec3 (width + radius2) 0 0) \
		                       (vec3 (width + radius2) (bez2 * radius2) 0) \
		                       (vec3 (width + radius2) (-bez2 * radius2) 0))
		addNext (getSplineKnot (vec3 (width + radius2 * tanX) (-radius2 * tanY) 0) \
		                       (vec3 (width + radius2 * (tanX + bez2 * tanY)) (-radius2 * (tanY - bez2 * tanX)) 0) \
		                       (vec3 (width + radius2 * tanX - width / 5 * tanY) (-radius2 * tanY - width / 5 * tanX) 0))
		addNext (getSplineKnot (vec3 (radius1 * tanX) (-radius1 * tanY) 0) \
		                       (vec3 (radius1 * tanX + width / 5 * tanY) (-radius1 * tanY + width / 5 * tanX) 0) \
		                       (vec3 (radius1 * (tanX - bez1 * tanY)) (-radius1 * (tanY + bez1 * tanX)) 0)) \
	)

	fn rebuildShape =
	(
		local shapeWrapper = bezierShapeClass._CreateWrapperFromFPValue BezierShape
		shapeWrapper.NewShape()
		local spline = shapeWrapper.NewSpline()
		makeRoundedTrapezoid spline.AddKnot
		spline.SetClosed()
		shapeWrapper.UpdateSels()
		shapeWrapper.InvalidateGeomCache()
		updateShape
		changed = false
		OK
	)

	rollout params "Parameters"
	(
		spinner spnRadius1 "Radius 1: " range:[1e-9, 1e9, 5] type:#worldUnits
		spinner spnRadius2 "Radius 2: " range:[1e-9, 1e9, 10] type:#worldUnits
		spinner spnWidth "Width: " range:[1e-9, 1e9, 20] type:#worldUnits
	)

	tool create numPoints:4
	(
		local center

		on mousePoint click do
		(	
			case click of
			(
				1: nodeTM.translation = worldPoint
				3: center = worldPoint
			)
		)	
		on mouseMove click do
		(	
			case click of
			(
				2: radius1 = radius2 = (gridDist.x^2+gridDist.y^2)^.5
				3: width = distance nodeTM.translation (orient &nodeTM worldPoint)
				4: radius2 = distance center worldPoint
			)
		)		
	)

	on create do initialized = false
	on postCreate do initialized = true
	on buildShape do if changed do rebuildShape()
)
