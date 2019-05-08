roGen_Road_Attributes = attributes roGen_Road_Attributes attribID:#(0x11aa99ff, 0x1234abcd)
(
	parameters main rollout:params 
	(
		startP 		type:#maxObject tabSize:0 tabSizeVariable:true
		endP		type:#maxObject tabSize:0 tabSizeVariable:true
		startT		type:#maxObject tabSize:0 tabSizeVariable:true
		endT		type:#maxObject tabSize:0 tabSizeVariable:true
		lineObj		type:#maxObject tabSize:0 tabSizeVariable:true
	)
	
	fn filterObject obj = ( 
		
		try( (classof obj.mesh == triMesh) and (getnumverts obj.mesh) > 0 and (getnumfaces obj.mesh) > 0 ) catch( false ) 
	)
	fn filterDummy obj = (classof obj == Dummy)
	fn filterShape obj = (classof obj == Line)
	
	rollout params "Road Parameters:" (
			
		group "Start:"
		(
			label lbl_1 "Point: " across:1 align:#center
			pickbutton btn_start_p "None" width:140 height:20  toolTip:"Start Point" filter:filterDummy align:#left
			label lbl_2 "Tangent: " across:1 align:#center
			pickbutton btn_start_t "None" width:140 height:20  toolTip:"Start Tangent" filter:filterDummy align:#left
			spinner sp_start_len "length" width:74 height:16 range:[1,9999,1] type:#float align:#left
		)
		group "End:"
		(
			label lbl_3 "Point: " across:1 align:#center
			pickbutton btn_end_p "None" width:140 height:20  toolTip:"End Point" filter:filterDummy align:#left
			label lbl_4 "Tangent: " across:1 align:#center
			pickbutton btn_end_t "None" width:140 height:20  toolTip:"End Tangent" filter:filterDummy align:#left
			spinner sp_end_len "length" width:74 height:16 range:[1,9999,1] type:#float align:#left
		)
		group "Path:"
		(
			label lbl_5 "Line: " across:1 align:#center
			pickbutton btn_line "None" width:140 height:20  toolTip:"Line Path" filter:filterShape align:#left
		)
		fn linkNode obj = (
			
			format "linkNode obj:%\n" obj
			obj.fpos.controller = point3_script()
			mt_obj = point size:10 wirecolor:green centermarker:false axistripod:false cross:false box:true name:(uniquename "MatrixPp_MT")
			mt_obj.transform.controller = obj.transform.controller
			local pos_pt = point size:6 wirecolor:green centermarker:false axistripod:false cross:true box:false name:(uniquename "MatrixPp_pos") pos:mt_obj.pos
			obj.fpos.controller.addTarget "tpos" pos_pt.pos.controller
			obj.fpos.controller.script = "tpos"
		)
		fn updateLabel btn max_obj = (
			
			local lbl = if (isValidNode max_obj.node) then max_obj.node.name else "None"
			btn.text = lbl	
		)
		fn addComponent obj type = (
			format "addComponent obj:%\n" obj
			case type of (
				
				#start_p: (

					startP = nodeTransformMonitor node:obj forwardTransformChangeMsgs:false
					btn_start_p.text = obj.name
				)
				#end_p: (
				
					endP = nodeTransformMonitor node:obj forwardTransformChangeMsgs:false
					btn_end_p.text = obj.name
				)
				#start_t: (
				
					startT = nodeTransformMonitor node:obj forwardTransformChangeMsgs:false
					btn_start_t.text = obj.name
				)
				#end_t: (
				
					endT = nodeTransformMonitor node:obj forwardTransformChangeMsgs:false
					btn_end_t.text = obj.name
				)
				#line: (
					
					lineObj = nodeTransformMonitor node:obj forwardTransformChangeMsgs:false
					btn_line.text = obj.name
				)
			)
		)
		fn init = (
			format "init.....\n"
			if startP 	!= undefined do updateLabel btn_start_p startP
			if endP	!= undefined do updateLabel btn_end_p endP
			if startT 	!= undefined do updateLabel btn_start_t  startT
			if endT 	!= undefined do updateLabel btn_end_t  endT
			if lineObj != undefined do updateLabel btn_line  lineObj
		)
		on params open do init()	
		on btn_start_p picked obj do (addComponent obj #start_p)
		on btn_start_t picked obj do (addComponent obj #end_p)
		on btn_end_p picked obj do (addComponent obj #start_t)
		on btn_end_t picked obj do (addComponent obj #end_t)
		on btn_line    picked obj do (addComponent obj #line)
		on attachedToNode obj do (linkNode obj)
	)
)
try (custAttributes.delete $ roGen_Road_Attributes baseObject:false) catch ()
custAttributes.add $ roGen_Road_Attributes --baseObject:false

/*
$.startP = nodeTransformMonitor node:$Dummy002 forwardTransformChangeMsgs:false 
*/