Global mcAlignObjectsDialog
if mcAlignObjectsDialog != undefined do DestroyDialog mcAlignObjectsDialog
rollout mcAlignObjectsDialog "Align Objects:" width:156 height:108
(
	GroupBox grp1 "Settings:" pos:[4,4] width:148 height:56
	radiobuttons rdo_axis "" pos:[48,32] width:97 height:16 labels:#("X", "Y", "Z") columns:3
	button btn_min "MIN" pos:[8,64] width:40 height:40
	button btn_max "MAX" pos:[108,64] width:40 height:40
	button btn_center "CENTER" pos:[52,64] width:52 height:40
	label lbl1 "Axis:" pos:[12,32] width:32 height:16
	fn getCenter obj_arr = (
		
		local center = [0,0,0]
		for o in obj_arr do center += o.pos
		center	/ obj_arr.count
	)
	fn getMaxX obj_arr = (
		
		local max_x = obj_arr[1].max.x
		for o in obj_arr where o.max.x > max_x do max_x = o.max.x
		max_x
	)
	fn getMaxY obj_arr = (
		
		local max_y = obj_arr[1].max.y
		for o in obj_arr where o.max.y > max_y do max_y = o.max.y
		max_y
	)
	fn getMaxZ obj_arr = (
		
		local max_z = obj_arr[1].max.z
		for o in obj_arr where o.max.z > max_z do max_y = o.max.z
		max_z
	)
	fn getMinX obj_arr = (
		
		local min_x = obj_arr[1].min.x
		for o in obj_arr where o.min.x < min_x do min_x = o.min.x
		min_x
	)
	fn getMinY obj_arr = (
		
		local min_y = obj_arr[1].min.y
		for o in obj_arr where o.min.y < min_y do min_y = o.min.y
		min_y
	)	
	fn getMinZ obj_arr = (
		
		local min_z = obj_arr[1].min.z
		for o in obj_arr where o.min.z < min_z do min_z = o.min.z
		min_z
	)
	fn getWidth   obj =  abs (obj.min.x - obj.max.x)
	fn getLength obj =  abs (obj.min.y - obj.max.y)
	fn getHeight  obj =  abs (obj.min.z - obj.max.z)
	fn offsetObjects way = (
		
		local sel = selection as Array
		if sel.count < 2 do return false
			
		local val = case rdo_axis.state of (
			
			1: if way == #min then getMinX sel else  getMaxX sel
			2: if way == #min then getMinY sel else  getMaxY sel
			3: if way == #min then getMinZ sel else  getMaxZ sel
		)
		
		for o in sel do (
		
			case rdo_axis.state of (
				
				1: (
					local half_w = ( getWidth o ) / 2
					o.pos.x =  if way == #min then val + half_w else val - half_w
				)
				2: (
					local half_l = ( getLength o ) / 2
					o.pos.y =  if way == #min then val + half_l else val - half_l
					)
				3: (
					local half_h = ( getHeight o ) / 2
					o.pos.z =  if way == #min then val + half_h else val - half_h
				)
			)
		)
	)
	fn centerObjects = (
		
		local sel = selection as Array
		if sel.count < 2 do return false
			
		local center = getCenter sel
		for o in sel do (
			
			case rdo_axis.state of (
				
				1: o.pos.x =  center.x
				2: o.pos.y =  center.y
				3: o.pos.z =  center.z
			)
		)
	)
	
	on btn_min		pressed	do	undo "Align Objects Min" on offsetObjects #min
	on btn_max	pressed	do	undo "Align Objects Max" on offsetObjects #max	
	on btn_center	pressed	do	undo "Align Objects Center" on centerObjects()
)
CreateDialog mcAlignObjectsDialog

/* Petr Capek
local max_x = getMaxX sel
local oPivTo_obbmaxX = 0
local obbmaxXTo_MaxX = 0
local oPivotTo_MaxX = 0
for o in sel do (

	oPivTo_obbmaxX     = o.max.x - o.pivot.x
	obbmaxXTo_MaxX   = max_x - o.max.x
	oPivotTo_MaxX        = max_x - o.pivot.x

	if obbmaxXTo_MaxX != 0 and offset_style == "border" then(
		o.pos.x += oPivotTo_MaxX - oPivTo_obbmaxX
	)
)
*/