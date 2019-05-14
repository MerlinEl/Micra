if isKindOf $ Shape do
(
	local obj = $
	local master = obj.baseObject[#Master]
	animateVertex obj #all

	TMDef = attributes pointTM attribID:#(0x174e3aa5, 0x67203398) \
			(parameters data (pos type:#point3; invTM type:#matrix3))

	fn getMatricesAlongSplineCurve spl curve count closed: =
	(
		local lastTangent = tangentCurve3D spl curve 0
		local lastRot = arbAxis lastTangent as quat
		local step = 1d0 / (count - (if closed then 0 else 1))

		for i = 0 to count collect
		(
			local location = interpCurve3D spl curve (i * step) pathParam:on
			local tangent = tangentCurve3D spl curve (i * step) pathParam:on

			local axis = normalize (cross tangent lastTangent)
			local theta = acos (dot tangent lastTangent)
			local rotation = quat theta axis

			lastTangent = tangent
			lastRot *= rotation
			translate (lastRot as matrix3) location
		)
	)

	fn addCtrl subAnim obj pt =
	(
		local ctrl = Point3_Script()
		custAttributes.add ctrl TMDef

		subAnim.controller = ctrl
		ctrl.addObject #pt (NodeTransformMonitor node:pt)
		ctrl.addObject #master (NodeTransformMonitor node:obj)
		ctrl.script = "if isValidNode pt do this.pos = pt.objectTransform.pos\n" + \
			"if isValidNode master do this.invTM = inverse master.objectTransform\n" + \
			"this.pos * this.invTM"
	)

	for spl = 1 to numSplines obj do
	(
		local knotCount = numKnots obj spl
		local knotTMs = getMatricesAlongSplineCurve obj spl knotCount closed:(isClosed obj spl)

		for knot = 1 to knotCount do
		(
			local knotPos = master["Spline_" + spl as string + "___Vertex_" + knot as string]
			local knotInVec = master["Spline_" + spl as string + "___InVec_" + knot as string]
			local knotOutVec = master["Spline_" + spl as string + "___OutVec_" + knot as string]

			local posPt = in obj Point prefix:"Knot" wirecolor:green cross:on box:off transform:knotTMs[knot]
			addCtrl knotPos obj posPt

			if getKnotType obj spl knot != #corner do
			(
				addCtrl knotInVec obj (in posPt Point prefix:"Tangent" wirecolor:green cross:off box:off centerMarker:on pos:(knotInVec.value * obj.objectTransform))
				addCtrl knotOutVec obj (in posPt Point prefix:"Tangent" wirecolor:green cross:off box:off centerMarker:on pos:(knotOutVec.value * obj.objectTransform))
			)
		)
	)
)
