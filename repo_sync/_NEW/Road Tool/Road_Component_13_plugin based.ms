-- https://forums.cgsociety.org/t/when-object-deleted-delete-children-huh/1585895/66
--https://forums.cgsociety.org/t/when-object-deleted-delete-children-huh/1585895/88
-- https://forums.cgsociety.org/t/how-can-i-delete-object-which-is-used-as-object-node-in-script-controller-wo-popup/1873581/7
--****************************************************************************************************--
--		Road Joint 
 --jo = roGen_Joint pos:[0,0,0] size:2 name:(uniqueName "Road_Joint")
--****************************************************************************************************--
-- if classOf roGen_Joint != Helper do (
	
	plugin Helper roGen_Joint
	name:"RoadJoint"
	classID:#(0x753a97d6, 0x50f2e011) --genClassID()
	category:"Road Tool"
	extends:Dummy
	(
		local lastSize, meshObj
		parameters main rollout:params (
			
			size type:#float animatable:true ui:amount default:0
			type type:#integer
			rails type:#boolean animateable:false default:false ui:chk_rails
			parkingL type:#boolean animateable:false default:false ui:chk_parking_l
			parkingR type:#boolean animateable:false default:false ui:chk_parking_r
			sidewalkL type:#boolean animateable:false default:false ui:chk_sidewalk_l
			sidewalkR type:#boolean animateable:false default:false ui:chk_sidewalk_r
			is_linked type:#boolean animateable:false default:false
			is_deleted type:#boolean animateable:false default:false
			node_name  type:#string animateable:false default:""
			tangent_pos type:#point3 animateable:false default:[0,0,0]
			parent_node type:#maxObject
		)
		rollout params "Road Tool Parameters" (
			
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
		on attachedToNode obj do ( --when node is created
			
			format "roGen_Joint > attachedToNode > node:%\n" obj
		)
		on detachedFromNode obj do ( --when node is deleted
			
			format  "roGen_Joint > detachedFromNode > node_name:%\n"  node_name
			if is_deleted do return false --prevent depency loop crash
			format  "roGen_Joint > detachedFromNode > parent:% is_deleted:%\n"  parent_node is_deleted
			is_deleted = true
			if classOf parent_node == NodeTransformMonitor do ( --when spline is dleted delete also master obj
				local obj = parent_node.node
				if isValidNode obj and not (isDeleted obj) and not (obj.is_deleted) do (
					
					format "roGen_Joint > detachedFromNode > Deleting parent node:%\n" obj.name
					try (delete parent_node.node) catch (format "roGen_Joint > detachedFromNode > Error:%\n" (getCurrentException()))
				)
			)
		)
		on deleted do (
			
			is_deleted = true
			format "roGen_Joint > deleted node:%\n"  node_name
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
-- )

--****************************************************************************************************--
--		Road Path 
 --line_path = roGen_Path startP:selection[1].pos endP: selection[2].pos name:(uniqueName "Road_Path_") build:true
--****************************************************************************************************--
-- if classOf roGen_Path != Shape do (
	
	plugin shape roGen_Path
	name:"RoadPath"
	classID:#(0x13a5b2ee, 0x319bf3a8)
	extends:line version:1
	category:"Road Tool"
	(
		local meshObj
		fn getNode = (
				
			refs.dependentnodes this firstonly:on
		)
		fn drawLineBetweenTwoPoints pointA pointB = (

			meshObj = getNode()
			if meshObj == undefined do meshObj = SplineShape pos:pointA
			addNewSpline meshObj
			addKnot meshObj 1 #corner #line PointA
			addKnot meshObj 1 #corner #line PointB
			updateShape meshObj
			meshObj.wirecolor = green
		)
		parameters main rollout:params (
			
			parent_node type:#maxObject
			startP type:#point3 animateable:false default:[0,0,0]
			endP type:#point3 animateable:false default:[0,0,0]
			is_deleted type:#boolean animateable:false default:false
			build type:#boolean animateable:false default:false
			node_name  type:#string animateable:false default:""
			
			on build set val do (
				
				if build do (
					
					format "build shape: % \n" val
					drawLineBetweenTwoPoints startP endP
				)
			)
		)
		rollout params "RoadTool:"  (
			
			group "About:" (
				
				label lbl1 "Road Spline Helper" align:#left
			)
		)
		on detachedFromNode obj do ( --when node is deleted
			
			format  "roGen_Path > detachedFromNode > node_name:%\n"  node_name
			if is_deleted do return false --prevent depency loop crash
			format  "roGen_Path > detachedFromNode > parent:% is_deleted:%\n"  parent_node is_deleted
			is_deleted = true
			if classOf parent_node == NodeTransformMonitor do ( --when spline is dleted delete also master obj
				local obj = parent_node.node
				if isValidNode obj and not (isDeleted obj) and not (obj.is_deleted) do (
					
					format "roGen_Path > detachedFromNode > Deleting parent node:%\n" obj.name
					try (delete parent_node.node) catch (format "roGen_Path > detachedFromNode > Error:%\n" (getCurrentException()))
				)
			)
		)

		on deleted do (
				
			is_deleted = true
			format "roGen_Path > deleted node:%\n"  node_name
		)
		
		tool create numPoints:3 (

			on mousePoint click do case click of (

				2: (
					startP = gridPoint
					nodeTM.translation = startP
				)
				3: (
					
					endP = gridPoint
					drawLineBetweenTwoPoints startP endP
					--meshObj.pivot = (meshObj.min + meshObj.max) / 2
					#stop
				)
			)
		)
	)
-- )

--****************************************************************************************************--
--		Road Attributes
--****************************************************************************************************--
--if classOf roGen_Road_CA != AttributeDef do (
	
	roGen_Road_CA = attributes roGen_Road_CA attribID:#(0x11aa99ff, 0x1234abcd)
	(
		fn getNode = (
			
			local owner = custattributes.getowner this
			refs.dependentnodes owner firstonly:on
		)
		local thisNode, handler
		parameters main rollout:params (
			
	-- 		node_list type:#nodeTab tabSizeVariable:true
			sp_start_len	type:#float animatable:true default:1 ui:sp_start_len
			sp_end_len		type:#float animatable:true default:1 ui:sp_end_len
			components_tab type:#MaxObjectTab tabSize:0 tabSizeVariable:true
			is_deleted type:#boolean animateable:false default:false
			node_name  type:#string animateable:false default:""
			--points_list type:#point3tab tabSizeVariable:true
			--destroy_self type:#boolTab default:false
		
	-- 		on sp_start_len set val do format "set start len:%\n" val
	-- 		on sp_end_len set val do format "set end len:%\n" val
	-- 		on node_list set obj index do (format "roGen_Road_CA > set nodeTab: % : %\n" obj index)
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
			fn previewTangents = (
				
	-- 			if startP == undefined or endP == undefined do return false
	-- 				
	-- 			gw.setColor #line yellow	
	-- 			gw.setTransform(Matrix3 1)	
	-- 			gw.polyline #(startP, endP) false --connect circle points
	-- 			gw.enlargeUpdateRect #whole
	-- 			gw.updateScreen()
			)	
			fn updateLabel btn max_obj = (
				
				local lbl = if (isValidNode max_obj.node) then max_obj.node.name else "None"
				btn.text = lbl	
			)
			fn updateList = (
				
				format "roGen_Road_CA > updateList...\n" 
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
					
					format "roGen_Road_CA > linkNode [ % ] to  [ % ]\n" obj_src obj_trgt
					obj_src.controller = link_constraint()
					obj_src.controller.addTarget obj_trgt 1 --at frame 1
				)
			)
			fn removeComponent = (
						
				--get node name
				local start_index = findString lbx.selected ":"
				local node_name = subString lbx.selected (start_index+1) -1
				--remove from viewport draw tangents collection
	--TODO
				--remove node from list and components_tab
				format "roGen_Road_CA > removeComponent >  ( % ) node:%\n" lbx.selection node_name
				for i=1 to components_tab.count do (
					
					local obj = components_tab[i].node
					if obj.name ==  node_name do (
					
	-- 					obj.transform.controller.deleteTarget 1 --remove constraint
						obj.transform.controller = prs () --replace Link_Constraint with Position_Rotation_Scale
						obj.parent_node = undefined
						deleteItem components_tab i
						exit
					)
				)	
				updateList()	
			)
			fn addComponent obj = (
				
				obj.parent_node = ( nodeTransformMonitor node:thisNode forwardTransformChangeMsgs:false )
				obj.node_name = obj.name
				linkConstraint obj thisNode
				format "roGen_Road_CA > addComponent node:% to:%\n" obj components_tab
				append components_tab (nodeTransformMonitor node:obj forwardTransformChangeMsgs:false)
				updateList()
			)
			on params open do ( updateList() )
			on btn_add picked obj	do ( addComponent obj 	)
			on btn_rem pressed		do ( removeComponent() 	)
			on btn_auto_tangents pressed do (
				
				format "roGen_Road_CA > Automatic Tangents Adjustment:%\n" (getNode())	
			)
			--debug
			on btn_test_1 pressed do (
					
				for n in components_tab do format "component:%\n" n.node 
			)
		)
		fn updateList = ( params.updateList() ) --public shortcut
		fn isEmptySlot slot_index = ( params.isEmptySlot slot_index ) --public shortcut
		fn addComponent obj = ( params.addComponent obj ) --public shortcut
		fn missingComponets = ( 
			
			(refs.dependentNodes thisNode).count == 0
		) 
		
		fn unregisterCallbacks = (
			
			format "roGen_Road_CA > unregisterCallbacks...\n"
			deleteChangeHandler handler
			handler = undefined
			gc()		
		)
		fn removeAttribute components:false = (
			
			format "roGen_Road_CA > removeAttribute this:% b:%\n" this thisNode	
			with undo "Delete Road" on ( with redraw off (
				
				try (custAttributes.delete thisNode roGen_Road_CA baseObject:true) catch (format "roGen_Road_CA > Error: % n" (getCurrentException()))	

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
				
			is_deleted = true
			local children = for o in components_tab where isValidNode o.node and not (isDeleted o.node) and not  (o.node.is_deleted) collect o.node	
			for o in children do (
				
				o.is_deleted = true
				try (
					
					format "roGen_Road_CA > selfDestroy > delete child:%\n" o.name
					delete o
				) catch (format "roGen_Road_CA > selfDestroy > Error during delete:% %\n" o (getCurrentException()))
			)
			gc()	
		)
		fn registerCallbacks = (
			
				format "roGen_Road_CA > registerCallbacks..."
				if handler != undefined do unregisterCallbacks()
				handler = when thisNode deleted obj do (
					
				format "roGen_Road_CA > Collection was destroyed by deleting a component:%\n" obj.name
				unregisterCallbacks()
				selfDestroy()
			)	
		)
		fn init = (

			thisNode = getNode()
			thisNode.name = uniqueName "Road_"
			node_name = thisNode.name
			format "roGen_Road_CA > init > Attribute applied to node: %\n" thisNode
			if not ( missingComponets() ) do return false
			--Generate and link Components
			local jo_start = roGen_Joint pos:[thisNode.min.x, (thisNode.min.y + thisNode.max.y) / 2, thisNode.min.z] size:2 name:(uniqueName "Road_Joint_Start_")
			local jo_end = roGen_Joint pos:[thisNode.max.x, (thisNode.min.y + thisNode.max.y) / 2, thisNode.min.z] size:2 name:(uniqueName "Road_Joint_End_")
			local line_path = roGen_Path startP:jo_start.pos endP: jo_end.pos name:(uniqueName "Road_Path_")  build:true
			format "line_path:%\n" line_path
			global rpath = line_path
			jo_start.wirecolor = jo_end.wirecolor =  green
			addComponent jo_start
			addComponent jo_end
			addComponent line_path
			--AddCallbacks
			registerCallbacks()	
		)
		on clone orig do (
		
			format "roGen_Road_CA > cloned a:% b:%\n" this orig	
		)
		on deleted do ( ---when the undo stack is cleared, such file new or reset.
		
			format "roGen_Road_CA > deleted node:%\n" node_name
		)
	)
-- )

--------------
--APPLY
--------------
(
	fn addAttribute obj = (
	
		if obj == undefined do return false
		try (obj.removeAttribute()) catch () --??????
		custAttributes.add obj roGen_Road_CA baseObject:true #unique
		obj.init() --must after creation
	)
	--ADD ATTRIBUTE
	addAttribute	selection[1]
)