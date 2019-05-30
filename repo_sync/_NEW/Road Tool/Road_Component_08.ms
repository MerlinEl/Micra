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
			type type:#integer
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
				
				meshObj = createInstance Sphere radius:size segments:8 mapCoords:false
				lastSize = size
				format "roGen_Joint > getDisplayMesh >  mesh:%\n" meshObj
			)
			if size != lastSize do (
				 
				lastSize = meshObj.radius = size
			)
			meshObj.mesh
		)
		--on create do (format "Dummy was created:% \n" this) --call before getDisplayMesh
		on attachedToNode obj do ( --when node is assinged in to attribute
			
			format "roGen_Joint > attachedToNode > node:% this:%\n" obj.name this
		)
		on detachedFromNode obj do ( --when node is deleted or detached from attribute
			
			format "roGen_Joint > detachedFromNode > node:% this:%\n" obj this
		)
		on deleted do (
			
			format "roGen_Joint > deleted this:%\n"  this
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
--if classOf roGen_Road_Attributes != AttributeDef do (
roGen_Road_Attributes = attributes roGen_Road_Attributes attribID:#(0x11aa99ff, 0x1234abcd)
(
	fn getNode = (
		
		local owner = custattributes.getowner this
		refs.dependentnodes owner firstonly:on
	)
	local thisNode, handler
	parameters main rollout:params 
	(
-- 		node_list type:#nodeTab tabSizeVariable:true
		sp_start_len	type:#float animatable:true default:1 ui:sp_start_len
		sp_end_len		type:#float animatable:true default:1 ui:sp_end_len
		components_tab type:#MaxObjectTab tabSize:0 tabSizeVariable:true
		--points_list type:#point3tab tabSizeVariable:true
		--destroy_self type:#boolTab default:false
	
-- 		on sp_start_len set val do format "set start len:%\n" val
-- 		on sp_end_len set val do format "set end len:%\n" val
-- 		on node_list set obj index do (format "roGen_Road_Attributes > set nodeTab: % : %\n" obj index)
-- 		on node_list get val index do (format "get nodeTab: % : %\n" val index;val)	
-- 		on node_list tabChanged change tabIndex tabCount do this.params.updateList()
	)

	rollout params "Road Parameters:" (
		
		--Pick object Filters
		fn isUnique obj = (
			
			local is_unique  = ( for itm in params.lbx.items where findString itm obj.name != undefined do exit with false )
			is_unique == OK
		)
		fn isEmptySlot slot_index = (
		
			if slot_index > params.lbx.items.count do return false
			findString params.lbx.items[slot_index] "None" != undefined
		)
		fn filterRoadComponents obj = (
			
			if not ( isUnique obj ) or not ( isEmptySlot this.params.lbx.selection ) do return false
			local is_valid_type = case this.params.lbx.selection of (
				
				1: classOf obj == roGen_Joint --"start"
				2: classOf obj == roGen_Joint --"end"
				3: classOf obj == SplineShape --"path"
			)
			is_valid_type
		)
		
		group "Components:"
		(
			listbox lbx "node_list" pos:[8,5] width:155 height:4 align:#center items:#("Start:None", "End:None", "Path:None")  --multiListBox
			pickbutton btn_add "Add" width:80 height:20  toolTip:"Add Component" filter:filterRoadComponents  align:#left across:2
			button btn_rem "Remove" width:80 height:20  toolTip:"Remove Component" align:#left
		)
		group "Tangents:"
		(
			checkbox tndisplay "Show"  width:150 height:14 align:#left
			spinner sp_start_len "Start length" width:150 height:16 range:[1,9999,1] type:#float align:#left
			spinner sp_end_len "End   length" width:150 height:16 range:[1,9999,1] type:#float align:#left
			button btn_auto_tangents "Auto" width:155  toolTip:"Automatic Tangents Adjustment"
		)
		group "Debug:"
		(
			button btn_test_1 "Print Components" width:140 height:20 align:#center
		)
		fn updateLabel btn max_obj = (
			
			local lbl = if (isValidNode max_obj.node) then max_obj.node.name else "None"
			btn.text = lbl	
		)
		fn updateList = (
			
			format "roGen_Road_Attributes > updateList...\n" 
			if not (isValidNode thisNode) do return false 
			local lbx_items = #("Start:None", "End:None", "Path:None") --default items
			for n in (refs.dependentnodes thisNode) do (
				
				case classOf n of (
						
					roGen_Joint: (
						
						if findString n.name "Start" != undefined do lbx_items[1] = "Start:" + n.name
						if findString n.name "End" != undefined do lbx_items[2] = "End:" + n.name
					)
					SplineShape: (
						
						lbx_items[3] = "Path:" + n.name
					)
				)
			)
			lbx.items = lbx_items
        )
		fn linkConstraint obj_src obj_trgt = (
		
			if isValidNode obj_src and isValidNode  obj_trgt do (
				
				format "roGen_Road_Attributes > linkNode [ % ] to  [ % ]\n" obj_src obj_trgt
				obj_src.controller = link_constraint()
				obj_src.controller.addTarget obj_trgt 1 --at frame 1
			)
		)
		fn removeComponent = (
					
			if not (isValidNode thisNode) do return false 
			--get node name
			local start_index = findString lbx.selected ":"
			local node_name = subString lbx.selected (start_index+1) -1
			--remove node self  callbacks	
			--remove node from this callback
--TODO
			--remove node from list
			format "roGen_Road_Attributes > removeComponent >  ( % ) node:%\n" lbx.selection node_name
			local components =  refs.dependentnodes thisNode
			for i=1 to components.count where components[i].name == node_name do (
				
				components[i].transform.controller.deleteTarget 1
				if components_tab.count >= i do deleteItem components_tab (findItem components components[i])
				exit
			)
			updateList()	
		)
		fn addComponent obj = (
			
			linkConstraint obj thisNode
			format "add component:% to:%\n" obj components_tab
			append components_tab (nodeTransformMonitor node:obj forwardTransformChangeMsgs:false)
			updateList()
		)
		on params open do ( updateList() )
		on btn_add picked obj	do ( addComponent obj 	)
		on btn_rem pressed		do ( removeComponent() 	)
		on btn_auto_tangents pressed do (
			
			format "roGen_Road_Attributes > Automatic Tangents Adjustment:%\n" (getNode())	
		)
		--debug
		on btn_test_1 pressed do (
				
			for n in components_tab do format "component:%\n" n.node 
		)
	)
	fn updateList = ( params.updateList() ) --public shortcut
	fn isEmptySlot slot_index = ( params.isEmptySlot slot_index ) --public shortcut
	fn addComponent obj = ( params.addComponent obj ) --public shortcut
	fn drawLineBetweenTwoPoints pointA pointB = (
		
	  local ss = SplineShape pos:pointA
	  addNewSpline ss
	  addKnot ss 1 #corner #line PointA
	  addKnot ss 1 #corner #line PointB
	  updateShape ss
	  ss
	)
	fn missingComponets = ( 
		
		(refs.dependentNodes thisNode).count == 0
	) 
	
	fn unregisterCallbacks = (
		
		format "roGen_Road_Attributes > unregisterCallbacks..."
		deleteChangeHandler handler
		handler = undefined
		gc()		
	)
	fn removeAttribute components:false = (
		
		format "roGen_Road_Attributes > removeAttribute this:% b:%\n" this thisNode	
		with undo "Delete Road" on ( with redraw off (
			
			try (custAttributes.delete thisNode roGen_Road_Attributes baseObject:true) catch (format "roGen_Road_Attributes > Error: % n" (getCurrentException()))	

				if components do (
				
					local children = for o in (refs.dependentnodes thisNode) where isValidNode o collect o
					for o in children do o.transform.controller.deleteTarget 1 --break constraint link
					if isValidNode 	thisNode do delete thisNode --delete road mesh and break all dependency links	
					delete children
			)
		))
		CompleteRedraw()
	)
	fn selfDestroy = (
		
-- 		if isValidNode 	thisNode do delete thisNode --delete road geometry and break all constraint links 	
		format "roGen_Road_Attributes > selfDestroy > nodes:%\n" components_tab
		local children = for o in components_tab where isValidNode o.node collect o.node	
		delete children
	)
	fn registerCallbacks = (
		
			format "roGen_Road_Attributes > registerCallbacks..."
-- 			components_tab = #() -- resets the #maxobjecttab array
			if handler != undefined do unregisterCallbacks()
			--handler = when (refs.dependentNodes thisNode) deleted obj do (
			handler = when thisNode deleted obj do (
		
			format "Collection was destroyed by deleting a component:%\n" obj
			unregisterCallbacks()
			selfDestroy()
		)	
	)
	fn init = (

		thisNode = getNode()
		
		format "roGen_Road_Attributes > init > Attribute applied to node: %\n" thisNode
		--https://forums.cgsociety.org/t/when-object-deleted-delete-children-huh/1585895/88
		if not ( missingComponets() ) do return false
		--Generate and link Components
		local jo_start = roGen_Joint pos:[thisNode.min.x, (thisNode.min.y + thisNode.max.y) / 2, thisNode.min.z] size:2 name:(uniqueName "Road_Joint_Start_")
		local jo_end = roGen_Joint pos:[thisNode.max.x, (thisNode.min.y + thisNode.max.y) / 2, thisNode.min.z] size:2 name:(uniqueName "Road_Joint_End_")
		local line_path = drawLineBetweenTwoPoints jo_start.pos jo_end.pos
		jo_start.wirecolor = jo_end.wirecolor = line_path.wirecolor = green
		thisNode.addComponent jo_start
		thisNode.addComponent jo_end
		thisNode.addComponent line_path
		--AddCallbacks
		registerCallbacks()	
	)
	on clone orig do (
	
		format "roGen_Road_Attributes > cloned a:% b:%\n" this orig	
	)
	on deleted do ( ---when the undo stack is cleared, such file new or reset.
	
		format "roGen_Road_Attributes > deleted:%\n" this
	)
)


--------------
--APPLY
--------------
(
	fn addAttribute obj = (
	
		try (obj.removeAttribute()) catch ()
		custAttributes.add obj roGen_Road_Attributes baseObject:true
		obj.init() --must after creation
	)
	--ADD ATTRIBUTE
	addAttribute	selection[1]
)







			--when select $ changes id:#roGen_Joint_Callback meshObj do format "changed obj:%\n" meshObj.name	
			/*when obj deleted id:#roGen_Joint_Callback obj  do ( 
					
				format "obj deleted:%\n" obj	
				deleteAllChangeHandlers id:#roGen_Joint_Callback
			)*/
/*

			obj.controller = link_constraint()
			obj.controller.addTarget this 1 --at frame 1
			
			obj.fpos.controller = point3_script()
			mt_obj = point size:10 wirecolor:green centermarker:false axistripod:false cross:false box:true name:(uniquename "MatrixPp_MT")
			mt_obj.transform.controller = obj.transform.controller
			local pos_pt = point size:6 wirecolor:green centermarker:false axistripod:false cross:true box:false name:(uniquename "MatrixPp_pos") pos:mt_obj.pos
			obj.fpos.controller.addTarget "tpos" pos_pt.pos.controller
			obj.fpos.controller.script = "tpos"

	fn postDeleteWholeClass =  (
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
	)

		this_name = thisNode.name	
		
		local track_nodes = #(thisNode, jo_start, jo_end)
		if handler != undefined do deleteChangeHandler handler
		handler = when track_nodes deleted obj do (
		
			format "Collection was destroyed by deleting a component:%\n" obj
			--format "Deleting nodes:%\n" node_list
			local nodes_for_delete = for n in this.node_list where isValidNode n collect n
			this.node_list = #()	
			delete nodes_for_delete
			
			local owner = custAttributes.getOwner this
			format "Deleting owner:%\n" owner
			local thisNode = refs.dependentNodes owner firstonly:on	
			format "Deleting thisNode:%\n" thisNode
			if isValidNode thisNode do delete thisNode
			--handler = undefined
			--gc()
		)
		
		--format "B: node_list:%\n" node_list
		
			local center = (this.min  + this.max) / 2 
			local start_pos = [this.min.x , this.min.y+center.y, this.min_z]
			local end_pos = [this.max.x , this.min.y+center.y, this.min_z]
			local jo_start = roGen_Joint pos:[0,0,0] size:2 name:(uniqueName "Road_Joint")
			local jo_end = roGen_Joint pos:[0,0,0] size:2 name:(uniqueName "Road_Joint")
			append node_list jo_start
			append node_list jo_end
		
			if startP 	!= undefined do updateLabel btn_start_p startP
			if endP	!= undefined do updateLabel btn_end_p endP
			if startT 	!= undefined do updateLabel btn_start_t  startT
			if endT 	!= undefined do updateLabel btn_end_t  endT
			if lineObj != undefined do updateLabel btn_line  lineObj
			when transform this changes do (
	
				print "moved"
			)
	)
	on getDisplayMesh do (
			
		--if (meshObj == undefined) do (
		
				 format "on display:%\n" this
				local jo_start = roGen_Joint pos:[0,0,0] size:2 name:(uniqueName "Road_Joint_Start")
				local jo_end = roGen_Joint pos:[0,0,0] size:2 name:(uniqueName "Road_Joint_End")
				append node_list jo_start
				append node_list jo_end
		--)
	)
	on attachedToNode obj do (
			
			format "1: node attached:%\n" obj
	)
	on update do (
	
		format "updated: %\n" this -- when plugin version is changed
	)
	---on create do (init())  --when first time attribute aded in to object
	on load do (
		
		format "load > load node: %\n" (getNode())
	)
	on postCreate do (
		
		format "postCreate > postCreate node: %\n" (this)
		format "postCreate > postCreate node: %\n" (getNode())
	)
	

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




--Link_Constraint
LinkCtrl.getLinkCount <controller>
LinkCtrl.getLinkTime <controller> <index>
LinkCtrl.setLinkTime <controller> <index> <time>
LinkCtrl.getLinkNode <controller> <index>
LinkCtrl.setLinkNode <controller> <index> <node>
LinkCtrl.addLink <controller> <node> <time>
LinkCtrl.deleteLink <controller> <index>
*/