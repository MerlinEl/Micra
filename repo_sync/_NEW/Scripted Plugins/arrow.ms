plugin simpleSpline arrow
	name:"Arrow"
	classID:#(0x2820e52d, 0x2410b5)
	category:"Examples"
	usePBValidity:true
(
	local kappa = 4 * (sqrt 2 - 1) / 3
	local origin = Point3 0 0 0
	local initialized = false
	local prevTime = currentTime

	local vector3 = dotNetClass "Autodesk.Max.MaxPlus.Point3"
	local splineKnot = dotNetClass "Autodesk.Max.MaxPlus.SplineKnot"
	local bezierKnot = (dotNetClass "Autodesk.Max.MaxPlus.SplineKnot+KnotType").BezierKnot
	local curveLine = (dotNetClass "Autodesk.Max.MaxPlus.SplineKnot+LineType").CurveLineType
	local bezierShapeClass = dotNetClass "Autodesk.Max.MaxPlus.BezierShape"

	fn filterShapes obj =
		isKindOf obj Shape

	fn vec3 x y z =
		dotNetObject vector3 x y z

	fn getSplineKnot pos inVec outVec =
		dotNetObject splineKnot bezierKnot curveLine pos inVec outVec

	fn getFlatCornerKnot pos =
		getSplineKnot (vec3 pos.x pos.y 0) (vec3 pos.x pos.y 0) (vec3 pos.x pos.y 0)

	fn adjustBy angle =
		if angle < 90 then 0 else 0.23 * (angle - 90) / 90.

	fn getAngleMultiplier dotProd =
		(1 + 1 / (tan (acos (amax dotProd -1) / 2))^2)^0.5

	fn getPlanarOrthoVec vec =
		normalize [vec.y, -vec.x, 0.0]

	fn getDirVec inSpline seg param =
		getPlanarOrthoVec (tangentBezier3D inSpline 1 seg param pathParam:true)

	fn getTanMult inSpline seg knotCount v1 v2 =
		if seg == 0 OR seg == knotCount then 0 \
		else this.getCurveLenMult inSpline seg v1 v2 knotCount

	fn getTanVec inSpline knot knotCount knotPos param =
		if param >= 0.99 AND knot == 1 then -normalize (getOutVec inSpline 1 knot - knotPos) \
		else if param <= 0.01 AND knot == knotCount then -normalize (getInVec inSpline 1 knot - knotPos) \
		else normalize (interpBezier3D inSpline 1 (int(knot - param + 1e-2)) param pathParam:true - knotPos)

	fn getAdjustedDir inSpline knot knotCount knotPos =
	(
		local inVec = getTanVec inSpline knot knotCount knotPos 0.99
		local outVec = getTanVec inSpline knot knotCount knotPos 0.01

		getPlanarOrthoVec (outVec - inVec) * getAngleMultiplier (dot inVec outVec)
	)

	fn getCurveLenMult inSpline seg v1 v2 knotCount offset:1.0 steps:5 =
	(
		local baseLen = 0, offsetLen = 0
		local prevPos = interpBezier3D inSpline 1 seg v1
		local prevOffsetPos = prevPos + offset * getAdjustedDir inSpline (int(seg + v1 + 1e-2)) knotCount prevPos
		local step = (v2 - v1) / steps

		for i = 1 to steps do
		(
			local dir = getDirVec inSpline seg (v1 + i * step)
			local pos = interpBezier3D inSpline 1 seg (v1 + i * step) pathParam:true
			local offsetPos = pos + offset * dir

			baseLen   += distance pos prevPos
			offsetLen += distance offsetPos prevOffsetPos

			prevPos = pos
			prevOffsetPos = offsetPos
		)
		-1 + offsetLen / baseLen
	)

	fn updateSplineOffsetData inSpline =
	(
		this.splineData = #()
		local knotCount = numKnots inSpline 1
		local multTM = inverse inSpline.transform
		local rotTM = matrix3 multTm.row1 multTm.row2 multTm.row3 [0, 0, 0]

		for knot = 1 to knotCount do
		(
			local knotPos = getKnotPoint inSpline 1 knot
			local offsetDir = getAdjustedDir inSpline knot knotCount knotPos * rotTM
			local inVec = if knot == 1 then [0, 0] else (getInVec inSpline 1 knot - knotPos) * rotTM
			local outVec = if knot == knotCount then [0, 0] else (getOutVec inSpline 1 knot - knotPos) * rotTM

			append this.splineData (knotPos * multTM).x
			append this.splineData (knotPos * multTM).y

			append this.splineData offsetDir.x
			append this.splineData offsetDir.y

			append this.splineData (getTanMult inSpline (knot - 1) knotCount 0.9999 0.5)
			append this.splineData (getTanMult inSpline knot knotCount 0.0001 0.5)

			append this.splineData inVec.x
			append this.splineData inVec.y

			append this.splineData outVec.x
			append this.splineData outVec.y
		)
	)

	fn makeArrowShape angle offset size length addNext =
	(
		local pts = #([0, .25, 0], [0, .5, 0], [.5, 0, 0], [0, -.5, 0], [0, -.25, 0])
		local rot = quat angle z_axis
		local dir = x_axis * rot

		if length > 0 do addNext (getFlatCornerKnot (offset + pts[1] * size * rot))
		for pt in pts do addNext (getFlatCornerKnot (offset + pt * size * rot + length * dir))
		if length > 0 do addNext (getFlatCornerKnot (offset + pts[pts.count] * size * rot))
	)

	fn makeArcShape angle radius dir addNext =
	(
		local bez = angle * kappa / 90 + adjustBy angle
		local radVec = x_axis * quat (angle - 90) z_axis * [dir, 1, 0]
		local radX = radius * radVec.x
		local radY = radius * radVec.y
		local radXY = radX - radius * dir * bez * radVec.y
		local radYX = radY + radius * dir * bez * radVec.x

		addNext (getSplineKnot (vec3 radX radY 0) (vec3 radX radY 0) (vec3 radXY radYX 0))
		addNext (getSplineKnot (vec3 0. radius 0) (vec3 (bez * dir * radius) radius 0) (vec3 (-bez * dir * radius) radius 0))
		addNext (getSplineKnot (vec3 -radX radY 0) (vec3 -radXY radYX 0) (vec3 -radX radY 0))
	)

	fn makeOffsetShape offset dir addNext =
	(
		local start = 0, end = this.splineData.count - 10
		if dir < 0 do swap start end

		for i = start to end by dir * 10 do
		(
			local knotPosX = this.splineData[i + 1] + offset * this.splineData[i + 3]
			local knotPosY = this.splineData[i + 2] + offset * this.splineData[i + 4]
			local inMult = 1 + offset * this.splineData[i + 5]
			local outMult = 1 + offset * this.splineData[i + 6]
			local inVec = vec3 (knotPosX + this.splineData[i + 7] * inMult) (knotPosY + this.splineData[i + 8] * inMult) 0
			local outVec = vec3 (knotPosX + this.splineData[i + 9] * outMult) (knotPosY + this.splineData[i + 10] * outMult) 0
			if dir < 0 do swap inVec outVec

			addNext (getSplineKnot (vec3 knotPosX knotPosY 0) inVec outVec)
		)
	)

	fn updateCurve obj =
	(
		updateSplineOffsetData obj
		this.rebuildShape()
	)

	parameters main rollout:params
	(
		size default:5 type:#worldUnits animatable:true ui:(spnSizeSingle, spnSizeDouble, spnSizeCross, spnSizeArc, spnSizeCustom)
		width default:5 type:#worldUnits animatable:true ui:(spnWidthSingle, spnWidthDouble, spnWidthCross)
		length default:5 type:#worldUnits animatable:true ui:spnLength
		radius default:5 type:#worldUnits animatable:true ui:spnRadius
		angle default:90 type:#float animatable:true ui:spnAngle
		arrowType default:1 type:#radiobtnIndex animatable:false ui:rbArrowType
		arrowState default:3 type:#radiobtnIndex animatable:false ui:(rbArrowState, rbArrowEnds)
		splineData type:#floatTab tabSize:0 tabSizeVariable:true animatable:false invisibleInTV:true
		curve type:#node ui:pbCurve

		on size set val do if initialized do this.rebuildShape()
		on width set val do if initialized do this.rebuildShape()
		on length set val do if initialized do this.rebuildShape()
		on radius set val do if initialized do this.rebuildShape()
		on angle set val do if initialized do this.rebuildShape()
		on arrowType set val do if initialized do this.rebuildShape()
		on arrowState set val do if initialized do this.rebuildShape()
		on curve set obj do  if initialized AND isValidNode obj do updateCurve obj

		changed default:true type:#boolean invisibleInTV:true
	)

	fn makeArrow addNext =
		makeArrowShape 0 origin size width addNext

	fn makeDoubleArrow addNext =
	(
		makeArrowShape 0 origin size (width / 2) addNext
		makeArrowShape 180 [-width / 2, 0, 0] size 0 addNext
	)

	fn makeCrossArrow addNext =
	(
		makeArrowShape 0 [size / 4, 0, 0] size (width / 2 - size / 4) addNext
		makeArrowShape 90 [0, -length / 2, 0] size 0 addNext
		makeArrowShape 180 [-size / 4, 0, 0] size (width / 2 - size / 4) addNext
		makeArrowShape 270 [0, length / 2, 0] size 0 addNext
	)

	fn makeRotArrow addNext =
	(
		local refAng = 180 - angle / 2

		if bit.get arrowState 1 do makeArrowShape (angle / 2) [-radius * sin refAng, radius * cos refAng, 0] size 0 addNext
		makeArcShape refAng (radius + size / 4) -1 addNext
		if bit.get arrowState 2 do makeArrowShape refAng [radius * sin refAng, radius * cos refAng, 0] size 0 addNext
		makeArcShape refAng (radius - size / 4) 1 addNext
	)

	fn makeCustomArrow addNext = if isValidNode curve do
	(
		local last = splineData.count - 10

		if bit.get arrowState 1 do makeArrowShape (atan2 splineData[10] -splineData[9]) [splineData[1], splineData[2], 0] size 0 addNext
		makeOffsetShape (-size / 4) 1 addNext
		if bit.get arrowState 2 do makeArrowShape (atan2 splineData[last + 8] -splineData[last + 7]) [splineData[last + 1], splineData[last + 2], 0] size 0 addNext
		makeOffsetShape (size / 4) -1 addNext
	)

	fn rebuildShape =
	(
		local shapeWrapper = bezierShapeClass._CreateWrapperFromFPValue BezierShape
		shapeWrapper.NewShape()
		local spline = shapeWrapper.NewSpline()

		case arrowType of
		(
			1: makeArrow spline.AddKnot
			2: makeDoubleArrow spline.AddKnot
			3: makeCrossArrow spline.AddKnot
			4: makeRotArrow spline.AddKnot
			5: makeCustomArrow spline.AddKnot
		)

		spline.SetClosed()
		shapeWrapper.UpdateSels()
		shapeWrapper.InvalidateGeomCache()
		updateShape
		prevTime = currentTime
		changed = false
		OK
	)

	rollout params "Parameters"
	(
		radioButtons rbArrowType labels:#("Single", "Double", "Cross", "Arc", "Custom: ") columns:1 align:#left offsets:#([0,0], [0,60], [0,117], [0,194], [0,325])

		spinner spnSizeSingle "Size: " range:[1e-9, 1e9, 5] offset:[0,-380] type:#worldUnits
		spinner spnWidthSingle "Width: " range:[1e-9, 1e9, 5] type:#worldUnits

		spinner spnSizeDouble "Size: " range:[1e-9, 1e9, 5] offset:[0, 30] type:#worldUnits
		spinner spnWidthDouble "Width: " range:[1e-9, 1e9, 5] type:#worldUnits

		spinner spnSizeCross "Size: " range:[1e-9, 1e9, 5] offset:[0, 30] type:#worldUnits
		spinner spnWidthCross "Width: " range:[1e-9, 1e9, 5] type:#worldUnits
		spinner spnLength "Length: " range:[1e-9, 1e9, 5] type:#worldUnits

		spinner spnSizeArc "Size: " range:[1e-9, 1e9, 5] offset:[0, 30] type:#worldUnits
		spinner spnRadius "Radius: " range:[1e-9, 1e9, 5] type:#worldUnits
		spinner spnAngle "Angle: " range:[1e-9, 360, 90] type:#float
		label lblArrowState "Arrow: " align:#right offset:[-3, 0] across:2
		radioButtons rbArrowState labels:#(" Left", " Right", " Both") offset:[-10, 0] columns:1

		pickButton pbCurve "None" width:75 offset:[35, 8] autoDisplay:true filter:filterShapes
		spinner spnSizeCustom "Size: " range:[1e-9, 1e9, 5] type:#worldUnits
		label lblArrowEnds "Arrow: " align:#right offset:[-3, 0] across:2
		radioButtons rbArrowEnds labels:#(" Start", " End", " Both") offset:[-10, 0] columns:1

		button lineDouble pos:[0, 75] width:161 height:1 enabled:false
		button lineCross pos:[0, 147] width:161 height:1 enabled:false
		button lineArc pos:[0, 240] width:161 height:1 enabled:false
		button lineCustom pos:[0, 385] width:161 height:1 enabled:false
	)

	tool create numPoints:3
	(
		on mousePoint click do
			if click == 1 do nodeTM.translation = worldPoint

		on mouseMove click do case click of
		(
			2: width = length = radius = gridDist.x
			3: size = (gridDist.x^2 + gridDist.y^2)^.5
		)
	)

	on create do initialized = false
	on postCreate do initialized = true
	on buildShape do if changed OR prevTime != currentTime do rebuildShape()
)
