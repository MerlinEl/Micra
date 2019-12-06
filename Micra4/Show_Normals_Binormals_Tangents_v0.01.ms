/**
*@Author HalfVector 2006
*@Modify by MerlinEl 2019
*@Source https://forums.cgsociety.org/t/finding-bi-normals-tangents/975005/5
*@Usage > Show  tangents, binnormals and normals on object faces
	tangent		RED
	binormal	GREEN
	normal		BLUE
*/
if isStruct gTangentNormalBinormal do gTangentNormalBinormal.stopTrace()
struct sTangentNormalBinormal  (
	
	axisLength,
	tSpace,
	TangentNormalBinormalCallbacks,
	isRunning = false,
	fn showTangentSpace = (
		
		if classOf tSpace != Array do return false
		local worldMat = inverse (viewport.getTM())
		gw.setTransform (matrix3 1)	
		for nFace = 1 to tSpace.count do (
			
			local tbn = tSpace[nFace]
			if (dot tbn.row3 worldMat.row3) >= 0.0 do (
				
				gw.setColor #line red
				gw.polyLine #( tbn.row4, (tbn.row4 + tbn.row1 * axisLength) ) false
				gw.setColor #line green
				gw.polyLine #( tbn.row4, (tbn.row4 + tbn.row2 * axisLength) ) false
				gw.setColor #line blue
				gw.polyLine #( tbn.row4, (tbn.row4 + tbn.row3 * axisLength) ) false	
			)
		)
		gw.enlargeUpdateRect #whole 
		gw.updateScreen()
	),
	fn computeTangentSpace obj = (

		local theMesh = snapshotAsMesh obj
		tSpace = #()
		for nFace = 1 to theMesh.numFaces do (
			local face = getFace theMesh nFace
			local tface = getTVFace theMesh nFace
			
			local v1 = getVert theMesh face[1]
			local v2 = getVert theMesh face[2]
			local v3 = getVert theMesh face[3]
			
			local w1 = getTVert theMesh tface[1]
			local w2 = getTVert theMesh tface[2]
			local w3 = getTVert theMesh tface[3]

			local x1 = v2.x - v1.x
			local x2 = v3.x - v1.x
			local y1 = v2.y - v1.y
			local y2 = v3.y - v1.y
			local z1 = v2.z - v1.z
			local z2 = v3.z - v1.z

			local s1 = w2.x - w1.x
			local s2 = w3.x - w1.x
			local t1 = w2.y - w1.y
			local t2 = w3.y - w1.y
			
			local r = 1.0 / (s1 * t2 - s2 * t1)

			local tan1 = [(t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r]
			local tan2 = [(s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r]
			local normal = normalize (getFaceNormal theMesh nFace)
			local tangent = normalize (tan1 - normal * (dot normal tan1))
			local handedness = if (dot (cross normal tan1) tan2) < 0.0 then -1.0 else 1.0
			local binormal = (normalize (cross normal tangent)) * handedness
			local fCenter = meshOp.getFaceCenter theMesh nFace
			append tSpace (Matrix3 tangent binormal normal fCenter)
		)
		delete theMesh
	),
	fn selectionChanged ev nd = (
		
		--format "selection:% event:%\n" nd ev
		local obj = selection[1]
		if classOf obj != Editable_Poly do (
			
			::gTangentNormalBinormal.tSpace = undefined
			return false
		)
		::gTangentNormalBinormal.computeTangentSpace obj	
	),
	fn unregister = (
		
		unRegisterRedrawViewsCallback showTangentSpace --simple prevent double run
		TangentNormalBinormalCallbacks = undefined --unregister selection change callbacks
		gc light:true
		completeRedraw()
		isRunning = false
	),
	fn register = (

		unregister()
		TangentNormalBinormalCallbacks = NodeEventCallback mouseUp:true delay:1000 \
		selectionChanged:selectionChanged \
		geometryChanged:selectionChanged \
		deleted:selectionChanged 
		
		registerRedrawViewsCallback showTangentSpace
		completeRedraw()
		selectionChanged undefined undefined
		isRunning = true
	),
	fn startTrace = (register()),
	fn stopTrace = (unregister()),
	fn switchEnabled = (
		
		if isRunning then stopTrace() else startTrace()
	),	
	on create do (
		
			format "created..\n"
	)
)
Global gTangentNormalBinormal = sTangentNormalBinormal 300 --set axis length to 300
/*
 gTangentNormalBinormal.startTrace()
*/


/*
I forgot that when you clone an object using the mirror tool, the faces and normals must be flipped. 
So I’ve modified the two versions of the script…again.

Version #1
fn computeTangentSpace obj = (

	local theMesh = snapshotAsMesh obj
	
	local tSpace = #()

	-- Do we have to flip faces?
	local flip = false
	local indices = #(1, 2, 3)
	if dot (cross obj.transform.row1 obj.transform.row2) obj.transform.row3 <= 0 do (
		indices[2] = 3
		indices[3] = 2
		flip = true
	)

	for nFace = 1 to theMesh.numFaces do (
		local face = getFace theMesh nFace
		local tface = getTVFace theMesh nFace
		
		local v1 = getVert theMesh face[indices[1]]
		local v2 = getVert theMesh face[indices[2]]
		local v3 = getVert theMesh face[indices[3]]
		
		local uv1 = getTVert theMesh tface[indices[1]]
		local uv2 = getTVert theMesh tface[indices[2]]
		local uv3 = getTVert theMesh tface[indices[3]]
		
		local dV1 = v1 - v2
		local dV2 = v1 - v3

		local dUV1 = uv1 - uv2
		local dUV2 = uv1 - uv3
		
		local area = dUV1.x * dUV2.y - dUV1.y * dUV2.x
		local sign = if area < 0 then -1 else 1
		
		local tangent = [0,0,1]

		tangent.x = dV1.x * dUV2.y - dUV1.y * dV2.x
		tangent.y = dV1.y * dUV2.y - dUV1.y * dV2.y
		tangent.z = dV1.z * dUV2.y - dUV1.y * dV2.z

		tangent = (normalize tangent) * sign
		local normal = normalize (getFaceNormal theMesh nFace)
		if flip do normal = -normal
		
		local binormal = (normalize (cross normal tangent)) * sign	
		local fCenter = meshOp.getFaceCenter theMesh nFace	
		append tSpace (Matrix3 tangent binormal normal fCenter)
	)
	
	delete theMesh
	
	return tSpace
)

Version #2
fn computeTangentSpace_terathon obj = (

	local theMesh = snapshotAsMesh obj
	
	local tSpace = #()

	-- Do we have to flip faces?
	local flip = false
	local indices = #(1, 2, 3)
	if dot (cross obj.transform.row1 obj.transform.row2) obj.transform.row3 <= 0 do (
		indices[2] = 3
		indices[3] = 2
		flip = true
	)
	
	for nFace = 1 to theMesh.numFaces do (
		local face = getFace theMesh nFace
		local tface = getTVFace theMesh nFace
		
		local v1 = getVert theMesh face[indices[1]]
		local v2 = getVert theMesh face[indices[2]]
		local v3 = getVert theMesh face[indices[3]]
		
		local w1 = getTVert theMesh tface[indices[1]]
		local w2 = getTVert theMesh tface[indices[2]]
		local w3 = getTVert theMesh tface[indices[3]]

		local x1 = v2.x - v1.x
		local x2 = v3.x - v1.x
		local y1 = v2.y - v1.y
		local y2 = v3.y - v1.y
		local z1 = v2.z - v1.z
		local z2 = v3.z - v1.z

		local s1 = w2.x - w1.x
		local s2 = w3.x - w1.x
		local t1 = w2.y - w1.y
		local t2 = w3.y - w1.y
		
		local r = 1.0 / (s1 * t2 - s2 * t1)

        local tan1 = [(t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r]
        local tan2 = [(s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r]

		local normal = normalize (getFaceNormal theMesh nFace)
		if flip do normal = -normal
		
		local tangent = normalize (tan1 - normal * (dot normal tan1))
		local handedness = if (dot (cross normal tan1) tan2) < 0.0 then -1.0 else 1.0
		local binormal = (normalize (cross normal tangent)) * handedness
		local fCenter = meshOp.getFaceCenter theMesh nFace
		append tSpace (Matrix3 tangent binormal normal fCenter)
	)
	delete theMesh
	return tSpace
)
*/