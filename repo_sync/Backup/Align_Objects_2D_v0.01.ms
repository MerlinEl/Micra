Global mcAlignObjectsDialog
if mcAlignObjectsDialog != undefined do DestroyDialog mcAlignObjectsDialog
rollout mcAlignObjectsDialog "Align Objects" width:280 height:152
(
	button 'btn_up' "T" pos:[120,24] width:40 height:36 align:#left
	button 'btn_left' "L" pos:[76,64] width:40 height:36 align:#left
	button 'btn_right' "R" pos:[164,64] width:40 height:36 align:#left
	button 'btn_down' "B" pos:[120,104] width:40 height:36 align:#left
	GroupBox 'grp1' "Settings:" pos:[4,4] width:272 height:144 align:#left
	radiobuttons 'rdo_axis' "View:" pos:[12,24] width:56 height:110 labels:#("Top", "Bottom", "Left", "Right", "Front", "Back") align:#left
	radiobuttons 'rdo_offset' "Align by:" pos:[212,24] width:54 height:46 labels:#("Border", "Center") default:1 columns:1 align:#left
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
	fn offsetObjects obj_arr val axis way = (
		
		for o in obj_arr do (
		
			case axis of (
				
				#x: o.pos.x =  if way == #max then val - o.width/2 else val + o.width/2
				#y: o.pos.y =  if way == #max then val - o.height/2 else val + o.height/2
			)
		)
	)
	fn centerObjects obj_arr val axis = (
		
		for o in obj_arr do (
			case axis of (
				
				#x: o.pos.x =  val
				#y: o.pos.y =  val
			)
		)
	)
	fn alignObjectsTo way = (
		
		local sel = selection as Array
		if sel.count < 2 do return false
		local center = getCenter sel
		local offset_style = if rdo_offset.state == 1 then "border" else "center"

		undo "Align Objects" on case way of (
			
			#up:(
				
				local max_y = getMaxY sel
				case offset_style of   (
					
					"border": offsetObjects sel max_y #y #min
					"center": centerObjects sel max_y #y
				)
			)
			#down:(
			
				local min_y = getMinY sel
				case offset_style of   (
					
					"border": offsetObjects sel min_y #y #max
					"center": centerObjects sel min_y #y
				)
			)
			#left:(
			
				local min_x = getMinX sel
				point pos:[min_x,0,0]
				case offset_style of   (
					
					"border": offsetObjects sel min_x #x #min
					"center": centerObjects sel center.x #x
				)
			)
			#right:(
		
				local max_x =  getMaxX sel 
				point pos:[max_x,0,0]
				case offset_style of   (
					
					"border": offsetObjects sel max_x #x #max
					"center": centerObjects sel center.x #x
				)
			)
		)		
	)
	on btn_up pressed  do alignObjectsTo #up
	on btn_down pressed  do alignObjectsTo #down	
	on btn_left pressed  do alignObjectsTo #left
	on btn_right pressed  do alignObjectsTo #right
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