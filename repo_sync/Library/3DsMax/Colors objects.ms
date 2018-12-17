
fn cloneObjectUp obj =
(
	if obj == undefined do return false
	local obj_pos = obj.pos
	local obj_min = [0, 0, (obj.max.z - obj.min.z)] + obj.pos
	local new_obj = instance obj
	new_obj.pos = obj_min
	return new_obj
)
----------------------
fn cloneObjectsUp obj cnt =
(
	if obj == undefined do return false
	local obj_pos = obj.pos
	local obj_min = [0, 0, (obj.max.z - obj.min.z)] + obj.pos
	local all_objects = #(obj)
	for i=1 to cnt do
	(
		local new_obj = instance obj
		all_objects += #(new_obj)
		new_obj.pos = obj_min
		obj_min = [0, 0, (new_obj.max.z - new_obj.min.z)] + new_obj.pos
	)
	return all_objects
)
fn cloneObjectGradient c1 c2 cnt = -- 
(
	local obj = selection[1]
	if obj == undefined do return false
	select (cloneObjectsUp obj cnt)
	
	local sel = selection as array
	if sel.count < 2 do return false
	
	stepsize_r = (c2.r - c1.r)/$.count
	stepsize_g = (c2.g - c1.g)/$.count
	stepsize_b = (c2.b - c1.b)/$.count
	
	for i=1 to sel.count do
	(
		local newColor = (color \
		((i*stepsize_r)+c1.r-stepsize_r) \
		((i*stepsize_g)+c1.g-stepsize_g) \
		((i*stepsize_b)+c1.b-stepsize_b))
		$[i].wirecolor = newColor
	)
	max select none
	completeRedraw()
)

----------------------------
	
/*
cloneObject $ 5
cloneObjectGradient red blue 20
cloneObjectGradient red yellow 20
cloneObjectGradient red white 20
cloneObjectGradient red black 20
cloneObjectGradient blue green 20
cloneObjectGradient blue yellow 20
*/