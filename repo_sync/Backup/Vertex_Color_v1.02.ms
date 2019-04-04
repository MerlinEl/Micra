Global mcVertexColorDialog
if ::mcVertexColorDialog != undefined do try(destroyDialog mcVertexColorDialog)catch()
rollout mcVertexColorDialog "Vertex Color v1.02" width:408 height:296
(
	--interface
	GroupBox 'grp1' "Color Sets:" pos:[4,4] width:104 height:284 align:#left
	GroupBox 'grp2' "Actions:" pos:[112,4] width:292 height:284 align:#left
	
	button 'btn_1' "button" pos:[44,24] width:52 height:24 align:#left 
 
	button 'btn_2' "button" pos:[44,52] width:52 height:24 align:#left
	button 'btn_3' "button" pos:[44,80] width:52 height:24 align:#left
	button 'btn_4' "button" pos:[44,108] width:52 height:24 align:#left 
 
	button 'btn_5' "button" pos:[44,136] width:52 height:24 align:#left 
 
	button 'btn_6' "button" pos:[44,164] width:52 height:24 align:#left 
 
	button 'btn_7' "button" pos:[44,192] width:52 height:24 align:#left
	button 'btn_8' "button" pos:[44,220] width:52 height:24 align:#left 
 
	button 'btn_show_colors' "ON" pos:[232,112] width:80 height:24 align:#left
	button 'btn_hide_colors' "OFF" pos:[320,112] width:80 height:24 align:#left
	button 'btn_show_alpha' "ON" pos:[232,140] width:80 height:24 align:#left
	button 'btn_hide_alpha' "OFF" pos:[320,140] width:80 height:24 align:#left
	button 'btn_show_shaded' "ON" pos:[232,168] width:80 height:24 align:#left
	button 'btn_hide_shaded' "OFF" pos:[320,168] width:80 height:24 align:#left
	button 'btn_set' "Assign" pos:[116,20] width:140 height:88 align:#left
	button 'btn_sel' "Select" pos:[264,20] width:136 height:88 align:#left
	button 'btn_set_dx' "Set DX Shader to selection" pos:[120,200] width:276 height:24 align:#left
	button 'btn_copy_dx' "Copy values from LS3D material to DX Shader" pos:[120,228] width:276 height:24 align:#left
	button 'btn_remove_dx' "Remove DX Shader from selection" pos:[120,256] width:276 height:24 align:#left

	radiobuttons 'rdo_1' "" pos:[12,28] width:31 height:16 labels:#("1") default:1 align:#left
	radiobuttons 'rdo_2' "" pos:[12,56] width:31 height:16 labels:#("2") default:0 align:#left
	radiobuttons 'rdo_3' "" pos:[12,84] width:31 height:16 labels:#("3") default:0 align:#left
	radiobuttons 'rdo_4' "" pos:[12,112] width:31 height:16 labels:#("4") default:0 align:#left
	radiobuttons 'rdo_5' "" pos:[12,140] width:31 height:16 labels:#("5") default:0 align:#left
	radiobuttons 'rdo_6' "" pos:[12,168] width:31 height:16 labels:#("6") default:0 align:#left
	radiobuttons 'rdo_7' "" pos:[12,196] width:31 height:16 labels:#("7") default:0 align:#left
	radiobuttons 'rdo_8' "" pos:[12,224] width:31 height:16 labels:#("8") default:0 align:#left

	label 'lbl_svc' "Show Vertex Colors:" pos:[120,116] width:104 height:20 align:#left
	label 'lbl_sva' "Show Vertex Alpha:" pos:[120,144] width:104 height:20 align:#left
	label 'lbl_svs' "Show Vertex Shaded:" pos:[120,172] width:104 height:20 align:#left

	--local variables
	local bmp_colors = #(
		color 0 255 0, --1
		color 32 0 128,
		color 64 225 225,
		color 96 128 0,
		color 128 128 128,
		color 160 128 255,
		color 192 0 0,
		color 224 0 255 --8
	)
	local current_color_index = 1

	--local functions
	fn getSelectionType sel= (
		
		if sel.count > 0 and  (subobjectLevel == undefined or subobjectLevel == 0) do return "objects"
		if subobjectLevel == 1 do return "verts"	
		if subobjectLevel == 4 or subobjectLevel == 5 do return "faces"	
	)
	fn isValidObject obj = (
	
		return classOf obj == Editable_Poly or classOf obj == Editable_Mesh	
	)
	fn getEditableObject obj = (
		
		local editable_object = undefined
		-- FOR MULTIPLE OBJECTS OPERATIONS
		if subobjectlevel == undefined or subobjectlevel == 0 then ( --if not editing object
			
			editable_object = obj.baseObject
			
		-- FOR SINGLE OBJECTS OPERATION
		) else if obj.modifiers.count == 0 then ( --if no modifiers
			
			if isValidObject obj do editable_object = obj
				
		) else (
			
			setCommandPanelTaskMode #modify
			local curren_mod = modpanel.getCurrentObject()
			if classOf curren_mod == Edit_Poly or classOf curren_mod == Edit_Mesh then ( --get editable modifier
				
				editable_object = curren_mod
			
			) else ( --get baseobject
			
				local base_object = obj.baseObject
				return if isValidObject base_object do editable_object = base_object
			)
		)
		return editable_object
	)	
	fn getVertexCount obj = (
	
		local editable_object = getEditableObject obj
		format "getVertexCount > editable_object:%\n" editable_object
		return case (classOf editable_object) of (

			Editable_Poly: polyop.getNumVerts editable_object
			Editable_Mesh: meshOp.getNumVerts editable_object
			Edit_Poly: editable_object.getNumVertices() --modifier
			Edit_Mesh: editable_object.getNumVertices() --modifier
			Default: 0
		)
	)

	--------
	fn getBaseNumVerts base_object = (
		
		return case (classOf base_object) of (

			Editable_Poly: polyop.getNumVerts base_object
			Editable_Mesh: meshOp.getNumVerts base_object
			Default: 0
		)
	)
	fn setObjectsColor sel verts_color map_channel = (
		
		undo "Set objects color" on for o in sel do (

			local base_object =  o.baseObject
			local num_verts = getBaseNumVerts base_object
			format "setObjectsColor > obj:% numverts:%\n"  base_object num_verts
			for i = 1 to num_verts do (
				
				--clr = color (random 0 255) (random 0 255) (random 0 255); --random colors (rainbow efect)
				case (classOf base_object) of (

					Editable_Poly: polyOp.setVertColor base_object map_channel i verts_color
					Editable_Mesh: meshOp.setVertColor base_object map_channel i verts_color
				)
			)
			update o
		)
	)
	fn setFacesColor obj verts_color = (
		
		format "setFacesColor > obj:% verts_color:%\n"  obj.name verts_color
		undo "Set face color" on obj.SetFaceColor verts_color #VertexColor
		/*undo "Set face color" on (
			
			local base_object =  obj.baseObject
			case (classOf base_object) of (

				Editable_Poly: polyOp.setFaceColor base_object 0 (getFaceSelection base_object.mesh) verts_color
				Editable_Mesh: meshOp.setFaceColor base_object 0 (getFaceSelection base_object.mesh) verts_color
			)
		)*/
	)
	fn setVertsColor obj verts_color = (
		
		--format "setVertsColor > obj:% verts_color:%\n"  obj.name verts_color
		--obj.SetVertexColor verts_color #VertexColor
		undo "Set vertex color" on (
			
			local base_object =  obj.baseObject
			case (classOf base_object) of (

				Editable_Poly: polyOp.setVertColor base_object 0 (getVertSelection base_object.mesh) verts_color
				Editable_Mesh: meshOp.setVertColor base_object 0 (getVertSelection base_object.mesh) verts_color
			)
		)
	)
	fn rdoSwitchTo index force_enable= (
		
		current_color_index = index
		local rdo_name = "rdo_" + index as string
		format "switch to rdo:%\n" rdo_name
		local radio_buttons = #(rdo_1, rdo_2, rdo_3, rdo_4, rdo_5, rdo_6, rdo_7, rdo_8)
		for b in radio_buttons do (
			
			if rdo_name != b.name then (
				
				b.state = 0 
				
			) else if force_enable do (
				
				 b.state = 1
			)
		)
 	)
	
	fn selectObjectsByColor sel verts_color = (
		
		
	)
	fn selectFacesByColor obj verts_color = (
	
		
	)
	
	fn selectVertsByColor obj verts_color = (
			
		undo "Select vertices by color" on(
				
			local myVertexes = obj.GetNumVertices()
			local selVertexes = #{}
			for index = 1 to myVertexes do(	
				
				obj.SetSelection #Vertex #{index}
				myColor = obj.GetVertexColor #VertexColor
				if (myColor == verts_color) then
				(
					append  selVertexes index
				)
			)
			obj.SetSelection #Vertex selVertexes
		)
		completeRedraw()
	)
	
	fn selectVertsByColor2 obj verts_color = (
		
		undo "Select vertices by color" on (
			
			local base_object =  obj.baseObject
			format "obj:% base:%\n" obj.name base_object
			local num_verts = getBaseNumVerts base_object
			local sel_verts = #{}
			for index = 1 to num_verts do
			(		
				
				--$.baseobject.GetFaceColor #VertexColor
							/*	case (classOf base_object) of (

					Editable_Poly: polyOp.setVertColor base_object map_channel i verts_color
					Editable_Mesh: meshOp.setVertColor base_object map_channel i verts_color
				)*/
				
				
					/*base_object.SetSelection #Vertex #{index}
					local vert_color = base_object.GetVertexColor #VertexColor
					if ((vert_color as string) == verts_color) then
					(
						append  sel_verts index
					)*/
			)
			base_obj.SetSelection #Vertex sel_verts
		)
	)
	------------------------------------------------------------------------------
	--> DXShader
	------------------------------------------------------------------------------
	fn updateDXShaderValues = 
	(
		if (gLS3DDXSupport != undefined) then (
			local sel = deepcopy (selection as array)
			if (not gLS3DDXSupport.ObjectsConvert sel MatUpdate:true withUI:false justSet:true) then ( 
				gLS3DDXSupport.LogM ("Unable to update DX material info on selection.") level:3 
			) else ( 
				if (not gLS3DDXSupport.UpdateBuildingsColors sel) then (
					gLS3DDXSupport.LogM ("Unable to update Building Colors on selection.") level:3 
				)				
			)
		)
	)
	------------------------------------------------------------------------------
	fn setDXShader = 
	(
		if (gLS3DDXSupport != undefined) then (
			local sel = deepcopy (selection as array)
			if (not gLS3DDXSupport.ObjectsConvert sel LS3DtoDX:true withUI:false justSet:true) then ( gLS3DDXSupport.LogM ("Unable to convert material on selection from LS3D to DX Shader") level:3 )
			else ( gLS3DDXSupport.LogM ("Successful conversion: Material on selection from LS3D to DX Shader") level:1 )			
			gLS3DCHTool.UpdateDXShaderValues()
		)
	)
	------------------------------------------------------------------------------
	fn removeDXShader = 
	(
		if (gLS3DDXSupport != undefined) then (
			local sel = deepcopy (selection as array)
			if (not gLS3DDXSupport.ObjectsConvert sel LS3DtoDX:false withUI:false)  then ( gLS3DDXSupport.LogM ("Unable to convert material on selection from DX Shader to LS3D") level:3 )
			else ( gLS3DDXSupport.LogM ("Successful conversion: Material on selection from DX Shader to LS3D") level:1 )		
		)
	)
	------------------------------------------------------------------------------
	--< DXShader
	------------------------------------------------------------------------------
	--interface actions
	on rdo_1 changed state do (rdoSwitchTo 1 false)
	on rdo_2 changed state do (rdoSwitchTo 2 false)
	on rdo_3 changed state do (rdoSwitchTo 3 false)
	on rdo_4 changed state do (rdoSwitchTo 4 false)
	on rdo_5 changed state do (rdoSwitchTo 5 false)
	on rdo_6 changed state do (rdoSwitchTo 6 false)
	on rdo_7 changed state do (rdoSwitchTo 7 false)
	on rdo_8 changed state do (rdoSwitchTo 8 false)
	
	on btn_1 pressed do (rdoSwitchTo 1 true)
	on btn_2 pressed do (rdoSwitchTo 2 true)
	on btn_3 pressed do (rdoSwitchTo 3 true)
	on btn_4 pressed do (rdoSwitchTo 4 true)
	on btn_5 pressed do (rdoSwitchTo 5 true)
	on btn_6 pressed do (rdoSwitchTo 6 true)
	on btn_7 pressed do (rdoSwitchTo 7 true)
	on btn_8 pressed do (rdoSwitchTo 8 true)
	
	on btn_set_dx pressed do setDXShader()
	on btn_copy_dx pressed do updateDXShaderValues()
	on btn_remove_dx pressed do removeDXShader()
	
	on btn_set pressed do	( 
		
		local sel = selection as array
		if (sel.count == 0) do (
		
			MessageBox "Nothing is selected." title:"Warning:" beep:off	
			return false
		)
		local verts_color =  bmp_colors[ current_color_index ]
		local map_channel = 0
		local sel_type = getSelectionType sel
		format "sel_type:% objects:%\n" sel_type sel.count
		case sel_type of (
			
			"objects"	: setObjectsColor sel verts_color map_channel
			"faces"		: setFacesColor sel[1] verts_color
			"verts"		: setVertsColor  sel[1] verts_color
			"default"		: (undefined)
		)
	)
	on btn_sel pressed do (
		
		local sel = selection as array
		if (sel.count == 0) do (
		
			MessageBox "Nothing is selected." title:"Warning:" beep:off	
			return false
		)
		local verts_color =  bmp_colors[ current_color_index ]
		local sel_type = getSelectionType sel
		format "sel_type:% objects:%\n" sel_type sel.count
		case sel_type of (
			
			"objects"	: selectObjectsByColor sel verts_color 
			"faces"		: selectFacesByColor sel[1] verts_color
			"verts"		: selectVertsByColor  sel[1] verts_color
			"default"		: (undefined)
		)
		
	)
	on btn_show_colors pressed  do
	(
		for o in selection do (
			o.vertexColorType = 0 --or o.vertexColorType = #color
			o.showVertexColors = true
			update o
		)
		completeRedraw()	
	)
	on btn_hide_colors pressed  do
	(
		for o in selection do o.showVertexColors = false
		completeRedraw()	
	)
	on btn_show_alpha pressed  do
	(
		for o in selection do (
			o.vertexColorType = 2 -- or o.vertexColorType = #alpha -- set Vertex Color type to Alpha
			o.showVertexColors = true
			update o
		)
		completeRedraw()	
	)
	on btn_hide_alpha pressed  do
	(
		for o in selection do o.showVertexColors = false
		completeRedraw()	
	)
	
	on btn_show_shaded pressed  do
	(
		for o in selection do o.vertexColorsShaded = true
		completeRedraw()
	)
	on btn_hide_shaded pressed  do
	(
		for o in selection do o.vertexColorsShaded = false
		completeRedraw()
	)
	on mcVertexColorDialog open do
	(
		--set buttons color
		local color_buttons = #(btn_1, btn_2, btn_3, btn_4, btn_5, btn_6, btn_7, btn_8)
		for i = 1 to color_buttons.count do  (
			
			local color_bmp =  (bitmap 50 50 color:bmp_colors[ i ])
			color_buttons[ i ].images = #(color_bmp, undefined, 1,1,1,1,1 )
		)
	)
	on mcVertexColorDialog close do
	(
		
	)	
)
createDialog mcVertexColorDialog

/**
*@Usage
	local col0 = [1,1,1] --100% alpha
	local col1 = [0.5,0.5,0.5] --50% alpha
	local col2 = [0.2,0.2,0.2] --20% alpha
	--min = 0.0 max = 1.0

fn setRandomVertexAlpha float_min float_max = ( 
	
	local obj = (selection as array)[1]
	if obj == undefined do return false
	local sel_verts = polyop.getVertSelection obj as array
	for v in sel_verts do (
		
		local random_float = random float_min float_max
		--format "random float:%\n" random_float
		local p2 = [random_float, random_float, random_float] 
		polyOp.setMapVert obj -2 v p2
	)
	--update
	obj.vertexColorType = #color
	update obj
	obj.vertexColorType = #alpha
	update obj
)

setRandomVertexAlpha 0.6 1.0
*/


/*
mcCall.createXMLDialog "mcScriptManDialog" "Properties_2"
mcScriptManDialog.grp_title.text = "Script Manager: v" + (mcFile.getScriptVersion "Script_Manager") --update script title with version
on mcScriptManDialog close do (mcCall.saveIniDialog "mcScriptManDialog" "Properties_2")
*/