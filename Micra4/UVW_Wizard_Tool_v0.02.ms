--Move mapping on object

Global uvWizardTool
Global uvWizardToolActive = true
Global uvWizardToolBreakPoints = 2

-->Tool
tool uvWizardTool  prompt:"Welcome to UV Map Tool" numPoints:3
( 
	local pointA, polyObj, matrix = #(#(),#()), active = false
	fn InitializeMatrix polyObj =
	(
		local mod = polyObj.modifiers[#unwrap_uvw]
		local vertNum = mod.unwrap.NumberVertices()
		
		for i=1 to vertNum do
		(
			mod.unwrap.selectVertices #{i}
			matrix[1] += mod.getSelectedVertices() as array
			matrix[2] += mod.getSelectedGeomVerts() as array
		)
		
		--format "matr1:%\n" matrix[1]
		--format "matr2:%\n" matrix[2]
		
		mod.unwrap.selectVertices #{}
	)
	fn getHitVert polyObj RayInt = --this operation with mesh of (faces:15250 vertices:7627) tok 78 - 94 milisecond
	(
		local vertCount = polyObj.verts.count
		if RayInt == undefined or vertCount == 0 do return undefined
		local dist = (for i=1 to vertCount collect distance (polyOp.getVert polyObj i) RayInt.pos)
		
		local minPickDist = 1
		local minDist     = (amin dist)
		if minPickDist < minDist do (pushPrompt " The selection offset is to low."; return undefined)
		return (findItem dist minDist) --get closest vert in poly
	)

	on start do
	(
		--print "start tool"
		polyObj = $
		InitializeMatrix polyObj
	)
	on mousePoint clickno do
	(			
		if clickno == 1 then 
		(
			--print "first click"
		)
		else
		(
			RayP = mapScreenToWorldRay viewPoint
			RayInt = intersectRay $ RayP
			pointA = viewPoint
			active = not active
			
			PolyVert = getHitVert polyObj RayInt
			if PolyVert != undefined do
			(				
				MapVert  = #{matrix[1][findItem matrix[2] PolyVert]}
			
				--format "PolyVert:%\tMapVert:%\n" PolyVert MapVert
				
				if MapVert.numberset != 0 do
				( 
					$.modifiers[#unwrap_uvw].unwrap.selectVertices MapVert
					uvWizardToolBreakPoints = 2
				)
			)
			
			--format "breakpoints:%\n" uvWizardToolBreakPoints

		)
	)
	on mouseMove clickno do undo off
	(
		if clickno == 1 then 
		(
			--print "drag begin"
		)
		else
		(
			if pointA != undefined and active do
			(
				newPos = pointA - viewPoint
				$.modifiers[#unwrap_uvw].unwrap2.moveSelected [newPos.x/100000,-newPos.y/100000,0]
			)
		)	
	)
	on stop do
	(
 		--print "stop"
		uvWizardToolBreakPoints -= 1 
		--format "breakpoints:%\n" uvWizardToolBreakPoints
		if uvWizardToolBreakPoints < 1 do uvWizardToolActive = false
 	)
) 

if selection[1] == undefined or classOf selection[1] != PolyMeshObject or classOf (modpanel.getcurrentobject()) != Unwrap_UVW 
then 
(
	uvWizardToolActive = false
)
else
(
	while uvWizardToolActive and (not keyboard.escPressed) do
	(
		startTool uvWizardTool
	)
	stopTool uvWizardTool
)