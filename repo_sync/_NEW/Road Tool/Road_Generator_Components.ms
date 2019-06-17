 Global RtCMS
 Global roGen_Road_CA
 Global roGen_Joint_CA
 Global roGen_Spline_CA
 --genClassID()
--****************************************************************************************************--
--Road Joint 
-- jo = Sphere pos:[0,0,0] name:(uniqueName "Road_Joint_Start_")
-- custAttributes.add jo roGen_Joint_CA baseObject:true #unique
-- jo.init()
-- jo.attachParent $Sphere001	
-- if isProperty $ "object_type" and $.object_type == "joint" do print "is joint"
--****************************************************************************************************--
-- if classOf roGen_Joint_CA != AttributeDef do (
		
	roGen_Joint_CA = attributes roGen_Joint_CA attribID:#(0x753a97d6, 0x50f2e011) --genClassID()
	(
		local thisNode, wire_color = green --(color 196 88 225)
		fn getNode = (
			
			local owner = custattributes.getowner this
			refs.dependentnodes owner firstonly:on
		)
		parameters main rollout:params (
			
			object_type type:#string default:"joint"
			type type:#integer animateable:false default:1 ui:ddl_type
			rails type:#boolean animateable:false default:false ui:chk_rails
			parkingL type:#boolean animateable:false default:false ui:chk_parking_l
			parkingR type:#boolean animateable:false default:false ui:chk_parking_r
			sidewalkL type:#boolean animateable:false default:false ui:chk_sidewalk_l
			sidewalkR type:#boolean animateable:false default:false ui:chk_sidewalk_r
			is_linked type:#boolean animateable:false default:false
			tangent_pos type:#point3 animateable:false default:[0,0,0]
			
			on sidewalkL set val do (
				
-- 				format "set sidewalkL to:%\n" val
			)
		)
		rollout params "Road Tool Parameters" rolledUp:false (
			
			group "Settings:" (
				
				label lbl_type "Joint Type:" align:#left
				dropDownList 'ddl_type' "" width:150 height:21 items:#("1-6", "2-2", "2-4", "2-4", "2-5", "4-4", "4-5") align:#left
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

			on params open do ( 
				
-- 				format "params open thisNode:%\n" thisNode
			)
		)
		fn getParentNode = (if isValidNode thisNode then thisNode.controller.getNode 1 else undefined)
		fn attachParent obj_trgt = (
				
			if not (isValidNode thisNode) or not (isValidNode obj_trgt) do return false		
			format "roGen_Joint_CA > attachParent > src:%  trgt:%\n" thisNode obj_trgt	
			thisNode.transform.controller = prs () --set default controller
			thisNode.controller = link_constraint() --set link constraint controller
			thisNode.controller.addTarget obj_trgt 1 --at frame 1
		)
		fn detachParent = (
			
			if not (isValidNode thisNode) or (isDeleted thisNode) do return false	
			format "roGen_Joint_CA > detachParent > obj:[ % ]\n" thisNode
			thisNode.transform.controller = prs () --replace Link_Constraint with Position_Rotation_Scale
		)	
		fn init parent_obj:undefined = (
			
			thisNode = getNode()
			thisNode.wirecolor = wire_color
			thisNode.radius = 5
			thisNode.segs = 4
			thisNode.smooth = false
			thisNode.hemisphere = 0
			thisNode.renderable = false
			thisNode.chop = 1
			thisNode.slice = false
			thisNode.recenter = false
		)
		on load do (
			
			format "roGen_Joint_CA > load\n"
			thisNode = getNode()
		)
	)
-- )
--****************************************************************************************************--
--		Road Path
-- 	sp = drawLineBetweenTwoPoints selection[1].pos selection[2].pos (uniqueName "Road_Path_")
-- 	custAttributes.add sp roGen_Spline_CA baseObject:true  #unique
-- 	sp.init()
--****************************************************************************************************--
roGen_Spline_CA = attributes roGen_Spline_CA attribID:#(0x761e31f5, 0xbcdcd7b)
(
	local thisNode, wire_color = green-- (color 196 88 225)
	fn getNode = (
		
		local owner = custattributes.getowner this
		refs.dependentnodes owner firstonly:on
	)
	parameters main rollout:params (
		
		parent_node type:#maxObject
	)
	rollout params "Road Parameters:" (
		
		group "About:" (
			
			label lbl1 "Road Spline Helper" align:#left
		)
	)
	fn getParentNode = (if isValidNode thisNode then thisNode.controller.getNode 1 else undefined)
	fn attachParent obj_trgt = (
			
		if not (isValidNode thisNode) or not (isValidNode obj_trgt) do return false		
		format "roGen_Spline_CA > attachParent > src:%  trgt:%\n" thisNode obj_trgt	
		thisNode.transform.controller = prs () --set default controller
		thisNode.controller = link_constraint() --set link constraint controller
		thisNode.controller.addTarget obj_trgt 1 --at frame 1
	)
	fn detachParent = (
		
		format "roGen_Spline_CA > detachParent > obj:[ % ]\n" thisNode
		if not (isValidNode thisNode) or (isDeleted thisNode) do return false	
		thisNode.transform.controller = prs () --replace Link_Constraint with Position_Rotation_Scale
	)	
	fn init = (
			
		thisNode = getNode()
		thisNode.wirecolor = wire_color
		thisNode.render_renderable = false
		thisNode.render_displayRenderMesh
		thisNode.steps = 6
-- 		format "roGen_Road_CA > init > Attribute applied to node [ % ]\n" thisNode.name
		format "INITIALIZED--------------------------------------------------[ % ]------------------------------------------------------------\n" thisNode.name
	)
	on load do (
			
		format "roGen_Spline_CA > load\n"
		thisNode = getNode()
	)
)
	
	
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
		local thisNode, wire_color = green-- (color 196 88 225)
		parameters main rollout:params (
			
	-- 		node_list type:#nodeTab tabSizeVariable:true
			script_path			type:#string default:""
			object_type			type:#string default:"road"
			sp_start_len		type:#float animatable:true default:1 ui:sp_start_len
			sp_end_len			type:#float animatable:true default:1 ui:sp_end_len
			components_tab	type:#MaxObjectTab tabSize:0 tabSizeVariable:true
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
					
					1: findString obj.name "Road_Joint_Start" != undefined
					2: findString obj.name "Road_Joint_End" != undefined
					3: findString obj.name "Road_Path" != undefined
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
			fn showTangents = (
				
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
				
				if not (isValidNode thisNode) do return false 
-- 				local linked_nodes =  (refs.dependentnodes thisNode) 
				format "roGen_Road_CA > updateList > node [ % ] components > \n" thisNode.name
				local lbx_items = #("Start:None", "End:None", "Path:None") --default items
				for c in components_tab do (
					
					local n = c.node
					if n == undefined do continue
					format "\t%\n" n.name
					if findString n.name "Road_Joint_Start" != undefined then (
						
						lbx_items[1] = "Start:" + n.name
						
					) else if findString n.name "Road_Joint_End" != undefined then (
						
						lbx_items[2] = "End:" + n.name
					)
					else if findString n.name "Road_Path" != undefined do (
						
						lbx_items[3] = "Path:" + n.name
					)
				)
				lbx.items = lbx_items
			)
			fn removeAll = (
				
				for c in components_tab do (c.node.detachParent())
				components_tab	= #()
				updateList()	
				OK
			)
			fn removeComponent = (
						
				--get node name
				local start_index = findString lbx.selected ":"
				local node_name = subString lbx.selected (start_index+1) -1
				--remove from viewport draw tangents collection
	--TODO
				--remove node from list and components_tab
-- 				format "roGen_Road_CA > removeComponent >  ( % ) node:%\n" lbx.selection node_name
				for i=1 to components_tab.count do (
					
					local obj = components_tab[i].node
					if obj.name ==  node_name do (
					
						obj.detachParent()
						deleteItem components_tab i
						exit
					)
				)	
				updateList()	
			)
			fn addComponent obj = (
				
-- 				format "roGen_Road_CA > addComponent node:% to:%\n" obj components_tab
				obj.attachParent thisNode
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
		fn removeAll = ( params.removeAll() ) --public shortcut
		fn updateList = ( params.updateList() ) --public shortcut
		fn isEmptySlot slot_index = ( params.isEmptySlot slot_index ) --public shortcut
		fn addComponent obj = ( params.addComponent obj ) --public shortcut
		fn getComponents = (
		
			for o in components_tab where isValidNode o.node and not (isDeleted o.node)  collect o.node	
		)
		fn registerEvents = (
			
			if RtCMS != undefined do return OK
			if not (doesFileExist script_path) do	(
				
				format "Error ::: Unable register Road Tool. Script file:% not found.\n" script_path
			)
			fileIn (script_path + "Road_Generator_Callbacks.ms")
		)
		fn init = (
			
			script_path =  getFilenamePath ( getSourceFileName() )
			thisNode = getNode()
			thisNode.name = uniqueName "Road_"
-- 			format "roGen_Road_CA > init > Attribute applied to node [ % ]\n" thisNode.name
			registerEvents()
			format "INITIALIZED--------------------------------------------------[ % ]------------------------------------------------------------\n" thisNode.name
		)
		on load do (
			
			format "roGen_Road_CA > load\n"
			thisNode = getNode()
			updateList()	
			registerEvents()
		)
	)
-- )

------------------------------
--Build Components
-----------------------------
(
	fn drawLineBetweenTwoPoints pointA pointB path_name = (
		
	  local ss = SplineShape pos:pointA
	  addNewSpline ss
	  addKnot ss 1 #corner #line PointA
	  addKnot ss 1 #corner #line PointB
	  updateShape ss
	  ss
	)
	fn addAttribute obj = (
	
		if obj == undefined do return false
		custAttributes.add obj roGen_Road_CA baseObject:true #unique
		obj.init() --must after creation
	)
	--ADD ATTRIBUTE
-- 	local road = selection[1]
	local road = plane length:50 width:100 wirecolor:(color 255 198 87)
	addAttribute	road

	--Generate Components
	local jo_start = Sphere pos:[road.min.x, (road.min.y + road.max.y) / 2, road.min.z] size:2 name:(uniqueName "Road_Joint_Start_") radius:1
	local jo_end = Sphere pos:[road.max.x, (road.min.y + road.max.y) / 2, road.min.z] size:2 name:(uniqueName "Road_Joint_End_") radius:1
	local line_path = drawLineBetweenTwoPoints jo_start.pos jo_end.pos (uniqueName "Road_Path_")
	--Add attributes
	custAttributes.add jo_start roGen_Joint_CA baseObject:true #unique
	custAttributes.add jo_end  roGen_Joint_CA baseObject:true #unique
	custAttributes.add line_path roGen_Spline_CA baseObject:true  #unique
		
	--init
	jo_start.init()
	jo_end.init()
	line_path.init()
	
	road.addComponent jo_start
	road.addComponent jo_end
	road.addComponent line_path
)
