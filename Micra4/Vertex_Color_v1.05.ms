Global mcVertexColorDialog
Global mcVertexAlphaVertsSelChange
if ::mcVertexColorDialog != undefined do try(destroyDialog mcVertexColorDialog)catch()
rollout mcVertexColorDialog "Vertex Color v1.02" width:408 height:348
(
	--interface
	GroupBox 'grp1' "Color Sets:" pos:[4,4] width:104 height:276 align:#left
	GroupBox 'grp2' "Actions:" pos:[112,4] width:292 height:276 align:#left
	
	button 'btn_1' "button" pos:[44,24] width:52 height:24 align:#left 
	button 'btn_2' "button" pos:[44,52] width:52 height:24 align:#left
	button 'btn_3' "button" pos:[44,80] width:52 height:24 align:#left
	button 'btn_4' "button" pos:[44,108] width:52 height:24 align:#left 
	button 'btn_5' "button" pos:[44,136] width:52 height:24 align:#left 
	button 'btn_6' "button" pos:[44,164] width:52 height:24 align:#left 
	button 'btn_7' "button" pos:[44,192] width:52 height:24 align:#left
	button 'btn_8' "button" pos:[44,220] width:52 height:24 align:#left 
	button 'btn_9' "button" pos:[44,248] width:52 height:24 align:#left 
 
	button 'btn_show_colors' "ON" pos:[232,112] width:80 height:24 align:#left
	button 'btn_hide_colors' "OFF" pos:[320,112] width:80 height:24 align:#left
	button 'btn_show_alpha' "ON" pos:[232,140] width:80 height:24 align:#left
	button 'btn_hide_alpha' "OFF" pos:[320,140] width:80 height:24 align:#left
	button 'btn_show_shaded' "ON" pos:[232,168] width:80 height:24 align:#left
	button 'btn_hide_shaded' "OFF" pos:[320,168] width:80 height:24 align:#left
	button 'btn_set' "Assign By Set" pos:[116,20] width:140 height:42 align:#left
	button 'btn_sel' "Select By Set" pos:[116,64] width:140 height:42 align:#left
	button 'btn_sel_simillar' "Select Simillar" pos:[260,20] width:140 height:42 align:#left
	button 'btn18' "..." pos:[260,64] width:140 height:42 align:#left
	--button 'btn_set_dx' "Set DX Shader to selection" pos:[120,200] width:276 height:24 align:#left
	--button 'btn_copy_dx' "Copy values from LS3D material to DX Shader" pos:[120,228] width:276 height:24 align:#left
	--button 'btn_remove_dx' "Remove DX Shader from selection" pos:[120,256] width:276 height:24 align:#left
	button 'btn_r' "" pos:[120,248] width:20 height:20 toolTip:"Set Color To Red" align:#left
	button 'btn_g' "G" pos:[140,248] width:20 height:20 toolTip:"Set Color To Green" align:#left
	button 'btn_b' "B" pos:[160,248] width:20 height:20 toolTip:"Set Color To Blue" align:#left
	button 'btn_r1' "R1" pos:[220,248] width:20 height:20 toolTip:"Set Color To Red" align:#left
	button 'btn_g1' "G1" pos:[240,248] width:20 height:20 toolTip:"Set Color To Red" align:#left

	radiobuttons 'rdo_1' "" pos:[12,28] width:31 height:16 labels:#("1") default:1 align:#left
	radiobuttons 'rdo_2' "" pos:[12,56] width:31 height:16 labels:#("2") default:0 align:#left
	radiobuttons 'rdo_3' "" pos:[12,84] width:31 height:16 labels:#("3") default:0 align:#left
	radiobuttons 'rdo_4' "" pos:[12,112] width:31 height:16 labels:#("4") default:0 align:#left
	radiobuttons 'rdo_5' "" pos:[12,140] width:31 height:16 labels:#("5") default:0 align:#left
	radiobuttons 'rdo_6' "" pos:[12,168] width:31 height:16 labels:#("6") default:0 align:#left
	radiobuttons 'rdo_7' "" pos:[12,196] width:31 height:16 labels:#("7") default:0 align:#left
	radiobuttons 'rdo_8' "" pos:[12,224] width:31 height:16 labels:#("8") default:0 align:#left
	radiobuttons 'rdo_9' "" pos:[12,252] width:31 height:16 labels:#("0") default:0 align:#left

	label 'lbl_svc' "Show Vertex Colors:" pos:[120,116] width:104 height:20 align:#left
	label 'lbl_sva' "Show Vertex Alpha:" pos:[120,144] width:104 height:20 align:#left
	label 'lbl_svs' "Show Vertex Shaded:" pos:[120,172] width:104 height:20 align:#left
	
	GroupBox 'grp3' "Alpha:" pos:[4,288] width:400 height:56 align:#left
	label 'lbl4' "value:" pos:[12,312] width:36 height:20 align:#left
	slider 'sld_alpha' "" pos:[48,304] width:272 height:25 range:[0,100,0] type:#integer align:#left
	spinner 'spn_alpha' "" pos:[324,312] width:68 height:16 range:[0,100,0] type:#integer align:#left

	--local variables
	local btn_set2_colors = #(red, green, blue, color 216 0 71, color 0 133 63)
	local btn_set2 = #(btn_r, btn_g, btn_b, btn_r1, btn_g1)
	local radio_buttons = #(rdo_1, rdo_2, rdo_3, rdo_4, rdo_5, rdo_6, rdo_7, rdo_8, rdo_9)
	local color_buttons = #(btn_1, btn_2, btn_3, btn_4, btn_5, btn_6, btn_7, btn_8, btn_9)
	local bmp_colors = #(
		color 0 255 0,			--1
		color 32 0 128,		--2
		color 64 225 225,	--3
		color 96 128 0,		--4
		color 128 128 128,	--5
		color 160 128 255,	--6
		color 192 0 0,			--7
		color 224 0 255,		--8
		color 255 255 255	--9
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
		for b in radio_buttons do (
			
			if rdo_name != b.name then (
				
				b.state = 0 
				
			) else if force_enable do (
				
				 b.state = 1
			)
		)
 	)
	fn getObjectColor obj = (
	
		obj.SetSelection #Vertex #{1}
		obj.getFaceColor #VertexColor --get current selected vertex color (#VertexColor|#Illumination|#Alpha)
	)
	fn getFaceColor obj = (
	
		local fsel = obj.getSelection #face as Array
		if fsel.count == 0 do return undefined
		obj.getFaceColor #VertexColor --get current selected face color (#VertexColor|#Illumination|#Alpha)
	)
	fn getVerticeColor obj = (
	
		local vsel = obj.getSelection #Vertex as Array
		if vsel.count == 0 do return undefined
		obj.getVertexColor #VertexColor --get current selected vertex color (#VertexColor|#Illumination|#Alpha)
	)
	fn faceHaveColor obj f clr = (
	
		obj.SetSelection #Face #{f}
		local sel_face_clr = getFaceColor obj
		sel_face_clr == clr
	)
	
	fn selectObjectsByColor sel clr = (
		
		if clr == undefined do return false
		print "todo..."
	)
	fn selectFacesByColor obj clr = (
	
		if clr == undefined do return false
		--format "selectFacesByColor clr:%\n" clr
		undo "Select faces by color" on (
		
			--local fsel = for f=1 to obj.numfaces where faceHaveColor obj f clr collect f
			--obj.SetSelection #Face (filtered_faces as BitArray)
			local verts = polyOp.getVertsByColor obj clr 1 1 1 channel:0	
			local vfaces = (polyOp.getFacesUsingVert obj verts) as Array
			--remove faces where all vertices have no same clr (verts to faces grow issue)
			local filtered_faces = for f in vfaces where faceHaveColor obj f clr collect f
			obj.SetSelection #Face (filtered_faces as BitArray)
		)
	)
	
	fn selectVertsByColor obj clr = (
			
		if clr == undefined do return false	
		undo "Select vertices by color" on(
				
			local verts = case (classOf obj) of (

				Editable_Poly: polyOp.getVertsByColor obj clr 0 0 0 channel:0	
				Editable_Mesh: meshOp.getVertsByColor obj clr 0 0 0 channel:0	
			)	
			obj.SetSelection #Vertex verts	
		)
		completeRedraw()
	)
	
	fn selectSimillar = with redraw off (
		
		
		local sel = selection as array
		if (sel.count != 1) do (
		
			MessageBox "One object must be selected." title:"Warning:" beep:off	
			return false
		)
		local obj = sel[1]
		if not (isValidObject obj) do return false
		local sel_type = getSelectionType #(obj)
		case sel_type of (
			
			"objects"	: selectObjectsByColor obj (getObjectColor obj )
			"faces"	: selectFacesByColor obj (getFaceColor obj)
			"verts"	: selectVertsByColor obj (getVerticeColor obj)
			"default"	: (false)
		)	
		completeRedraw()
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
	fn setSelectionColor clr = (
		
		local sel = selection as array
		if (sel.count == 0) do (
		
			MessageBox "Nothing is selected." title:"Warning:" beep:off	
			return false
		)
		local map_channel = 0
		local sel_type = getSelectionType sel
		format "sel_type:% objects:%\n" sel_type sel.count
		case sel_type of (
			
			"objects"	: setObjectsColor sel clr map_channel
			"faces"		: setFacesColor sel[1] clr
			"verts"		: setVertsColor  sel[1] clr
			"default"		: (undefined)
		)	
	)
	fn getSelectedVertexAlpha s a = (
		
		--format "sel changed\n"
		local obj = selection[1]
		if  subobjectLevel != 1 or classOf obj != Editable_Poly or  not (polyOp.getMapSupport obj -2) do return false
		local vsel = (getVertSelection obj) as Array
		if vsel.count == 0 then (
			
			spn_alpha.value = 0
			sld_alpha.value = 0
			return false
		) else if vsel.count > 1 do return false
		local col = polyOp.getMapVert obj -2 vsel[1]
		spn_alpha.value = col[1]*100
		sld_alpha.value = col[1]*100
	)
	fn setSelectedVerticesAlpha val = (
		
		local obj = selection[1]
		if classOf obj != Editable_Poly do return false
		if  not (polyOp.getMapSupport obj -2) do polyOp.setMapSupport obj -2 true
		local vsel = (getVertSelection obj) as Array
		if subobjectLevel != 1 or vsel.count == 0 do return false
		local col = [1,1,1] * (val / 100.0)
		--format "vsel:% val:% col:%\n" vsel val col
		with redraw off (for v in  vsel do polyOp.setMapVert obj -2 v col)
		 --update changes (without this no alpha change is visible)
		obj.SetVertexColor (color 0 0 0) 3 --Channel enums: {#VertexColor|#Illumination|#Alpha}
		update obj
	)	
	fn setSelectionAlpha val src = (
		
		if src == #sld then (
		
			spn_alpha.value = val
			
		) else (
			
			sld_alpha.value = val			
		)
		setSelectedVerticesAlpha val
	)
	fn init = (
		
		--set buttons color
		for i = 1 to color_buttons.count do  (
			
			local color_bmp =  (bitmap 50 50 color:bmp_colors[ i ])
			color_buttons[ i ].images = #(color_bmp, undefined, 1,1,1,1,1 )
		)
		
		for i = 1 to btn_set2.count do  (
			
			local color_bmp =  (bitmap 50 50 color:btn_set2_colors[ i ])
			btn_set2[ i ].images = #(color_bmp, undefined, 1,1,1,1,1 )
		)
		
		--callbacks.removeScripts id:#VertexAlphaCallbacks
		--callbacks.addScript #selectionSetChanged "try( getSelectedVertexAlpha() )catch()" id:#VertexAlphaCallbacks
		mcVertexAlphaVertsSelChange = nodeEventCallback subobjectSelectionChanged:getSelectedVertexAlpha	
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
	on rdo_9 changed state do (rdoSwitchTo 9 false)
	
	on btn_1 pressed do (rdoSwitchTo 1 true)
	on btn_2 pressed do (rdoSwitchTo 2 true)
	on btn_3 pressed do (rdoSwitchTo 3 true)
	on btn_4 pressed do (rdoSwitchTo 4 true)
	on btn_5 pressed do (rdoSwitchTo 5 true)
	on btn_6 pressed do (rdoSwitchTo 6 true)
	on btn_7 pressed do (rdoSwitchTo 7 true)
	on btn_8 pressed do (rdoSwitchTo 8 true)
	on btn_9 pressed do (rdoSwitchTo 9 true)
	
	--on btn_set_dx pressed do setDXShader()
	--on btn_copy_dx pressed do updateDXShaderValues()
	--on btn_remove_dx pressed do removeDXShader()
	
	on btn_set pressed do	( 
		
		local verts_color =  bmp_colors[ current_color_index ]
		setSelectionColor verts_color 
	)
	on btn_sel pressed do ( --select
		
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
	on btn_sel_simillar pressed do selectSimillar()

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
	--COLOR
	on btn_r pressed do ( setSelectionColor btn_set2_colors[1] )
	on btn_g pressed do ( setSelectionColor btn_set2_colors[2]  )
	on btn_b pressed do ( setSelectionColor btn_set2_colors[3]  )
	on btn_r1 pressed do ( setSelectionColor btn_set2_colors[4]  )
	on btn_g1 pressed do ( setSelectionColor btn_set2_colors[5]  )

	--ALPHA
	on sld_alpha changed val do (setSelectionAlpha val #sld)
	on spn_alpha changed val do (setSelectionAlpha val #spn)
	/*on sld_alpha buttonup  do (
		
		$.vertexColorType = 2 --#alpha
		update $
	)*/
	/*on sld_alpha buttondown  do ()
	on spn_alpha entered text do ()
	on spn_alpha buttondown  do ()
	on spn_alpha buttonup  do ()*/
	--OPEN-CLOSE
	on mcVertexColorDialog open do
	(
		format "open\n"
		init()
	)
	on mcVertexColorDialog close do (
		
		mcVertexAlphaVertsSelChange = undefined
		gc light:true
		--callbacks.removeScripts id:#VertexAlphaCallbacks
	)	
)
createDialog mcVertexColorDialog


	/*
		$.SetSelection #Vertex #{322}
		clr = $.getVertexColor #VertexColor
		verts = polyOp.getVertsByColor $ clr 0 0 0 channel:0
		$.SetSelection #Vertex verts
		fsel = polyOp.getFacesUsingVert $ verts
		$.SetSelection #Face fsel --some selected faces has no vertex color (grow issue)
	*/
				
			/*local myVertexes = obj.GetNumVertices()
			local selVertexes = #{}
			for index = 1 to myVertexes do(	
				
				obj.SetSelection #Vertex #{index}
				myColor = obj.getVertexColor #VertexColor
				if (myColor == clr) then
				(
					append  selVertexes index
				)
			)
			obj.SetSelection #Vertex selVertexes*/


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