rollout cutToolDialog "cutTool" width:120 height:120
(
	checkbox chk1 "Cut on X axis" pos:[17,8] width:100 height:19
	checkbox chk2 "Cut on Y axis" pos:[17,27] width:100 height:19
	spinner spn1 "Threshold" pos:[21,51] width:83 height:16 type:#float range:[0,100,0.01] 
	button btn1 "Cut" pos:[15,77] width:90 height:33
	
	fn cutTool =
	(
	obj = $
	threshold = spn1.value --choose the needed threshold : higher value creates more connections
	numverts = polyOp.getNumVerts obj
	getverts = polyOp.getvert
	cutverts = polyop.cutvert
	local a, b
	
	on_X = chk1.checked --Cut on X Axis
	on_Y = chk2.checked --Cut on Y Axis
		
	for i = 1 to numverts do 
	(
		for j = 1 to numverts do
		(
			a = getverts obj i
			b = getverts obj j
			if a != b do
			(
				if on_X == true do if (b.x-threshold) <= a.x and a.x <= (b.x+threshold) then cutverts $ i b [0,0,1]
				if on_Y == true do if (b.y-threshold) <= a.y and a.y <= (b.y+threshold) then cutverts $ i b [0,0,1]
			)
		)
	)
	update obj
	)

	on btn1 pressed do cutTool()
)
createdialog cutToolDialog