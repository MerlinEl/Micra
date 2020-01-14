rollout Conformm "Conform" width:121 height:125
(
	pickButton btn_obj "Object" pos:[22,22] width:80 height:25
	pickButton btn_target "Target" pos:[22,50] width:80 height:25
	groupBox grp1 "Pick from scene" pos:[6,4] width:107 height:84
	button btn_run "Run" pos:[37,96] width:51 height:23

on btn_obj picked arg do
(
	global Vobject = arg
	btn_obj.text = arg.name
)

on btn_target picked arg do
(
	global Vtarget = arg
	btn_target.text = arg.name
)

on btn_run pressed do
(
	n = polyOp.getNumVerts Vobject 
	for pt=1 to n do
	(
		 
		TheRay = Ray (polyOp.getVert Vobject pt) [0,0,-1]
		TheInt = (IntersectRay Vtarget TheRay)
		if TheInt != undefined then
		(
			polyOp.setVert Vobject pt TheInt.pos 
		)
	)
)

)createdialog Conformm 