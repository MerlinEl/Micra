Global mcQuickMaterialsDialog
if mcQuickMaterialsDialog != undefined do destroyDialog mcQuickMaterialsDialog
rollout mcQuickMaterialsDialog "Quick Materials:" width:556 height:428
(
	--variables and structures
	struct MAT_ITEM (key, id, tile_u, tile_v)
	local mat_items = #(
		
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
	local drawingColor   = dotNetClass "drawing.color"
	local bgColor   = ((colorMan.getColor #background)*255)as color
	local winColor  = ((colorMan.getColor #window)*255)as color
	local textColor = ((colorMan.getColor #text)*255)as color
	local current_mat_id = 140
	local list_items = #() --backup collection for search bar (edt_filter_names)
	local list_names = #() --backup collection for search bar (edt_filter_names)
	--UI
	button 'btn_apply' "Assign" pos:[108,392] width:84 height:28 toolTip:"Aply material to selected faces" align:#left
	GroupBox 'grp1' "Preview:" pos:[4,4] width:280 height:228 align:#left
	button 'btn_unwrap' "Unwrap UVW" pos:[204,392] width:76 height:28 align:#left
	checkbox 'chk_collapse' "Collapse Modifier" pos:[12,256] width:100 height:16 checked:true align:#left
	bitmap 'bmp_preview' "Bitmap" pos:[12,24] width:264 height:200 align:#left
	checkbox 'chk_autoorient' "Orientation Auto" pos:[12,276] width:100 height:16 checked:false align:#left
	dotNetControl 'edt_filter_names' "textbox" pos:[320,24] width:204 height:20 align:#left
	dotNetControl 'lv_mat_names' "listView" pos:[292,48] width:252 height:368 align:#left
	button 'btn_clear_text' "<" pos:[526,24] width:18 height:20 toolTip:"Clear Text" align:#left
	GroupBox 'grp4' "Materials:" pos:[288,4] width:264 height:420 align:#left
	label 'lbl7' "filter:" pos:[292,28] width:28 height:12 align:#left
	GroupBox 'grp5' "Settings:" pos:[4,236] width:280 height:152 align:#left
	button 'btn_get_sel' "Get Simmilar" pos:[8,392] width:84 height:28 align:#left
	
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
	fn addTempMaterial obj sel_item = (
		
		if classOf obj != Editable_Poly do (
			
			messageBox "Object must be Editable Poly." title:"Aborted:"
			return false
		)
		local mod_matid, sublevel = subobjectLevel
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
		local mod_uvw = uvwMap axis:2 maptype:0 mapChannel:1 realWorldMapSize:false --name:sel_item.key
		if (chk_autoorient.checked and sublevel == 4) then (
			
			alignUVGizmoToSelectedFaces obj mod_uvw
			
		)  else (
			
			modPanel.addModToSelection mod_uvw ui: on -- Add UVW Map Modifier to selection 	
		)
		--format "mo w:% h:% name:%\n" mod_uvw.width mod_uvw.length sel_item
		local mat_data = sel_item.tag.value
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
	fn applyUnwrapUVW = (
		
			local mo = 	Unwrap_UVW ()
			modPanel.addModToSelection mo ui:on
			mo.edit()	
	)
	fn fillListView lv items = (
		
		lv.BeginUpdate()
		lv.items.Clear()
		local all_items = #()
		for itm in items do ( 
			
			local li = dotNetObject "ListViewItem" itm.key
			li.UseItemStyleForSubItems=true
			li.BackColor= drawingColor.fromArgb 90 200 200
			format "add item name:% id:%\n" itm.key itm.id
			li.tag = dotnetMxsValue  itm  --DotNet value holding the MAXScript value
			
			li.subitems.add (itm.id as String)
            li.subitems.add "NaN"
			li.subitems.item[0].name="0"
			li.subitems.item[1].name="1"
			
			append all_items li 
		)
		format "lv:% items:% all_items:%\n" lv items.count all_items.count
		lv.Items.AddRange all_items
		lv.items.item[ 0 ].selected = true --select first item
		lv.EndUpdate()
		lv.Refresh()
		lv.Update()
		--lv.focus()
  	)
	
	fn filterListView lv ignoreCase:true = (
			
		local search_str = edt_filter_names.text
		--collect all items before filtering. They canbe restored when filter changes
		if list_items.count < lv.items.count do (
		
			list_items = for i = 0 to lv.Items.count-1 collect lv.Items.item[ i ] --recolect list items
			list_names = for i in list_items collect i.text --recolect list names
		)
		
		local list = (
			
			local tempAry = #()
			local pat = search_str + "*"
			for n in list_names where matchPattern n pattern:pat do (append tempAry n)
			tempAry
		)
		
		lv.items.clear()
		if list.count == 0 do (current_list_item = undefined; return false)
		
		if search_str != "" then ( --get items from list_items in to new_list_array
	
			local new_list_items = for i in list collect ( list_items[ findItem list_names i ] )
			lv.items.addrange ( new_list_items )
			if lv.items.count != 0 do current_list_item = new_list_items[1]
				
		) else (
			
			lv.items.addrange list_items --fill list with all  items
			if lv.items.count != 0 do current_list_item = list_items[1] --set first item as current
		)
		if lv.items.count == 0 do return false
		lv.items.item[ 0 ].selected = true --select first item
	)
	fn  selectSimillarFaces =(
		
		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		if subobjectLevel != 4 and subobjectLevel != 5 do return false
		local fsel = polyOp.getFaceSelection obj as Array
		if fsel.count < 1 do return false
		local id  = polyop.getFaceMatID obj fsel[1] --get first face Mat ID
		if id == undefined do return false
		local newFaceSel = for f = 1 to obj.numfaces where polyop.getFaceMatID obj f == id collect f
		setFaceSelection obj newFaceSel --set the selection when the loop is done!
	)
	fn init = (
		
		--Text Box
		edt_filter_names.BackColor = drawingColor.fromArgb winColor.r winColor.g winColor.b
		edt_filter_names.ForeColor = drawingColor.fromArgb textColor.r textColor.g textColor.b
		edt_filter_names.AcceptsTab = false
		edt_filter_names.Multiline = false
		--List View
		local column_names=#("Name", "ID", "SID")
		lv_mat_names.BackColor = drawingColor.fromArgb winColor.r winColor.g winColor.b
		lv_mat_names.ForeColor = drawingColor.fromArgb textColor.r textColor.g textColor.b
		lv_mat_names.MultiSelect = false
		lv_mat_names.FullRowSelect=true		--Set so full width of listView is selected and not just first column.
		lv_mat_names.GridLines=true			--Show lines between the items.
		lv_mat_names.CheckBoxes=false
		lv_mat_names.HideSelection=false
		lv_mat_names.LabelEdit = false
		lv_mat_names.LabelWrap = false
		lv_mat_names.sorting = lv_mat_names.sorting.ascending
		lv_mat_names.allowDrop = false
		lv_mat_names.view = lv_mat_names.view.Details
		lv_mat_names.HeaderStyle = lv_mat_names.HeaderStyle.Nonclickable
		lv_mat_names.Columns.add column_names[1] 147
		lv_mat_names.Columns.add column_names[2] 50
		lv_mat_names.Columns.add column_names[3] 50
		--Fill List View
		fillListView lv_mat_names mat_items
		--Focus Text Box
		setFocus edt_filter_names
	)
	on mcQuickMaterialsDialog open do init()
	on lv_mat_names ItemSelectionChanged arg do (
		
		local a = lv_mat_names.SelectedItems
		if a.count > 0 do (
			
			--format "sel items:%\n" a.item[0].tag
			--local mat_name = execute  (a.item[0].subitems.item[0].text)
			local mat_id = execute  (a.item[0].subitems.item[1].text)
			--local mat_sid = execute  (a.item[0].subitems.item[2].text)
			previewMaterial mat_id
		)
	)
	on btn_apply pressed do (if lv_mat_names.selectedItems.count > 0 do addTempMaterial $ lv_mat_names.selectedItems.item[0])
	on btn_unwrap pressed do (applyUnwrapUVW())
	on edt_filter_names keyUp arg do (filterListView lv_mat_names)
	on btn_clear_text pressed do (edt_filter_names.text = ""; filterListView lv_mat_names)
	on btn_get_sel pressed  do (selectSimillarFaces())
)
createDialog mcQuickMaterialsDialog




/*
lv_mat_names.selectedItems.item[0].text

   private void listView1_MouseClick(object sender, MouseEventArgs e)
    {
        ListView list = sender as ListView;

        for (int i = 0; i < list.Items.Count; i++)
        {
            if (list.Items[i].Bounds.Contains(e.Location) == true)
            {
                list.Items[i].BackColor = Color.Blue; // highlighted item
            }
            else
            {
                list.Items[i].BackColor = SystemColors.Window; // normal item
            }
        }
    }
*/