Global mcVertexSnapDialog
if mcVertexSnapDialog != undefined do destroyDialog mcVertexSnapDialog
rollout mcVertexSnapDialog "" width:320 height:256
(
	local form_title = "Vertex Snap"
    local metric_type = units.SystemType as String
	local offset_list = #("1", "2", "3", "4", "5", "10", "15", "20", "25", "30", "40", "50", "70", "99")
	pickbutton 'btn_pick_trgt' "None" pos:[96,92] width:208 height:20 align:#left
	label 'lbl5' "Target Object:" pos:[16,96] width:76 height:16 align:#left
	label 'lbl6' "Range:" pos:[16,120] width:76 height:16 align:#left
	spinner 'spn_offset' "" pos:[96,120] width:52 height:16 range:[0,1e+06,1] type:#float scale:0.1 align:#left
	label 'lbl_units' "units..." pos:[152,120] width:68 height:16 align:#left
	GroupBox 'grp2' "Single:" pos:[8,4] width:308 height:56 align:#left
	button 'btn_get_pos' "Get Position" pos:[16,24] width:136 height:24 align:#left
	button 'btn_set_pos' "Set Position" pos:[160,24] width:148 height:24 align:#left
	GroupBox 'grp3' "Multiple:" pos:[8,72] width:308 height:180 align:#left
	radiobuttons 'rdo_offset' "" pos:[64,148] width:245 height:32 labels:#("1", "2", "3", "4", "5", "10", "15", "20", "25", "30", "40", "50", "70", "99") columns:7 align:#left
	label 'lbl4' "quick:" pos:[16,148] width:40 height:16 align:#left
	button 'btnSnapMore' "Snap Vertices" pos:[16,208] width:292 height:36 align:#left
	checkbox 'chk_borders_only' "Borders only" pos:[228,117] width:76 height:20 enabled:true checked:true align:#left
	checkbox 'chk_copy_vertex_color' "Copy Vertex Color" pos:[16,184] width:132 height:20 enabled:true checked:false align:#left
    local vert_pos
    
	function GetVertexSelection obj =
	(
		case classof(obj) of
		(
			Editable_Poly: return polyOP.GetVertSelection obj
			PolyMeshObject: return EditPolyMod.GetSelection obj.Edit_Poly #Vertex
			default: return undefined
		)
	)
	
	function FilterBorderVerts obj onlySelectedVerts:true=
	(
		local verts
		if(onlySelectedVerts)then
		(
			verts = polyop.getVertSelection obj
		)
		else
		(
			verts = #{1..(polyop.getNumVerts obj)}
		)
		edges = polyop.getOpenEdges obj
		local newVerts = #{}
		for edg in edges do
		(
			for edgeVert in (polyop.getEdgeVerts obj edg) do
			(
				if((findItem verts edgeVert)!=0)then append newVerts edgeVert
			)
		)
		newVerts
	)
	

	function MoveVertex obj v vEndLocation =
	(
		case classof(obj) of
		(
			Editable_Poly: polyOp.setVert obj v vEndLocation
			PolyMeshObject: 
			(
				EditPolyMod.MoveSelection obj.Edit_Poly #Vertex
			)
			default: return undefined
		)
	)

	function GetClosestPosition originObj arrTargetObjBorderVerts vertexSourcePos spnOffsetValue &v_src =
	(
		local closest_pos
		local smalest_dist = 9999999
		for v in arrTargetObjBorderVerts do  (
			
			local trgt_pos = polyOp.getVert originObj v
			
			local verts_dist = distance vertexSourcePos trgt_pos
			if verts_dist > spnOffsetValue do continue
			if smalest_dist > verts_dist do (
				
				smalest_dist = verts_dist
				closest_pos = trgt_pos
				v_src = v
			)
		)
		closest_pos
	)

	fn getVertColor obj vertexIndex = (
	
		--getVertColor obj.baseobject.mesh vertexIndex
		obj.setSelection #Vertex #{vertexIndex}
		obj.getVertexColor #VertexColor --get current selected vertex color (#VertexColor|#Illumination|#Alpha)
	)
	
	fn setVertColor obj vertexIndex clr = (
		
		obj.setSelection #Vertex #{vertexIndex}
		obj.setVertexColor clr #VertexColor  --set current selected vertex color
		--obj.SetVertexColor verts_color #VertexColor
		-- newColor = [1.0,0.0,0.0]
		-- uv =  uvwmap length:0.0 width:0.0 channel:1 utile:newColor.x vtile:newColor.y wtile:newColor.z
		-- addModifier selection uv
		
		/*local base_object = obj.baseObject
		case (classOf base_object) of (

			Editable_Poly: polyOp.setVertColor base_object 0 (getVertSelection base_object.mesh) verts_color
			Editable_Mesh: meshOp.setVertColor base_object 0 (getVertSelection base_object.mesh) verts_color
		)*/
	)


	function transferVertexColor srcObj trgtObj v_src v_trgt = (
	
		local clr = getVertColor srcObj v_src
		if classOf clr != Color or clr == black do return false
		setVertColor trgtObj v_trgt clr
	)

	function AlignVerticesToObject targetObj arrTargetObjBorderVerts objToAlign rangeValue copyVertsColor =
	(
		local isAllGood = true

-- 		select objToAlign
-- 		format "AlignVerticesToObject > targetObj:%tobjToAlign:%\n\tarrTargetObjBorderVerts:%\n\trangeValue:%\n" targetObj.name objToAlign.name arrTargetObjBorderVerts  rangeValue
		

		local vSel = if chk_borders_only.checked then FilterBorderVerts objToAlign.baseObject else polyop.getVertSelection objToAlign.baseObject	 --quick fix baseobject
-- 		format "tarrSourceObjBorderVerts:%\n" vSel
		if vSel == undefined then isAllGood = false
		local failedVertices = #{}
		
		if(isAllGood)then
		(
			for v in vSel do
			(
				local vertexPos = polyOp.getVert objToAlign v
				local v_src = undefined
				local closestPosInRange = GetClosestPosition targetObj arrTargetObjBorderVerts vertexPos rangeValue &v_src
-- 				format "closest pos:%\n" closestPosInRange
				if closestPosInRange == undefined then ( 
				
					failedVertices += #{v}

				) else (
				
					if copyVertsColor do transferVertexColor targetObj objToAlign v_src v
					polyOp.setVert objToAlign v closestPosInRange
				)
			)
			format "Remains vertices to snap:%\n" failedVertices.numberset
			polyOP.setVertSelection objToAlign failedVertices
		)
	)
	function AlignObjectsVerticesToObject target_object source_objects rangeValue copyVertsColor =
	(	
		DisableSceneRedraw()
		-- mcPoly.deselectObject target_object
		local gco = modPanel.getCurrentObject() --store current modifier selection
		if (classOf gco != Editable_Poly and classOf gco != Edit_Poly) do (
					
			MessageBox "Selected objects must be Editable_Poly or have Edit_Poly modifier." title:form_title
			return false
		)
		subobjectlevel = 0; max create mode --speed up
		undo "Snap vertices" on (
			
			local targetObjVerts = if chk_borders_only.checked then (
				
				FilterBorderVerts target_object onlySelectedVerts:false		-- optimalization, we can select only from border verts -> quicker times hell yeah
				
			) else (
				
				#{1..(polyop.getNumVerts target_object)}	
			)
			if source_objects.count > 1 and copyVertsColor do (
			
				MessageBox "Copy vertex colors can be used only for single object, without modifiers. For now."
				return false;
			)
			for obj in source_objects do (

				AlignVerticesToObject target_object targetObjVerts obj rangeValue copyVertsColor
			)

		)
		max modify mode
		local max_try = 100
		while modPanel.getCurrentObject() != gco and max_try > 0 do  ( max prev mod; max_try -=1 ) --restore modifier selection
		subobjectlevel = 1 --restore vertex  subobject level
		EnableSceneRedraw()
	)

	fn init = (
		
		lbl_units.text = metric_type
		mcVertexSnapDialog.title = form_title
	)
-- 	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	ROLLOUT EVENTS START
-- 	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	on btnSnapMore pressed do (
	
		local target_object = getNodeByName btn_pick_trgt.text
		if superClassOf target_object != GeometryClass do return (mcMsgList.warn "not_geo_trgt")
		local source_objects = selection as array
		if (source_objects.count == 0) do return (mcMsgList.warn "not_sel")
		AlignObjectsVerticesToObject target_object source_objects spn_offset.value chk_copy_vertex_color.checked
	)
	on chckIncreaseRange changed theState do
	(
		if chckIncreaseRange.checked then spnStep.enabled = true
		else spnStep.enabled = false
	)
		
	on btn_pick_trgt picked obj do
	(
	        if classOf obj == Editable_Poly or classOf obj == PolyMeshObject then
			(
				btn_pick_trgt.text = obj.name
			)
			else return false 
	       
	    )
	on btn_get_pos pressed do
	(
	        
	        local obj = selection[1]
	        if obj == undefined or classOf obj != Editable_Poly do (
				
				messageBox "Object must be Editable_Poly" title:"Aborted"
				return false
			)
	        local vert = (polyop.getVertSelection obj as array)[1]
	        if vert == undefined do return false
	        vert_pos = polyop.getVert obj vert  
	        format "vert pos:%\n" vert_pos
	    )
	on btn_set_pos pressed do (
		
	        if vert_pos == undefined do return false
	        local obj = selection[1]
	        if obj == undefined do return false
	        if subobjectLevel == undefined or subobjectLevel == 0 then ( --snap object to pos
	            
				obj.pos = vert_pos
	            
	        ) else ( --snap vertex to pos
	            
	            local vert = (polyop.getVertSelection obj as array)[1]
	            if vert == undefined do return false
	            undo "Snap vertex" on polyop.setVert obj vert vert_pos
	        )
	    )
	on rdo_offset changed index do (spn_offset.value = execute offset_list[index])
	on mcVertexSnapDialog open do ( init() )
)

createDialog mcVertexSnapDialog
/*
uv_channel = 1
uvVert1 = polyOp.getMapVert $ uv_channel 210
polyOp.setMapVert $ uv_channel 210 -uvVert1
*/
/*
channel = 1;
local num_faces = polyop.getNumFaces $;
for f = 1 to num_faces do(
    uvF = polyOp.getMapFace $ channel f;
    
    uvVert1 = polyOp.getMapVert $ channel uvF[1];
    uvVert2 = polyOp.getMapVert $ channel uvF[2];
    uvVert3 = polyOp.getMapVert $ channel uvF[3];
    --manipulate each uvVert, like uvVert1.x = 0.5; 
    --or like this: uvVert2.x+= 0.5; 
    
    --store them back
    polyOp.setMapVert $ channel uvF[1] uvVert1;
    polyOp.setMapVert $ channel uvF[2] uvVert2;
    polyOp.setMapVert $ channel uvF[3] uvVert3;
)
*/
/*
PreserveUV = $.modifiers[#Edit_Poly].preserveUVs
if preserveUV == false then (
    $.modifiers[#Edit_Poly].preserveUVs = on
    )
else (
    $.modifiers[#Edit_Poly].preserveUVs = off
    )
)
myEPoly.preserveUvs = True
myObject.modifiers[#Edit_Poly].preserveUVs = True
*/

-- 	local obj = selection[1]
--         if classOf obj != Editable_Poly or target_object == undefined or classOf obj != PolyMeshObject do return false
-- 		if classOf obj == Editable_Poly or classOf obj == PolyMeshObject then
-- 		(
-- 			undo "Snap vertices" on (
-- 				
-- 				local vsel = polyOP.getVertSelection obj
-- 				local failed_snap_vertices = #{}
-- 				
-- 				for v in vsel do (
-- 				
-- 					local vertex_pos = polyOp.getVert obj v
-- 					local closest_pos_in_range = getClosetPos target_object vertex_pos spn_offset.value
-- 					if closest_pos_in_range == undefined do (
-- 						
-- 						--format "Failed snap vertex %\n" v   
-- 						failed_snap_vertices += #{v}
-- 						continue
-- 					)
-- 					--format "Succes snap vertex:%\n" v   
-- 					polyOp.setVert obj v closest_pos_in_range
-- 				)
-- 				if failed_snap_vertices.numberset > 0 then (
-- 					
-- 					polyOP.setVertSelection obj failed_snap_vertices 
-- 					format "Some vertices( % / % )  was unable to snap.\n" failed_snap_vertices.numberset vsel.numberset
-- 					
-- 				) else (
-- 					
-- 					format "All vertices( % / % ) was snapped Succes.\n" vsel.numberset vsel.numberset
-- 					polyOP.setVertSelection obj #{} 
-- 				)
-- 			)
-- 			local total_cnt = vsel.numberset
-- 			local failed_cnt = failed_snap_vertices.numberset
-- 			messageBox ("Snapped:" + (total_cnt - failed_cnt) as String + " Total:" + total_cnt as String + " Remains:" + failed_cnt as String) title:"Vertex Snap:"
-- 		)
-- 		else return false
--     

