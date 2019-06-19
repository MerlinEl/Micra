Global RoadCustomGeneratorDialog
if RoadCustomGeneratorDialog != undefined do destroyDialog RoadCustomGeneratorDialog
rollout RoadCustomGeneratorDialog "Road Custom Generator:" width:428 height:332
(
	local obj_prefab, obj_start, obj_end, obj_path
	button 'btn_gen_spline' "Generate Spline" pos:[12,180] width:208 height:36 align:#left
	pickbutton 'btn_start' "Start..." pos:[12,24] width:64 height:20 align:#left
	pickbutton 'btn_end' "End..." pos:[12,48] width:64 height:20 align:#left
	pickbutton 'btn_path' "Path..." pos:[12,152] width:64 height:20 align:#left
	label 'lbl_start' "..." pos:[84,24] width:188 height:20 align:#left
	label 'lbl_end' "..." pos:[84,48] width:188 height:20 align:#left
	label 'lbl_path' "..." pos:[80,152] width:332 height:20 align:#left
	GroupBox 'grp1' "Joints:" pos:[4,4] width:420 height:116 align:#left
	GroupBox 'grp2' "Road:" pos:[4,232] width:420 height:96 align:#left
	button 'btn_gen_road' "Generate Road" pos:[208,280] width:208 height:36 align:#left
	pickbutton 'btn_prefab' "Prefab..." pos:[8,252] width:64 height:20 align:#left
	label 'lbl_prefab' "..." pos:[80,252] width:332 height:20 align:#left
	spinner 'spn_density' "" pos:[100,300] width:84 height:16 range:[0,90,4] type:#float scale:0.05 align:#left
	label 'lbl_density' "Density:" pos:[12,300] width:80 height:16 align:#left
	spinner 'spn_twist' "" pos:[100,280] width:84 height:16 range:[-90,90,0] type:#float scale:0.5 align:#left
	label 'lbl_twist' "Twist:" pos:[12,280] width:80 height:16 align:#left
	button 'btn_gen_points' "Create Joints" pos:[12,72] width:208 height:36 align:#left
	GroupBox 'grp3' "Path:" pos:[4,128] width:420 height:96 align:#left
	button 'btn_sync_spline' "Sync Spline" pos:[320,180] width:92 height:36 toolTip:"Snap spline Start, End points and Rebuild curve." align:#left
	checkbox 'cb_update_curve' "whole" pos:[232,188] width:76 height:20 checked:true align:#left
	checkbox 'chk_joint_start' "start" pos:[248,84] width:56 height:20 checked:true align:#left
	checkbox 'chk_joint_end' "end" pos:[328,84] width:56 height:20 checked:true align:#left
	button 'btn_two_werts_align_start' "Align To 2Verts" pos:[280,20] width:80 height:24 align:#left
	button 'btn_two_werts_align_end' "Align To 2Verts" pos:[280,46] width:80 height:24 align:#left
	checkbox 'chk_invert_start' "invert" pos:[368,24] width:48 height:20 checked:true align:#left
	checkbox 'chk_invert_end' "invert" pos:[368,48] width:48 height:20 checked:true align:#left
	fn rotateBetweenTwoPoints trgt_obj inverted:false = (
		
		local src_obj = selection[1]
		if classOf src_obj != Editable_Poly  do return false
		local vsel = (polyOp.getVertSelection src_obj) as Array
		if vsel.count != 2 do return false
		local p1 =  polyOp.getVert src_obj vsel[1]
		local p2 =  polyOp.getVert src_obj vsel[2]
		
		local v1 = if inverted then p1-p2 else p2-p1 --#this is the vector defined by them, looking from 1 at 2
		local theZ = normalize v1 --#this is the looking axis (Z)
		local theUp =  [0, 0, 1]--#take the world Z as the up vector
		local theX = normalize (cross theUp theZ) --#calculate an X axis orthogonal to both
		local theY = normalize (cross theZ theX) --#calculate a Y axis orthogonal to X and Z
		local theTM = matrix3 theX theY theZ p1 --#build a matrix from the 3 vectors 
		local theQuat = (inverse theTM) as quat --#convert the inverse of the matrix to a quaternion value
		local theEuler = theQuat as EulerAngles --#then convert the Quat to Euler. 
		trgt_obj.rotation = theEuler --#set the rotation of the cone to the Euler angles we calculated
		trgt_obj.pos = (p1 + p2) / 2 --#and place the cone at the first point 	
	)
	fn initJoint  obj = (
		
		obj.wirecolor = green
		obj.centermarker = false
		obj.axistripod  = false
		obj.cross = false
		obj.box  = true
		obj.constantscreensize = false
		obj.drawontop = false
	)
	fn initTangent  obj obj_parent = (
		
		obj.wirecolor = red
		obj.centermarker = true
		obj.axistripod  = false
		obj.cross = true
		obj.box  = true
		obj.constantscreensize = false
		obj.drawontop = false
		obj.parent  = obj_parent
	)
	fn getSelPos = (
		
		local obj = selection[1]
		if obj == undefined do return undefined
		local target_pos = undefined
		case subobjectLevel of (
			
			0: (--object
				
				target_pos = obj.pos
			)
			1: (--vertex
				
				if classOf obj == Editable_Poly do (
					
					local vsel = (polyOp.getVertSelection obj) as Array
					target_pos = if vsel.count > 0 then polyOp.getVert obj vsel[1] else undefined
				)
			)
			4: (--face
				
				target_pos = if roGenStruct != undefined then roGenStruct.getSelectedFacesCenter obj else undefined
			)
		)
		target_pos
	)
	fn createTwoPoints = (
		
		local pos = getSelPos()
		--create points
		if chk_joint_start.checked do (
			
			obj_start = point pos:[5000,0,0] size:1000 name:(uniqueName "Road_Joint_Start_")	
			local tangent_start = point pos:[-200,0,0] size:100 name:(uniqueName "Road_Tanget_Start_")	
			initJoint obj_start
			initTangent tangent_start obj_start
			lbl_start.text = obj_start.name
			if pos != undefined do obj_start.pos = pos
		)	
		if chk_joint_end.checked do (	
			
			obj_end = point pos:[-5000,0,0] size:1000 name:(uniqueName "Road_Joint_End_")	
			local tangent_end = point pos:[200,0,0] size:100 name:(uniqueName "Road_Tanget_End_")	
			initJoint obj_end
			initTangent tangent_end obj_end
			lbl_end.text = obj_end.name
			if pos != undefined do obj_end.pos = pos
		)
	)
	fn syncSpline = (
		
		if obj_path == undefined or 
			obj_start == undefined or obj_start.children.count == 0 or 
				obj_end == undefined or obj_end.children.count == 0 do return false
	
		local p1		= obj_start.pos
		local p2		= obj_end.pos
		local tIn		= obj_start.children[1].pos
		local tout	= obj_end.children[1].pos

		local knot_count = numKnots obj_path 1
		setKnotPoint obj_path 1 1 p1
		setKnotPoint obj_path 1 knot_count p2
		
		if cb_update_curve.checked do (
		
			setOutVec obj_path 1 1 (tIn)
			setInVec obj_path 1 knot_count (tout)
		)
		updateShape obj_path
		subobjectLevel = 0 --exit editing spline
	)
	on btn_start picked obj do if classOf obj == Point do (
		
		obj_start = obj
		lbl_start.text = obj.name
	)
	on btn_end picked obj do if classOf obj == Point do (
		
		obj_end = obj
		lbl_end.text = obj.name
	)
	on btn_path picked obj do if classOf obj == SplineShape do (
		
		obj_path = obj
		lbl_path.text = obj.name
	)
	on btn_prefab picked obj do if classOf obj == Editable_Poly do (
		
		obj_prefab = obj
		lbl_prefab.text = obj.name
	)
	on btn_gen_spline pressed  do if obj_start != undefined and obj_end != undefined  and roGenStruct != undefined do (
		
		obj_path = roGenStruct.createSplineFromJoints obj_start obj_end
		obj_path.name =  (uniqueName "Road_Path_")
		lbl_path.text = obj_path.name
	)
	on btn_gen_road pressed  do if obj_path != undefined and obj_prefab != undefined and roGenStruct != undefined do  (
		
		subobjectLevel = 0
		suspendEditing()
		local finalRoad = roGenStruct.createRoadFromSpline obj_prefab obj_path spn_density.value spn_twist.value
		finalRoad.name = uniqueName "road_custom_"
		resumeEditing()
	)
	on btn_gen_points pressed do createTwoPoints()
	on btn_sync_spline pressed  do syncSpline()
	on btn_two_werts_align_start pressed do  if obj_start != undefined do rotateBetweenTwoPoints obj_start inverted:chk_invert_start.checked
	on btn_two_werts_align_end pressed do  if obj_end != undefined do rotateBetweenTwoPoints obj_end inverted:chk_invert_end.checked
)
createDialog RoadCustomGeneratorDialog