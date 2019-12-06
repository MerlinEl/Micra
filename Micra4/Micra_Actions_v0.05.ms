Global mcAction
Global mcCreate

--fix this
Global mcSelVertsInXDialog
Global mcSilhouetteSelection
Global mcSilhouetteWirecolors

struct mcAction (

	url = getSourceFileName(),
	fn getSource = getSourceFileName(), --get path of this script
	fn addModToSel mod_name = --add modifier to selection
	(
		local sel = selection as array
		if sel.count == 0      do return false
		if classof mod_name != name do return false 
		
		undo label:"Add Modifier" on try
		(
			case mod_name of
			(
				#Extrude       : modPanel.addModToSelection (Extrude       ()) ui:on
				#Lathe         : modPanel.addModToSelection (Lathe         ()) ui:on
				#Mirror        : modPanel.addModToSelection (Mirror        ()) ui:on
				#MeshSmooth    : modPanel.addModToSelection (MeshSmooth    ()) ui:on
				#Slice         : modPanel.addModToSelection (SliceModifier ()) ui:on
				#UvwMap        : modPanel.addModToSelection (UvwMap        ()) ui:on
				#Unwrap_UVW    : (
						
					local mo = 	Unwrap_UVW ()
					modPanel.addModToSelection mo ui:on
					--mo.setIgnoreBackFaceCull off
					--mo.unwrap.move()
					--mo.unwrap2.setFreeFormMode on
					mo.edit()
				)
				#Bend          : modPanel.addModToSelection (Bend          ()) ui:on
				#Taper         : modPanel.addModToSelection (Taper         ()) ui:on
				#Noise         : modPanel.addModToSelection (Noisemodifier ()) ui:on
				#Twist         : modPanel.addModToSelection (Twist         ()) ui:on
				#Skew          : modPanel.addModToSelection (Skew          ()) ui:on
				#Stretch       : modPanel.addModToSelection (Stretch       ()) ui:on
				#Push          : modPanel.addModToSelection (Push          ()) ui:on
				#Melt          : modPanel.addModToSelection (Melt          ()) ui:on
				#Shell         : modPanel.addModToSelection (Shell         ()) ui:on
				#Projection    : modPanel.addModToSelection (Projection    ()) ui:on
				#Relax         : modPanel.addModToSelection (Relax         ()) ui:on
				#CameraMap     : modPanel.addModToSelection (CameraMap     ()) ui:on
				#Skin          : modPanel.addModToSelection (Skin          ()) ui:on
				#Conform       : mcFile.fileInVersion "Conform"
				#mbFracture    : mcFile.fileInVersion "mbFracture"
				#ResetXForm    : 
				(
					ResetXForm sel
					if keyboard.controlPressed do convertTo sel PolyMeshObject
				)
				#Symmetry      :
				(
					modPanel.addModToSelection (Symmetry ()) ui:on
					sel.modifiers[#Symmetry].flip = on 
					sel.modifiers[#Symmetry].threshold = 0.001
				)
				#Tessellate    :
				(
					modPanel.addModToSelection (tessellate ()) ui:on
					sel.modifiers[#Tessellate].faceType = 1
					sel.modifiers[#Tessellate].tension = 0	
				)
				#StlCheck      :
				(
					
					local obj = sel[1]
					if classOf obj != Editable_Poly do return false
					modPanel.addModToSelection (STL_Check ()) ui:on
					obj.modifiers[#STL_Check].Selection_Type = 4
					obj.modifiers[#STL_Check].Check_Now = 1
				)
			)
		)
		catch (format "Failed to add modifier: %\n" mod_name)
		
		local active = mcFile.readSettings Micra.UserProfile "Properties_1/mc_Dialog_F" type:"pos" == "true" --if modifiers dialog was opened in last session
		--if not keyboard.shiftPressed and not active and mc_Dialog_F != undefined do destroyDialog mc_Dialog_F
	),
	fn translateCubeMapToAway3D = 
	(
		if selection.count == 0 do return false
		local cube_mat = $.material
		local reflect_mat = cube_mat.diffusemap
		local textures = reflect_mat.bitmapName    
		for f in textures do(

			local fname = getFilenameFile f
			local fpath = getFilenamePath f
			local ftype = getFilenameType f
			local pattern = substring fname (fname.count-1) fname.count --get two last letters
			
			--format "pattern:% fname:% ftype:% fpath:%\n" pattern fname ftype fpath
			
			local away_name = ""
			
			case (pattern) of (
			
				"UP": away_name += "cubemap_posY"
				"DN": away_name += "cubemap_negY"
				"LF": away_name += "cubemap_negX"
				"RT": away_name += "cubemap_posX"
				"FR": away_name += "cubemap_negZ"
				"BK": away_name += "cubemap_posZ"
				default:away_name += "none"
			)
			
			local new_f = fpath + away_name + ftype
			print ("create new file:" + new_f)
			copyFile f new_f
		)
	),
	fn UVW_Align type:#u =
	(
		local uv       = modpanel.getcurrentobject()
		if classOf uv != Unwrap_UVW do return false
		local uvsel    = uv.getselectedvertices() as array
		local mid      = 0.0
		
		uv.forceupdate false
		
		case type of
		(
			#u:
			(
				for i in uvsel do
				(
					mid += (uv.getvertexposition currenttime i).x
				)
				mid /= uvsel.count
				
				undo "Align U" on uv.movex mid
			)
			#v:
			(
				for i in uvsel do
				(
					mid += (uv.getvertexposition currenttime i).y
				)
				mid /= uvsel.count
				
				undo "Align V" on uv.movey mid
			)
		)
		
		uv.forceupdate true
		uv.updateview()
	),
	fn UVW_Offset = 
	(
		max modify mode
		local sel = selection as array
		try
		(
			undo "Offset Mapping" on 
			(
				modPanel.addModToSelection (UVW_Xform ()) --ui:on
				--addModifier sel[i] (UVW_Xform ()) --[before:index] -- mapped
				for i in sel do
				(
					select i
					i.modifiers[#UVW_Xform].U_Offset = 1
					maxOps.CollapseNodeTo i 1 true
				)
				collapseStack sel
			)
		)
		catch()
	),
	fn tempUnwrapPack chn:8 val:10.0 = -- using vert data channel 8 , starting at value 10.0
	(
		local sel = selection as array
		local first_obj = sel[1]
		if sel.count < 2 or classOf first_obj != Editable_Poly do return false
		-- setup place for vData 
		polyOp.setNumVDataChannels first_obj chn -- add new channel
		polyOp.setVDataChannelSupport first_obj chn TRUE -- enable new channel supporting 
		-- assing a value for first verts group
		polyOp.setVDataValue first_obj chn first_obj.verts val
		local group_values = #( val                 )
		local group_names  = #( first_obj.name      )
		local group_pivots = #( first_obj.pivot     )
		local group_colors = #( first_obj.wirecolor )
		-- grouping poly objects
		undo "Temp Unwrap" on for i=2 to sel.count do -- attach next obj and create new set for each
		(
			local next_obj = sel[i] --get next object from array
			if classOf next_obj != Editable_Poly do continue -- skip object if is not poly
			
			group_values += #( val+i              )
			group_names  += #( next_obj.name      )
			group_pivots += #( next_obj.pivot     )
			group_colors += #( next_obj.wirecolor )
			
			local old_verts = first_obj.verts as bitarray -- get old verts
			polyOp.attach first_obj next_obj   -- attach new object
			local all_verts = first_obj.verts as bitarray -- get all verts
			local new_verts = all_verts - old_verts -- make an intersection 
			
			polyOp.setVDataValue first_obj chn new_verts ( val+i ) -- assing next flag for new verts
		)
		--store old objects data
		setUserProp first_obj "VDataChannelValues" group_values
		setUserProp first_obj "VDataChannelNames"  group_names
		setUserProp first_obj "VDataChannelPivots" group_pivots
		setUserProp first_obj "VDataChannelColors" group_colors
		setUserProp first_obj "VDataChannel"       chn
		
		clearSelection()
		select first_obj
	),
	fn tempUnwrapUnPack =
	(
		local obj = selection[1]
		local chn = (getUserProp obj "VDataChannel")
		
		if chn == undefined then return false
		
		if classOf obj != Editable_Poly or not (polyOp.getVDataChannelSupport obj chn) do return false
		
		local values = getUserProp obj "VDataChannelValues"
		local pivots = getUserProp obj "VDataChannelPivots"
		local colors = getUserProp obj "VDataChannelColors"
		local names  = getUserProp obj "VDataChannelNames"

		if values  == undefined then return false else values  = execute values 
		if pivots  == undefined then return false else pivots  = execute pivots
		if colors  == undefined then return false else colors  = execute colors
		if names   == undefined then return false else names   = execute names

		for i=2 to values.count do
		(
			local new_obj_verts = #()
			for v in obj.verts as bitarray do 
			(
				local val = polyOp.getVDataValue obj chn v
				if val == values[i] do new_obj_verts += #(v)
			)
			if new_obj_verts.count > 2 do 
			(
				local faces = polyOp.getFacesUsingVert obj new_obj_verts
				polyOp.detachFaces obj faces delete:true asNode:true name:names[i] 
				local node = getNodeByName names[i] 
				if node != undefined do 
				(
					node.pivot     = pivots[i]
					node.wirecolor = colors[i]
				)
			)
		)
		completeRedraw()
	),
	fn pickEdgePivot =
	(
		local obj = selection[1]
		if obj != undefined and classOf obj != Editable_Poly do return false
		local edge = ((polyop.getEdgeSelection obj) as array)[1]
		local edge_vert = ((polyOp.getVertsUsingEdge obj edge)as array)[1]
		if edge == undefined do return false
		--get edge normal
		local edge_faces = ((polyOp.getFacesUsingEdge obj edge) as array)
		local the_normal
		if edge_faces.count == 1 
		then the_normal = normalize (polyOp.getFaceNormal obj edge_faces[1])
		else the_normal = normalize (((polyOp.getFaceNormal obj edge_faces[1]) + (polyOp.getFaceNormal obj edge_faces[1]))/2)
		--create temp point and assing him to tools mode
		local p = point pos:(polyOp.getVert obj edge_vert) dir:the_normal name:(uniqueName "temp_align_point") wirecolor:green
		toolMode.coordsys p
	),
	fn objectAlignByTwoEdges =
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
	),
	fn object_move_to_center =
	(
		undo label:"Center Object's" on
		(
			for i in selection where not isGroupMember i do i.pos = [0,0,0]
		)
	),
	fn object_move_to_grid =
	(
		undo label:"Object's to Grid" on
		(
			for i in selection where not isGroupMember i do 
			(
				if keyboard.shiftPressed then i.pos.y = 0
				else if keyboard.controlPressed then i.pos.z = 0
				else i.pos.x = 0
			)
		)
	),
	fn moveObjectToGround = (
		
		undo "Object's to Ground" on (
			
			if selection.count == 1 then ( --aim snap object
				
				if keyboard.shiftPressed then ( --show planter tool
				
					 mcFile.fileInVersion "Object_Planter"
					
				) else (  --snap selected objwcts to z min
					
					for i in selection do (i.pos.z = i.pivot.z - i.min.z)
				)
				
			) else (
				
				mcCall.displayMsg "Selektni si nejdrive nejake objeky." green
			)
		)
	),
	fn mergeMaxFileByPath =
	(
		if keyboard.shiftPressed 
		then
		(			
			local file_path = mcFile.getClipboardTxt()
			if file_path == "" or not doesFileExist file_path do return false
			if getFilenameType file_path != ".max" do return false
			loadMaxFile file_path
		)
		else
		(
			max file merge
		)
	),
	fn objectsReplace = --replaces Object InBase from first selected
	(
		undo "Replace Object" on
		(
			local sel = selection as array
			if sel.count < 2 do return false
			local source = sel[1]
			for i = 2 to sel.count do sel[i].baseobject = source
		)
	),
	fn objectNameDupplicate =
	(
		local all_names = for i in objects collect i.name
		local dupplicates = #()
		while all_names.count != 0 do
		(
			local n = all_names[1]
			deleteItem all_names 1 
			if findItem all_names n != 0 do dupplicates += #(n)
		)
		format "dupplicates found:%\n" dupplicates.count
		print dupplicates
	),
	fn objectGradient c1 c2 = -- objectGradient green blue
	(
		local sel = selection as array
		if sel.count < 2 do return false
		if classOf c1 != color or classOf c2 != color do return false
		
		stepsize_r = (c2.r - c1.r)/$.count
		stepsize_g = (c2.g - c1.g)/$.count
		stepsize_b = (c2.b - c1.b)/$.count
		
		for i=1 to sel.count do
		(
			local newColor = (color \
			((i*stepsize_r)+c1.r-stepsize_r) \
			((i*stepsize_g)+c1.g-stepsize_g) \
			((i*stepsize_b)+c1.b-stepsize_b))
			$[i].wirecolor = newColor
		)
	),
	fn randomWirecolor =
	(
		for i in selection do i.wirecolor = color (random 1 255) (random 1 255) (random 1 255)
	),
	fn pivot_move_to_center =
	(
		undo label:"Center Pivot" on
		(
			for i in selection do (i.pivot = ((i.max + i.min)/2))
		)
	),
	fn pivot_move_to_x =
	(
		undo label:"Pivot to X" on
		(
			for i in selection do (i.pivot = [0, i.pos.y, i.pos.z])
		)
	),
	fn pivot_align_limited =
	(
		local sel = selection as array
		if sel.count != 0 do
		(
			if keyboard.controlPressed then 
			(
				local pers =(viewPort.getType() == #view_persp_user)
				local user =(viewport.getType() == #view_iso_user)
				if pers or user do
				(
					sel.objectoffsetrot= (viewport.getTM()).rotationPart
					rotate sel (viewport.getTM()).rotationPart
				)
			)
			else (WorldAlignPivot sel) --Align pivot to world
		)
	),
	fn pivot_iron_sight =
	(		
		if (keyboard.shiftPressed) then 
		(
			local dPos = ((GetDialogPos pivDialog) + (GetDialogSize pivDialog) + [6,-58])
		
			rollout slidDialog "" width:252 height:58
			(
				slider sldVal "" pos:[10,20] width:244 height:25 type:#integer ticks:10
				label lbl "  Zoom Factor: [0]" pos:[72,4] width:108 height:16
				on slidDialog rbuttonup pos do destroyDialog slidDialog
				on slidDialog open do 
				(
					local val = mcFile.readSettings Micra.UserSettings "Settings/AimScaleFactor"
					lbl.caption = "  Zoom Factor: ["+val+"]"
					sldVal.value = execute val 
				)
				on sldVal changed val do
				(
					lbl.caption = "  Zoom Factor: ["+val as string+"]"
				)
				on sldVal buttonup do
				(
					mcFile.saveSettings Micra.UserSettings "Settings/AimScaleFactor" (sldVal.value as string)
					destroyDialog slidDialog
				)
			)
			CreateDialog slidDialog pos:dpos style:#(#style_border)
		)
		else
		(
			local iVal = mcFile.readSettings Micra.UserSettings "Settings/AimScaleFactor"
			
			--Store Snap Settings
			local snap_settings = mcSnap.getSnapSettings()

			completeredraw()
			
			--Enable 3D Snap only in Faces
			snapMode.type = #3D
			snapMode.Active = on
			mcSnap.setItems off
			mcSnap.enabled #("Face") on
			
			--Get aim point from picked surface
			local aimp = pickPoint snap:#3D
			if classOf aimp == Point3 do
			(
				local size = execute iVal --zoom factor
				local mi = aimp+[-size,-size,-size]
				local ma = aimp+[size,size,size]
			
				viewport.ZoomToBounds false mi ma
			)
			
			--Restore Snap Settings
			mcSnap.setSnapSettings snap_settings
		)
		--**\ Created by Merlin el' 9.6.2006 10:11:23 /**--
	),
	fn pivot_align_3p =
	(
		local sel = selection[1]
		if sel == undefiend do return false

		fn localMatrix p1 p2 p3 = 
		(
			v1 = normalize (p2 - p1)
			v3 = normalize (cross v1 (normalize (p3 - p1)))
			v2 = normalize (cross v3 v1)
			return matrix3 v1 v2 v3 p1
		)

		local p1, p2, p3, UserSnap, UserVertSnap
		
		--Store  snap property
		local snap_settings = mcSnap.getSnapSettings()

		
		--Set snap property
		snapMode.Active = on
		mcSnap.enabled #("Vertex") on
		
		p1 = pickpoint snap:#3d
		if classof p1 == point3 then 
		(
			p2 = pickpoint snap:#3d rubberband:p1
			if classof p2 == point3 then 
			(
				p3 = pickpoint snap:#3d rubberband:p2
				if classof p3 == point3 then 
				(
					--format "p1:% p2% p3:%" p1 p2 p3
					mymatrix = localMatrix p1 p2 p3
					--create helper for align
					point name:"mcHelpAlignPivot" transform:mymatrix
					--take rotation and offset A B
					local b1Offset = sel.objectOffsetRot
					local b2Rotation = $mcHelpAlignPivot.rotation 
					--align object and pivot to helper
					in coordsys (transmatrix sel.transform.pos) sel.rotation = b2Rotation
					--return object align back
					sel.objectOffsetRot = b2Rotation
					--delete helper
					delete $mcHelpAlignPivot
				) 
			)
		)
		--Restore snap property
		mcSnap.setSnapSettings snap_settings
	),
	fn pivot_align_to_edge =		
	(		
		local obj   = (selection as array)[1]
		if obj == undefined or classOf obj != Editable_Poly do return false
		local eSel  = (polyOp.getEdgeSelection obj as array)[1]
		if eSel == undefined do return false
		
		undo "Pivot To Edge" on
		(
			ResetXForm obj
			ResetTransform obj 
			ResetScale obj
			ResetPivot obj
			ConvertToPoly obj
			
			
			local o_pos = obj.pos
			local verts = polyOp.getEdgeVerts obj eSel
			local v1_pos   = polyOp.getVert obj verts[1]
			local v2_pos   = polyOp.getVert obj verts[2]
			local o_center = (v1_pos + v2_pos) / 2
			--local eNormal  = v1_pos - v2_pos
			--local p = point pos:center dir:n
	
			local temp_tape=tape pos:(v1_pos) target:(targetObject pos:(v2_pos))
			
			pivot_rotate_angle= inverse (temp_tape.transform.rotation)
			obj.rotation *= pivot_rotate_angle
			obj.objectoffsetrot *= pivot_rotate_angle
			obj.objectoffsetpos *= pivot_rotate_angle
			obj.pos=o_pos
			obj.pivot=o_center
			
			delete temp_tape
		)
	),
	fn pivot_move_to_vert =
	(
	    local sel = selection[1]
		if sel != undefiend do 
		(
			local oldSnap = snapMode.Active
			snapMode.Active = on
			local pp = pickpoint prompt:"Click to desired location." snap:#3d 
			if pp != undefiend do sel.pivot = pp  
			snapMode.Active = oldSnap	
		)										
	),
	fn pointToVertSelection =
	(
		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		--get Pos from Vert Selection
		local vert_sel = polyOp.getVertSelection obj as array
		if vert_sel.count < 3 do return false
		local verts_pos = for v in vert_sel collect polyOp.getVert obj v
		--get Center from Vert Selection
		local verts_center = [0,0,0]
		for p in verts_pos do verts_center += p
		verts_center = verts_center/vert_sel.count
		--get Normal from Vert Selection
		local verts_normals = #()
		for i = 1 to vert_sel.count by 3 do
		(
			local pA = verts_pos [ 1 ]
			local pB = verts_pos [ if i+1 > vert_sel.count then 1 else i+1 ]
			local pC = verts_pos [ if i+2 > vert_sel.count then 2 else i+2 ]
			local vAB=pB-pA
			local vAC=pC-pA
			verts_normals += #( cross vAB vAC )
			if i+2 > vert_sel.count do exit
		)
		local verts_normal =
		(
			if verts_normals.count == 1 
			then verts_normals[1]
			else
			(
				local n = [0,0,0]
				for i in verts_normals do n += i
				n/verts_normals.count
			)
		)
		undo "Point To Selection" on point pos:verts_center dir:verts_normal name:(uniqueName "point_center")
	),
	fn pivot_to_base =
	(
		local sel = selection as array
		if sel.count == 0 do return false
		undo "Pivot to Base" on
		(	
			for i in sel do (i.pivot = [i.pos.x, i.pos.y, i.min.z])
		)
	),
	fn pivot_affect_only =
	(
		if maxops.pivotmode  == #none
		then maxops.pivotmode = #pivotonly
		else maxops.pivotmode = #none
		completeRedraw()
	),
	fn addLightMap num =
	(
		local spacing = 0.01
		local obj = selection[1]
		if getCommandPanelTaskMode() != #modify do setCommandPanelTaskMode mode:#modify
		if obj == undefined do return false
		modPanel.addModToSelection (Unwrap_UVW name:"UVW channel 1")
		local gco = modPanel.getCurrentObject()
		local verts = #{1..gco.NumberVertices()}
		
		if keyboard.shiftPressed do
		(
			gco.selectVertices verts
			gco.setWeldThreshold 0.001
			gco.weld()
		)
		--gco.copy()
		channelInfo.CopyChannel obj 3 1
		channelInfo.PasteChannel obj 3 2
		channelInfo.update()

		modPanel.addModToSelection (Unwrap_UVW name:"UVW channel 2")
		--completeRedraw()
		gco = modPanel.getCurrentObject()
		gco.setMapChannel num
		modPanel.validModifier gco -- lol , if not check , not works!
		--format "is valid:%\n" (modPanel.validModifier gco)
		--format "modifier:%\tverts num:%\n" gco verts 
		gco.selectVertices verts
		--gco.paste false
		gco.pack 0 spacing true true true
		gco.selectVertices verts
		gco.scaleSelectedCenter .95 0 --x,y
	),
	fn mirror_2 =
	(
		if selection.count == 0 do return false
		
		if keyboard.controlPressed then undo label:"Mirror 2" on
		(
			local sel_1 = selection[1]    -- control: if mirror is done
			max mirror
			if  sel_1  != selection[1] do -- control: if mirror is done
			(
				ResetXForm $
				modPanel.addModToSelection (Normalmodifier ()) ui:on
				for i in selection do i.modifiers[#Normal].flip = on
				convertTo $ PolyMeshObject
			)
		)
		else (undo label:"Mirror 2" on (max mirror))	
	),
	fn reset_transform =
	(
		if selection.count == 0 do return false
		undo label:"Reset Transform" on
		(
			Local curPos = $.pos 
			$.transform = (matrix3 [1,0,0] [0,1,0] [0,0,1] curPos)
		)
	),
	fn groups action =
	(
		local sel = selection as array
		case action of
		(		
				#create: 
				(
					if sel.count > 0 do undo "Group" on
					(
						local data = mcCall.teleportText title:"Group Name"
						if data[1] do group sel name:data[2] select:true
					) 
				)
				#destroy: (undo "Ungroup"     on ungroup sel    )
				#open:    (undo "Group Close" on max group open )
				#close:   (undo "Group Open"  on max group close)
		)
				
	),
	fn triCount =
	(
		local obj      =  selection as array
		local sel      =  false
		local TriCount =  0
		if obj.count   == 0 then 
		(
			obj = for o in objects where not o.isHidden and classOf o.baseObject == Editable_Poly collect o
		)
		else
		(
			obj = for o in obj where classOf o.baseObject == Editable_Poly collect o
			sel = true	
		)
		if obj.count == 0 do return false
		for o in obj do try (TriCount+= o.mesh.numfaces ) catch (TriCount = "")
		local click_pos = mouse.screenpos
		if sel 
		then mcCall.popUp ("Poly objects selected: "+ obj.count as string + " / " + "Triangles: " +TriCount as string) 10 dPos:[click_pos.x, click_pos.y - 50]
		else mcCall.popUp ("Poly objects in scene: "+ obj.count as string + " / " + "Triangles: " +TriCount as string) 10 dPos:[click_pos.x, click_pos.y - 50]
		--then mcCall.displayMsg ("Poly objects selected: "+ obj.count as string + " / " + "Triangles: " +TriCount as string) green
		--else mcCall.displayMsg ("Poly objects in scene: "+ obj.count as string + " / " + "Triangles: " +TriCount as string) green
	),
	fn lockObjects state =
	(
		local sel = selection as array
		if sel.count != 0 do
		(
			case state of
			(
				true : setTransformLockFlags sel #{1,2,3,4,5,6,7,8,9}--Selection Lock
				false: setTransformLockFlags sel #{}--Selection Unlock
			)
		)
	),
	fn cleanEmptyGeometry =
	(
		local Obj = for i in objects where classOf i.baseobject == Editable_Poly or classOf i.baseobject == Editable_Mesh or classOf i.baseObject == Editable_Patch collect i
		local EmptyGeometry = for i in Obj where i.Faces.count == 0 collect i
		if EmptyGeometry.count != 0 
		then
		(
			local info = newScript()
			print ("(" +(EmptyGeometry.count as string)+ ")" + " Empty geometry objects are deleted...\n") to:info
			for i in EmptyGeometry do print i.name to:info
	  		try undo "Clean Scene" on (delete EmptyGeometry) catch messagebox " Medic!" title:" Micra"
		)
		else (mcCall.popUp "Empty Geometry is not found." 100)
	),
	fn showObjectNames = --registerRedrawViewsCallback mcAction.showObjectNames ; completeredraw()
	(
		for o in objects where not o.isHidden do
		(
			gw.text o.pos o.name color:yellow
		) 
		gw.enlargeUpdateRect #whole
		gw.updateScreen()		
	),
	fn setWeldTresholdUVW = --Weld Treeshod to 0.0001
	(
		if selection.count == 1 do (try ($.unwrap_uvw.unwrap.setWeldThreshold 0.0001) catch())
	),
	fn move_verts_to axis =
	(
		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		
		if subobjectLevel == 1 then
		(
			local vSel = polyOp.getVertSelection obj
			if vSel.count == 0 do return false
			
			undo label:("Vertex To "+axis as string) on for v in vSel do
			(
				local vPos = polyop.getvert obj v 
				case axis of
				(
					#X:vPos.x = 0 
					#Y:vPos.y = 0
					#Z:vPos.z = 0
				)
				polyOp.setVert obj v vPos
			)	
		)
		else if subobjectLevel == 4 or subobjectLevel == 5 do
		(
			local face_sel = polyOp.getFaceSelection obj 
			if face_sel.count == 0 do return false
			local face_verts = polyOp.getVertsUsingFace obj face_sel
			local closest_vert = polyOp.getVert obj (face_verts as array)[1]
			
			--find vert which is most close to axis
			for v in face_verts where 
			(
				local vert_pos = polyOp.getVert obj v

				case axis of
				(
					#x:abs closest_vert.x > abs vert_pos.x
					#y:abs closest_vert.y > abs vert_pos.y
					#z:abs closest_vert.z > abs vert_pos.z
				)
			) 
			do closest_vert = vert_pos
			
			format "closest_vert:%\n" closest_vert
			
			local new_pos = case axis of
			(
				#x:-closest_vert.x
				#y:-closest_vert.y
				#z:-closest_vert.z
			)
			
			--move all verts to new pos
			for v in face_verts do
			(
				local vert_pos = polyOp.getVert obj v
				local p = case axis of
				(
					#x:[vert_pos.x + new_pos, vert_pos.y, vert_pos.z]
					#y:[vert_pos.x, vert_pos.y + new_pos, vert_pos.z]
					#z:[vert_pos.x, vert_pos.y, vert_pos.z + new_pos]
				)
				polyOp.setVert obj v p
			)
		)
	),
	fn fuseEdges =
	(
		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		if subobjectlevel != 2 do return false
		local edges_sel = polyOp.getEdgeSelection obj
		if edges_sel.numberSet == 0 do return false
		undo "Fuse Edges" on polyOp.weldEdgesByThreshold obj edges_sel
	),
	fn selectHalf side =
	(
		local faces = #()
		local obj   = selection[1]
		if obj == undefined or classOf obj != Editable_Poly do return false
		try (max modify mode ; subobjectlevel = 4) catch()
		
		local axis = "X"
		if keyboard.shiftPressed then axis = "Y"
		else if keyboard.controlPressed then axis = "Z"
		
		for f = 1 to obj.Faces.count do 
		(
			local thePos = polyOp.getFaceCenter obj f 
			case axis of
			(
				"X":
				(
					thePos.x -= obj.pos.x
					case side of
					(
						#left:  (if thePos.x < 0 do append faces f)
						#right: (if thePos.x > 0 do append faces f)
					)
				)
				"Y":
				(
					thePos.y -= obj.pos.y
					case side of
					(
						#left:  (if thePos.y < 0 do append faces f)
						#right: (if thePos.y > 0 do append faces f)
					)
				)
				"Z":
				(
					thePos.z -= obj.pos.z
					case side of
					(
						#left:  (if thePos.z < 0 do append faces f)
						#right: (if thePos.z > 0 do append faces f)
					)
				)
			)
		)
		polyOp.setFaceSelection obj faces
		completeredraw()
	),
	fn select_verts type =
	(
		local obj = selection[1]
		if obj == undefined do return false
		if classOf obj != Editable_Poly and subobjectLevel != 1 do return false
		
		case type of
		(
			#loop :
			(
				undo "Verts Loop" on
				(
					local oldEdge= (polyOp.getEdgeSelection obj.baseobject as bitarray) --store edge selection
					obj.ConvertSelection #Vertex #Edge				  
					obj.ShrinkSelection selLevel:#Edge				 
					obj.SelectEdgeLoop ()							
					obj.ConvertSelection #Edge #Vertex				  
					obj.SetSelection #edge oldEdge  						            --restore oldEdge selection
				)
			)
			#X :
			(
				rollout mcSelVertsInXDialog "Untitled" width:156 height:100
				(
					local dMove = false, DmPos
					GroupBox grp1 "Select Vertices in Center:" pos:[8,4] width:140 height:56
					label lbl1 "Range:" pos:[16,28] width:48 height:16
					spinner spnRange "" pos:[68,28] width:68 height:16 range:[0,100,0.001] type:#float scale:0.01
					button btnConect "CONECT" pos:[8,64] width:140 height:28
					/* Functions */
					fn selectVertsInRange val =
					(
						local verts = #()
						for v = 1 to $.verts.count do 
						(
							local pos = polyOp.getVert $ v 
	--						format "%\t%\n" pos.x val
							if pos.x >= -val and pos.x <= val do append verts v
						)
						polyOp.setVertSelection $ verts
						completeredraw()
					)
					fn isModeTrue = 
					(
						local obj = selection[1]
						obj != undefined and classOf obj == Editable_Poly and subobjectLevel == 1
					)
					fn CollapseVerts =
					(
						local vSel = polyOp.getVertSelection $
						if vSel.count > 0 do 
						(
							for v in vSel do
							(
								local vPos = polyop.getvert $ v 
								polyOp.setVert $ v [0, vPos.y, vPos.z] 
							)	
						)
						local oldTreshold = $.weldThreshold
						$.weldThreshold = 0.001
						$.EditablePoly.weldFlaggedVertices ()
						$.weldThreshold = oldTreshold
					)
					on mcSelVertsInXDialog rbuttonup pos do (destroyDialog mcSelVertsInXDialog)
					-->MoveMode
					on mcSelVertsInXDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
					on mcSelVertsInXDialog lbuttonup   pos do (dMove = false; pushprompt "")
					on mcSelVertsInXDialog mouseMove   pos do
					(
						if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcSelVertsInXDialog DmPos
					)
					/* Actions */
					on spnRange changed val do undo "select verts" on (if isModeTrue() do (selectVertsInRange val) )
					on btnConect pressed do undo "veld verts" on (if isModeTrue() do CollapseVerts() )
				)	
				createDialog mcSelVertsInXDialog style:#(#style_border)
			)
		)
	),
	fn select_edges type =
	(
		local obj = selection[1]
		if obj == undefined do return false
		if classOf obj != Editable_Poly and subobjectLevel != 2 do return false
		case type of
		(
			#loop   : undo "Edges Loop"   on obj.SelectEdgeLoop()
			#ring   : undo "Edges Ring"   on obj.SelectEdgeRing()
			#border : undo "Edges Border" on obj.SelectBorder()
		)
	),
	fn select_quads type =
	(
		local obj = selection[1]
		if obj == undefined do return false
		if classOf obj != Editable_Poly and subobjectLevel != 4 do return false
		local faceSel = polyOp.getFaceSelection obj as array
		if faceSel.count < 2 or not mcPoly.isQuads obj faceSel do return false 
		if (mcPoly.intersectionExists obj).numberSet == 0 then
		(--intersectionExists
				with undo on
				(--undo on
					with redraw off
					(
						local faceEdges = polyOp.getEdgesUsingFace obj faceSel[1]
						local yourSel = polyOp.getEdgeSelection obj
						polyOp.setEdgeSelection obj faceEdges
						obj.buttonOp #selectEdgeRing
						local newSel = (polyOp.getEdgeSelection sel) - faceEdges
						local oppEdge01 = newSel * (polyOp.getEdgesUsingFace obj faceSel[2])
					)
					if oppEdge01.numberSet != 0 then
					(--oppEdge01
						with redraw off
						(--redraw off
							polyOp.setEdgeSelection obj oppEdge01
							obj.buttonOp #selectEdgeRing
							local newerSel = (polyOp.getEdgeSelection obj) - oppEdge01
							local oppEdge02 = newerSel * (polyOp.getEdgesUsingFace obj faceSel[1])
							local edgesBA = #{}
							for i = 1 to 2 do
							(
								polyOp.setEdgeSelection obj #((oppEdge01 as array)[i], (oppEdge02 as array)[i])
								try (selectERing()) catch () --prevent for crash in selection one by one polygon
								local edgeSelX = polyOp.getEdgeSelection obj
								for f in edgeSelX do
								(
									append edgesBA f
								)
							)
							local SOsYouWant = #{}
							for i = 1 to (polyOp.getNumFaces obj) do
							(
								local faceEdges = polyOp.getEdgesUsingFace obj i
								if (faceEdges * edgesBA).numberSet == 2 do
								(
									append SOsYouWant i
								)
							)
							polyOp.setEdgeSelection obj yourSel
							polyOp.setFaceSelection obj SOsYouWant
						)--redraw off
						redrawViews()
					)--oppEdge01
					else
					(
						with redraw off
						(
							polyOp.setEdgeSelection obj yourSel
						)
						print "Polys are not from the same ring or poly ring is blocked"
					)
				)--undo on
		)--intersectionExists
		else
		(
			with undo on
			(
				with redraw off
				(
					local edgesBA = #{}
					local yourSel = polyOp.getEdgeSelection obj
					polyOp.setEdgeSelection obj (mcPoly.intersectionExists obj)
					obj.buttonOp #selectEdgeRing
					for i = 1 to (polyOp.getNumFaces obj) do
					(
						local faceEdges = polyOp.getEdgesUsingFace obj i
						if (faceEdges * (polyOp.getEdgeSelection obj)).numberSet >= 2 do
						(
							append edgesBA i
						)
					)
					polyOp.setEdgeSelection obj yourSel
					polyOp.setFaceSelection obj edgesBA
				)
				redrawViews()
			)
		)
	),
	fn convertSelectionTo type =
	(
		local lvl = case subobjectLevel of
		(
			1:#vertex
			2:#edge
			3:#border
			4:#face
			5:#element
		)
		local obj = selection[1]
		if obj == undefined do return false
		if classOf obj != Editable_Poly and subobjectLevel == 0 do return false
		undo "Convert Selection"  on
		(
			obj.ConvertSelection lvl type
			--switch to subobject level
			local num = case type of
			(
				#vertex:1
				#edge:2
				#face:4
			)
			subobjectlevel = num
			num = subobjectlevel
			--shrink idepend of level
			if lvl == #vertex and num == 2 then obj.ShrinkSelection selLevel:num
		)
	),
	fn make_planar type =
	(
		local obj = selection[1]
		if obj == undefined do return false
		if classOf obj != Editable_Poly and subobjectLevel == 0 do return false
		local str = "Make Planar in "+type as string
		undo str on 
		(
			obj.MakePlanarIn type
		)
	),
	fn select_oposite =
	(
		local obj = selection[1]
		if obj == undefined do return false
		if classOf obj != Editable_Poly and subobjectLevel != 1 do return false
		undo "Select Oposite" on 
		(
			local vSel, vCount, vSelPos, vOpositePos, vPos, radius, vList, inCheck
		
			vSel = polyOp.getVertSelection obj
			vCount = obj.verts.count 
			radius = 0.1
			vList = #()
			
			for v in vSel do
			(
				for i = 1 to vCount do
				(
					vSelPos = polyop.getVert obj v
					
					vSelPos.x += - obj.pos.x
					vOpositePos = [obj.pos.x - vSelPos.x, vSelPos.y , vSelPos.z] 
					
					vPos = polyop.getVert obj i
	
					if distance vOpositePos vPos < radius do 
					(
						vList += #(i)
					)
				)
			)
			if keyboard.controlPressed do (vList +=  vSel)
			polyop.setVertSelection obj vList
		)
	),
	fn swapTwoObjects =
	(
		if selection.count != 2 do return false
		local s1 = selection[1].pos
		local s2 = selection[2].pos
		selection[1].pos = s2
		selection[2].pos = s1
	),
	fn dupplicateObject =
	(
		if selection.count < 1 do return false
		copy selection
		selection[1].name = selection[1].name + "_clone"
	),
	fn capHoles =
	(
		local obj = selection[1]
		if obj == undefined or classOf obj != Editable_Poly do return false 
		if subobjectLevel == 2 or subobjectLevel == 3 do undo "Cap Holes" on (obj.capholes #edge)
	),
	fn weldVerts =
	(
		local obj = selection[1]
		if obj == undefined or classOf obj != Editable_Poly do return false 
		obj.weldThreshold = 0.001 
		if subobjectLevel == 1 do undo "Weld Vertices" on (obj.EditablePoly.weldFlaggedVertices ())
	),
	fn mirrorWeld =
	(
		local flip
		if keyboard.controlPressed then flip=true else flip=false
		local obj = selection[1]
		if obj == undefined do return false
		--obj.pivot = ((obj.max + obj.min)/2) -- center pivot
		--obj.pivot = [0, obj.pos.y, obj.pos.z] -- move pivot to X = 0
		undo "Mirror Weld" on
		(
			modPanel.addModToSelection (Symmetry ()) ui:on
			obj.modifiers[#Symmetry].flip = flip
			obj.modifiers[#Symmetry].threshold = 0.001
			convertTo obj PolyMeshObject
		)
	),
	fn weldAndAutoSmooth = with redraw off
	(
		local obj = selection[1]
		if classOf obj != Editable_Mesh and classOf obj != Editable_Poly do return false
		convertToPoly obj
		--store settings
		old_wtreshold = obj.weldThreshold
		old_streshold = obj.autoSmoothThreshold
		--setup 
		obj.weldThreshold = 0.001
		obj.autoSmoothThreshold = 60
		--perform operation
		polyOp.weldVertsByThreshold obj obj.verts
		max modify mode
		subobjectlevel = 5
		max select all
		max create mode
		polyOp.autosmooth obj
		--restore settings
		obj.weldThreshold = old_wtreshold
		obj.autoSmoothThreshold = old_streshold
		max create mode
		completeRedraw()
	),
	fn clean_verts_in_line	=
	(
		local obj = selection[1]
		if obj == undefined or classOf obj != Editable_Poly and subobjectLevel != 1 do return false 
		(
			local vSel = polyOp.getVertSelection obj
			local forRemove = #()
			for v in vSel where 
			(
				(polyOp.getEdgesUsingVert obj v).numberset < 3
			)
			do (append forRemove v)
			polyOp.setVertSelection obj forRemove
			undo "Clean Verts in Line" on obj.EditablePoly.Remove()
		)
	),
	fn find_double_faces =
	(
		local obj = Selection[1]
		if obj == undefined and classOf obj!= Editable_Poly do return false

		local DoubleFaces = #()
		local fCount = obj.faces.count
		local facesPos = for i=1 to fCount collect polyop.getFaceCenter obj i 
		for i=facesPos.count to 1 by -1 do
		(
			local fPos = facesPos[i]
			deleteItem facesPos i
			local fDouble = findItem facesPos fPos
			if fDouble != 0 do DoubleFaces += #(fDouble)
		)
		undo "Find Double Faces" on polyOp.setFaceSelection obj DoubleFaces
	),
	fn quad_check =	
	(	
		local obj = Selection[1]
		if obj == undefined and classOf obj!= Editable_Poly do return false
		local triangles = #()
		for f=1 to obj.faces.count where (polyOp.getVertsUsingFace obj f ).numberset != 4 do append triangles f
		if triangles.count != 0 
		then (polyOp.setFaceSelection obj triangles; mcCall.popUp (">> "+triangles.count as string+" << Non Quad polygons is found and selected!") 5 )
		else (mcCall.popUp "All is Quad!" 3)
	),
	fn scale_to_zb = undo "Scale To ZBrush" on (
		
		--Global BEFORE_TO_ZB_DATA = mcObject()
		local cnt = 1
		for o in selection where superClassOf o == GeometryClass do (
			
			if o.scale.x != 1 do (
				
				format "Skiped object: [ % ] Scale must be 1\n" o.name
				continue
			)
			--BEFORE_TO_ZB_DATA.add o.name o.material
			 --strore original pos in placeholder
			local s = sphere pos:o.pos name:("ZB_Placeholder_0" + cnt as string) radius:10000 wirecolor:green
			 o.pos = [0,0,0]
			--change scale for zb
			case units.SystemType of ( --ZB default cube is 5x5 cm
				
				#meters: o.scale = [0.1, 0.1, 0.1]
				#centimeters: o.scale = [0.0001, 0.0001, 0.0001]
			)	
			cnt +=1
		)
	),	
	fn scale_from_zb = undo "Scale From ZBrush" on (
		
		local cnt = 1 
		for o in selection where superClassOf o == GeometryClass do (
			 			
			--restore original pos
			local s = getNodeByName ("ZB_Placeholder_0" + cnt as string)	
			if s != udefined do (
				
					o.pos = s.pos
					delete s
			)
			if o.scale.x != 1 do (
				
				o.scale = [1,1,1]
				continue
			)
			--restore original scale
			case units.SystemType of (	

				#meters: o.scale = [10, 10, 10]
				#centimeters: o.scale = [10000, 10000, 10000]
			)
			resetTransform o
			convertToPoly o
-- 			o = mcPoly.rebuildObject o keepScale:false
-- 			local mat = BEFORE_TO_ZB_DATA.get o.name
-- 			if superClassOf mat == material do o.material = mat
			max zoomext sel
			cnt +=1
		)
	),	
	fn concaveCheck = -- <> convex >< concave
	(
		--get all Edgs
		fn isEPoly obj = (classOf obj == Editable_Poly)
		fn collectEdgeFaces obj =
		(
			struct OBJ_DATA (edge, faces=#())
			local data=#()
			for i=1 to obj.edges.count do
			(
				local faces = (polyop.getFacesUsingEdge obj i) as array
				if faces.count == 2 do append data (OBJ_DATA i faces)
			)   
			return data
		)
		fn isConcave obj faces edg debug:false=
		(
			local edge_verts = (polyop.getVertsUsingEdge obj edg) as array
			
			local n1= polyop.getFaceNormal obj faces[1]
			local n2= polyop.getFaceNormal obj faces[2]
			
			local a1 = polyop.getFaceCenter obj faces[1]
			local a2 = n1*10+a1
			local b1 = polyop.getFaceCenter obj faces[2]
			local b2 = n2*10+b1
			local btm_dist = distance a1 b1
			local top_dist = distance a2 b2
			
			if debug do
			(
				point pos:a1 wirecolor:yellow
				point pos:b1 wirecolor:yellow
				point pos:a2 wirecolor:red
				point pos:b2 wirecolor:red
				format "Is concave?:%\n" (btm_dist > top_dist)
			)
			btm_dist > top_dist --if is concave return true
		)
		local sel = for o in selection where isEPoly o collect o
		local obj_copy
		for o in sel do
		(
			obj_copy = copy o
			obj_copy.pos.x = (o.max.x - o.min.x)
			convertToMesh obj_copy
			-- turn off all visible edges
			for f = 1 to obj_copy.numfaces do
			(
				setEdgeVis obj_copy f 1 true
				setEdgeVis obj_copy f 2 true 
				setEdgeVis obj_copy f 3 true
			)
			update obj_copy
			convertToPoly obj_copy
			
			local concave_edges = #()
			local obj_data = collectEdgeFaces obj_copy
			for d in obj_data where isConcave obj_copy d.faces d.edge debug:false do append concave_edges d.edge
			
			polyOp.setEdgeSelection obj_copy concave_edges	
		)
		if sel.count == 1 do 
		(
			select obj_copy
			max modify mode
			subobjectlevel = 2
		)
	),
	fn collapse_objects = 
	(
		if not keyboard.controlPressed 
		then --clasic way
		(
			local sel_geometry = for i in selection where superClassOf i == GeometryClass collect i
			if sel_geometry.count < 2 do return false
			try undo "Collapse" on
			(
				convertToPoly sel_geometry
				local first_obj = sel_geometry[1]
				for i=2 to sel_geometry.count do 
				(
					polyOp.attach first_obj sel_geometry[i]
					mcPopUp.progeressbar (100.*i/sel_geometry.count) msg:"Objects Collapsed:"
				)
				mcPopUp.progeressbar 100 msg:"Objects Collapsed:" close:true
				select first_obj
				messagebox "Collapse Objects Is Finished!" title:Micra.version
			) 
			catch (mcCall.popUp "Incorrect objecs!" 3)	
		)
		else -- Attach Objects With Unique ID
		(
			local sel = selection as array
			if sel.count != 0 do selection.material = sel[1].material
			--filter non editable poly obj
			fn convertToEPoly obj =
			(
				if superClassOf obj != GeometryClass do return false
				try (convertToPoly obj) catch (false)
			)

			sel = for i in sel where convertToEPoly i != false collect i

			if sel.count < 2 do return false
			local obj = sel[1]
			
			local obj_faces = (for i = 1 to obj.faces.count collect i) as bitarray
			polyop.setFaceMatID obj obj_faces 1
			
			undo "Pack By ID" on for i = 2 to sel.count do with redraw off
			(
				local next_obj = sel[i]
				(
					polyOp.attach obj next_obj
					all_obj_faces = (for i = 1 to obj.faces.count collect i) as bitarray
					local next_obj_faces =  all_obj_faces - obj_faces
					polyOp.setFaceMatID obj next_obj_faces i
					obj_faces = all_obj_faces
					mcPopUp.progeressbar (100.*i/sel.count) msg:"Objects Collapsed:"
				)
			)
			mcPopUp.progeressbar 100 msg:"Objects Collapsed:" close:true
			messagebox "Packed By ID" title:" Finished"
		)
		completeRedraw()
	),
	fn hold_fetch_scene type =	
	(
		case type of
		(
			#hold : holdMaxFile()
			#fetch: if checkForSave() do  fetchMaxFile quiet:true
		)
	),
	fn holdSelection = (
	
		local sel = selection as array
		local obj = sel[1]
		local xml_file = Micra.UserDir + "Hold_Fetch_Selection_Data.xml"
		if sel.count > 1 then ( --save selected objects in Set List
		
			if keyboard.controlPressed --save selection in to xml
			then (

				mcFile.delSettings xml_file "Selection" type:"keys"
				mcFile.saveSettings xml_file "Selection" (for i in sel collect i.name) type:"keys"
		
			) else (
			
				selectionSets["objSel"] = selection
			)
		) else if obj != undefined and classOf obj == Editable_Poly and modPanel.getCurrentObject() != undefined and subobjectLevel > 0 then ( --save seleccted elements in Set List
		
			case subobjectLevel of( --save selection at current level [vertices, triangls, polygons]
			
				1: obj.verts["vSel"] = (polyOp.getVertSelection obj.baseobject)
				2: obj.edges["eSel"] = (polyOp.getEdgeSelection obj.baseobject)
				4: obj.faces["fSel"] = (polyOp.getFaceSelection obj.baseobject)
			)
		) else if obj != undefined and keyboard.altPressed do ( --when Alt pressed save single object pos
		
			mcGM.setParam "selected_object_position" selection[1].pos
		)
	),
	fn fetchSelection =
	(
		local sel = selection as array
		local obj = selection[1]
		local xml_file = Micra.UserDir + "Hold_Fetch_Selection_Data.xml"
		undo "Fetch Selection" on (

			if keyboard.altPressed and classOf mcGM.getParam "selected_object_position" == point3 and selection.count == 1 then ( --when Alt pressed restore single object pos
			
				selection[1].pos = mcGM.getParam "selected_object_position"
				
			) else if keyboard.controlPressed and sel.count != 0 then ( --load selection from xml
			
				if not doesFileExist xml_file do return false
				local names = mcFile.readSettings xml_file "Selection" type:"keys"
				if names.count != sel.count do return false
				for i=1 to sel.count do sel[i].name = names[i]
				
			) else if obj != undefined and classOf obj == Editable_Poly and modPanel.getCurrentObject() != undefined and  subobjectLevel > 0 then ( --restore selected elements
			
				case subobjectLevel of ( --get selection at current level [vertices, triangls, polygons]
				
					1: if obj.verts["vSel"] != undefined then
					(
						sel = for i in obj.verts["vSel"] collect execute(filterString (i as string) "(:")[2] 
						sel += (polyOp.getVertSelection obj.baseobject)
						obj.verts["vSel"] = sel
						select obj.verts["vSel"]
					)
					2: if obj.edges["eSel"] != undefined then
					(
						sel = for i in obj.edges["eSel"] collect execute(filterString (i as string) "(:")[2] 
						sel += (polyOp.getEdgeSelection obj.baseobject)
						obj.edges["eSel"] = sel
						select obj.edges["eSel"]
					)
					4: if obj.faces["fSel"] != undefined then
					(
						sel = for i in obj.faces["fSel"] collect execute(filterString (i as string) "(:")[2] 
						sel += (polyOp.getFaceSelection obj.baseobject)
						obj.faces["fSel"] = sel
						select obj.faces["fSel"]
					)
				)
			) else if selectionSets["objSel"] != undefined do ( --restore selected objects
			
				sel = for o in selectionSets["objSel"] collect o--execute(filterString (i as string) "(:")[2]
				sel += selection as array
				selectionSets["objSel"] = sel
				select selectionSets["objSel"]
			)
		)	
	),
	fn nurms_sub_toggle =
	(
		local sel  = selection as array
		local obj = objects as array
		if sel.count != 0 then
		(
			local switch = not sel[1].surfsubdivide
			for i in sel where classof i.baseobject == Editable_Poly do i.surfsubdivide = switch
		)
		else if obj.count != 0 then
		(
			local switch = not obj[1].surfsubdivide
			for i in objects where not i.isHidden and classof i.baseobject == Editable_Poly do i.surfsubdivide = switch
		)
	),
	fn reinstance = 
	(
		--If only one object selected, try select all instances
		if (selection.count == 1) then undo "Select All Instances" on (
	
			InstanceMgr.GetInstances $ &instances
			if instances != undefined do select instances
			instances = undefined
		
		) else if (selection.count >= 1) do ( --Make instances	
			
			local obj = selection[1] --get first object
			local mat = obj.material
			local sel_replace  = deleteItem (selection as array) 1 --remove fisrt obj from array
			--chosse transform method
			local keyboard_key = if keyboard.controlPressed then #ctrl else if keyboard.shiftPressed then #shift
			format "key pressed:%\n" keyboard_key
			undo "Reinstance" on (
				
				with redraw off (
					
					max select none
					select sel_replace
					local tm_list = for o in selection collect mcTransform.getTM o --collect tm for clones
					--format "tm:%\n" tm_list
					delete selection --delete selected
					--make clones and position
					for tm in tm_list do (
						
						maxOps.cloneNodes obj cloneType:#instance newNodes:&instance_arr #nodialog
						local new_obj = instance_arr[1]
						--format "instance:%\n" new_obj
						case  (keyboard_key) of (
							
							#ctrl: obj.pos = tm.pos --pos only
							#shift: mcTransform.setRotation obj tm.rot --rotation only
							default: mcTransform.setTM new_obj tm --rotation, position and scale
						)	
						new_obj.material = mat
					)
				)
			)
			completeredraw()
		)
	),
	fn reset_mat_editor = 
	(
		local matedit_state = MatEditor.isOpen()
		if matedit_state do MatEditor.Close()
		for slots = 1 to 24 do
		(											
			getMeditMaterial slots					
			setMeditMaterial slots (standard())
			mEditMaterials [slots].name = slots as string + " - Default"
		)
		if matedit_state do MatEditor.Open()
	),
	fn materialsColorFlatten =
	(
		--collect all object assinged to projection
		local shell_obj = selection[1]
		if shell_obj == undefined do return false
		local mod_proj = shell_obj.modifiers[#projection]
		if mod_proj == undefined do return false
		local objs = for i=1 to mod_proj.numObjects() collect mod_proj.getObjectNode i
		--collect materials assinged to objects
		local mats = for i in objs collect i.material
		--change self properties for each one
		undo "Materials Color Flatten" on for i in mats do 
		(
			if       (classOf i) == Multimaterial then
			(
				for y in i where (classOf y) == Standardmaterial do 
				(
					y.selfIllumAmount = 100
					y.specularLevel = 0
					y.glossiness = 0
					y.opacity = 100
				)
			)
			else if  (classOf i) == Standardmaterial do 
			(
				i.selfIllumAmount = 100
				i.specularLevel = 0
				i.glossiness = 0
				i.opacityq = 100
			)
		)
	),
	fn silhouetteSwitch =
	(
		if displayColor.shaded == #material
		then
		(
			mcSilhouetteSelection  = selection as array
			if mcSilhouetteSelection.count == 0 do return false
			displayColor.shaded = #object
			mcSilhouetteWirecolors = for i in mcSilhouetteSelection collect i.wirecolor
			selection.wirecolor = black
		)
		else
		(
			displayColor.shaded = #material
			if mcSilhouetteSelection != undefined do 
			(
				for i = 1 to mcSilhouetteSelection.count do if isValidNode mcSilhouetteSelection[i] do 
				(
					mcSilhouetteSelection[i].wirecolor = mcSilhouetteWirecolors[i]
				)
				mcSilhouetteWirecolors = undefined
			)
		)
	),
	fn removeMaterials =
	(
		undo "Remove Materials" on selection.material = undefined
	),
	fn show_materials =
	(
		Local textures=#()
		Local debug = newScript()
		local obj = (selection as array)[1]
		if obj == undefined do return false
		local mat = obj.material
		if mat != undefined 
		then
		(
			case classOf obj.material of
			(
				MultiMaterial:
				(
					for i=1 to mat.count do
					(
						if mat.material[i].diffusemap.bitmap.filename!=undefined and finditem textures mat.material[i].diffusemap.bitmap.filename == 0 
						do append textures mat.material[i].diffusemap.bitmap.filename
					)
				)
				StandardMaterial:
				(
					if mat.diffusemap.bitmap.filename!=undefined and finditem textures mat.diffusemap.bitmap.filename ==0 
					do append textures mat.diffusemap.bitmap.filename
				)
			)
			format "\nObject: [%] have assinged material: [%]\n\n" obj.name mat.name to:debug
			format "Textures in use: (%)\n\n" textures.count to:debug
			for i in textures do (print (i as string) to:debug)
		)
		else (format "\nObject: [%] have no material assinged!\n" obj.name to:debug)
	),
	fn show_hide_texture switch =
	(
		local objArr = selection as array
		if objArr.count == 0 do return false
		for i in 1 to objArr.count do
		( 
			local mat = objArr[i].material
			if classof mat == StandardMaterial do showtexturemap mat switch
			if classof mat == MultiMaterial do 
			(
				for u in 1 to mat.numsubs do
				try showtexturemap mat[u] switch
				catch ()
			)
		)
	),
	fn image_to_plane = (
		
		local imageBrowser = dotNetObject "System.Windows.Forms.OpenFileDialog" --create a OpenFileDialog 
		imageBrowser.title = "Please select one or more Images" --set the title
		imageBrowser.Multiselect = true --allow multiple files to be selected
		imageBrowser.Filter = "Image Files(*.BMP;*.JPG;*.PNG)|*.BMP;*.JPG;*.PNG|All files (*.*)|*.*" --specify the filter
		imageBrowser.FilterIndex = 2 --set the filter drop-down list to All Files
		local result = imageBrowser.showDialog() --display the dialog, get result into variable
		if result.Equals result.Cancel do return false
		local theFilenames = imageBrowser.fileNames --the selected filenames will be returned as an array
		if theFilenames.count == 0 do return false
		local offset = 200
		undo "Image(s) To Plane" on for i = 1 to  theFilenames.count do (
			--Get texture info
			local fpath = theFilenames[i]
			local img_name="Plane_"+(getfilenamefile fpath)
			local bmp_info = getBitmapInfo  imageBrowser.fileNames[1]
			local w = bmp_info[3]
			local h = bmp_info[4]
			--Create plane
			local new_plane=Plane width:w length:h  pos:[0,0,0] lengthsegs:1 widthsegs:1 wirecolor:(color 250 200 150) name:(img_name) 
			new_plane.rotation =eulerangles -90 0 0
			new_plane.pos.y = offset*i
			--Assing texture
			local mat = Standardmaterial ()
			mat.name = img_name
			mat.diffuseMap = Bitmaptexture fileName:(fpath)
			new_plane.Material = mat
			showTextureMap new_plane.material new_plane.material.diffusemap on
		)
		/*
		--OLD
		--Get texture info
		local img=selectbitmap()
		if img == undefined do return false
			
		
		local obj_plane
		local img_name="Plane_"+(getfilenamefile img.filename)
		local BPath = (replace (img as string) 1 7 "")
		
		undo "Create plane" on
		(
			obj_plane=Plane length:(img.height) width:(img.width) pos:[0,0,0] lengthsegs:1 widthsegs:1 \ 
			wirecolor:(color 250 200 150) name:(img_name) obj_plane.rotation =eulerangles -90 0 0
		)
		--Assing texture
		local mat = Standardmaterial ()
		mat.name = img_name
		mat.diffuseMap = Bitmaptexture fileName:(BPath)
		obj_plane.Material = mat
		showTextureMap obj_plane.material obj_plane.material.diffusemap on*/
	),
	fn color_to_material =
	(
		undo "Color To Material" on for i in selection do i.material = standard diffuse:(i.wirecolor) name:(i.name)
	),
	fn select_objects_by_material =
	(
		if selection.count > 0 do 
		local objs = (for o in objects where o.material == selection[1].material collect o)
		undo "Select Objects By Material" on select objs
	),
	fn create_ambient_lights multiA:0.1 multiB:0.08 =
	(
		local light_1,light_2
		undo "Create Ambient Lights" on
		(
			--IES_Skyw
			light_1 = IES_Sky pos:[0,0,900] target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [0,0,0])) name:"Light_IES_Sky"
			light_1.multiplier = multiA
			--Skylight
			light_2 = Skylight transform:(matrix3 [1,0,0] [0,-1,0] [0,0,-1] [0,0,-600]) name:"Light_Skylight"
			light_2.multiplier = multiB
			
		)
		return #(light_1,light_2)
	),
	fn create_bounding_box =
	(
		max modify mode
		local vsel = #{}, esel = #{}, fsel = #{}
		local bmin, bmax, center, opos, slev = subobjectLevel
		local sel = selection, obj = selection[1]
		if sel.count == 0 do return false
		if classOf obj == editable_poly do
		(
			case slev of
			(
				1:(vsel = polyOp.getVertSelection obj)
				2:
				(
					esel = polyOp.getEdgeSelection obj
					vsel = polyOp.getVertsUsingEdge obj esel
				)
				3:
				(
					esel = polyOp.getEdgeSelection obj
					vsel = polyOp.getVertsUsingEdge obj esel
				)
				4:
				(
					fsel = polyOp.getFaceSelection obj
					vsel = polyOp.getVertsUsingFace obj fsel
				)
				5:
				(
					fsel = polyOp.getFaceSelection obj
					vsel = polyOp.getVertsUsingFace obj fsel
				)
			)
		)
		
		--create dummy
		if keyboard.controlPressed then undo "Create Dummy" on
		(
			if vsel.numberSet != 0 then
			(
				local sum = [0,0,0]
				for v in vsel do sum += polyOp.getVert obj v
				center = sum/vsel.numberSet
				dummy pos:center
			)
			else (dummy pos:obj.pos dir:obj.dir)
		)
		--create mesh box
		else undo "Create Bounding Box" on with redraw off
		(
			if vsel.numberSet != 0 do
			(
				local sum = [0,0,0]
				for v in vsel do
				(
					local p = polyOp.getVert obj v --vert pos				
					sum += p
					if bmin != undefined then
					(
						bmin.x = amin #(p.x, bmin.x)
						bmin.y = amin #(p.y, bmin.y)
						bmin.z = amin #(p.z, bmin.z)
						
						bmax.x = amax #(p.x, bmax.x)
						bmax.y = amax #(p.y, bmax.y)
						bmax.z = amax #(p.z, bmax.z)
					)
					else bmin = copy (bmax = p)
				)
				center = sum/vsel.numberSet
			)

			if center == undefiend 
			then 
			(
				opos   = (sel.min + sel.max)/2 
				opos.z = sel.min.z
			)
			else opos  = center
			
			local bbox = box pos:opos lengthsegs:0 widthsegs:0 heightsegs:0
			convertToPoly bbox
			local bmin = if bmin == undefiend then sel.min else bmin
			local bmax = if bmax == undefiend then sel.max else bmax
			polyOp.setVert bbox 1 bmin
			polyOp.setVert bbox 2 [bmax.x, bmin.y, bmin.z]
			polyOp.setVert bbox 3 [bmin.x, bmax.y, bmin.z]
			polyOp.setVert bbox 4 [bmax.x, bmax.y, bmin.z]
			
			polyOp.setVert bbox 5 [bmin.x, bmin.y, bmax.z]
			polyOp.setVert bbox 6 [bmax.x, bmin.y, bmax.z]
			polyOp.setVert bbox 7 [bmin.x, bmax.y, bmax.z]
			polyOp.setVert bbox 8 bmax
			local mat = standardMaterial opacity:24 diffuse:(color 196 37 248) selfIllumAmount:64
			bbox.material = mat
			bbox.name = uniqueName "C_"
			subobjectLevel = slev
		)
		completeRedraw()
	),
	fn breake_to_elements =
	(
		if  keyboard.controlPressed then ( --break by mat ID
			
			local mcCenterPivot
			fn mcCenterPivot obj =
			(
				if obj == undefined do return false
				obj.pivot = (obj.min + obj.max)/2
			)
			local obj = selection[1]
			if classOf obj != Editable_Poly do return false
			local dettaching = true
			local ID = 0
			local new_objects_names = #()
			undo "Break By ID" on while dettaching and not keyboard.escPressed do with redraw off
			(
				--format "id:%\tdetaching:%\n" id dettaching
				ID += 1
				obj.EditablePoly.selectByMaterial ID
				local element_faces = polyOp.getFaceSelection obj
				local new_obj_name = uniQueName obj.name
				new_objects_names += #(new_obj_name)
				dettaching = polyOp.detachFaces obj element_faces delete:true asNode:true name:new_obj_name
			)
			clearselection()
			delete obj
			for i in new_objects_names do mcCenterPivot (getNodeByName i)
			messagebox "Break By ID Is Finished!" title:Micra.version
		)
		else if  keyboard.shiftPressed then ( --break by polygons

			local obj = (selection as array)[1]
			if obj == undefined or classOf obj != Editable_Poly do return false
			max modify mode 
			undo "Break By Polygons" on (
				
				for p = (polyop.getNumFaces obj)-1 to 1 by -1 do (
					
					local new_name=uniquename (obj.name+"_00")
					polyOp.detachFaces obj #{p} delete:true asNode:true name:new_name
					centerpivot (getnodebyname new_name)
				)
			)
			messagebox "Break By Polygons Is Finished!" title:Micra.version
		) else ( --break by elements
			
			local obj = (selection as array)[1]
			if obj == undefined or classOf obj != Editable_Poly do return false
			max modify mode 
			subobjectlevel = 4
			--undo "Breake to Elements" on (
				local prog = 1
				local elements = #()
				while obj.faces.count > 0 do
				(
					polyop.SetFaceSelection obj 1
					obj.selectElement()
					local element = polyop.getFaceSelection obj
					local obj_name = uniqueName obj.name
					polyop.detachFaces obj element asNode:true name:obj_name
					elements += #(getNodeByName obj_name)
					mcPopUp.progeressbar (100.*prog/obj.faces.count) msg:"Elements Breaked:"
					prog += 1
				)
				delete obj
				select elements
				mcAction.objectGradient red blue
			--)
			mcPopUp.progeressbar 100 msg:"Elements Breaked:" close:true
			messagebox "Break By Elements Is Finished!" title:Micra.version
		)
		completeRedraw()
	),
	fn nurms_toggle = (
		
		if selection.count == 0 or not hasProperty selection[1] "surfSubdivide" do return false
		local current_state = selection[1].baseobject.surfSubdivide
		viewport.SetShowEdgeFaces current_state
		--classOf i == Editable_Poly or classOf i == PolyMeshObject
		undo "NURMS Toggle" on  for o in selection where hasProperty o "surfSubdivide" do (
			
			o.baseobject.showCage = false
			o.baseobject.surfSubdivide = not current_state
		)
	),
	/**
	*@Usage > divide , connect, edges, vertices, faces
	*/
	fn divide_edges =
	(	
		DisableSceneRedraw()
		try (
	-- suspendEditing which:#modify alwaysSuspend:true
	-- 		max create mode
			local gco = modPanel.getCurrentObject()
			if gco == undefined or not mcPoly.isInPoly() do return false
			local sub_level = subobjectlevel
			if sub_level == 2 do gco.connectEdgeSegments = 1 --set divide count to 1

			local eSel = mcPoly.get #eSel
			local fSel = mcPoly.get #fSel
			local vSel = mcPoly.get #vSel
			
			fn isLoop eSel =
			(
				Local fEdge = mcPoly.get #fuEdge
				Local vEdge = mcPoly.get #vuEdge
				if (eSel.count*2 == fEdge.count or vEdge.count < 4)
				then return true  --#loop
				else return false --#ring
			)
			case sub_level of
			(
				1: (--Conect Vertices
					
					if vSel.count > 1 do gco.ButtonOp #ConnectVertices
	-- 				if vSel.count > 1 do actionMan.executeAction 369982487 "40061"  -- Editable Poly: Connect
				)
				2: (--Split One or More Edges in loop --vNum == 2
					
	-- 				max create mode
					if eSel.count > 0 and (isLoop eSel) then (	
						
						gco.setSelection #Vertex #{} --deselect vertices
						case classOf gco of (
							
							Editable_Poly: (for i in eSel do gco.divideEdge i 0.5 select:on)
							Edit_Poly: (
									
								for i in eSel do gco.divideEdge i 0.5 ---node:$
								gco.Commit () --important to update changes
							)
						)
						subobjectlevel = 1
					)	else if eSel.count > 1 do ( --Split More Edges in ring
						
						gco.ButtonOp #ConnectEdges
						--actionMan.executeAction 369982487 "40061"  -- Editable Poly: Connect
					)
	-- 				max modify mode
	-- 				local max_try = 100
	-- 				while modPanel.getCurrentObject() != gco and max_try > 0 do  ( max prev mod; max_try -=1 ) --restore modifier selection
					
				)
				4:
				(
					--Divide one Face
					if fSel.count > 0 do
					(
						local vFace_1 = (mcPoly.get #vuFace) as BitArray
						for f in fSel do 
						( 
							polyOp.divideFace gco f (polyOp.getFaceCenter gco f)
						)
						local vFace_2 =  (mcPoly.get #vuFace) as BitArray
					
						subobjectlevel = 1
						polyOp.setVertselection gco (vFace_2 - vFace_1) 
					)
				)
			)
	-- 		max modify mode
	-- resumeEditing which:#modify alwaysSuspend:true
	-- 		if sub_level == 2 do subobjectlevel = 1
			EnableSceneRedraw()
			CompleteRedraw()
		) catch (
		
				EnableSceneRedraw()
				CompleteRedraw()
		)
	),
	fn detriangulate =
	(
		local obj = selection[1]
		if classOf obj != editable_poly do return false	
		triangles = for i in obj.faces where (polyOp.getVertsUsingFace obj i).numberset == 3 collect i
		for i=triangles.count to 1 by -1 where (polyOp.getVertsUsingFace obj i).numberset == 3 do
		(
			edges = (polyOp.getEdgesUsingFace obj triangles[i]) as array
			--format "edges:%\n" edges
			lenghts = for ed in edges collect 
			(
				verts = (polyOp.getVertsUsingEdge obj ed) as array
				--format "verts:%\n" verts
				distance (polyOp.getVert obj verts[1]) (polyOp.getVert obj verts[2])

			)
			--format "lenghts:%\n" lenghts
			longest_edge = edges[findItem lenghts(amax lenghts)]
			polyop.setEdgeSelection obj longest_edge
			obj.Remove selLevel:#Edge
		)
	),
	fn drawLineBetweenTwoPoints p1 p2 =
	(
		if classOf p1 != point3 and classOf p2 != point3 do return false
		local sp = SplineShape pos:p1
		addNewSpline sp
		addKnot sp 1 #corner #line p1
		addKnot sp 1 #corner #line p2
		updateShape sp
		return sp
	),
	fn drawLineBetweenTwoMeshes =
	(
		local sel = selection as array 
		if sel.count != 2 do return false
		mcAction.drawLineBetweenTwoPoints sel[1].pos sel[2].pos
	),
	fn chamfer_edge =
	(
		modPanel.addModToSelection (EdgeChEx ()) ui:on
		modPanel.addModToSelection (TurboSmooth ()) ui:on
		/*
		local my_obj     = selection[1]
		if my_obj == undefined or classof my_obj != editable_poly do return false
		local my_edge    = polyOp.getEdgeSelection my_obj 
		if my_edge.numberset == 0 do return false
		undo "Camfer_Box" on
		(
			local len = mcPoly.getEdgeLength my_obj my_edge
			polyOp.SetedgeSelection my_obj my_edge
			my_obj.EditablePoly.SelectEdgeRing ()
			my_obj.EditablePoly.ConnectEdges ()
			my_obj.EditablePoly.chamferEdges (len/2 - 0.25)
			--my_obj.EditablePoly.chamferEdges (0.1)
		) 
		*/
	),
	fn create_poly =
	(
		local obj = selection[1]
		if not mcPoly.isInPoly() or SubObjectLevel != 1 do return false
		if (polyOp.getVertSelection obj).numberset > 2 then 
		(
			polyOp.createPolygon obj (polyOp.getVertSelection obj as array)
			completeredraw()
		)
		else (print "select 3 vertices.")
	),
	fn clean_edges =
	(
		local gco = modPanel.getCurrentObject()
		if not mcPoly.isInPoly() do return false
		case subobjectlevel of
		(
			1: undo "Clean Vertices" on (
				
				case classOf gco of (
					
					Editable_Poly:selection[1].baseobject.remove()
					Edit_Poly: gco.ButtonOp #RemoveVertex
				)	
			)
			2:
			(
				local eSel = mcPoly.get #eSel
				if eSel.count == 0 do return false
	
				with undo "Clean Edges" on with redraw off
				(
					local deadVerts, vuEdges, euVert, verts = #{}, deadVerts = #{}, vuEdges = #()
					
					for i in eSel do verts += (mcPoly.getVertsFrom i)
	
					for v in verts do
					(
						euVert = (mcPoly.getEdgesFrom v) - (eSel as BitArray)				
						if (euVert.numberset == 2) or (euVert.numberset == 0) do (append deadVerts v)
					)
					
					case classOf gco of (
						
						Editable_Poly: (
							
								polyOp.setVertSelection selection[1].baseobject deadVerts
								selection[1].baseobject.remove selLevel:#edge
								selection[1].baseobject.remove selLevel:#vertex
						)
						Edit_Poly: (
								
							gco.SetSelection #Vertex deadVerts
							gco.ButtonOp #RemoveEdge
							gco.ButtonOp #RemoveVertex
						)
					)
				)
			)--2:	
		)
		redrawViews()
	),
	fn optimizeSpline num:2 = --optimizeSpline num:2 
	(
		local obj = selection[1]
		if classOf obj != SplineShape do return false
		local verts = numKnots obj 1
		undo "Optimize Spline" on for v=verts to 1 by (num* -1) do deleteKnot obj 1 v
		completeRedraw()
	),
	fn triangle_counter =
	(
		local TriCount=0, viewText = "", lastText = "", lastViewport, textPos = [5,42,0]
		local updateRect = box2 (textPos.x) (textPos.y-(gw.getTextExtent "X").y) 0 0
		local sel = selection as array
		if sel.count > 0 then
		(
			for i in sel where mcPoly.isPoly i do
			(
				try  (TriCount+=(i.mesh.numfaces)) catch (TriCount ="")
			) 
			viewText = ("Objects: "+ (sel.count as string) + " / " + "Triangles: " +(TriCount as string))
		)
		else (viewText = "Objects: 0 / Triangles: 0")

		local needUpdate = viewText != lastText
		if viewport.activeViewport != lastViewport then
		(	completeredraw()
			lastViewport = viewport.activeViewport 
		)
		else if needUpdate do
		(	local rect = gw.getTextExtent lastText
			updateRect.w = rect.x+1
			updateRect.h = rect.y+1
			gw.clearscreen updateRect useBkg:true
			gw.enlargeUpdateRect updateRect 
			gw.updateScreen() 
			gw.resetUpdateRect()
		)
		
		if (viewText != "") do
		(	gw.wtext textPos viewText color:green--(color 255 234 0)
			rect = gw.getTextExtent viewText 
			updateRect.w = rect.x+1
			updateRect.h = rect.y+1
			gw.enlargeUpdateRect updateRect
			gw.updateScreen() 
		)
		lastText = viewText
	),
	fn hide_sel =
	(
		local sel = selection as array
		if sel.count == 1 and mcPoly.isInPoly() and subobjectlevel > 0 then
		(	
			sel[1].Hide #CurrentLevel
		)
		else if sel.count > 0 do
		(
			max hide selection
		)
	),
	fn unhide_sel =
	(
		local sel = selection as array
		if sel.count == 1 and mcPoly.isInPoly() and subobjectlevel > 0 then
		(	
			sel[1].unhideAll #CurrentLevel
		)
		else
		(
			max unhide all
		)
	),
	fn make action =
	(
		local cur_mod = Filters.GetModOrObj()
		case action of
		(
			#PlanarInX: undo "Planar In X" on (cur_mod.buttonOp #MakePlanarInX)
			#PlanarInY: undo "Planar In Y" on (cur_mod.buttonOp #MakePlanarInY)
			#PlanarInZ: undo "Planar In Z" on (cur_mod.buttonOp #MakePlanarInZ)
			#PolyRelax: undo "Poly Relax"  on (cur_mod.buttonOp #Relax)
		)
	),
	fn smoothPoly =
	(
		local obj =  selection[1]
		if not mcPoly.isPoly obj  do return false
		undo "Smooth" on
		(
			modPanel.addModToSelection (smooth ()) ui:on
			obj.modifiers[#Smooth].smoothingBits = 1
			macros.run "Modifier Stack" "Convert_to_Poly"
		)
	),
	fn getSimilarFacesByID obj id =
	(
		 for f in obj.faces where polyOp.getFaceMatID obj f.index == id collect f.index	 
	),
	fn detachByID =
	(
		--local start = timeStamp()
		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		local cnt = 0
		while obj.faces.count > 0 and not keyboard.escPressed do
		(
			cnt+=1
			local faces = mcAction.getSimilarFacesByID obj cnt
			polyOp.detachFaces obj faces delete:true asNode:true name:(uniqueName obj.name)
		)
		delete obj
		--local end = timeStamp()
		--format "Processing took % seconds\n" ((end - start) / 1000.0)
	),
	fn getFaceSmoothGroup obj face = 
	( 
		if classOf obj != Editable_Poly and classOf obj != Editable_Mesh do return false
		local sgroup_val = case (classOf obj) of
		(
			Editable_Mesh: getFaceSmoothGroup obj face 
			Editable_Poly: polyOp.getFaceSmoothGroup obj face 
		)
		local sg_bitarray=#{} 
		if sgroup_val < 0 do 
		( 
			sg_bitarray[32]=true 
			sgroup_val -= 2^31 
		) 
		for i = 1 to 31 do 
		( 
			sg_bitarray[i]= (mod sgroup_val 2 > .5) 
			sgroup_val /= 2 
		) 
		sg_bitarray 
	),
	fn setFaceSmoothGroup obj face sg_bitarray = 
	( 
		if classOf obj != Editable_Poly and classOf obj != Editable_Mesh do return false
		local sgroup_val=0 
		for i in sg_bitarray do sgroup_val += 2^(i-1) 
		case (classOf obj) of
		(
			Editable_Mesh: setFaceSmoothGroup obj face sgroup_val
			Editable_Poly: polyOp.setFaceSmoothGroup obj face sgroup_val
		)
		--update obj 
	),
	fn copySmootgGroups =
	(
		Global mcSmooth_Group_Bitarray_Temp
		local obj = selection[1]
		if obj == undefined do return false
		local fcount = obj.faces.count
		mcSmooth_Group_Bitarray_Temp = for i=1 to fcount collect (mcAction.getFaceSmoothGroup obj i)
	),
	fn pasteSmoothGroups =
	(
		if mcSmooth_Group_Bitarray_Temp == undefined do return false
		local obj = selection[1]
		if obj == undefined do return false
		local fcount = obj.faces.count
		for i=1 to fcount do mcAction.setFaceSmoothGroup obj i mcSmooth_Group_Bitarray_Temp[i]
		update obj
	),
	fn selectUnsmoothFaces =
	(
		local obj = selection[1]
		if obj == undefined or classOf obj != Editable_Poly do return false
		local fcount = obj.faces.count
		local unsmooth = for i=1 to fcount where (mcAction.getFaceSmoothGroup obj i).numberset == 0 collect i
		if unsmooth.count != 0 do polyOp.SetFaceSelection obj unsmooth
		messagebox ("Unsmoothed faces found: "+ unsmooth.count as string) title:"Micra:"
	),
	--resizePlane 29.21
	fn resizePlane _length = -- proportional change size of a plane (lenhth == vyska)
	(
		local obj = selection[1]
		if classOf obj != Plane do return false
		local multiplier = obj.length / _length
		undo "Resize Plane" on
		(
			obj.length = _length
			obj.width  = obj.width / multiplier
		)
	) , 	
	fn getObjectProps = (
		
		local obj = selection[1]
		if obj == undefined do return false
		mcGM.setParam "selected_object_parent" (if obj.parent != undefined then obj.parent.name else undefined)
		mcGM.setParam "selected_object_layer" obj.layer.name
		format "Store objects(1) data:\n\tlink:%\n\tlayer:%\n" (mcGM.getParam "selected_object_parent") (mcGM.getParam "selected_object_layer")
	),
	fn setObjectProps = (
		
		local sel = selection as array
		if sel.count == 0 do return false
		local parent_name = mcGM.getParam "selected_object_parent"
		local layer_name = mcGM.getParam "selected_object_layer"
		local parent_node = if parent_name != undefined then getNodeByName parent_name else undefined
		local target_layer = if layer_name != undefined then LayerManager.getLayerFromName layer_name else undefined
		for o in sel do (
			
			if parent_node != undefined do o.parent = parent_node
			if 	target_layer != undefined do target_layer.addNode o
		)
		format "Set objects(%) data:\n\tlink:%\n\tlayer:%\n" sel.count parent_name layer_name
	),
	fn setSubobjectLevel level_index = (
	
		--switch to mmodify mode
		if subObjectLevel == undefined then max modify mode
		--if modifier not support levels go to base
		if numSubObjectLevels == 0 and selection.count == 1 do (
			
			modPanel.setCurrentObject $.baseObject -- Select the base object in the modifier stack
		)
		--if is already in wanted level or num levels is less exit
		if subObjectLevel == level_index or numSubObjectLevels < level_index do return false
		--activate subobject level
		subObjectLevel = level_index
	),
	fn getEdgesLength = ( --todo for multiple edges selected
	
		local obj = (selection as array)[1]
		 if obj == undefined or  classOf obj != Editable_Poly do return false
		local  esel = polyOp.getEdgeSelection obj	 
		if (esel.numberSet == 1) do (
			  
			local elen = mcPoly.getEdgeLength obj (esel as Array)[1]
			format "Edge: %  length: %\n"  esel elen
		)
	),
	fn pivotToZero = (
		
		undo "Pivot To Zero" on try (for o in selection do o.pivot = [0, 0, 0]) catch(format "Pivot To Zero was Failed.")
	),
	fn alignPivotToObject src_obj trg_obj = (
		
		mcPoly.alignPivotToObject src_obj trg_obj
	),
	fn alignPivotToSelectedFace = (
	
		local obj = (selection as array)[1]
		if obj == undefined or classOf obj != Editable_Poly do return false
		local face_index = (polyop.getFaceSelection obj as Array)[1]	 
		mcPoly.alignPivotToFace obj face_index
	),
	fn createPointAtVertex = (
		
		local obj = selection[1]
		local p1 = case (classOf obj) of (
			
				Editable_Poly:(
					
					local vert_index = (polyop.getVertSelection obj as array)[1]
					if vert_index == undefined do return false
					polyop.getVert obj vert_index
				)
				SplineShape:(
					
					local knot_index =  (getKnotSelection obj 1)[1]
					if knot_index == undefined do return false
					getKnotPoint obj 1 knot_index
				)
				Undefined: undefined
		)
		if p1 == undefiend do return false
		local po = point pos:p1
		subobjectlevel = 0
		select po
	),
	fn selectObjectsByWirecolor = (
		
		local obj = selection[1]
		if obj == undefined do return false
		select(for o in objects where o.wirecolor == obj.wirecolor collect o)
	),
	fn smoothPolyHard = (
		
		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		obj.autoSmoothThreshold = 5
		obj.EditablePoly.autosmooth ()
	),
	fn OffsetRotateObject = (
		
		Global mcOffsetRotationDialog
		if mcOffsetRotationDialog != undefined do destroyDialog mcOffsetRotationDialog
		rollout mcOffsetRotationDialog "Offset Rotation" width:108 height:124
		(
			button 'btn_pick_src_edge' "Get Source Edge" pos:[8,20] width:92 height:28 align:#left
			button 'btn_pick_trgt_edge' "Get Target Edge" pos:[8,52] width:92 height:28 align:#left
			button 'btn_rotate_src' "Rotate Source" pos:[8,84] width:92 height:28 align:#left
			groupBox 'grp1' "Acrtions:" pos:[4,4] width:100 height:116 align:#left
			local src_obj, src_edge_index
			local trgt_obj, trgt_edge_index
			fn getSelectedEdge &obj &edge_index = (
				
				obj = selection[1]
				if classOf obj != Editable_Poly do return false
				edge_index = (polyOp.getEdgeSelection obj as array)[1]
			)
			fn rotateObjectByEdgesAngleOffset = (
				
				if 	src_edge_index == undefined or trgt_edge_index == undefined do return false
				local e1_verts = polyOp.getVertsUsingEdge src_obj src_edge_index
				local e2_verts = polyOp.getVertsUsingEdge trgt_obj trgt_edge_index
				--format "e1_verts:% e2_verts:%\n" e1_verts e2_verts
				local e1_pos = for v in e1_verts collect polyOp.getVert src_obj v
				local e2_pos = for v in e2_verts collect polyOp.getVert trgt_obj v
				--format "e1_pos:% e2_pos:%\n" e1_pos e2_pos
				local center_p = if e1_pos[1] == e2_pos[1] then e1_pos[1] else e1_pos[2]
				local src_p	=  if e1_pos[1] == center_p then e1_pos[2] else e1_pos[1]
				local trgt_p	=  if e2_pos[1] == center_p then e2_pos[2] else e2_pos[1]
				local v1 = src_p - center_p
				local v2 = trgt_p - center_p
				local offset_angle = (acos(dot (normalize v1) (normalize v2)))
				--format "v1:% v2:% offset angle:%\n" v1 v2 offset_angle
				undo "Offset Rotate" on (src_obj.rotation.z_rotation += offset_angle)
				--undo "Offset Rotate" on (in coordsys (getRefCoordSys() )  src_obj.rotation.z_rotation += offset_angle/2)
			)
			on btn_pick_src_edge pressed  do (
				getSelectedEdge &src_obj &src_edge_index
				if src_edge_index != undefined do btn_pick_src_edge.text = ("Source Edge("+src_edge_index as String+")")
			)
			on btn_pick_trgt_edge pressed  do (
				
				getSelectedEdge &trgt_obj &trgt_edge_index
				if trgt_edge_index != undefined do btn_pick_trgt_edge.text = ("Target Edge("+trgt_edge_index as String+")")
			)
			on btn_rotate_src pressed  do rotateObjectByEdgesAngleOffset()
		)
		createDialog mcOffsetRotationDialog
	),
	fn replaceMaterialID = (
		
		Global replaceMateialIDdialog
		if replaceMateialIDdialog != undefined do destroyDialog replaceMateialIDdialog
		rollout replaceMateialIDdialog "Material ID Replace:" width:284 height:56
		(
			GroupBox 'grp1' "" pos:[4,1] width:276 height:48 align:#left
			button 'btn_go' "GO" pos:[226,13] width:46 height:28 align:#left
			spinner 'spn_from' "From ID:" pos:[12,21] width:60 height:16 range:[1,100000,1] type:#integer scale:1 align:#left
			spinner 'spn_to' "To ID:" pos:[124,21] width:70 height:16 range:[1,100000,1] type:#integer scale:1 align:#left
			fn getFacesByMatID obj mat_id = (
			
				local all_faces = #{1..(polyop.getNumFaces obj)}
				for f in all_faces where polyop.getFaceMatID obj f == mat_id collect f
			)

			fn replaceObjectID obj fom_index to_index = ( 

				local id_faces = getFacesByMatID obj fom_index
				if id_faces.count == 0 do return false
				polyop.setFaceMatID obj id_faces to_index
			)

			fn replaceObjectsID objs fom_index to_index prog_debug:false = (
				
				fn isValidClass obj = (classOf obj == Editable_Poly or classOf obj == PolyMeshObject)
				local replaced_count = 0
				with redraw off for o in objs do ( 

					if not ( isValidClass o ) do (format "Skip!. Not valid type of object:%" o.name; continue)
					local result =replaceObjectID o fom_index to_index 
					if prog_debug do format "Replaced object [ % ] ID status:%\n"  o.name result
				)
				format "Replaced objects ( % ) mat ID from:% to:%\n" replaced_count fom_index to_index 
			)

			on btn_go pressed do
			(
				local sel = selection as array
				if sel.count > 0 then (
					
					undo "Material ID Replace" on (replaceObjectsID sel spn_from.value spn_to.value prog_debug:false)
					
				) else (
					messageBox "Nothing is selected" title:"Abotred"
				)
			)
		)
		createDialog replaceMateialIDdialog
	),
	fn moveObjectToSurface = (
		
		if superClassOf ::gPlantObjectOnSurface != StructDef do mcFile.fileInVersion "Object_Planter_Interactive"
		if superClassOf ::gPlantObjectOnSurface == StructDef do gPlantObjectOnSurface.startTrace()
		/*undo "Object's to Surface" on
		(
			
			if selection.count == 1 then (--aim snap object
				
				local obj = selection[1]
				if obj == undefined do return false
				--Store Snap Settings
				local snap_settings = mcSnap.getSnapSettings()

				completeredraw()
				
				--Enable 3D Snap only in Faces
				snapMode.type = #3D
				snapMode.Active = on
				mcSnap.setItems off
				mcSnap.enabled #("Face") on
				
				--Get aim point from picked surface
				local aimp = pickPoint snap:#3D
				if classOf aimp == Point3 do obj.pos = aimp

				--Restore Snap Settings
				mcSnap.setSnapSettings snap_settings
			)
		)*/
	)
	/*<end>*/
)


struct mcCreate (

	fn getSource = getSourceFileName(), --get path of this script
	fn cameraFromView name:(uniquename "Camera") type:#target =
	(
		if viewport.getType() == #view_persp_user do
		(
			local targdist = getScreenScaleFactor [0,0,0]	 
			local viewfov = getVIewFOV()
			local cXform =  Inverse(viewport.getTM())
			local c = (Freecamera fov:viewfov targetDistance:targdist Transform:cXform orthoProjection:false name:name) 
			c.type = type
			viewport.setCamera c
			return c
		)
	),
	fn pointIn3DFromMousePos =
	(
		local tm = Matrix3(1)
		tm.row3 = -(Inverse(viewport.getTM())).row3
		local m = mouse.pos
		local p = gw.snapPoint m snapPlane:tm
		local po = point pos:p dir:tm.row3
		local dist = getScreenScaleFactor po.pos
		in coordsys local move po [0,0,-dist]
	),
	fn grid3p =	
	(	
		mcFile.fileInVersion "Create_3PGrid"
	),
	fn gridFromPlygon = (
		
		local obj = selection[1]
		if classOf Obj != Editable_Poly do return false
		local face_index = (polyOp.getFaceSelection obj as array)[1]
		if face_index == undefined do return false
		local corner_vertices = mcPoly.getFaceCornerVertices obj face_index
		local points = for v in corner_vertices collect polyOp.getVert obj v
		--create tm from 3 points
		local tm = mcTransform.getLocalMatrix points[1] points[2] points[3]
		--tm.Row4 = polyop.getfacecenter obj face_index --not realy need
		local space    = getGridSpacing()
		local lines    = getGridMajorLines()
		local gname    = uniqueName "Grid_Polygon_"
		local new_grid
		undo label:"Create 3P Grid" on new_grid = grid length:1500 width:1500 grid:space transform:tm name:gname wirecolor:black --isSelected:on
		Try (ActiveGrid = new_grid) Catch()
		Toolmode.coordsys #Grid -- change view coordinates to grid
	),
	fn cereateChecker color1:blue color2:white =
	(
		if selection.count == 0 do return false
		undo "Add Checker" on
		(
			local m = meditMaterials[6] = StandardMaterial name:"Checker Blue"
			m.diffuseMap = Checker name:"blue"
			m.diffuseMap.coords.U_Tiling = 50
			m.diffuseMap.coords.V_Tiling = 50
			m.diffuseMap.color1 = color1
			m.diffuseMap.color2 = color2
			showTextureMap m on
			selection.material = m
		)
	),
	fn createDXMaterial =
	(
		undo "Add DX Material" on
		(
			local obj = selection[1]
			if obj == undefined do return false
			local dx_mat = DirectX_9_Shader ()
			dx_mat.name = obj.name + "_DX_9"
			dx_mat.effectFile = GetDir #maxroot + "maps\fx\StandardFX.fx"
			obj.material = dx_mat
			/*
			meditMaterials[1] = DirectX_9_Shader ()
			meditMaterials[1].effectFile = GetDir #maxroot + "maps\fx\StandardFX.fx"
			meditMaterials[1].name = obj.name + "_DX_9"
			obj.material = meditMaterials[1]
			*/
		)
	),
	fn createBonesAlongThePath =
	(
		local obj = selection[1]
		if classOf obj != SplineShape do return false
		local verts = numKnots obj 1
		local points_array = for v=1 to verts collect (getKnotPoint obj 1 v)
		local bones_array = #()
		undo "Create Bones Along Path" on
		(
			--build bones
			for i=1 to points_array.count do
			(
				local p1 = points_array[i]
				local p2 = points_array[i+1]
				if p1 != undefined and p2 != undefined do bones_array += #(BoneSys.createBone p1 p2 obj.dir)
			) 
			--link bones
			for i=bones_array.count to 1 by -1 do if i > 1 do bones_array[i].parent = bones_array[i-1] 
		)
	)
	/*<end>*/
)
