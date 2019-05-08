


Road_Generator_Shortcut = attributes Road_Generator_Shortcut attribID:#(0x11aa99ff, 0x1234abcd)
(
	parameters main rollout:params 
	(
		
		maxObj				type:#maxObject			tabSizeVariable:true
		maxObjectTab	type:#maxObjectTab 		tabSizeVariable:true
		nodeTab	 			type:#nodeTab 				tabSizeVariable:true
		point3Tab			type:#point3Tab 				tabSizeVariable:true default:[0,0,0]
		matrix3Tab 			type:#matrix3Tab 			tabSizeVariable:true
		materialTab			type:#materialTab 			tabSizeVariable:true
		textureMapTab	type:#texturemapTab		tabSizeVariable:true
		bitmapTab 			type:#bitmapTab 			tabSizeVariable:true
		intTab					type:#inttab						tabSizeVariable:true
		intVal 					type:#integer					animateable:true default:0 --ui:intVal 
	)
	fn filterObject obj = ( 
		
		try( (classof obj.mesh == triMesh) and (getnumverts obj.mesh) > 0 and (getnumfaces obj.mesh) > 0 ) catch( false ) 
	)
	fn filterDummy obj = (classof obj == Dummy)
	
	rollout params "Parameters" (
			
		multiListBox lbxNodeList "Objects: " items:#() selection:0
		button btn1 "Edit profile" width:160 height:20 align:#center
		label lblAxis "Axis : " across:2
		radiobuttons rdoAxis "" labels:#("X","Y","Z") align:#right columns:3
		spinner spnTwist "Twist : " type:#float range:[-2000,2000,20] fieldWidth:50 align:#right
		GroupBox grp5 "Position:" width:156 height:40 align:#center
		spinner sp_rot_x "x" width:74 height:16 range:[-9999,9999,0] align:#left
        spinner sp_rot_y "y" width:74 height:16 range:[-9999,9999,0] align:#left
        spinner sp_rot_z "z" width:74 height:16 range:[-9999,9999,0] align:#left
		edittext edt1 "" width:149 height:50 align:#center
		pickbutton btn_start "Pick Start" width:116 height:24  toolTip:"#center" filter:filterDummy
		pickbutton btn_end "Pick End" width:116 height:24  toolTip:"#center" filter:filterDummy
		fn linkNode obj = (
		    
			/*obj.fpos.controller = point3_script()
			mt_obj = point size:10 wirecolor:green centermarker:false axistripod:false cross:false box:true name:(uniquename "MatrixPp_MT")
			mt_obj.transform.controller = obj.transform.controller
			local pos_pt = point size:6 wirecolor:green centermarker:false axistripod:false cross:true box:false name:(uniquename "MatrixPp_pos") pos:mt_obj.pos
			obj.fpos.controller.addTarget "tpos" pos_pt.pos.controller
			obj.fpos.controller.script = "tpos"*/
		)
		fn addObjectInToList obj = (
			
			local item_exists = findItem lbxNodeList.items obj.name == undefined
			format "picked Dummy name:%\n" obj.name
			format "picked Dummy exists:%\n" item_exists
			if not item_exists do lbxNodeList.items += #(obj.name)
		)
		fn init = (
			
			format "init.....\n"
		)
		on params open do init()	
		on btn_start picked obj do addObjectInToList obj
		on attachedToNode obj do linkNode obj
		/*on nodeTab set val index do format "set nodeTab: % : %\n" val index
		on nodeTab get val index do (format "get nodeTab: % : %\n" val index;val)
		on intTab set val index do format "set intTab: % : %\n" val index
		on intTab get val index do (format "get intTab: % : %\n" val index;val)
		on point3Tab set val index do format "set point3Tab: % : %\n" val index
		on point3Tab get val index do (format "get point3Tab: % : %\n" val index;val)
		on intVal set val do format "set intVal: %\n" val
		on intVal get val do (format "get intVal: %\n" val;val)*/
	)
)
try (custAttributes.delete $ Road_Generator_Shortcut baseObject:false) catch ()
custAttributes.add $ Road_Generator_Shortcut --baseObject:false
