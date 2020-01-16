/**
*@Author d3coy 2006
*@Mod Merlin El 2020
*/
fn getBoundingBoxFromVerts obj verts = (
	 
	if classof obj != Editable_Poly do return false
	verts  = verts as array	
	local verts_pos = for v in verts collect polyop.getvert obj v
	local verts_count = verts.count
	local avg_pos = [0,0,0]
	local zComp = #()
	local xComp = #()
	local yComp = #()
	zComp[verts_count] = xComp[verts_count] = yComp[verts_count] = undefined
	local zMax, zMin, xMax, xMin, yMax, yMin, xVect, yVect, zVect, theMatrix,
		  theLength, theWidth, theHeight, xAmt, yAmt, zAmt, zMaxHold, zMinHold
	
	--Get average position
	for v in verts_pos do avg_pos += v
	avg_pos /= verts_count
	
	--Get farthest vert
	for x = 1 to verts_count do
		zComp[x] = distance avg_pos verts_pos[x]
	
	zMaxHold = verts[(finditem zComp (amax zComp))]
	zMax = polyop.getvert obj zMaxHold
	
	--Get farthest vert from farthest vert (the 2 extremes)
	for x = 1 to verts_count do
		zComp[x] = distance zMax verts_pos[x]
	
	zMinHold = verts[(finditem zComp (amax zComp))]
	zMin = polyop.getvert obj zMinHold
	
	--Construct matrix from vectors
	zVect = normalize (zMax - zMin)
	xVect = normalize (cross [0,0,1] zVect)
	yVect = normalize (cross xVect zVect)
	theMatrix = matrix3 xVect yVect zVect [0,0,0]
	
	--Determine dimensions and construct box
	in coordsys theMatrix
	(		
		for x = 1 to verts_count do
		(
			thePos = polyop.getvert obj verts[x]
			xComp[x] = thePos.x
			yComp[x] = thePos.y
		)
		
		xMax = polyop.getvert obj verts[(finditem xComp (amax xComp))]
		xMin = polyop.getvert obj verts[(finditem xComp (amin xComp))]
		yMax = polyop.getvert obj verts[(finditem yComp (amax yComp))]
		yMin = polyop.getvert obj verts[(finditem yComp (amin yComp))]
		zMax = polyop.getvert obj zMaxHold
		zMin = polyop.getvert obj zMinHold
		
		xAmt = ((xMax + xMin) / 2.).x
		yAmt = ((yMax + yMin) / 2.).y
		zAmt = ((zMax + zMin) / 2.).z
		
		theWidth = xMax.x - xMin.x
		theLength = yMax.y - yMin.y
		theHeight = distance zMax zMin
	)
	
	theBox = box width:theWidth length:theLength height:theHeight xray:true
	theBox.pivot = theBox.center
	theBox.transform = theMatrix
	
	in coordsys theMatrix(move theBox [xAmt, yAmt, zAmt])
	completeredraw()
	theBox
)
 
 
obj = $
esel =  polyOp.getEdgeSelection obj
verts = polyOp.getVertsUsingEdge obj esel
bo = getBoundingBoxFromVerts obj verts
 
 
 