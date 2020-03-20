fn resetBoundingBoxToSelection rotation_angle = (
	struct OBJ_DATA (oname, otm)
	for obj in selection do (

		local object_instances = #()
		InstanceMgr.GetInstances obj &object_instances
		local old_pos = obj.pos 
		local olr_rot_z = obj.rotation.z_rotation
		obj.pivot = (obj.min + obj.max)/2
		obj.rotation.z_rotation -= rotation_angle
		resetXform obj
		convertToPoly obj
		obj.rotation.z_rotation += rotation_angle
		obj.pivot = old_pos
		if object_instances.count > 1 do (
			
			for o in object_instances where o.handle != obj.handle do (
				
				local p = o.pos		
				o.pivot = (o.min + o.max)/2
				local r = o.rotation.z_rotation
				o.rotation.z_rotation = 0
				o.baseobject = obj.baseobject
				o.rotation.z_rotation = r + rotation_angle
				o.pivot = p
			)
		)
	)
)
undo "Reset BB" on resetBoundingBoxToSelection 20
	


/*
fn resetBB obj rotation_angle = (
	
	local old_pos = obj.pos 
	local olr_rot_z = obj.rotation.z_rotation
	obj.pivot = (obj.min + obj.max)/2
	obj.rotation.z_rotation -= rotation_angle
	resetXform obj
	convertToPoly obj
	obj.rotation.z_rotation += rotation_angle
	obj.pivot = old_pos
)
fn resetBoundingBoxToSelection rotation_angle = (
	
	struct OBJ_DATA (oname, otm)
	for obj in selection do (

		local object_instances = #()
		InstanceMgr.GetInstances obj &object_instances
		resetBB obj rotation_angle
		if object_instances.count > 1 do (
			
			for o in object_instances where o.handle != obj.handle do (
				
				resetBB o rotation_angle
				o.baseobject = obj.baseobject
			)
		)
	)
)
undo "Reset BB" on resetBoundingBoxToSelection 20
*/