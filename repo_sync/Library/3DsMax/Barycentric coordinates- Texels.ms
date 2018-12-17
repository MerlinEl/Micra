
/*
theFace = meshop.getMapFace theMesh theChannel faceIndex
vert1= meshop.getMapVert theMesh theChannel theFace.x
vert2= meshop.getMapVert theMesh theChannel theFace.y
vert3= meshop.getMapVert theMesh theChannel theFace.z

This gives you the UVW coordinates of the 3 vertices, NOT the pixel values.
You might have to take the min. and max. of these 3 values and convert them into texel values, 
giving you a rectangle of pixels that potentially are within the face, then go through all these pixels, 
calcluate their corresponding UV coordinates and see whether they are inside the triangle or outside 
(possibly by modifying the barycentric coordinates code shown in http://forums.cgsociety.org/showthread.php?t=275372)

*/

   ---------------------------------
 ----------------------------------  
   ----------------------------

theMesh = $Line01         --this is the mesh triangle with just one face
   v1 = getVert theMesh 1  --get the 3 vertices in world space
   v2 = getVert theMesh 2  
   v3 = getVert theMesh 3
   p = $Dummy01.pos        --get the position of the dummy as the point to get the bary coords from
   
   vector1 = p - v1           --this is the vector from vertex 1 to the dummy
   vector2 = p - v2           --this is the vector from vertex 2 to the dummy
   vector3 = p - v3           --this is the vector from vertex 3 to the dummy
   
   
   --because the length of the cross product vector is equal to the area of the parallelogram
   --defined by the two operands, half of it is the area of the triangle!
   area1 = (length (cross vector2 vector3))/2  --this is the area of the first sub-triangle
   area2 = (length (cross vector1 vector3))/2  --this is the area of the second sub-triangle
   area3 = (length (cross vector1 vector2))/2  --this is the area of the third sub-triangle
   
   fullArea = area1 + area2 + area3 --this is the full area of the triangle
   
   b1 = area1 / fullArea  --this is the proportion of the first triangle vs. the full triangle
   b2 = area2 / fullArea  --this is the proportion of the second triangle vs. the full triangle
   b3 = area3 / fullArea  --this is the proportion of the third triangle vs. the full triangle
   
   baryCoords = [b1, b2, b3]  --Behold! Hand-made Barycentric coordinates!!!
   baryfrommesh = meshop.getBaryCoords theMesh 1 p --compare to the MAXScript result...

---OR
   ---------------------------------
 ----------------------------------  
   ----------------------------

theMesh = $NGon01		 --this is the mesh triangle with just one face
   v1 = getVert theMesh 1  --get the 3 vertices in world space
   v2 = getVert theMesh 2  
   v3 = getVert theMesh 3
   p = $Dummy01.pos		--get the position of the dummy as the point to get the bary coords from
   
   vector1 = p - v1		   --this is the vector from vertex 1 to the dummy
   vector2 = p - v2		   --this is the vector from vertex 2 to the dummy
   vector3 = p - v3		   --this is the vector from vertex 3 to the dummy
   
   --Calculate the cross product of the 3 vectors
   theCross1 = (cross vector2 vector3)
   theCross2 = (cross vector3 vector1)
   theCross3 = (cross vector1 vector2)
   
   --calculate the face normal using the cross product of two edges
   theNormal = normalize (cross (v2-v1) (v3-v1))
   
   --because the length of the cross product vector is equal to the area of the parallelogram
   --defined by the two operands, half of it is the area of the triangle!
   area1 = (length theCross1 )/2  --this is the area of the first sub-triangle
   area2 = (length theCross2 )/2  --this is the area of the second sub-triangle
   area3 = (length theCross3 )/2  --this is the area of the third sub-triangle
   
   --calculate the angle of each cross product with the face normal
   angle1 = acos ( dot ( normalize theCross1) theNormal )
   angle2 = acos ( dot ( normalize theCross2) theNormal )
   angle3 = acos ( dot ( normalize theCross3) theNormal )

   --if the angle is different from the other two, take its area as negative
   if angle1 != angle2 and angle1 != angle3 then area1 = -area1
   if angle2 != angle1 and angle2 != angle3 then area2 = -area2
   if angle3 != angle1 and angle3 != angle2 then area3 = -area3
   
   fullArea = area1 + area2 + area3 --this is the full area of the triangle
   
   b1 = area1 / fullArea  --this is the proportion of the first triangle vs. the full triangle
   b2 = area2 / fullArea  --this is the proportion of the second triangle vs. the full triangle
   b3 = area3 / fullArea  --this is the proportion of the third triangle vs. the full triangle
   
   baryCoords = [b1, b2, b3]  --Behold! Hand-made Barycentric coordinates!!!
   baryfrommesh = meshop.getBaryCoords theMesh 1 p --compare to the MAXScript result...
   
   ---------------------------------
 ----------------------------------  
   ----------------------------
--This function simply returns the sum of the intensity/value of each pixel of the map 
--that is in the diffuse color slot for a specified face of a specified mesh.
   
   struct mline
(
slope, -- negative 1 means vertical, and intercept is for x not y
intercept
)
function sumFaceTexturePixels tmesh face=
(
if (face < 0 or face > tmesh.numfaces) then
(
messagebox ("sumFaceTexturePixels: face index out of bounds (" + (face as string) + ")")
return -1;
)
function getSlope a b coords = 
(
if (coords[a].x == coords[b].x) then
return -1 --slope is infinite, vertical line
else
return ((coords[a].y - coords[b].y) / (coords[a].x - coords[b].x))
)
 
function getIntercept a b slope coords =
( 
if (coords[a].x == coords[b].x) then
return coords[a].x --no Y intercept, so give X intercept instead...
else
return (coords[a].y - (slope * coords[a].x))
)
 
--returns the x coord of the line at the y coord
--note: if its a vertical line, the line intercepts the X axis at intercept
-- otherwise, intercept is the Y intercept
function interceptLine y line =
(
 
if (line.slope == -1) then
return line.intercept
else
return (y - line.intercept) / line.slope
) 
 
--get the bmp
tbmp = (getSubTexMap tmesh.material 2).bitmap
 
--gets the indices of the 3 verts using this face
theFace = meshop.getMapFace tmesh 1 face
 
--gets the UV coordinates of each vert
uvCoords = #()
append uvCoords (meshop.getMapVert tmesh 1 theFace.x)
append uvCoords (meshop.getMapVert tmesh 1 theFace.y)
append uvCoords (meshop.getMapVert tmesh 1 theFace.z)
 
--convert the UV coords to absolute bmp coords
bmpCoords = #()
 
for i = 1 to uvCoords.count do
append bmpCoords [uvCoords[i].x * tbmp.width, uvCoords[i].y * tbmp.height]
 
--calculate the left/middle/and right verts of the face triangle
topVert = 1
for i = 2 to uvCoords.count do
(
if uvCoords[i].y > uvCoords[topVert].y then
topVert = i
) 
 
bottomVert = 1
for i = 2 to uvCoords.count do
(
if uvCoords[i].y < uvCoords[bottomVert].y then
bottomVert = i
)
 
middleVert = 1
for i = 2 to uvCoords.count do
(
if topVert == middleVert or bottomVert == middleVert then
middleVert = middleVert + 1
)
 
--perform necessary swaps in order to know which line EQs to use...
 
if ((bmpCoords[topVert].y == bmpCoords[middleVert].y) and (bmpCoords[topVert].x > bmpCoords[middleVert].x)) then
(
temp = topVert
topVert = middleVert
middleVert = temp
)
 
if ((bmpCoords[bottomVert].y == bmpCoords[middleVert].y) and (bmpCoords[bottomVert].x > bmpCoords[middleVert].x)) then
(
temp = bottomVert
bottomVert = middleVert
middleVert = temp
)
 
--ASSERT: if bottom.y == middle.y, then bottom.x < middle.x
--ASSERT: if top.y == middle.y, then top.x < middle.x
edgeLines = #() 
 
--edgeLines[1] = line from top to bottom vert
aslope = (getSlope topVert bottomVert bmpCoords)
aintercept = (getIntercept topVert bottomVert aslope bmpCoords)
aline = mline slope: aslope intercept: aintercept
 
append edgeLines aline
 
--edgeLines[2] = line from top to middle vert
aslope = (getSlope topVert middleVert bmpCoords)
aintercept = (getIntercept topVert middleVert aslope bmpCoords)
aline = mline slope: aslope intercept: aintercept
append edgeLines aline
 
--edgeLines[3] = line from middle to bottom vert
aslope = (getSlope middleVert bottomVert bmpCoords)
aintercept = (getIntercept middleVert bottomVert aslope bmpCoords)
aline = mline slope: aslope intercept: aintercept
append edgeLines aline
 
--determine which equations should be used to bound the column start/ends of each row strip
leftEQ = 1
rightEQ = 2
changeof = true --will switch equations after passing mid-vertex
 
if (bmpCoords[bottomVert].y == bmpCoords[middleVert].y) then
(
leftEQ = 1
rightEQ = 2
changeof = false
)
 
if (bmpCoords[topVert].y == bmpCoords[middleVert].y) then
(
leftEQ = 1
rightEQ = 3
changeof = false
)
 
pixelArray = #()
row = bmpCoords[topVert].y
rowscounted = 0
 
while (row > bmpCoords[bottomVert].y) do
(
--switch equations after passing the middle vert if need be
if (changeof and row > bmpCoords[middleVert].y) then
rightEQ = 3
 
startcol = (interceptLine row edgeLines[leftEQ] )
endcol = (interceptLine row edgeLines[rightEQ] )
 
if (startcol > endcol) then
(
temp = startcol
startcol = endcol
endcol = temp
)
 
--grab the row strip of pixels
newRow = getPixels tbmp [startcol, (tbmp.height - row)] (endcol - startcol)
 
pixelArray = pixelArray + newRow
row = row - 1
rowscounted = rowscounted + 1
 
--messageBox (startcol as string + "	" + endcol as string)
)
pixelSum = 0
for i = 1 to pixelArray.count do
pixelSum = pixelSum + pixelArray[i].value
 
if (pixelArray.count > 0) then
pixelAvg = pixelSum / pixelArray.count
else
pixelAvg = 0
 
return pixelAvg
)
   
   
   
   
   ------------bitmap to grayscale planes
   ----------------------------
   ---------------------------
   ---------
   (
 	-- -
 	-- CgTalk Maxscript Challenge 008: "BACK TO BASICS: Bitmap to Planes"
 	-- Dipl. Des. Georg Dümlein
 	-- www.preset.de
 	-- -
 	-- this utility converts a bitmap to grayscale and 
 	-- displays the grayscale value by rotating the pixel plane
 	-- -
 	-- 2005-08-30 inital release
 	-- -
 	-- 3ds max 7.0 
 	-- -
 	-- know issues:
 	-- mixed up x an y in a uncomfortable way
  	-- instancing the planes is much more effective ?
 	-- -
 	-- used referneces:
 	-- see below
 	-- - 
 	global rdg_bmp2Plane
 	global theBitmap
 	try(destroyDialog rdg_bmp2Plane)catch()
 	-- -
 	rollout rdg_bmp2Plane "8::rdg" (
 		
 		-- functions
 		fn grayMode_luminosity theInputColor = (
     	    theOutputColor=theInputColor[1].r*0.299+theInputColor[1].g*0.587+theInputColor[1].b*0.114
 			return theOutputColor
 		)
 		fn grayMode_average theInputColor = (
     	    theOutputColor=(theInputColor[1].r+theInputColor[1].g+theInputColor[1].b)/3
 			return theOutputColor
 		)
 		fn calcAngle thePixel = (
 			theAngle=90-90.0/255.0*thePixel
 			return theAngle
 		)
 		fn calcInvAngle thePixel = (
 			theAngle=90.0/255.0*thePixel
 			return theAngle
 		)
 		
 		-- interface
 		button imgSel_btn " select bitmap "
 		button action_btn "process bitmap" enabled:false
 		group "grayscale mode" (
     		radiobuttons    theGrayMode_rdBtn "" labels:#("luminosity", "average")
 		)
 		
 		-- interface: color correction options
 		group "color correction" (
			colorpicker tintColor "tint color" color:(color 255 255 255)
 			checkbox invertBitmap "invert bitmap"
 		)
 		
 		-- progressbar -> could be better 		
 		progressbar bitmapProgress
 		
 		-- events
 		on imgSel_btn pressed do (
 			theBitmap=selectbitmap()
 			if theBitmap != undefined then (
 				action_btn.enabled=true
 			)else(
 				action_btn.enabled=false
 			)
 		)
 		on action_btn pressed do (
 			theBitmapWidth=theBitmap.width
 			theBitmapHeight=theBitmap.height
 			-- set function to convert bitmap to grayscale
 			case theGrayMode_rdBtn.state of (
 				1: grayAction=grayMode_luminosity
 				2: grayAction=grayMode_average
 			)
 			-- set function to calculate the angle -> invert bitmap
 			case invertBitmap.checked of (
 				true: angleCalc=calcInvAngle
 				false: angleCalc=calcAngle
 			)
 			bitmapProgress.value=0
 			pbTotal=theBitmapWidth*theBitmapHeight
 			pWidth=pLength=10
 			-- process the image
 			for x=0 to (theBitmapWidth-1) do (
 				for y=0 to (theBitmapHeight-1) do (
     		    	thePixel=getPixels theBitmap [x,y] 1
 					thePixel=grayAction thePixel
 		 	currentPlane=plane lsegs:1 wsegs:1 width:pWidth length:pLength
 	 		 currentPlane.name="pixel_"+x as String+"-"+y as String
     		    	currentPlane.wireColor=tintColor.color 
     		    	move currentPlane [x*pWidth,-y*pLength,0]
 					theAngle=angleCalc thePixel
     		    	rot_plane=eulerangles theAngle 0 0
 					rotate currentPlane rot_plane
 					
 				)
     		    bitmapProgress.value=100.0/(theBitmapHeight as Float)* (x as Float)
 			)
 			-- garbage collect ...
 			gc()
 			bitmapProgress.value=0
 		)
 
 	)
 	-- start the show
 	createDialog rdg_bmp2Plane 100 210
 	
 	-- refences
 	-- http://forums.cgsociety.org/showthread.php?t=270025&highlight=destroydialog
 	-- MaxScript Help: Bitmap Values
 	-- grayscale alogorythms: http://www.puppet.cgtalk.ru/download/shaders_p_e.shtml
 	-- MaxScript Help: The Return Expression
 	-- MaxScript Help: Case Expression
 	-- MaxScript Help: Radiobuttons
 	-- MaxScript Help: Plane : GeometryClass
 	-- MaxScript Help: Applying Standard Transformations
 	-- MaxScript Help: Colorpicker
 	-- MaxScript Help: ProgressBar
 )
	
   