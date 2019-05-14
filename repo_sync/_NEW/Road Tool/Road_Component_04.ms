--****************************************************************************************************--
--		Road Joint 
 --jo = roGen_Joint pos:[0,0,0] size:2 name:(uniqueName "Road_Joint")
--****************************************************************************************************--
if classOf roGen_Joint != Helper do (
	
	plugin Helper roGen_Joint
	name:"RoadJoint"
	classID:#(0x753a97d6, 0x50f2e011) --genClassID()
	category:"Standard"
	extends:Dummy
	(
		local lastSize, meshObj
		parameters pblock rollout:params (
			
			size type:#float animatable:true ui:amount default:0
			type type:#integer animateable:false default:1
			rails type:#boolean animateable:false default:false ui:chk_rails
			parkingL type:#boolean animateable:false default:false ui:chk_parking_l
			parkingR type:#boolean animateable:false default:false ui:chk_parking_r
			sidewalkL type:#boolean animateable:false default:false ui:chk_sidewalk_l
			sidewalkR type:#boolean animateable:false default:false ui:chk_sidewalk_r
			is_linked type:#boolean animateable:false default:false
		)
		rollout params "Parameters" (
			
			group "Visual:"
			(
				spinner amount "Size:" range:[0, 1e9, 0] align:#left
			)
			group "Settings:" (
				
				label lbl_type "Joint Type:" align:#left
				dropDownList 'ddl_type' "" width:170 height:21 items:#("1-6", "2-2", "2-4", "2-4", "2-5", "4-4", "4-5") align:#left
				checkbox 'chk_rails' "Rails" width:85 height:14 align:#left
				label lbl_parking "Parking Lane:" height:14 align:#left across:3
				checkbox 'chk_parking_l' "Left" width:40 height:14 align:#right
				checkbox 'chk_parking_r' "Right" width:40 height:14 align:#right
				label lbl_sidewalk "Sidewalk:" height:14 align:#left across:3
				checkbox 'chk_sidewalk_l' "Left" width:40 height:14 align:#right
				checkbox 'chk_sidewalk_r' "Right" width:40 height:14 align:#right
			)
			group "About:"
			(
				label lbl1 "Road Joint Helper" align:#left
			)
		)
		on getDisplayMesh do (
			
			if (meshObj == undefined) do (
				
				meshObj = createInstance pyramid depth:size width:size height:size mapCoords:false wirecolor:green
			)
			if size != lastSize do (
				 
				lastSize = meshObj.depth = meshObj.width = meshObj.height = size
			)
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

--****************************************************************************************************--
--		Road Tangent
 --ta = roGen_Tangent pos:[0,0,0] size:2 name:(uniqueName "Road_Tangent")
--****************************************************************************************************--
if classOf roGen_Tangent != Helper do (

	plugin Helper roGen_Tangent
	name:"RoadTangent"
	classID:#(0x7fcacacd, 0x6c3d781b) --genClassID()
	category:"Standard"
	extends:Dummy
	--replaceUI:true 
	--version:1
	(
		local meshObj
		parameters pblock rollout:params (
			
			linked_to type:#string default:"None"
		)
		rollout params "Parameters" (
			
			group "About:"
			(
				label lbl1 "Road Tangent Helper" align:#left
			)
		)
		fn createPoint pos:[0, 0, 0] size:10 = (

			local sps = SplineShape wirecolor:green
			addNewSpline sps
			addKnot sps 1 #corner #line [-size/2, 0, 0]
			addKnot sps 1 #corner #line [size/2, 0, 0]
			addNewSpline sps
			addKnot sps 2 #corner #line [0, -size/2, 0]
			addKnot sps 2 #corner #line [0, size/2, 0]
			addNewSpline sps
			addKnot sps 3 #corner #line [0, 0, -size/2]
			addKnot sps 3 #corner #line [0, 0, size/2]
			sps.render_renderable = false
			sps.render_displayRenderMesh = false
			updateShape sps
			sps.pos = pos
		)
		on getDisplayMesh do ( 
			
			if (meshObj == undefined) do (
				
				createPoint()
			)
		)
		fn init = (
				
				--centermarker = true
				--constantscreensize = true
		)
		on create do init()
	)
)

--****************************************************************************************************--
--		Road Attributes
--****************************************************************************************************--
roGen_Road_Attributes = attributes roGen_Road_Attributes attribID:#(0x11aa99ff, 0x1234abcd)
(
	fn getNode = (
		--maxscript get attribute owner
		---https://github.com/Pjanssen/Outliner/blob/master/maxscript/script/nestedlayers.ms
		format "owner:%\n" (custattributes.getowner this)
		refs.dependentnodes (custattributes.getowner this) firstonly:on
	)
	parameters main rollout:params 
	(
		node_list type:#nodeTab tabSizeVariable:true
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

	rollout params "Road Parameters:" (
		
		fn isUnique obj = findItem this.node_list obj == 0
		fn filterRoadComponents obj = (isUnique obj and (classof obj == roGen_Joint or classof obj == Line))
		
		group "Components:"
		(
			listbox lbx1 "node_list" pos:[8,5] width:170 height:8 align:#center --multiListBox
			dropDownList 'ddl_type' "" width:170 height:21 items:#("Start_Point", "End_Point", "Start_Tangent", "End_Tangent", "Path") align:#left
			pickbutton btn_add "Add" width:80 height:20  toolTip:"Add Component" filter:filterRoadComponents  align:#left across:2
			button btn_rem "Remove" width:80 height:20  toolTip:"Remove Component" align:#left
		)
		group "Settings:"
		(
			spinner sp_start_len "T1 length" width:74 height:16 range:[1,9999,1] type:#float align:#left
			spinner sp_end_len "T2 length" width:74 height:16 range:[1,9999,1] type:#float align:#left
		)
		button printNode "PrintNode" 
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

            lbx1.items = for n in node_list collect n.name
        )
		on params open do updateList()
		on btn_add picked obj do append node_list obj
		on btn_rem pressed do (
			
			if lbx1.selection == 0 do return false
			 deleteItem node_list lbx1.selection
			updateList()
			-- collect all nodes that aren't selected
			--node_list = for i = 1 to node_list.count where not node_list.selection[i] collect node_list[i]
		)
		on attachedToNode obj do format "A attached node: %\n" obj
		on printNode pressed do format "%\n" (getNode())	
	)
	
	fn init = (

			local thisNode = getNode()
			format "init > created node: %\n" thisNode
			/*local center = (this.min  + this.max) / 2 
			local start_pos = [this.min.x , this.min.y+center.y, this.min_z]
			local end_pos = [this.max.x , this.min.y+center.y, this.min_z]
			local jo_start = roGen_Joint pos:[0,0,0] size:2 name:(uniqueName "Road_Joint")
			local jo_end = roGen_Joint pos:[0,0,0] size:2 name:(uniqueName "Road_Joint")
			append node_list jo_start
			append node_list jo_end*/
		
			/*if startP 	!= undefined do updateLabel btn_start_p startP
			if endP	!= undefined do updateLabel btn_end_p endP
			if startT 	!= undefined do updateLabel btn_start_t  startT
			if endT 	!= undefined do updateLabel btn_end_t  endT
			if lineObj != undefined do updateLabel btn_line  lineObj*/
			/*when transform this changes do (
	
				print "moved"
			)*/
	)
	 on getDisplayMesh do format "on display:%\n" this
	on attachedToNode obj do format "B attached node: %\n" obj --target = obj.target
	on update do format "updated: %\n" this -- when plugin version is changed
	on create do init()  --when first time attribute aded in to object
	on load do format "load > load node: %\n" (getNode())
	on postCreate do format "postCreate > postCreate node: %\n" (getNode())
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



		--register callbacks
		mcLiveMeasureCallbacks = NodeEventCallback mouseUp:true delay:1000 \
		selectionChanged:selectionChanged \
		deleted:nodeDeleted \
		geometryChanged:geometryChanged \
		callbackBegin: cbBegin \
		callbackEnd: cbEnd
		
		
		mcLiveMeasureCallbacks = undefined --unregister selection change callbacks
		gc()-- light:true
*/