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
	fn getObjectsBB obj_arr = (
		
		local mi = obj_arr[1].min
		local ma = obj_arr[1].max
		for o in obj_arr do (

			--get min
			 mi.x = amin mi.x o.min.x
			 mi.y = amin mi.y o.min.y
			 mi.z = amin mi.z o.min.z
			--get max
			 ma.x = amax ma.x o.max.x
			 ma.y = amax ma.y o.max.y
			 ma.z = amax ma.z o.max.z
			
		)
		#(mi, ma)
	)
	fn getPivotOffset obj = (

		local center = (obj.min + obj.max) / 2
		center - obj.pos
	)
	fn getObjectsCenter obj_arr = (
		
		local bb = getObjectsBB obj_arr
		(bb[1] + bb[2]) / 2
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
		for o in obj_arr where o.max.z > max_z do max_z = o.max.z
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
	fn offsetObjects way = (
		--get current selected objects
		local sel = selection as Array
		if sel.count < 2 do return false
		--get (min or max) (x or y or z) of objects bounding box	
		local border_pos = case rdo_axis.state of (
			
			1: if way == #min then getMinX sel else  getMaxX sel
			2: if way == #min then getMinY sel else  getMaxY sel
			3: if way == #min then getMinZ sel else  getMaxZ sel
		)
		
		--> debug only
		local border = (selection.min + selection.max) / 2
		case rdo_axis.state of (
		
			1: border.x = border_pos
			2: border.y = border_pos
			3: border.z = border_pos
		)
		point pos:border wirecolor:yellow
		--< debug only
		
		with redraw off for o in sel do (
		
			local bm = mcBoxMatrix o
			case rdo_axis.state of ( 
			
				1:(
					if bm.right < border_pos then (

						o.pos.x = border_pos - bm.of_right 

					) else if bm.left > border_pos do (
					
						o.pos.x = border_pos + bm.of_left 
					)
				)
				2:(
					if bm.back < border_pos then (

						o.pos.y = border_pos - bm.of_back 

					) else if bm.front > border_pos do (
					
						o.pos.y = border_pos + bm.of_front
					)
				)
				3:(
					if bm.top < border_pos then (

						o.pos.z = border_pos - bm.of_top

					) else if bm.bottom > border_pos do (
					
						o.pos.z = border_pos + bm.of_bottom 
					)
				)
			)
		)
		completeRedraw()
	)
	fn centerObjects = (
		
		local sel = selection as Array
		if sel.count < 2 do return false
		local center = getObjectsCenter sel
		
		with redraw off for o in sel do (
			
			local offset = getPivotOffset o
			case rdo_axis.state of (
				
				1: o.pos.x =  center.x - offset.x
				2: o.pos.y =  center.y - offset.y
				3: o.pos.z =  center.z - offset.z
			)
		)
		completeRedraw()
	)
	
	on btn_min		pressed	do	undo "Align Objects Min" on offsetObjects #min
	on btn_max	pressed	do	undo "Align Objects Max" on offsetObjects #max	
	on btn_center	pressed	do	undo "Align Objects Center" on centerObjects()
)
CreateDialog mcAlignObjectsDialog

-- for the help thanks to Petr Capek
-- local max_x = getMaxX sel
-- local oPivTo_obbmaxX = 0
-- local obbmaxXTo_MaxX = 0
-- local oPivotTo_MaxX = 0
-- for o in sel do (

-- 	oPivTo_obbmaxX     = o.max.x - o.pivot.x
-- 	obbmaxXTo_MaxX   = max_x - o.max.x
-- 	oPivotTo_MaxX        = max_x - o.pivot.x

-- 	if obbmaxXTo_MaxX != 0 and offset_style == "border" then(
-- 		o.pos.x += oPivotTo_MaxX - oPivTo_obbmaxX
-- 	)
-- )
