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
			tangent_pos type:#point3 animateable:false default:[0,0,0]
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
				format "2: node display:%\n" meshObj
			)
			if size != lastSize do (
				 
				lastSize = meshObj.depth = meshObj.width = meshObj.height = size
			)
			meshObj.mesh
		)
		on attachedToNode obj do (
			
			format "1: node attached:%\n" obj
			--when select $ changes id:#roGen_Joint_Callback meshObj do format "changed obj:%\n" meshObj.name	
			/*when obj deleted id:#roGen_Joint_Callback obj  do ( 
					
				format "obj deleted:%\n" obj	
				deleteAllChangeHandlers id:#roGen_Joint_Callback
			)*/
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
--		Road Attributes
--****************************************************************************************************--
roGen_Road_Attributes = attributes roGen_Road_Attributes attribID:#(0x11aa99ff, 0x1234abcd)
(
	fn getNode = (refs.dependentnodes (custattributes.getowner this) firstonly:on)
	local handler
	parameters main rollout:params 
	(
		node_list type:#nodeTab tabSizeVariable:true
		points_list type:#point3tab tabSizeVariable:true
		this_name type:#string default:"undefined"
		--destroy_self type:#boolTab default:false
		destroy_self type:#boolean default:false
		--thisNode type:#node tabSizeVariable:true
		sp_start_len	type:#float animatable:true default:1 ui:sp_start_len
		sp_end_len		type:#float animatable:true default:1 ui:sp_end_len
		on sp_start_len set val do format "set start len:%\n" val
		on sp_end_len set val do format "set end len:%\n" val
		--on sp_start_len get val do (format "get sp_start_len: % : \n" val ;val)
		--on sp_end_len get val do (format "get sp_start_len: % : \n" val ;val)
		
		--on lineObj changed do  format "deleted :%\n" lineObj

		--on node_list set val index do (format "set nodeTab: % : %\n" val index)
		--on node_list get val index do (format "get nodeTab: % : %\n" val index;val)
		
		--on destroy_self get val do (format "get destroy_self: % : %\n" val)
		--on destroy_self get val do (format "get destroy_self: % : %\n" val;val)
/*	
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
			listbox lbx1 "node_list" pos:[8,5] width:170 height:4 align:#center items:#("Start : None", "End   : None", "Path  : None")  --multiListBox
			pickbutton btn_add "Add" width:80 height:20  toolTip:"Add Component" filter:filterRoadComponents  align:#left across:2
			button btn_rem "Remove" width:80 height:20  toolTip:"Remove Component" align:#left
		)
		group "Tangents:"
		(
			checkbox tndisplay "Show"  width:150 height:14 align:#left
			spinner sp_start_len "Start length" width:150 height:16 range:[1,9999,1] type:#float align:#left
			spinner sp_end_len "End   length" width:150 height:16 range:[1,9999,1] type:#float align:#left
			button btn_auto_tangents "Auto" width:170  toolTip:"Automatic Tangents Adjustment"
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
		fn updateList = (
			
			format "updateList...\n"
            --lbx1.items = for n in node_list collect n.name
        )
		on params open do updateList()
		on btn_add picked obj do append node_list obj
		on btn_rem pressed do (
			
			if lbx1.selection == 0 do return false
			deleteItem node_list lbx1.selection
			updateList()
		)
		on btn_auto_tangents pressed do (
			
			format "Automatic Tangents Adjustment:%\n" (getNode())	
		)
	)
	/*fn postDeleteWholeClass =  (
				--callbacks.addscript #nodePreDelete "preDeleteWholeClass()" id:#delete_same_class
			callbacks.addscript #nodePostDelete "postDeleteWholeClass()" id:#delete_same_class
		deleteAllChangeHandlers id:#delete_same_class
		local obj = callbacks.notificationParam()
		format "Collection was destroyed by deleting a component:%\n" obj
		--if node belongs to this collection class will be deleted
		
		deleteAllChangeHandlers id:#delete_same_class
		delete (for n in this.node_list where isValidNode n collect n) --delete rest nodes from collection
		local thisNode = getNode()
		if isValidNode thisNode do delete thisNode
		gc()
	)*/
	fn init = (

			local thisNode = getNode()
			format "init > created node: %\n" thisNode
			this_name = thisNode.name	
			local jo_start = roGen_Joint pos:[thisNode.min.x, (thisNode.min.y + thisNode.max.y / 2), 0] size:2 name:(uniqueName "Road_Joint_Start")
			local jo_end = roGen_Joint pos:[thisNode.max.x, (thisNode.min.y + thisNode.max.y / 2), 0] size:2 name:(uniqueName "Road_Joint_End")
			node_list[1] = jo_start
			node_list[2] = jo_end
			--https://forums.cgsociety.org/t/when-object-deleted-delete-children-huh/1585895/88
			

			
		local track_nodes = #(thisNode, jo_start, jo_end)
		if handler != undefined do deleteChangeHandler handler
		handler = when track_nodes deleted obj do (
		
			format "Collection was destroyed by deleting a component:%\n" obj
			--format "Deleting nodes:%\n" node_list
			local nodes_for_delete = for n in this.node_list where isValidNode n collect n
			this.node_list = #()	
			delete nodes_for_delete
			
			/*local owner = custAttributes.getOwner this
			format "Deleting owner:%\n" owner
			local thisNode = refs.dependentNodes owner firstonly:on	
			format "Deleting thisNode:%\n" thisNode
			if isValidNode thisNode do delete thisNode*/
			handler = undefined
			gc()
		)
		
		--format "B: node_list:%\n" node_list
		
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
	/*on getDisplayMesh do (
			
		--if (meshObj == undefined) do (
		
				 format "on display:%\n" this
				local jo_start = roGen_Joint pos:[0,0,0] size:2 name:(uniqueName "Road_Joint_Start")
				local jo_end = roGen_Joint pos:[0,0,0] size:2 name:(uniqueName "Road_Joint_End")
				append node_list jo_start
				append node_list jo_end
		--)
	)*/
	/*on attachedToNode obj do (
			
			format "1: node attached:%\n" obj
	)*/
	/*on update do (
	
		format "updated: %\n" this -- when plugin version is changed
	)*/
	---on create do (init())  --when first time attribute aded in to object
	/*on load do (
		
		format "load > load node: %\n" (getNode())
	)*/
	/*on postCreate do (
		
		format "postCreate > postCreate node: %\n" (this)
		format "postCreate > postCreate node: %\n" (getNode())
	)*/
	on clone orig do (
	
		format "cloned a:% b:%\n" this orig	
	)
	/*on deleted do ( ---when the undo stack is cleared, such file new or reset.
	
		format "deleted:%\n" this
	)*/
)
try (custAttributes.delete $ roGen_Road_Attributes baseObject:false) catch ()
custAttributes.add $ roGen_Road_Attributes --baseObject:false
$.init() --must after creation

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

/*
global ContainerAttrib = attributes ContainerAttrib attribID:#(0x1f05aab6, 0x7a59c3a6)
(
	local handler
	fn getNode = (refs.dependentnodes (custattributes.getowner this) firstonly:on)
	fn constructNode node: = if not (theHold.Redoing() or theHold.Holding()) do
	(
		if node == unsupplied do node = getNode()
		if isvalidnode node and not isdeleted node and handler == undefined do
		(
			handler = when node deleted node do if (attr = node.baseobject.custattributes[#ContainerAttrib]) != undefined do 
			(
				if attr.handler != undefined do deleteChangeHandler attr.handler
				attr.handler = undefined
				delete (for n in attr.container where isvalidnode n and not isdeleted n collect n)
				attr.container = #()
			)
		)
	)
	parameters params 
	(
		container type:#nodeTab tabsizevariable:on
		on container set val do constructNode()
	)

	on update do constructNode()
	on load do constructNode()
)
(
	num = [50,10,10]
	for i=1 to num[1] do 
	(
		gc()
		delete objects
		for k=1 to num[2] do
		(
			y = (k-1)*20
			global b = dummy name:(uniquename "master") pos:[0,y,0]
			custattributes.add b ContainerAttrib
			b.ContainerAttrib.constructNode()
			b.container = for k = 1 to num[3] collect (point pos:[k*20,y,0] wirecolor:orange)
		)
	)
	print "DONE!"
	ok
)
*/


/*
try
(
	PostDelete_NodeEventCallback.enabled = off
	PostDelete_NodeEventCallback = undefined
)
catch()

callbacks.removescripts id:#delete_same_class
callbacks.removeScripts id:#undo
callbacks.removeScripts id:#redo

global NodesForDeletion = #()
global objCount = objects.count


fn PostDelete_Callback event handles = 
(
	nodes = for node in NodesForDeletion where isvalidnode node collect node
	NodesForDeletion = #()
	if nodes.count > 0 do	undo "Post Delete" on delete nodes
	redrawViews()
)

fn preDeleteWholeClass =
(
	if not PostDelete_NodeEventCallback.enabled do
		NodesForDeletion = #()

	if not theHold.Redoing() do
	(
		node = callbacks.notificationParam()
		if isvalidnode node do
		(
			join NodesForDeletion (for n in (getclassinstances (classof node) astrackviewpick:on) where isvalidnode n.client and n != n.client collect n.client)
		)
	)
)

fn undo_Callback =
(
	if (callbacks.notificationParam()) == "Post Delete" do with undo off (max undo)
)

fn redo_Callback =
(
	if objects.count != objCount and (callbacks.notificationParam()) == "Create Selection Set" do
	(
		max redo
		objCount = objects.count
	)
)


PostDelete_NodeEventCallback = NodeEventCallback deleted:(with undo on (PostDelete_Callback))
callbacks.addscript #nodePreDelete "preDeleteWholeClass()" id:#delete_same_class
callbacks.addScript #sceneUndo "undo_Callback()" id:#undo
callbacks.addScript #sceneRedo "redo_Callback()" id:#redo


delete objects
with redraw off
(
	for k=0 to 4 do box pos:[k*30,0,0] width:20 length:20 height:20
	for k=0 to 4 do cylinder pos:[k*30,40,0] radius:10
	for k=0 to 4 do sphere pos:[k*30,80,0] radius:10
)
*/