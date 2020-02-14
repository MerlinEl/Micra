Global arcPointsTestDialog
if arcPointsTestDialog != undefined do DestroyDialog arcPointsTestDialog
rollout arcPointsTestDialog "Points To Arc:" width:232 height:120
(
	groupBox grp1 "Params" pos:[4,4] width:224 height:112
	groupBox grp5 "angle step:" pos:[140,68] width:84 height:44
	label lbl_step "..." pos:[148,92] width:72 height:16
	label lbl1 "center x:" pos:[12,20] width:48 height:16
	label lbl3 "y:" pos:[148,20] width:12 height:16
	label lbl4 "angle from:" pos:[12,44] width:60 height:16
	label lbl5 "to:" pos:[148,44] width:12 height:16
	label lbl6 "radius:" pos:[12,68] width:60 height:16
	label lbl7 "count:" pos:[12,92] width:60 height:16
		
	spinner spn_center_x "" pos:[76,20] width:56 height:16 range:[0, 1000000, 0] type:#float scale:0.01
	spinner spn_center_y "" pos:[164,20] width:56 height:16 range:[0, 1000000, 0] type:#float scale:0.01
	spinner spn_angle_from "" pos:[76,44] width:56 height:16 range:[0, 359, 0] type:#integer 
	spinner spn_angle_to "" pos:[164,44] width:56 height:16 range:[1, 360, 90] type:#integer 
	spinner spn_radius "" pos:[76,68] width:56 height:16 range:[2, 1000000, 100] type:#integer
	spinner spn_count "" pos:[76,92] width:56 height:16 range:[2, 1000, 5] type:#integer
	
-- 	timer clock "Timer" pos:[172,75] width:24 height:24
	
	local points = #()
-- 	local ready_to_draw = false
	
	fn getArcPoints center radius angle_from angle_to cnt = (

		local arc_angle = angle_to - angle_from
		local step = arc_angle / cnt --(cnt - 1)
		lbl_step.text = step as string + " ?"
		local step_angle = angle_from
		--collect points in arc trajectory
		for i = 1 to cnt collect (
		
			local px = (cos step_angle) * radius
			local py = (sin step_angle) * radius
			step_angle += step
			center + [px, py]
		)
	)
	fn drawArcPoints = (

-- 		if not ready_to_draw do return false
		delete points
		local center = [spn_center_x.value, spn_center_y.value]
		local radius = spn_radius.value
		local angle_from = spn_angle_from.value
		local angle_to = spn_angle_to.value
		local cnt = spn_count.value
		local arc_points = getArcPoints center radius angle_from angle_to cnt
		local clr = red
		points = for p in arc_points collect (
		
			clr.h -= 10
			po = point pos:[p.x, p.y, 0] wirecolor:clr
		)
-- 		ready_to_draw = false
	)
-- 	on clock tick do  (
-- 		 
-- 		--format "tick:%\n" tick
-- 		ready_to_draw = true
-- 	)
	on arcPointsTestDialog open do drawArcPoints()
	on arcPointsTestDialog close do delete points
	on spn_center_x changed val do drawArcPoints()
	on spn_center_y changed val do drawArcPoints()
	on spn_angle_from changed val do drawArcPoints()
	on spn_angle_to changed val do drawArcPoints()
	on spn_radius changed val do drawArcPoints()
	on spn_count changed val do drawArcPoints()
)
CreateDialog arcPointsTestDialog 
