 Global RtCMS
 Global roGen_Road_CA
 Global roGen_Joint_CA
 
 struct Road_Tool_Component_Manager_Struct (
	 
	DELETED_CALLBACKS_ENABLED = true,
	rest_objects_for_delete = #(),
	fn hasCustomAttribute obj attr = (

		if not (isValidNode obj) do return false 
		local defs = custAttributes.getDefs obj
		if defs == undefined do return false
		for a in defs where a.name == attr do return true
		false
	),
	fn isRoad obj = (hasCustomAttribute obj #roGen_Road_CA),
	fn isJoint obj = (hasCustomAttribute obj #roGen_Joint_CA),
	fn isValidComponent obj = (
		
		isRoad obj or isJoint obj --or isPath <--- TODO
	),
	fn findItemByName arr obj_name = (
		
		for i=1 to arr.count where arr[i].name == obj_name do exit with i
		0
	),
	fn addObjectsInCollection arr = (
		
		for o in arr where (findItemByName arr o.name) == 0 do append rest_objects_for_delete o
	),
	fn getRoadChildren obj = (
		
		for o in obj.components_tab where isValidNode o.node and not (isDeleted o.node) and not (o.node.is_deleted) collect o.node	
	),
	fn onPreDeleteObject = (
		
		if not DELETED_CALLBACKS_ENABLED do return false --depency loop break
		local deleted_objects = callbacks.notificationParam()
		format "onPreDeleteObject > deleted_objects:%\n" deleted_objects
		for o in deleted_objects do ( --for each deleted object collect rest componens
		
			if ( isRoad o ) then (
				
				format "onPreDeleteObject > isRoad get children...\n"
				addObjectsInCollection ( getRoadChildren o )
				
			) else if ( isJoint o ) then (
				
				format "onPreDeleteObject > isJoint get parent...\n"
				local parent_node = o.getParentNode()
				addObjectsInCollection #( parent_node )
				addObjectsInCollection ( getRoadChildren parent_node)
			)
		)
	),
	fn onPostDeleteObject = (
	
		if not DELETED_CALLBACKS_ENABLED do return false --depency loop break
		format "onPostDeleteObject > deleted_objects:%\n" rest_objects_for_delete
		DELETED_CALLBACKS_ENABLED = FALSE 
		local objs = for o in rest_objects_for_delete where isValidNode o and not (isDeleted o) collect o --filter only not deleted objects
		delete objs
		DELETED_CALLBACKS_ENABLED = TRUE
	),
	fn onCloneObject = (
		
		local params = callbacks.notificationParam()
		local src_arr = params[1]
		local trgt_arr = params[2]
		format "onCloneObject > src_arr:%\n" src_arr
		format "onCloneObject > trgt_arr:%\n" trgt_arr
		return false
		for i=1 to src_arr.count do (
		
			local obj_src = src_arr[i]
			local obj_trgt = trgt_arr[i]
			if not (isValidComponent obj_src) do continue  --filter only objects which belongs to Road_Tool 
			 --recreate  attribute
			custattributes.delete obj_trgt (custattributes.getdefs obj_trgt baseobject:on)[1]
			custAttributes.add obj_trgt ::roGen_Road_CA baseObject:true #unique
			--redefine params and register events
			obj_trgt.init() 
			--clone all components
			format "onCloneObject > src:% trgt:%\n" obj_src.name obj_trgt.name
			local components_clones = for obj in obj_src.components_tab collect (copy obj.node)
			if components_clones.count == 0 do continue
			--redefine components
			for obj in components_clones do (
		
-- 				obj_src.addComponent o
-- 				o.init()
				 --recreate  attribute
				custattributes.delete obj (custattributes.getdefs obj baseobject:on)[1]
				custAttributes.add obj ::roGen_Joint_CA baseObject:true #unique
				obj.init()
				--link contraint and register callbacks
				obj.controller.addTarget obj_trgt 1 --relink to new node (for reposition only)
				obj.attachParent obj_trgt
				--append in to parent tab
				append obj_trgt.components_tab (nodeTransformMonitor node:obj forwardTransformChangeMsgs:false)		
			)	
			obj_trgt.updateList()
		)
	),
	fn init = (
		
		callbacks.RemoveScripts #postNodesCloned id:#roGen_Road_onClone_Callbacks	
		callbacks.RemoveScripts #selectedNodesPreDelete id:#roGen_Road_onPreDelete_Callbacks
		callbacks.RemoveScripts #selectedNodesPostDelete  id:#roGen_Road_onPostDelete_Callbacks
		gc()
		callbacks.addScript #postNodesCloned "RtCMS.onCloneObject()" id:#roGen_Road_onClone_Callbacks
		callbacks.addScript #selectedNodesPreDelete "RtCMS.onPreDeleteObject()" id:#roGen_Road_onPreDelete_Callbacks
		callbacks.addScript #selectedNodesPostDelete "RtCMS.onPostDeleteObject()" id:#roGen_Road_onPostDelete_Callbacks
		--#nodePreDelete: Node 
		--#nodePostDelete: undefined 
	),
	register = init()
 )
RtCMS = Road_Tool_Component_Manager_Struct()