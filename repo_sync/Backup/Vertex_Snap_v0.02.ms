Global mcVertexSnapDialog
if mcVertexSnapDialog != undefined do destroyDialog mcVertexSnapDialog
rollout mcVertexSnapDialog "Vertex Snap" width:320 height:272
(
    local metric_type = units.SystemType as String
	pickbutton 'btn_pick_trgt' "None" pos:[96,92] width:208 height:20 align:#left
	label 'lbl5' "Target Object:" pos:[16,96] width:76 height:16 align:#left
	button 'btn_snap' "Snap Object" pos:[224,116] width:80 height:24 align:#left
	label 'lbl6' "Range:" pos:[16,120] width:76 height:16 align:#left
	spinner 'spn_offset' "" pos:[96,120] width:72 height:16 range:[0,100,1] type:#float scale:0.1 align:#left
	label 'lbl_units' "meters" pos:[172,120] width:44 height:16 align:#left
    
	GroupBox 'grp2' "Single:" pos:[8,4] width:308 height:56 align:#left
	button 'btn_get_pos' "Get Position" pos:[16,24] width:136 height:24 align:#left
	button 'btn_set_pos' "Srangeet Position" pos:[160,24] width:148 height:24 align:#left
	GroupBox 'grp3' "Multiple:" pos:[8,72] width:308 height:184 align:#left
	radiobuttons 'rdo_offset' "" pos:[64,208] width:245 height:32 labels:#("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14") columns:7 align:#left
	label 'lbl4' "quick:" pos:[16,208] width:40 height:16 align:#left
	button 'btnSnapMore' "Snap Objects" pos:[224,176] width:80 height:24 align:#left
	label 'lblStep' "Step:" pos:[16,176] width:76 height:16 align:#left
	checkbox 'chckIncreaseRange' "Increase Range" pos:[16,144] width:96 height:24 align:#left
	spinner 'spnStep' "" pos:[96,176] width:72 height:16 range:[0,100,1] type:#float scale:0.1 align:#left
	label 'lblMeters' "meters" pos:[176,176] width:40 height:16 align:#left
            
    local target_object
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

	function GetClosestPosition originObj vertexSourcePos spnOffsetValue =
	(
		local all_vert_list = #{1..(polyop.getNumVerts originObj)}
		local closest_pos
		local smalest_dist = 9999999
		for v in all_vert_list do  (
			
			local trgt_pos = polyOp.getVert originObj v
			
			local verts_dist = distance vertexSourcePos trgt_pos
			if verts_dist > spnOffsetValue do continue
			if smalest_dist > verts_dist do (
				
				smalest_dist = verts_dist
				closest_pos = trgt_pos
			)
		)
		closest_pos
	)


	function AlignVerticesToObject targetObj objToAlign rangeValue &failedVertices=
	(
		local isAllGood = true

		select objToAlign
		
		if (classOf(objToAlign) != Editable_Poly) then convertTo objToAlign Editable_Poly
		
		local vSel = GetVertexSelection objToAlign
		if vSel == undefined then isAllGood = false
		
		if(isAllGood)then
		(
			failedVertices = #{}
			for v in vSel do
			(
				local vertexPos = polyOp.getVert objToAlign v
				local closestPosInRange = GetClosestPosition targetObj vertexPos rangeValue
				if closestPosInRange == undefined do 
				(
					failedVertices += #{v}
					continue
				)
				
				polyOp.setVert objToAlign v closestPosInRange
			)
		)
	)
	
	function AlignObjectsVerticesToObject targetObj arrObjsToAlign rangeValue stepValue =
	(	
		DisableSceneRedraw()
		subobjectlevel = 0
		max create mode
		undo "Snap vertices" on
		(
			for obj in arrObjsToAlign do
			(
				local failedVerts = #{}
				
				if(stepValue == undefined)then
				(
					AlignVerticesToObject targetObj obj rangeValue &failedVerts
				)
				else
				(
					
					local counter = 1
					
					do
					(
						failedVerts = #{}
						AlignVerticesToObject targetObj obj (rangeValue + (stepValue * counter)) &failedVerts
						counter += counter
						polyop.setVertSelection obj failedVerts
					)
					while ((counter <= 5) or (failedVerts.count != 0))
				)
			)
		)
		max modify mode
		subobjectlevel = 1
		EnableSceneRedraw()
	)

-- 	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 	ROLLOUT EVENTS START
-- 	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
	on btnSnapMore pressed do
	(
-- 		sourceObj = execute ("$'"+btnpSourceObj.text + "'")		-- same as GetObjectByName
		sourceObj = target_object
		if sourceObj == undefined then MessageBox("Please select source object")
		else
		(
			deselect sourceObj
			selObjects = selection as array
			if(selObjects.count == 0) then MessageBox("Please select Objects for vertex alignment")
			else
			(
				local step = undefined
				if chckIncreaseRange.checked then step = spnStep.value
				AlignObjectsVerticesToObject sourceObj selObjects spn_offset.value step
			)
		)
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
				target_object = obj
				btn_pick_trgt.text = obj.name
			)
			else return false 
	       
	    )
	on btn_snap pressed do
	(
	        
	        local obj = selection[1]
	--         if classOf obj != Editable_Poly or target_object == undefined or classOf obj != PolyMeshObject do return false
			if classOf obj == Editable_Poly or classOf obj == PolyMeshObject then
			(
				undo "Snap vertices" on (
					
					local vsel = polyOP.getVertSelection obj
					local failed_snap_vertices = #{}
					
					for v in vsel do (
					
						local vertex_pos = polyOp.getVert obj v
						local closest_pos_in_range = GetClosestPosition target_object vertex_pos spn_offset.value
						if closest_pos_in_range == undefined do (
							
							--format "Failed snap vertex %\n" v   
							failed_snap_vertices += #{v}
							continue
						)
						--format "Succes snap vertex:%\n" v   
						polyOp.setVert obj v closest_pos_in_range
					)
					if failed_snap_vertices.numberset > 0 then (
						
						polyOP.setVertSelection obj failed_snap_vertices 
						format "Some vertices( % / % )  was unable to snap.\n" failed_snap_vertices.numberset vsel.numberset
						
					) else (
						
						format "All vertices( % / % ) was snapped Succes.\n" vsel.numberset vsel.numberset
						polyOP.setVertSelection obj #{} 
					)
				)
				local total_cnt = vsel.numberset
				local failed_cnt = failed_snap_vertices.numberset
				messageBox ("Snapped:" + (total_cnt - failed_cnt) as String + " Total:" + total_cnt as String + " Remains:" + failed_cnt as String) title:"Vertex Snap:"
			)
			else return false
	    )
	on btn_get_pos pressed do
	(
	        
	        local obj = selection[1]
	        if obj == undefined do return false
	        local vert = (polyop.getVertSelection obj as array)[1]
	        if vert == undefined do return false
	        vert_pos = polyop.getVert obj vert  
	        format "vert pos:%\n" vert_pos
	    )
	on btn_set_pos pressed do
	(
	            
	        if vert_pos == undefined do return false
	        local obj = selection[1]
	        if obj == undefined do return false
	        if subobjectLevel == 0 then ( --snap object to pos
	            obj.pos = vert_pos
	            
	        ) else ( --snap vertex to pos
	            
	            local vert = (polyop.getVertSelection obj as array)[1]
	            if vert == undefined do return false
	            undo "Snap vertex" on polyop.setVert obj vert vert_pos
	        )
	    )
	on rdo_offset changed index do
		(spn_offset.value = index)
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
