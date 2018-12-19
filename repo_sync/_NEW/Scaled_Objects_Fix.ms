scaled_objects = for o in $ where o.scale != [1,1,1] collect o
select scaled_objects
for o in scaled_objects do print o.name
for o in $.children do print ([o.scale.x as float, o.scale.y as float, o.scale.z as float])
for o in $ do print (o.scale == [1,1,1])

--fix object which have scale 0.000000001 scale
for o in scaled_objects do (

	format "obj:%" o.name
	/*if o.scale.x == 1 then print ("x ok") else print ("x" + o.scale.x as String)
	if o.scale.y == 1 then print ("y ok") else print ("y" + o.scale.y as String)
	if o.scale.z == 1 then print ("z ok") else print ("z" + o.scale.z as String)*/
	local is_not_scaled = isNotScaled o
	format " is_not_scaled:%\n"  is_not_scaled
	if is_not_scaled do o.scale = [1,1,1]
)

fn isNotScaled obj = (

	local scale_x = mcMath.roundToDecimals obj.scale.x 3
	local scale_y = mcMath.roundToDecimals obj.scale.y 3
	local scale_z = mcMath.roundToDecimals obj.scale.z 3
	format " scale x:% y:% z:%" scale_x scale_y scale_z
	return scale_x == scale_y == scale_z == 1 
)


obj:Box384 scale x:0.666667 y:0.666667 z:1.0 is_not_scaled:false
obj:Box385 scale x:0.666667 y:0.666667 z:1.0 is_not_scaled:false
obj:Box386 scale x:0.666667 y:0.666667 z:1.0 is_not_scaled:false
obj:Object007 scale x:0.0 y:1.33333 z:1.0 is_not_scaled:false
obj:Box387 scale x:0.666667 y:0.666667 z:1.0 is_not_scaled:false
obj:Box388 scale x:0.666667 y:0.666667 z:1.0 is_not_scaled:false
obj:Box389 scale x:0.666667 y:0.666667 z:1.0 is_not_scaled:false
obj:Object006 scale x:0.0 y:1.33333 z:1.0 is_not_scaled:false




--clean up scale transformation data
ResetScale $  --OK
ResetTransform $ --ls3d exporter have problem with instanced objects with different transform


--link to node
unlinked_objects = for o in selection where o.parent == undefined do o.parent = $lh_loc_farm_geometry
resettransform $
for o in selection where o.scale != [1,1,1] do ResetScale o
	

