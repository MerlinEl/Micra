fn computeTangentSpace_terathon obj = (

local theMesh = snapshotAsMesh obj

local tSpace = #()

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

return tSpace
)

fn showTangentSpace tSpace axisLength = 
(
	local worldMat = inverse (viewport.getTM())
	
	gw.setTransform (matrix3 1)
	
	for nFace = 1 to tSpace.count do 
	(
		local tbn = tSpace[nFace]
		
		if (dot tbn.row3 worldMat.row3) >= 0.0 do 
		(
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
)

showTangentSpace (computeTangentSpace_terathon $) 10