 --fit the UVW Mapping gizmo to the geometry
 fn UVWMapFit theObj theMap useSel:#none=
(
--RESET THE GIZMO SCALE FIRST:

--Multiply the gizmo's transformation with the inverse of a matrix created from its scale factor
theMap.gizmo.transform *= inverse (scaleMatrix theMap.gizmo.transform.scalepart)
--RESULT: the gizmo scaling will be reset to [1,1,1]

--GET THE MESH IN OBJECT SPACE BEFORE PRS AND WSM
--NOTE that this will get the mesh from TOP of the modifier stack just before PRS transforms.
--This means that the script SHOULD be applied to the UVW_Mapping modifier only when it is
--the TOP modifier on the stack, otherwise the geometry used might not be the geometry
--that the modifier is really applied to.
theMesh = theObj.mesh

--TRANSFORM ALL VERTICES IN GIZMO SPACE AND FIND MIN. AND MAX. OF GIZMO BBOX
minX = minY = minZ = 100000000 --initialize  min.values to very large numbers
maxX = maxY = maxZ = -100000000 --initialize max.values to very low numbers
theTM = theMap.gizmo.transform --store the transformation matrix of the UVW gizmo in a variable
theTMInv = inverse theTM --calculate the inverse of the gizmo TM and store in another variable
 

--DEPENDING ON THE OPTIONAL 3RD ARGUMENT, GET THE VERTICES TO OPERATE ON:
theVerts = case useSel of
(
--If no selection is defined, use a bitarray containing ALL vertices.
#none: #{1..theMesh.numverts}

--If vertex selection is requested, get the selection from the mesh
#verts: (getVertSelection theMesh)

--if edge selection is requested, convert the edge selection to vertex list:
#edges: (meshop.getVertsUsingEdge theMesh (getEdgeSelection theMesh))

--if face selection is requested, convert the face selection to vertex list:
#faces: (meshop.getVertsUsingFace theMesh (getFaceSelection theMesh))
)
 

for v in theVerts do --loop through all vertices in the bitarray defined above
(
  theVert = (getVert theMesh v) * theTMInv --get the vertex position in gizmo space

--Record min. and max. values for X, Y and Z:
  if theVert.x > maxX do maxX = theVert.x
  if theVert.y > maxY do maxY = theVert.y
  if theVert.z > maxZ do maxZ = theVert.z
  if theVert.x < minX do minX = theVert.x
  if theVert.y < minY do minY = theVert.y
  if theVert.z < minZ do minZ = theVert.z
)--end v loop


delete theMesh --delete the TriMesh value from memory

--CALCULATE THE GIZMO-ALIGNED BOX SIZE
case theMap.axis of --take into account axis orientation
(
  0: (
    X = maxZ - minZ  --gizmo's Z axis is aligned to the object's local X axis
    Y = maxY - minY
    Z =maxX - minX
  )
  1: (
    X = maxX - minX
    Y = maxZ - minZ --gizmo's Z axis is aligned to the object's local Y axis
    Z =maxY - minY
  )
  2: (
    X = maxX - minX
    Y = maxY - minY
    Z = maxZ - minZ --gizmo's Z axis is aligned to the object's local Z axis
  )
)--end case

if theVerts.numberset == 0 then --if no vertices processed, set all sizes to 10
  X = Y = Z = 10
else --if any vertices are processed, add 0.1 % padding
(
  X += 0.001*X
  Y += 0.001*Y
  Z += 0.001*Z
)

--Set the values for length, width and height in the general case
theMap.length = Y
theMap.width = X
theMap.height= Z

case theMap.maptype of --now take into account the mapping type
(
  default: theMap.width = theMap.length = amax #(X,Y) --get the bigger of the two values for width and length
  0: () --do nothing for planar mode - will use the above general case
  1: (
    case theMap.axis of --special axis handling for cylinder!
    (
      0: (theMap.width = theMap.length = amax #(X,Z); theMap.height = Y)
      1: (theMap.width = theMap.length = amax #(Y,Z); theMap.height = X)
      2: (theMap.width = theMap.length = amax #(X,Y); theMap.height = Z)
    )--end axis case
  )
  2: theMap.width = theMap.length = theMap.height = amax #(X,Y,Z) --radius from the largest of the 3 values
  3: theMap.width = theMap.length = theMap.height = amax #(X,Y,Z) --radius from the largest of the 3 values
  4: () --do nothing for box mode - will use the above general case
)--end maptype case

--CALCULATE THE CENTER IN GIZMO SPACE - IT IS THE MIDDLE OF THE BOX'S DIAGONAL
theCenter = ([maxX,maxY,maxZ] + [minX,minY,minZ])/2.0
--CONVERT THE CENTER INTO OBJECT SPACE BY MULTIPLYING WITH THE GIZMO TM
theCenter *= theTM
--THEN CENTER THE GIZMO
theTM.row4 = theCenter --set the translation part of the matrix to the new center
theMap.gizmo.transform = theTM --and assign the matrix back to the gizmo transformation
)--end function



--execute
--Print the old gizmo transform.
--If you hit FIT in the UI before running the script and then run this line,
--the results from the script should be identical to the result of the FIT:
theMap.gizmo.transform

--Call the funtion, specifying the object to get the geometry from, the modifier to fit and the selection level to use:
UVWMapFit $Teapot01 $Teapot01.uvw_Mapping useSel:#none