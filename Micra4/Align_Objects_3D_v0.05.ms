Global mcAlignObjectsDialog
if mcAlignObjectsDialog != undefined do DestroyDialog mcAlignObjectsDialog
rollout mcAlignObjectsDialog "Align Objects:" width:156 height:296
(
	local axis_labels = #("X", "Y", "Z")
	GroupBox grp9 "Axis:" pos:[4,4] width:148 height:46
	radiobuttons rdo_axis "" pos:[28,22] width:97 height:16 labels:#("X", "Y", "Z") columns:3
	
	GroupBox grp1 "Align:" pos:[4,84] width:148 height:52
	button btn_min "MIN" pos:[8,104] width:40 height:24
	button btn_max "MAX" pos:[104,104] width:40 height:24
	button btn_center "CENTER" pos:[48,104] width:52 height:24
	
	GroupBox grp2 "Copy - Paste:" pos:[4,140] width:148 height:76
	button btn_Copy "COPY" pos:[8,184] width:66 height:24
	button btn_paste "PASTE" pos:[80,184] width:66 height:24
	dropdownList ddl_way "" pos:[8,160] width:136 height:21 items:#("X", "Y", "Z", "MIN", "MAX", "CENTER")
	GroupBox grp4 "Snap:" pos:[4,220] width:148 height:72
	pickbutton btn_pick_obj "pick..." pos:[8,236] width:36 height:24
	label lbl_obj_name "..." pos:[48,240] width:96 height:20
	button btn_snap_obj "SNAP" pos:[8,264] width:136 height:24
	button btn_distribute_obj "DISTRIBUTE" pos:[4,56] width:148 height:24
	struct NODE_TM (pos, mi, ma)
	local saved_tm = NODE_TM [0, 0, 0]  [0, 0, 0]  [0, 0, 0]
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
	
	fn centerObjects sel = (
		
		if sel.count < 2 do return false
		local center = getObjectsCenter sel
		with redraw off for o in sel do (
			
			local offset = getPivotOffset o
			local axis = axis_labels[rdo_axis.state]
			case axis of (
				
				"X": o.pos.x =  center.x - offset.x
				"Y": o.pos.y =  center.y - offset.y
				"Z": o.pos.z =  center.z - offset.z
			)
		)
		completeRedraw()
	)
	fn getObjectsBorder sel way = ( --get (min or max) (x or y or z) of objects bounding box
		
		local axis = axis_labels[rdo_axis.state]
		local border_pos = case axis of (
			
			"X": if way == #min then getMinX sel else  getMaxX sel
			"Y": if way == #min then getMinY sel else  getMaxY sel
			"Z": if way == #min then getMinZ sel else  getMaxZ sel
		)
		border_pos
	)
	
	fn offsetObjects way border_pos:undefined= (
		--get current selected objects
		local sel = selection as Array
		if sel.count < 2 do return false
		if way == #center do (
				
			centerObjects sel
			return OK
		)
		if border_pos == undefined do border_pos = getObjectsBorder sel way
			
		--> debug only
		/*local border = (selection.min + selection.max) / 2
		case rdo_axis.state of (
		
			1: border.x = border_pos
			2: border.y = border_pos
			3: border.z = border_pos
		)
		point pos:border wirecolor:yellow*/
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

	fn copyPosition = (
		
		local obj = selection[1]
		if obj == undefined do return false
		saved_tm = NODE_TM obj.pos obj.min obj.max
	)
	fn pastePosition = (
		
		if saved_tm == undefined do return false
		with redraw off for o in selection do (
				
			case ddl_way.selected of (
				
				"X": o.pos.x = saved_tm.pos.x	
				"Y": o.pos.y = saved_tm.pos.y	
				"Z": o.pos.z = saved_tm.pos.z	
				"CENTER": (
						
					local center = (saved_tm.mi + saved_tm.ma) / 2
					offsetObjects #center border_pos:center
					/*local offset = getPivotOffset o
					case axis of (
						
						"X": o.pos.x =  center.x - offset.x
						"Y": o.pos.y =  center.y - offset.y
						"Z": o.pos.z =  center.z - offset.z
					)*/
				)
				"MIN": (
					
					local mi = getObjectsBorder #(o) #min --depends on selected axis 
					offsetObjects #min	border_pos:mi
				)
				"MAX": (
					
					local ma = getObjectsBorder #(o) #max --depends on selected axis 
					offsetObjects #min	border_pos:ma
				)
			)
		)
		completeRedraw()
	)

	fn getPosAt obj axis = (
		
		case axis of (
			
			"X":obj.pos.x
			"Y":obj.pos.y
			"Z":obj.pos.z
		)
	)
	
	fn setPosAt obj axis val = (
		
		case axis of (
			
			"X":obj.pos.x = val
			"Y":obj.pos.y = val
			"Z":obj.pos.z = val
		)
	)
	
	--For now DISTANCES are based on PIVOT not on SIZE
	fn distributeObjectsAlongAxis sel axis = (
	
		if sel.count < 3 do return false
		local first_obj = sel[1]
		local last_obj = sel[1]
		local first_val = getPosAt first_obj axis
		local last_val = getPosAt last_obj axis
		--Find FIRST
		for o in sel where getPosAt o axis < first_val do (
		
			first_obj = o
			first_val = getPosAt o axis
		)
		--Find LAST
		for o in sel where getPosAt o axis > last_val do (
		
			last_obj = o
			last_val = getPosAt o axis
		)	
		format "axis:% fo:% lo:%\n" axis first_obj.name last_obj.name
		--calculate distances
		local len = distance first_obj last_obj
		local dist = len / (sel.count - 1)
		local next_val = first_val
		-- Distribute objects between FISRT and LAST point
		for o in sel do (
		
			setPosAt o axis next_val
			next_val += dist
		)
	)
	
	fn distributeObjects = (
		
		local sel = selection as array
		local axis = axis_labels[rdo_axis.state]
		distributeObjectsAlongAxis sel axis
	)
	
	on btn_min				pressed	do	( undo "Align Objects Min" on offsetObjects #min				)
	on btn_max			pressed	do	( undo "Align Objects Max" on offsetObjects #max				)
	on btn_center			pressed	do	( undo "Align Objects Center" on offsetObjects #center		)
	on btn_copy			pressed 	do	( copyPosition()																		)
	on btn_paste			pressed 	do	( undo "Align Objects" on pastePosition()							)
	on btn_pick_obj picked obj 	do 	(lbl_obj_name.text = obj.name												)
	on btn_snap_obj		pressed 	do	( 
		
		local obj = getNodeByName lbl_obj_name.text
		if isValidnode obj do mcPoly.alignObjectToSelection obj
	)
	on btn_distribute_obj pressed do ( undo "Distribute Object's" on distributeObjects() )
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
