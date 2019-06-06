	roGen_Joint_CA = attributes roGen_Joint_CA attribID:#(0x753a97d6, 0x50f2e011) --genClassID()
	(
		local thisNode, handler
		fn getNode = (
			
			local owner = custattributes.getowner this
			refs.dependentnodes owner firstonly:on
		)
		parameters main rollout:params_rt (
			
			type type:#integer animateable:false default:1 ui:ddl_type
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
			
			on sidewalkL set val do (
				
-- 				format "set sidewalkL to:%\n" val
			)
		)
		rollout params_rt "Road Tool Parameters" rolledUp:false (
			
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

			on params_rt open do ( 
				
-- 				format "params_rt open thisNode:%\n" thisNode
			)
		)

		fn attachParent obj_trgt = (
				
			if not (isValidNode thisNode) or not (isValidNode obj_trgt) do return false		
			format "roGen_Joint > attachParent > src:[ % ] to  trgt:[ % ]\n" thisNode obj_trgt
			parent_node = ( nodeTransformMonitor node:obj_trgt forwardTransformChangeMsgs:false )		
			thisNode.controller = link_constraint()
			thisNode.controller.addTarget obj_trgt 1 --at frame 1
		)
		
		fn detachParent = (

			if not (isValidNode thisNode) do return false		
			format "roGen_Joint > detachParent > src:[ % ] to  trgt:[ % ]\n" thisNode parent_node
-- 			thisNode.transform.controller.deleteTarget 1 --remove constraint
			thisNode.transform.controller = prs () --replace Link_Constraint with Position_Rotation_Scale
			parent_node = undefined
		)	
		
		fn deleteParent = (
			
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
	
		fn onSelfDeleted = (
			
				format "roGen_Joint_CA > register callback onSelfDeleted\n"
				handler = when thisNode deleted obj do (
					
				deleteChangeHandler handler
				handler = undefined
				deleteParent()
			)	
		)
		
		fn registerCallbacks = (
			
			if handler != undefined or  thisNode == undefined do return false
			onSelfDeleted()	
		)	
		
		fn init parent_obj:undefined = (
			
			thisNode = getNode()
			thisNode.wirecolor = green
			thisNode.radius = 10
			thisNode.segs = 4
			thisNode.smooth = false
			thisNode.hemisphere = 0
			thisNode.renderable = false
			thisNode.chop = 1
			thisNode.slice = false
			thisNode.recenter = false
			node_name = thisNode.name
			registerCallbacks()
		)
		on load do (
			
			format "roGen_Joint > load\n"
			registerCallbacks()
		)
		on create do (

			format "roGen_Joint > created this:%\n"  this
		)
		on update do (
			
-- 			format "roGen_Joint > update this:%\n"  this	
		)
		on deleted do (
			
			format "roGen_Joint > deleted node:%\n"  node_name
		)
	)

--****************************************************************************************************--
--Road Joint 
/*
jo = Sphere pos:[0,0,0] name:(uniqueName "Road_Joint_Start_")
custAttributes.add jo roGen_Joint_CA baseObject:true #unique
jo.init()
jo.attachParent $Sphere001	
*/
--****************************************************************************************************--
