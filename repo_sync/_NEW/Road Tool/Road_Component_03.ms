--****************************************************************************************************--
--		Road Components
--****************************************************************************************************--
if classOf roGen_Joint != Helper do (
	
	plugin Helper roGen_Joint
	name:"Road_Handle"
	classID:#(0x753a97d6, 0x50f2e011)
	category:"Standard"
	extends:dummy
	(
		parameters pblock rollout:params (
			
			size type:#float animatable:true ui:amount default:0
			type type:#integer animateable:false default:1
			rails type:#boolean animateable:false default:false ui:chk_rails
			parkingL type:#boolean animateable:false default:false ui:chk_parking_l
			parkingR type:#boolean animateable:false default:false ui:chk_parking_r
			sidewalkL type:#boolean animateable:false default:false ui:chk_sidewalk_l
			sidewalkR type:#boolean animateable:false default:false ui:chk_sidewalk_r
		)
		rollout params "Parameters" (
			
			label lbl_type "Connection Type:" align:#left
			dropDownList 'ddl_type' "" width:170 height:21 items:#("1-6", "2-2", "2-4", "2-4", "2-5", "4-4", "4-5") align:#left
			checkbox 'chk_rails' "Rails" width:85 height:25 align:#left
			label lbl_parking "Parking Lane:" height:25 align:#left across:3
			checkbox 'chk_parking_l' "Left" width:40 height:25 align:#left
			checkbox 'chk_parking_r' "Right" width:40 height:25 align:#left
			label lbl_sidewalk "Sidewalk:" height:25 align:#left across:3
			checkbox 'chk_sidewalk_l' "Left" width:40 height:25 align:#left
			checkbox 'chk_sidewalk_r' "Right" width:40 height:25 align:#left
			spinner amount "Visual Size:" range:[0, 1e9, 0] align:#left
		)
		on getDisplayMesh do (
			
			meshObj = createInstance pyramid depth:size width:size height:size mapCoords:false wirecolor:green
			meshObj.mesh
		)
		tool create (
			
			local p1
			on mousePoint click do (
				
				case click of  ( 
					
					1: (
						p1=gridPoint
						nodeTM.translation =  p1
					)
					2: #stop
				)
			)
			on mousemove click do (
				
				size = (distance p1 gridPoint)
			)
		)
	)
)

jo_1 = roGen_Joint pos:[0,0,0] size:2

roGen_Road_Attributes = attributes roGen_Road_Attributes attribID:#(0x11aa99ff, 0x1234abcd)
(
	parameters main rollout:params 
	(
		nodes type:#nodeTab tabSizeVariable:true
		sp_start_len	type:#float animatable:true default:1 ui:sp_start_len
		sp_end_len		type:#float animatable:true default:1 ui:sp_end_len
		on sp_start_len set val do format "set start len:%\n" val
		on sp_end_len set val do format "set end len:%\n" val
		--on sp_start_len get val do (format "get sp_start_len: % : \n" val ;val)
		--on sp_end_len get val do (format "get sp_start_len: % : \n" val ;val)
		
		--on lineObj changed do  format "deleted :%\n" lineObj

/*	
nodeTab type:#nodetab tabSizeVariable:true
on nodeTab set val index do format "set nodeTab: % : %\n" val index
on nodeTab get val index do (format "get nodeTab: % : %\n" val index;val)
on <name> tabChanged < arg1 > < arg2 > < arg3 > do < expr >
		
	theNodeList type:#nodeTab tabSize:0 tabSizeVariable:true	
	-- update the multiListBox when the nodeTab has changed
	on theNodeList tabChanged change tabIndex tabCount do this.theRollout.updateNodeList()
*/
	)
	
	fn filterObject obj = ( 
		
		try( (classof obj.mesh == triMesh) and (getnumverts obj.mesh) > 0 and (getnumfaces obj.mesh) > 0 ) catch( false ) 
	)
	fn filterDummy obj = (classof obj == Dummy)
	fn filterShape obj = (classof obj == Line)
	
	rollout params "Road Parameters:" (
			
		group "Components:"
		(
			listbox lbx1 "nodes" pos:[8,5] width:170 height:8 align:#center
			dropDownList 'ddl_type' "" width:170 height:21 items:#("Start_Point", "End_Point", "Start_Tangent", "End_Tangent", "Path") align:#left
			button btn_add "Add" width:80 height:20  toolTip:"Add Component" align:#left across:2
			button btn_rem "Remove" width:80 height:20  toolTip:"Remove Component" align:#left
		)
		group "Settings:"
		(
			spinner sp_start_len "T1 length" width:74 height:16 range:[1,9999,1] type:#float align:#left
			spinner sp_end_len "T2 length" width:74 height:16 range:[1,9999,1] type:#float align:#left
		)
		fn linkNode obj = (
			
			format "linkNode obj:%\n" obj
			/*obj.controller = link_constraint()
			obj.controller.addTarget this 1 --at frame 1*/
			
			/*obj.fpos.controller = point3_script()
			mt_obj = point size:10 wirecolor:green centermarker:false axistripod:false cross:false box:true name:(uniquename "MatrixPp_MT")
			mt_obj.transform.controller = obj.transform.controller
			local pos_pt = point size:6 wirecolor:green centermarker:false axistripod:false cross:true box:false name:(uniquename "MatrixPp_pos") pos:mt_obj.pos
			obj.fpos.controller.addTarget "tpos" pos_pt.pos.controller
			obj.fpos.controller.script = "tpos"*/
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
				)
				#end_p: (
				
					endP = nodeTransformMonitor node:obj forwardTransformChangeMsgs:false
				)
				#start_t: (
				
					startT = nodeTransformMonitor node:obj forwardTransformChangeMsgs:false
				)
				#end_t: (
				
					endT = nodeTransformMonitor node:obj forwardTransformChangeMsgs:false
				)
				#line: (
					
					lineObj = nodeTransformMonitor node:obj forwardTransformChangeMsgs:false
				)
			)
		)
		fn updateModel = (
			
			format "updateModel..."
		)
		fn init = (
			format "init.....\n"
			
			/*if startP 	!= undefined do updateLabel btn_start_p startP
			if endP	!= undefined do updateLabel btn_end_p endP
			if startT 	!= undefined do updateLabel btn_start_t  startT
			if endT 	!= undefined do updateLabel btn_end_t  endT
			if lineObj != undefined do updateLabel btn_line  lineObj*/
			/*when transform this changes do (
	
				print "moved"
			)*/
		)
		fn updateList = (

            lbx1.items = for n in nodes collect n.name
        )
		on params open do updateList()
	)
	fn init = (
		
			format "init > created: %\n" this

			/*if startP 	!= undefined do updateLabel btn_start_p startP
			if endP	!= undefined do updateLabel btn_end_p endP
			if startT 	!= undefined do updateLabel btn_start_t  startT
			if endT 	!= undefined do updateLabel btn_end_t  endT
			if lineObj != undefined do updateLabel btn_line  lineObj*/
			/*when transform this changes do (
	
				print "moved"
			)*/
	)
	on update do format "updated: %\n" this -- when plugin version is changed
	on create do init()  --when first time attribute aded in to object
	on clone orig do (
	
		format "cloned a:% b:%\n" this orig	
	)
	on deleted do ( ---when the undo stack is cleared, such file new or reset.
	
		format "deleted:%\n" this
	)
)
try (custAttributes.delete $ roGen_Road_Attributes baseObject:false) catch ()
custAttributes.add $ roGen_Road_Attributes --baseObject:false

/*
$.startP = nodeTransformMonitor node:$Dummy002 forwardTransformChangeMsgs:false 
*/