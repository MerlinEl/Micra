try (destroyDialog ZRotationTestDialog) catch ()
rollout ZRotationTestDialog "Untitled" width:436 height:148
(
	local last_val = 0
	groupBox grp1 "Z Rotation Test:" pos:[8,4] width:424 height:140
	slider sld1 "Slider 0 - 360" pos:[68,56] width:284 height:44 range:[0,360,0] type:#integer orient:#horizontal ticks:32
	fn rotateObject val =
	(
		print val
		local obj = selection[1] 
		if obj == undefined do return false
		in coordsys local obj.rotation.z_rotation = val - last_val
		last_val = val
	)
	on sld1 changed val do (rotateObject val)
	on sld1 buttondown  do ()

	on sld1 buttonup  do
	(
	
	)
)
createDialog ZRotationTestDialog