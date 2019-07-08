/*
----------------------------------------------------------------------------------------------------------------
			INIT CUSTOM ATTRUBUTES
----------------------------------------------------------------------------------------------------------------
*/

if  classOf roGen_Joint_CA != AttributeDef or classOf gSplineGenCa != AttributeDef  do (
	
	Global gRoadGenCa = attributes RoadGenCa attribID:#(0x2949a7a0, 0x5246449a) ( --genClassID()

		parameters params(
			
			roadSpline 		type:#node
			startPoint		type:#node
			endPoint		type:#node
			controlsStr		type:#string
		)
	)
	-------------------------------------------------------------------------------------
	Global gSplineGenCa = attributes SplineGenCa attribID:#(0x2d6fe027, 0x4236cbe9) ( ---- buuuuu

		parameters params(
		
			road 			type:#string
		)
	)
)


Global RoadCustomGeneratorDialog
if RoadCustomGeneratorDialog != undefined do destroyDialog RoadCustomGeneratorDialog
rollout RoadCustomGeneratorDialog "Road Custom Generator:" width:1052 height:220
(
	local obj_prefab, obj_start, obj_end, obj_path
	button 'btn_gen_spline' "Create" pos:[12,140] width:68 height:68 align:#left
	pickbutton 'btn_start' "Start..." pos:[148,44] width:64 height:20 align:#left
	pickbutton 'btn_end' "End..." pos:[148,68] width:64 height:20 align:#left
	pickbutton 'btn_path' "Path..." pos:[92,164] width:64 height:20 align:#left
	label 'lbl_start' "..." pos:[220,44] width:172 height:20 align:#left
	label 'lbl_end' "..." pos:[220,68] width:172 height:20 align:#left
	label 'lbl_path' "..." pos:[160,164] width:176 height:20 align:#left
	GroupBox 'grp1' "Joints:" pos:[4,4] width:1044 height:104 align:#left
	GroupBox 'grp2' "Road:" pos:[568,120] width:480 height:96 align:#left
	button 'btn_gen_road' "Generate Road" pos:[864,140] width:176 height:68 align:#left
	pickbutton 'btn_prefab' "Prefab..." pos:[572,140] width:64 height:20 align:#left
	label 'lbl_prefab' "..." pos:[644,140] width:212 height:20 align:#left
	spinner 'spn_density' "" pos:[628,192] width:84 height:16 range:[0,90,4] type:#float scale:0.05 align:#left
	label 'lbl_density' "Density:" pos:[576,192] width:48 height:16 align:#left
	spinner 'spn_twist' "" pos:[628,168] width:84 height:16 range:[-90,90,0] type:#float scale:0.5 align:#left
	spinner 'spn_rotation' "" pos:[772,168] width:84 height:16 range:[-90,90,0] type:#float scale:0.5 align:#left
	label 'lbl_twist' "Twist:" pos:[576,168] width:48 height:16 align:#left
	button 'btn_gen_points' "Create" pos:[12,28] width:68 height:68 align:#left
	GroupBox 'grp3' "Path:" pos:[4,116] width:556 height:100 align:#left
	button 'btn_sync_spline' "Sync" pos:[364,156] width:92 height:36 toolTip:"Snap spline Start, End points and Rebuild curve." align:#left
	checkbox 'cb_update_curve' "whole" pos:[468,164] width:76 height:20 checked:true align:#left
	checkbox 'chk_joint_start' "start" pos:[84,32] width:44 height:20 checked:true align:#left
	checkbox 'chk_joint_end' "end" pos:[84,76] width:44 height:20 checked:true align:#left
	button 'btn_two_werts_align_start' "By To 2Verts" pos:[416,44] width:80 height:24 align:#left
	button 'btn_two_werts_align_end' "By To 2Verts" pos:[416,70] width:80 height:24 align:#left
	checkbox 'chk_invert_start' "invert" pos:[504,48] width:48 height:20 checked:true align:#left
	checkbox 'chk_invert_end' "invert" pos:[504,72] width:48 height:20 checked:true align:#left
	spinner 'spn_t1_len' "" pos:[612,48] width:68 height:16 range:[0,100,100] type:#float scale:0.1 align:#left
	label 'lbl7' "length:" pos:[576,49] width:36 height:16 align:#left
	spinner 'spn_t2_len' "" pos:[612,69] width:68 height:16 range:[0,100,100] type:#float scale:0.1 align:#left
	label 'lbl8' "length:" pos:[576,70] width:36 height:16 align:#left
	spinner 'spn_t1_angle_x' "" pos:[732,49] width:68 height:16 range:[0,100,100] align:#left
	label 'lbl9' "angle x:" pos:[688,50] width:44 height:16 align:#left
	spinner 'spn_t2_angle_x' "" pos:[732,70] width:68 height:16 range:[0,100,100] type:#float scale:0.1 align:#left
	label 'lbl10' "angle x:" pos:[688,71] width:44 height:16 align:#left
	GroupBox 'grp4' "Tangents" pos:[568,28] width:472 height:72 align:#left
	GroupBox 'grp5' "Pick" pos:[140,24] width:260 height:72 align:#left
	GroupBox 'grp6' "Align" pos:[408,28] width:152 height:72 align:#left
	GroupBox 'grp7' "Pick" pos:[84,136] width:260 height:72 align:#left
	GroupBox 'grp8' "Adjust" pos:[352,136] width:200 height:72 align:#left
	spinner 'spn_t1_angle_y' "" pos:[848,48] width:68 height:16 range:[0,100,100] align:#left
	label 'lbl11' "angle y:" pos:[804,49] width:44 height:16 align:#left
	spinner 'spn_t2_angle_y' "" pos:[848,69] width:68 height:16 range:[0,100,100] type:#float scale:0.1 align:#left
	label 'lbl12' "angle y:" pos:[804,72] width:44 height:16 align:#left
	spinner 'spn_t1_angle_z' "" pos:[964,48] width:68 height:16 range:[0,100,100] align:#left
	label 'lbl13' "angle z:" pos:[920,49] width:44 height:16 align:#left
	spinner 'spn_t2_angle_z' "" pos:[964,69] width:68 height:16 range:[0,100,100] type:#float scale:0.1 align:#left
	label 'lbl14' "angle z:" pos:[920,70] width:44 height:16 align:#left
	label 'lbl15' "Rotation:" pos:[720,168] width:48 height:16 align:#left
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
				
				target_pos = roGenStruct.getSelectedFacesCenter obj
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
	on RoadCustomGeneratorDialog open do (
		
		--Import Structure if need
		if roGenStruct == undefined do (
			
			local script_path =  getFilenamePath ( getSourceFileName() )
			local struct_path = script_path + "Road_Generator_Struct_v1.11.ms"
			if doesFileExist struct_path do fileIn struct_path
		)
		if roGenStruct == undefined do (
			
			messageBox ("Missing Structure [ " +struct_path+ " ]" ) title:"Error:"
			DestroyDialog RoadCustomGeneratorDialog
		)
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
	on btn_gen_spline pressed  do if obj_start != undefined and obj_end != undefined do (
		
		obj_path = roGenStruct.createSplineFromJoints obj_start obj_end
		obj_path.name =  (uniqueName "Road_Path_")
		lbl_path.text = obj_path.name
	)
	on btn_gen_road pressed  do if obj_path != undefined and obj_prefab != undefined do  (
		
		subobjectLevel = 0
		suspendEditing()
		local finalRoad = roGenStruct.createRoadFromSpline obj_prefab obj_path spn_density.value spn_twist.value spn_rotation.value
		finalRoad.name = uniqueName "custom_road_"
		resumeEditing()
	)
	on btn_gen_points pressed do createTwoPoints()
	on btn_sync_spline pressed  do syncSpline()
	on btn_two_werts_align_start pressed do  if obj_start != undefined do rotateBetweenTwoPoints obj_start inverted:chk_invert_start.checked
	on btn_two_werts_align_end pressed do  if obj_end != undefined do rotateBetweenTwoPoints obj_end inverted:chk_invert_end.checked
)
createDialog RoadCustomGeneratorDialog