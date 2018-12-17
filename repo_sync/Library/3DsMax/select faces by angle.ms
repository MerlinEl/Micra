fn selectFacesByAngle =
(
	local obj = selection[1]
	local face_angle
	if classOf obj != editable_poly do return false
	local face_sel = polyOp.getFaceSelection obj
	for i in face_sel where 
	(
		face_angle = polyOp.getFaceNormal obj i
		print (matrixFromNormal (face_angle*$.transform) ) as eulerAngles
		face_angle != [1,1,1]
	) do print 0--face_angle
	
	local tm = (inverse (viewport.getTM())).row4
	
)

selectFacesByAngle()

fn selectFacesByAngle offset:1 =
(
	local obj = selection[1]
	if classOf obj != editable_poly do return false
	local face_sel = (polyOp.getFaceSelection obj as array)[1]
	if face_sel == undefined do return false 
	fn getVectorsAngle v1 v2 = acos (dot (normalize v1) (normalize v2))
	local v1 = polyOp.getFaceNormal obj face_sel
	local faces = for f=1 to obj.faces.count where \
		getVectorsAngle v1 (polyOp.getFaceNormal obj f) < offset \
		collect f
	/*
	local faces = #()
	for f=1 to obj.faces.count do
	(
		local v2  = polyOp.getFaceNormal obj f
		local ang = getVectorsAngle v1 v2
		--format "v1:% v2:% ang:%\n" v1 v2 ang
		if ang < offset do faces += #(f)
	)
	*/
	polyOp.setFaceSelection obj faces
)

selectFacesByAngle offset:45




fn collectFlippedFaces node selectit:on = 
(
	 cam_dir = -(inverse (getViewTM())).row4
	 towards_faces = #{}
	 for f in (node.faces as bitarray) \
	  where dot (polyOp.getFaceNormal node f) cam_dir > 0 do append towards_faces f 
	 if selectit do node.selectedfaces = towards_faces
	 towards_faces
)

collectFlippedFaces selection[1]


function collectFlippedFaces theNode:selection[1] selectIt:true =
(
    local baFlippedFaces = #{}

    if (isKindOf theNode Editable_Poly) do
    (
        local p3ViewDir = -(inverse(getViewTM())).row3
        local iNumFaces = polyOp.getNumFaces theNode

        for iFace = 1 to iNumFaces where ( (dot (polyOp.getFaceNormal theNode iFace) p3ViewDir) > 0 ) do
            baFlippedFaces[iFace] = true

        if (selectIt == true) do
        (
            polyOp.setFaceSelection theNode baFlippedFaces
            
            if (subObjectLevel != 4) do
                subObjectLevel = 4

            forceCompleteRedraw()
        )
    )

    return baFlippedFaces
)

collectFlippedFaces()


fn collectFlippedPolyFaces node:selection[1] selectit:on = if iskindof node Editable_Poly do
(
 cam_dir = -(inverse (getViewTM())).row3
 flipped_faces = #{}
 getpolynormal = polyop.getfacenormal   
 for f in (node.faces as bitarray) \
  where dot (getpolynormal node f) cam_dir > 0 do append flipped_faces f 
 if selectit do node.selectedfaces = flipped_faces
 flipped_faces
)
collectFlippedPolyFaces()


(

theObj = selection[1]

--convertToMesh theObj --convert to EMesh

theMeshCount = theObj.numfaces --get the number of faces in the object

selArray = #() --init. an array to collect faces

for f = 1 to theMeshCount do --loop through all faces

(

in coordsys (inverse (viewport.GetTM())) theFN = polyop.getfacenormal theObj f

if theFN.z < 0 then append selArray f --if Z is negative, add to array

)

polyop.setFaceSelection theObj selArray --set the face selection in the EMesh

max modify mode --go to modify mode

select theObj --select the mesh

subObjectLevel = 4 --go to Face SO level

--modPanel.addModToSelection (deleteMesh()) --add a delete mesh, preserving the SO selection

)




/*
obj = geosphere() --create a GeoSphere

convertToMesh obj --collapse to Editable_Mesh

--Count backwards from the last vertex to the first.

--This is necessary because we intend to delete vertices

--and this will renumber the remaining ones. Counting backwards

--ensures the renumbering does not affect the loop:

for v = obj.numVerts to 1 by -1 do 

(

--get the vertex normal and get the dot product with the +Z vector

--If the result is less than the specified threshold,

--then delete the vertex the normal belongs to

if dot (getNormal obj v) [0,0,1] <= -0.25 do deleteVert obj v

)

update obj --update the mesh


*/
tm = inverse (viewport.getTM())
b=box()
b.transform = tm

(matrixFromNormal (polyOp.getFaceNormal $ 4)*$.transform ) as eulerAngles