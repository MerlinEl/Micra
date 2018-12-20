/** 
*  Script:
*  Find identical geometry and instance it. 
* =======================================
* Everybody who have imported large amount of data from any cad system know that it normally kills the instancing.
* The intention of this script is to find geometrically identical nodes and instance them. 
* This script will ofcourse work if someone have use copy instead of instance in a scene and wants them instanced instead.
*
* To be instanced.....
* The nodes needs to have:  Identical face count, same class, identical face setup and identical scale 
* The nodes does not need to have : Identical Transform, Materials, Parents or Children
*
* Author:
*   Martin Enthed (at IKEA Communications AB)
*  History:
*   v01 r01  :6/02/10 : menthed: First working version on testsceen
*   v01 r02  : 7/02/10 : menthed: Changed tolerance calculation algorithm to not be additative, and local coordsys
*   v01 r03  :20/02/10 : menthed: Now handles non Editable mesh objects (solved with snapshot)
*   v02 r01  : 27/02/10 :menthed: Made simple interface and result presentation
*  
*/


fn IKEAsameGeometry a b tol=
	(
		-- already same node?
		if (a==b) then return false
		-- Already Instanced ?
		if (areNodesInstances a b) then return false
	
		-- Is same Class?
		classA=classof a
		classB=classof b
		if (classA!=classB) then return false
		
		-- If not Editablemesh then snapshot
		killsnapshots=false 
		if (classA!=Editable_mesh) then 
			(
				killsnapshots=true
				a=snapshot a
                b=snapshot b
            )		
			
		-- Same amount of faces
		anum=getNumFaces a
		bnum=getNumFaces b
		if (anum!=bnum) then 
		(
			if killsnapshots then 
			( 
				delete a
				delete b
			)	
			return false
		)
		
		-- Go through facenormal diff and facecenter diff
		-- Compared to first face, return false if diff is > than tolerance
		ax=getFaceNormal a 1
		bx=getFaceNormal b 1
		ap=in coordsys local meshop.getFaceCenter a 1 
		bp=in coordsys local meshop.getFaceCenter b 1 
		
		diff=0
		bigdiff=0
		for x=2 to anum do
		(
			----- angle diff
			axx=getFaceNormal a x
			bxx=getFaceNormal b x
			diff+=(dot ax axx)-(dot bx bxx)
			----- pos diff
			app=in coordsys local meshop.getFaceCenter a x 
			bpp=in coordsys local meshop.getFaceCenter b x 
			diff+=abs ((distance app ap)-(distance bpp bp))
			--print diff
			if diff>bigdiff then bigdiff=diff
			if diff>tol then 
			(
				if killsnapshots then 
				( 
					delete a
					delete b
				)	
				return false
			)	
			diff=0.0
		)
		if killsnapshots then 
				( 
					delete a
					delete b
				)	
		--print bigdiff
		return true
	)

	-- Build transform Matrix from first face in node
	fn IKEAgetmatrixfromfirstface  m =
	(
		if (classof m!=Editable_mesh) then 
			(
				killsnapshots=true
				m=snapshot m
            )	
		else
				killsnapshots=false
			
		setFaceSelection m #{1}
		verts=meshop.getVertsUsingFace m #{1} 
		verts= verts as array
		 p1=(getVert m verts[1])
		p3=(getVert m verts[2])
		p2=(getVert m  verts[3])
		v1 = normalize (p2-p1) --the vector from Point01 to Point02
		v2 = normalize (p3-p1) --the vector from Point01 to Point03
		nv1 = cross v1 v2 --the cross product, the normal to the plane
		nv2 = cross nv1 v1 --the cross product of the normal and vector 1
		--Create a matrix3 value using he first vector, the vector perpendicular 
		--to it and the normal to the plane and the normal vector itself.
		--The translation part (.row4 which is the position) is the middle point
		--of the 3 points' positions:
		mat=orthogonalize (matrix3 v1 nv2 nv1 ((p1+p2+p3)/3)) 
		if killsnapshots then delete m
		return mat

	)
	

	
	fn IKEAInstanceSameGeometryWithTolerance Tolerance=
	(
		result=""
		instancesMade=0
		-- Only include geometry nodes
		all=$*/geometry as array
		x=1
		while (x<all.count) do
		(
			y=all.count
			while (y>x) do
			(
				if (IKEAsamegeometry all[x] all[y] Tolerance) then
				(
					-- Create indivudual transforms from first face on each geometry
					xMat=IKEAgetmatrixfromfirstface all[x] 
					yMat=IKEAgetmatrixfromfirstface all[y] 
					newInstance=Instance all[x]	
					-- Do the transform from the instanced node geometrys first face transform to the node to replaces first face transform
					-- This was hard to figure out and I'm not sure that it's optimal but it seams to work ;-) 	
					newInstance.transform=((inverse (xmat*(inverse all[x].transform)))*(ymat*(inverse all[y].transform)))*all[y].transform
					-- Replace all other stuff on the new instance from the object to replace, like material and parent and child info and name	
					newInstance.material=all[y].material
					newInstance.parent=all[y].parent
					all[y].children.parent=newInstance
					newInstance.name=all[y].name
					-- Write the result information	
					result+=("Instanced ->"+all[y].name+"<- with ->"+all[x].name) +"\n"	
					instancesMade+=1
					---Delete the node that we replaced by the instance in the scene and in the array	
					delete all[y]
					deleteItem all y
					
				)
				y-=1
			)
			x+=1
		)	
		result="Instanced "+(instancesMade as string)+ " nodes\n"+result
		return result
	)

		
rollout IKEARolloutFindIdenticalGeometry "Find identical geometry and instance it (by M.Enthed)" width:731 height:191
(
	spinner spnTolerance "Tolerance" pos:[59,16] width:158 height:16 scale:0.001
	button btn_instanceIt "Instance it..." pos:[541,9] width:167 height:22
	edittext edt_Result "Result" pos:[16,40] width:693 height:139

	on IKEARolloutFindIdenticalGeometry open do
		spnTolerance.value=0.001
	on btn_instanceIt pressed do
	(
		edt_Result.text=IKEAInstanceSameGeometryWithTolerance spnTolerance.value
	)
)

createdialog IKEARolloutFindIdenticalGeometry