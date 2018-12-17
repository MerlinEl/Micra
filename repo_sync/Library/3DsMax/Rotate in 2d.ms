fn strightenShell obj debug:false =
(
	local sel_center = (obj.min+obj.max)/2
	local verts = polyOp.getVertSelection obj
	local p1, p2
	--get two verts in selection bounds to define a line
	for v in verts do 
	(
		local vp = polyOp.getVert obj v
		if p1 == undefined
		then 
		(
			p1 = copy (p2 = vp)
		)
		else
		(
			if vp.x < p1.x do p1 = vp
			if vp.y > p2.y do p2 = vp
		)
	)
	--get middle point in line
	local mid = (p1+p2)/2
	local v0 = [0,1,0] -- Y
	local v1 = normalize (mid - sel_center)
	--get angle betwen two vectors
	local a  = acos(dot v0 v1)
	--rotate selection CW or CCW
	if a == 90 or a == 180
	then
	(
		format "The object:% is already aligned to Y at angle:%\n" obj.name a
	)
	else if a <= 45.0
	then --rotate CW (to axis Y)
	(
		format "object1:% , angle to Y is :%\n" obj.name a
		obj.rotation.z_rotation -= a
	)
	else --rotate CCW (to axis X)
	(
		format "object2:% , angle to Y is :%\n" obj.name a
		obj.rotation.z_rotation += (90 - a)
	)
	if debug do 
	(
		point pos:p1 name:"point_rect_ld" wirecolor:red
		point pos:p2 name:"point_rect_rd" wirecolor:green
		point pos:((p1+p2)/2) name:"point_rect_rd" wirecolor:white
	)
)

/*
delete $point_rect_*
for i in geometry do strightenShell i debug:true	
strightenShell $ debug:true	

<void>rotateSelectedCenter <float>angle
<point3>getPivotOffset()
<point3>getSelCenter()

bo.w()
bo.h()
bo.center()
bo.size()
uv1.rotateSelectedVerticesCenter (sweepAngle* PI/180)
*/