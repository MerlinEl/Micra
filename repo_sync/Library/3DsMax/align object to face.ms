--move object to center dir to Z
p = [0,0,0]
n = [0,0,1]
$.transform = translate (matrixFromNormal n) p


fn localMatrix p1 p2 p3 = 
(
	local v1 = normalize (p1 - p2)
	local v3 = normalize (cross v1 (normalize (p3 - p2)))
	local v2 = normalize (cross v3 v1)
	return matrix3 v1 v2 v3 [0,0,0]
)

fn alignObjectByTwoEdges obj debug:false =
(
	if classOf obj != Editable_Poly or subobjectLevel != 2 do return false
	local edges = (polyOp.getEdgeSelection obj) as array
	if edges.count != 2 do return false
	local a = polyOp.getVertsUsingEdge obj edges[1]
	local b = polyOp.getVertsUsingEdge obj edges[2]
	
	local p1 = polyOp.getVert obj ((a-b)as array)[1]
	local p2 = polyOp.getVert obj ((a*b)as array)[1]
	local p3 = polyOp.getVert obj ((b-a)as array)[1]
	
	local tmA = localMatrix p1 p2 p3
	local tmB = matrixFromNormal [0,0,1]
	local tm  = tmB * (inverse tmA)
	local center = (obj.min + obj.max)/2
	
	
	if debug do
	(
		local po = point wirecolor:green
		point wirecolor:red pos:center
		po.transform = tm
	)
	
	for v=1 to obj.verts.count do
	(
		local vpos = polyOp.getVert obj v
		local v1 = vpos - center
		local v2 = v1 * tm
		local v3 = v2 + center
		polyOp.setVert obj v v3
	)

)
alignObjectByTwoEdges ( (selection as array)[1] ) debug:false

fn alignObjectByFaceToWorld =
(
	local obj = (selection as array)[1]
	if classOf obj != Editable_Poly do return false
	local face = ((polyOp.getFaceSelection obj) as array)[1]
	if face == undefined do return false
	local center = obj.pos --polyop.getfacecenter obj face
	local normal = polyop.getfacenormal obj face
	
	local tmA = matrixFromNormal normal
	local tmB = matrixFromNormal [0,0,1]
	local tm  = tmB * (inverse tmA)
			
	for v=1 to obj.verts.count do
	(
		local vpos = polyOp.getVert obj v
		local v1 = vpos - center
		local v2 = v1 * tm
		local v3 = v2 + center
		polyOp.setVert obj v v3
	)
)
alignObjectByFaceToWorld()



fn alignObjectByEdgeToWorld =
(
	local obj = (selection as array)[1]
	if classOf obj != Editable_Poly do return false
	local esel  = (polyOp.getEdgeSelection obj as array)[1]
	if esel == undefined do return false
	
	local o_pos = obj.pos
	local verts = polyOp.getEdgeVerts obj esel
	local v1_pos   = polyOp.getVert obj verts[1]
	local v2_pos   = polyOp.getVert obj verts[2]
	local o_center = (v1_pos + v2_pos) / 2
	
	polyOp.getFaceEdges <Poly poly> <int face>
)




fn alignObjectToSelectedFace =
(
	local obj = (selection as array)[1]
	if classOf obj != Editable_Poly do return false
	local face = ((polyOp.getFaceSelection obj) as array)[1]
	if face == undefined do return false
	local center = polyop.getfacecenter obj face
	local normal = polyop.getfacenormal obj face
	obj.transform = translate (matrixFromNormal normal) center 
)
alignObjectToSelectedFace()



fn alignToFace source target face:1 = if isvalidnode source and iskindof target Editable_Poly do
(
  center = polyop.getfacecenter target face
   normal = polyop.getfacenormal target face

  source.transform = translate (arbmatrix normal) center 
)




fn generateTransformationMat obj =
   (
  	local theFaceCenter=polyOp.getFaceCenter obj  1 --get the face center
  	local theNormal=polyop.getFaceNormal obj 1 --get the face normal
  	 
  	local theUp = [0,0,1]  --define an up vector
  	local theX = if acos (dot theUp theNormal) < 0.001 then  --if the normal is nearly pointing up,
  		[1,0,0]	--assume the X to be the world X
  	else 
  		normalize (cross theNormal theUp) --otherwise perpendicular to the up vector and the normal
  	local theY = normalize (cross theNormal theX) --the Y will be perpendicular to both N and X
  	matrix3 theX theY theNormal theFaceCenter --the matrix will use the 3 axes and the center
   )
   
   
   
   
 fn createAPlane theName=(
 	thePlane=plane width:150 length:150 lengthsegs:1 widthsegs:1 name:theName
 	convertToPoly thePlane
 	thePlane
 )
 
 fn fingAngleFrom3Points A B C =
 (
 	n1=normalize(B-A)
 	n2=normalize(C-A)
 	--return
 	acos(dot n1 n2)
 )	
 	
 fn findZorientation norm =
 (
 	A=[0,0,0]
 	B=[0,-1,0]
 	C=norm
 	C.z=0
 	C=normalize C
 
 	X=C.x
 	if X!=0 then
 		((fingAngleFrom3Points A B C)*(X/abs X))
 	else
 		(fingAngleFrom3Points A B C)
 )
 	
 fn generateTransformationMat obj =
 (
 	theNormal=polyop.getFaceNormal obj 1
 
 	Zorientation=findZorientation (copy theNormal)
 
 	theNormalMatrix=matrixFromNormal  theNormal
 
 	theFaceCenter=polyOp.getFaceCenter obj  1
 			
 	theMat=matrix3 1
 
 	--ZORIENTATION
 	rotateZ theMat (Zorientation)
 
 	--INCLINATION
 	rotate theMat (theNormalMatrix.rotationpart )
 
 	--TRASLATION
 	translate theMat theFaceCenter					
 
 --		RETURN		
 	theMat
 )
 	
 
 theFirstPlane=createAPlane "first plane"
 theSecondPlane=createAPlane "Second plane"
 
 move theFirstPlane [200,0,0]
 
 rotate theFirstPlane (eulerangles 40 0 0)
 rotate theSecondPlane(eulerangles 40 0 20)
 
 
 
 
 theFirstBox=box name:"first box" width:14 lenght:25 height:12 transform:(generateTransformationMat theFirstPlane)
 
 theSecondBox=box name:"second box" width:14 lenght:25 height:12 transform:(generateTransformationMat theSecondPlane)
 
 
 
 
 
 
 fn alignObjectToSelectedFace =
(
	local obj = (selection as array)[1]
	if classOf obj != Editable_Poly do return false
	local face = ((polyOp.getFaceSelection obj) as array)[1]
	if face == undefined do return false
	local center = polyop.getfacecenter obj face
	local normal = polyop.getfacenormal obj face
	
	obj.transform = translate (matrixFromNormal normal) center 
)
alignObjectToSelectedFace()



fn alignObjectToSelectedFace =
(
	local obj = (selection as array)[1]
	if classOf obj != Editable_Poly do return false
	local face = ((polyOp.getFaceSelection obj) as array)[1]
	if face == undefined do return false
	m1 = matrixFromNormal (polyop.getfacenormal obj face)
	m2 = inverse obj.transform 
	m2.pos = [0,0,0]
	obj.transform *= m1*m2
)
alignObjectToSelectedFace()



fn alignObjectToSelectedFace =
(
	local obj = (selection as array)[1]
	if classOf obj != Editable_Poly do return false
	local face = polyOP.getFaceSelection obj
	local fverts = polyOP.getVertsUsingFace obj face
	local fvertpos = for v in fverts collect polyOP.getVert obj v
	fn localMatrix p1 p2 p3 = 
	(
		local v1 = normalize (p2 - p1)
		local v3 = normalize (cross v1 (normalize (p3 - p1)))
		local v2 = normalize (cross v3 v1)
		return matrix3 v1 v2 v3 ((p1+p2+p3)/3)
	)
	local tm = localMatrix fvertpos[1] fvertpos[2] fvertpos[3]
	--obj.transform = tm
	local pl = plane transform:tm
	obj.parent = pl
	pl.rotation = quat 0 0 0 0
	delete pl
)

fn strightenObjectByTwoEdges = 
(
	local obj = (selection as array)[1]
	if classOf obj != Editable_Poly do return false
	--get two edges
	local esel = polyOP.getEdgeSelection obj
	if esel.numberset != 2 do return false
	--get edges verts
	local edges_verts = #()
	for i in esel do 
	(
		local verts = for v in (polyOP.getVertsUsingEdge obj i) collect polyOP.getVert obj v
		append edges_verts verts 
	)
	--format "verts:%\n" edges_verts
	local p1 = edges_verts[1][1]
	local p2 = edges_verts[1][2]
	local p3 = edges_verts[2][1]
	local p4 = edges_verts[2][2]
	local v1 = normalize (p2 - p1)
	local v2 = normalize (p3 - p4)
	local v3 = normalize (cross v2 v1)
	local tm = matrix3 v1 v2 v3 ((p1+p2+p3+p4)/4)
		--obj.transform = tm
	local pl = plane transform:tm
	obj.parent = pl
	pl.rotation = quat 0 0 0 0
	delete pl
)
strightenObjectByTwoEdges()



	fn objectAlignByTwoEdges_old =
	(
		local obj = (selection as array)[1]
		if classOf obj != Editable_Poly or subobjectLevel != 2 do return false
		local edges = (polyOp.getEdgeSelection obj) as array
		if edges.count != 2 do return false
		local a = polyOp.getVertsUsingEdge obj edges[1]
		local b = polyOp.getVertsUsingEdge obj edges[2]
		
		local p1 = polyOp.getVert obj ((a-b)as array)[1]
		local p2 = polyOp.getVert obj ((a*b)as array)[1]
		local p3 = polyOp.getVert obj ((b-a)as array)[1]
		
		--fn localMatrix p1 p2 p3 =
		local v1 = normalize (p1 - p2)
		local v3 = normalize (cross v1 (normalize (p3 - p2)))
		local v2 = normalize (cross v3 v1)
		
		local tmA = matrix3 v1 v2 v3 [0,0,0]
		local tmB = matrixFromNormal [0,0,1]
		local tm  = tmB * (inverse tmA)
		local center = (obj.min + obj.max)/2

		for v=1 to obj.verts.count do
		(
			local vpos = polyOp.getVert obj v
			local v1 = vpos - center
			local v2 = v1 * tm
			local v3 = v2 + center
			polyOp.setVert obj v v3
		)
	),