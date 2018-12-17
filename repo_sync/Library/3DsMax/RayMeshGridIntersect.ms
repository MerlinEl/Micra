RayMeshGridIntersect.addNode $Sphere04
RayMeshGridIntersect.buildGrid 1
RayMeshGridIntersect.getHitFace
RayMeshGridIntersect.initialize 2 4
RayMeshGridIntersect.ClearStats()

rayMeshGridIntersectOps.ClearStats()
RayMeshGridIntersect.rayMeshGridIntersectOps.buildGrid
RayMeshGridIntersect.rayMeshGridIntersectOps.addNode $Sphere04
RayMeshGridIntersect.rayMeshGridIntersectOps.free()
RayMeshGridIntersect.rayMeshGridIntersectOps.PrintStats()
RayMeshGridIntersect.rayMeshGridIntersectOps.initialize()


showinterface RayMeshGridIntersect.rayMeshGridIntersectOps

-----------------------------------------------------------------



--RayMeshGridIntersect
rm = RayMeshGridIntersect()--create an instance of the Reference Target
rm.Initialize 10 --init. the voxel grid size to 10x10x10
rm.addNode theSphere --add the sphere to the grid
rm.buildGrid() --build the grid data (collecting faces into the grid voxels)
theGSMesh = snapshotasmesh theGeoSphere --grab the TriMesh of the Geosphere
theIndex = rm.getClosestHit()--get the index of the closest hit by the ray
theFace = rm.getHitFace theIndex--get the face index corresponding to that indexed hit



--------------------------
--intersectRayEx <node> <ray>

s = sphere()
r = ray [-100,5,0] (s.center-[-100,5,0])-- Get the Intersection details
arr = (intersectRayEx s r)

--A Ray defining the position of intersection in 3-space and the surface normal direction vector at the point.
--The index of the face the ray intersects with
--The barycentric coordinates of the face that was hit.




 -- from help file; constructs a ray through the center of the current viewport (perspective/non-ortho camera)
 fn getViewDirectionRay = 
 (
 	local coordSysTM = Inverse(getViewTM())
 	local viewDir = -coordSysTM.row3
 	local viewPt = coordSysTM.row4
 	ray viewPt viewDir
 )
 
 -- make a sphere where we can select its faces and have that effect a change in material IDs
 -- this will visualize the selected face
 mySphere = GeoSphere()
 convertToMesh mySphere
 addModifier mySphere (Mesh_Select())
 max modify mode
 select mySphere
 subObjectLevel = 3
 modPanel.addModToSelection (MaterialModifier())
 mySphere.material = MultiMaterial()
 mySphere.material.materialList[1].diffuse = (color 255 0 0)
 
 /* *********************************************
 	EXAMPLE 1:
 	set up a callback using intersectRayEx
 ********************************************* */
 callbacks.removeScripts id:#test
 callbacks.addScript #viewportChange "
 	myRay = getViewDirectionRay()
 	myHit = intersectRayEx mySphere myRay
 	if (myHit != undefined) then (
 		myHitFace = myHit[2]
 		setFaceSelection mySphere mySphere.modifiers[#Mesh_Select] #(myHitFace)
 	)
 	else (
 		setFaceSelection mySphere mySphere.modifiers[#Mesh_Select] #()
 	)
 " id:#test
 forceCompleteRedraw()
 
 /* **************************************************  
 	EXAMPLE 2:
 	set up a callback using rayMeshGridIntersect
 **************************************************   */
 callbacks.removeScripts id:#test
 rMGI = rayMeshGridIntersect()
 rMGI.initialize 50
 rMGI.addNode mySphere
 rMGI.buildGrid()
 callbacks.addScript #viewportChange "
 	myHit = rMGI.intersectray (getViewDirectionRay()).pos (getViewDirectionRay()).dir false
 	if (myHit != 0) then (
 		myHitFace = rMGI.getHitFace 1
 		setFaceSelection mySphere mySphere.modifiers[#Mesh_Select] #(myHitFace)
 	)
 	else (
 		setFaceSelection mySphere mySphere.modifiers[#Mesh_Select] #()
 	)
 " id:#test
 forceCompleteRedraw()



