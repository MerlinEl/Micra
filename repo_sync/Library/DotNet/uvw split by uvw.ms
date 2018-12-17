fn splitMeshByUVElements mesh channel =

(

local obj = copy mesh --copy the original object

convertToMesh obj --convert to editable mesh

while obj.numfaces > 0 do --repeat until all elements have been detached

(

face_array = #(1) --init. an array including only face 1

cnt = 0 --init. a counter

--repeat until the counter is higher than the faces stored in the array

while cnt < face_array.count do 

(

cnt += 1 --increase the counter

--get all map vertices used by the current map face in the collection array:

theVerts = meshop.getMapVertsUsingMapFace obj channel #(face_array[cnt])

--get all map faces used by these map vertices - 

--this gives us all neighbours of the current map face

theFaces = meshop.getMapFacesUsingMapVert obj channel theVerts 

--make sure only unique faces are written to the array

for f in theFaces where findItem face_array f == 0 do 

append face_array f

)--end while

--once all connected faces in an element are collected, 

--create a new empty EMesh:

new_emesh = Editable_mesh()

--detach the collected faces and assign to the EMesh's TriMesh

new_emesh.mesh = meshop.detachFaces obj face_array delete:true asMesh:true

--Copy the transformation of the original object

new_emesh.transform = mesh.transform

--Assign a unique name based on the original one

new_emesh.name = uniquename (mesh.name +"_UVsplit")

)

delete obj --delete the clone which has no faces at this point

)

 

--Example usage:

splitMeshByUVElements $Teapot01 1