Global mcQuickMaterialsDialog
if mcQuickMaterialsDialog != undefined do destroyDialog mcQuickMaterialsDialog
rollout mcQuickMaterialsDialog "Quick Materials:" width:288 height:292
(
	struct MAT_ITEM (key, id, tile_u, tile_v)
	local items_pattern = #(
		
		MAT_ITEM "grass" 140 0.4 0.4,
		MAT_ITEM "pavement1" 53 0.16 0.32,
		MAT_ITEM "pavement2" 58 0.25 0.25,
		MAT_ITEM "pavement3" 50 0.12 0.25, 
		MAT_ITEM "bricks1" 54 0.4 0.4, 
		MAT_ITEM "bricks2" 59 0.4 0.4,  
		MAT_ITEM "bricks3" 51 0.9 0.9, 
		MAT_ITEM "dirt" 103 0.4 0.4,
		MAT_ITEM "asphalt" 3 0.4 0.4
	)
	button 'btn_apply' "Apply" pos:[8,252] width:84 height:28 align:#left
	dropdownList 'ddl_mat_names' "" pos:[84,24] width:104 height:21 align:#left
	label 'lbl1' "Add material" pos:[16,28] width:64 height:12 align:#left
	GroupBox 'grp1' "Set-Up:" pos:[4,4] width:280 height:284 align:#left
	label 'lbl2' "to selected faces." pos:[192,28] width:92 height:12 align:#left
	button 'btn_close' "Close" pos:[200,252] width:76 height:28 align:#left
	checkbox 'chk_collapse' "collapse" pos:[96,252] width:56 height:16 checked:true align:#left
	bitmap 'bmp_preview' "Bitmap" pos:[12,48] width:264 height:200 align:#left
	checkbox 'chk_autoorient' "orientation auto" pos:[96,268] width:100 height:16 checked:false align:#left
	local current_mat_id = 140
	fn getMatDataByName mod_name = (
		
		for itm in items_pattern where itm.key == mod_name do return itm
		return undefined
	)
	fn getMatIDByName mod_name = (
		
		local mat_data = getMatDataByName mod_name
		if mat_data != undefined then mat_data.id else 1
	)
	fn UVWMapFit theObj theMap useSel:#none = (
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
	fn alignUVGizmoToSelectedFaces obj mod_uvw = (
		
		local fsel = polyop.getFaceSelection obj as Array
		if (fsel.count == 0) do return false
		local faces_normals = in coordsys obj (polyop.getFaceNormal obj fsel[1]) --get first normal
		for f=2 to fsel.count do faces_normals +=  in coordsys obj (polyop.getFaceNormal obj f) --get rest normals
		local faceNormal = faces_normals / fsel.count
		local worldUpVector = [0,0,1]
		local rightVector	= normalize (cross worldUpVector faceNormal)
		local upVector	= normalize ( cross rightVector faceNormal )
		local theMatrix	= matrix3 rightVector upVector faceNormal [0,0,0]
		modPanel.addModToSelection mod_uvw ui: on -- Add UVW Map Modifier to selection 
		mod_uvw.gizmo.transform = theMatrix
		UVWMapFit obj mod_uvw useSel:#none
	) 
	fn addTempMaterial obj mod_name = (
		
		if classOf obj != Editable_Poly do (
			
			messageBox "Object must be Editable Poly." title:"Aborted:"
			return false
		)
		local mod_matid, mod_name, sublevel = subobjectLevel
		max modify mode
		--all terrains must use one multimaterial
		if obj.material == undefined or obj.material.name != "lh_terain" do ( 
			
			local terrain_mat = meditMaterials["lh_terain"]
			if terrain_mat == undefined do (
					
				messageBox "Terrain Material Not Found" title:"Aborted"
				return false
			)
			obj.material = terrain_mat
		)
		--continute to add and setup modifiers
		local mod_uvw = uvwMap axis:2 maptype:0 mapChannel:1 realWorldMapSize:false name:mod_name
		if (chk_autoorient.checked and sublevel == 4) then (
			
			alignUVGizmoToSelectedFaces obj mod_uvw
			
		)  else (
			
			modPanel.addModToSelection mod_uvw ui: on -- Add UVW Map Modifier to selection 	
		)
		--format "mo w:% h:% name:%\n" mod_uvw.width mod_uvw.length mod_name
		local mat_data = getMatDataByName mod_name
		local u_tile = mod_uvw.width *  (mat_data.tile_u / 100) --default mod_uvw.width * 0.0016
		local v_tile = mod_uvw.length * (mat_data.tile_v / 100) --default mod_uvw.length * 0.0032
		local mat_id = mat_data.id

		mod_matid = Materialmodifier materialID:mat_id
		mod_uvw.utile = u_tile	--length is in generic units
		mod_uvw.vtile = v_tile	--width is in generic units
		modPanel.addModToSelection  mod_matid	
		if chk_collapse.checked do (
			
			maxOps.CollapseNodeTo obj 1 true
			if sublevel != undefined do subobjectLevel = sublevel
		) 
	)
	fn stretchBitmapTo bm w h = (
		
		local bb= bitmap w h color:black 
		local tx = bitmaptexture bitmap:bm
		rendermap tx into:bb size:[bb.width,bb.height] filter:on display:off	
		bb
	)
	fn previewMaterial mat_id = (
		
		local terrain_mat = meditMaterials["lh_terain"]
		if terrain_mat == undefined do return false
		local mat = terrain_mat[mat_id]
		local bm = case classOf mat of (

			DirectX_9_Shader: (
				
				local mt = mat.renderMaterial
				local dm = if classOf mt == LS3DMaterial then mt.diffuseMap else undefined
				if dm != undefined then dm.bitmap else undefined
			)
			LS3DMaterial: (

				local dm = mt.diffuseMap
				if dm != undefined then dm.bitmap else undefined
			)
			default: undefined
		)
		if classOf bm == BitMap do bmp_preview.bitmap = stretchBitmapTo bm 264 200
	)
	fn init = (
		
		ddl_mat_names.items = for itm in items_pattern collect itm.key
		previewMaterial current_mat_id
	)
	on mcQuickMaterialsDialog open do init()
	on ddl_mat_names selected sel do previewMaterial (getMatIDByName ddl_mat_names.items[ sel ])
	on btn_apply pressed do (addTempMaterial $ ddl_mat_names.selected)
	on btn_close pressed do (destroyDialog mcQuickMaterialsDialog)
)
createDialog mcQuickMaterialsDialog