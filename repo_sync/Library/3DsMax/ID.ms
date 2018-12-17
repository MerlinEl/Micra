fn setMatID node:selection[1] rangeID:[1,64] = 
(
	for f in (node.faces as bitarray) do polyop.setfacematid node f (random rangeID[1] rangeID[2])
)
fn getMatID node:selection[1] = 
(
	ids = #{}
	for f in (node.faces as bitarray) do append ids (polyop.getfacematid node f)
	ids
)
fn detachByID node:selection[1] = 
(
	ids = getMatID node:node
	with redraw off for id in ids do
	(
		node.selectByMaterial id
		if (polyop.detachfaces node node.selectedfaces delete:on asnode:on name:("id_" + id as string)) do objects[objects.count].parent = node
	)
)
/*
delete objects
sp = converttopoly (sphere name:"sp" segments:32)
setMatID node:sp
detachByID node:sp
*/


--------------------------------




fn randomColor=(color (random 1 255)  (random 1 255) (random 1 255)) 		
fn createTestMesh =
(
	local obj = (convertToPoly (sphere segments:100 radius:200))
	
	polyOp.setFaceMatID	obj #{1..1000} 2
	polyOp.setFaceMatID	obj #{1000..2000} 8
	polyOp.setFaceMatID	obj #{2000..3000} 9
	polyOp.setFaceMatID	obj #{3000..4000} 22
	local mm = multimaterial numsubs:10
	for i in mm do i.diffusecolor = randomColor()
	obj.material = mm
	select obj
)



fn getSimilarFacesByID obj id =
(
	 for f in obj.faces where polyOp.getFaceMatID obj f.index == id collect f.index	 
)

fn detachByID =
(
	local start = timeStamp()
	
	createTestMesh()
	local obj = selection[1]
	if classOf obj != Editable_Poly do return false
	local cnt = 0
	while obj.faces.count > 0 and not keyboard.escPressed do
	(
		cnt+=1
		local faces = getSimilarFacesByID obj cnt
		polyOp.detachFaces obj faces delete:true asNode:true name:(uniqueName obj.name)
	)
	delete obj
	
	local end = timeStamp()
	format "Processing took % seconds\n" ((end - start) / 1000.0)
)
detachByID()
		


		
fn detachByID =
(
	
	
	local obj = selrdection[1]
	if classOf obj != Editable_Poly do return false
	--collect face data
	struct FACE_DATA (num,id)
	local FD = for i=1 to obj.faces.count collect (FACE_DATA i (polyOp.getFaceMatID obj i))
	--sort faces by id
	local sorted_faces = #()
	for i in FD do
	(
		while i.id > sorted_faces.count do append sorted_faces #()
		sorted_faces[i.id] += #(i.num)
	)
	--detach faces by id
	for f in sorted_faces where f.count !=0 do
	(
		polyOp.detachFaces obj f delete:true asNode:true \
		name:(uniqueName obj.name) 
	)
	delete obj
	

)		
	
detachByID()



if obj.material == undefined do return false
for m = 1 to obj.material.numsubs do
(
	
)			
emod = Edit_Poly()

addMod Edit_Poly
addmodifier $ Emod

emod.selectByMaterialID = 2
newname = obj.name + "_" + obj.material[subindex].name
emod.detachtoobject newname
emod.separateByMaterial = true


$.selectByMaterial 2 clearCurrentSelection:true
