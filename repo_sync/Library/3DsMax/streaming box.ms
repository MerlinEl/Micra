--Get Box ... musi byt box
--Get Objects ... musi byt editable poly objekty


Global hideGeomOutsideBoxDialog
if hideGeomOutsideBoxDialog != undefined do destroyDialog hideGeomOutsideBoxDialog
rollout hideGeomOutsideBoxDialog "Hide Geom Outside Box" width:164 height:312
(
	local cube, models = #()
	GroupBox grp1 "Box Intersection:" pos:[4,4] width:156 height:304
	button btn_box "Get Box" pos:[24,28] width:112 height:24
	button btn_objs "Get Objects" pos:[24,52] width:112 height:24
	listbox lbx_polys "Objects:" pos:[24,80] width:112 height:11
	button btn_hide "Hide Outside" pos:[24,252] width:112 height:24
	button btn_unhide "Unhide All" pos:[24,276] width:112 height:24
	progressBar pbar_faces "ProgressBar" pos:[8,28] width:12 height:272 color:red orient:#vertical
	progressBar pbar_objs "ProgressBar" pos:[140,28] width:12 height:272 color:green orient:#vertical
	fn resetBars =
	(
		pbar_faces.value = 0
		pbar_objs.value = 0
	)
	fn getCube =
	(
		local obj = selection[1]
		if obj == undefined do return false
		btn_box.text = obj.name
		obj
	)
	fn getModels =
	(
		local poly_objs = for i in selection where classOf i == Editable_Poly collect i
		lbx_polys.items = for i in poly_objs collect i.name	
		return poly_objs
	)
	fn isPointInBox p b =
	(
		--translate point to rotated box
		--p = p * (inverse b.transform)
		--get intersection
		b.min.x <= p.x and p.x <= b.max.x and
		b.min.y <= p.y and p.y <= b.max.y and
		b.min.z <= p.z and p.z <= b.max.z
	)
	fn isFaceInBox2 obj face cube =
	(
		local face_verts = polyOP.getVertsUsingFace obj face
		--check if one of verts is inside of cube
		for v in face_verts where (isPointInBox (polyOp.getVert obj v) cube) do return true
		return false
	)
	fn isFaceInBox obj face cube =
	(
		local face_center = polyOP.getFaceCenter obj face
		isPointInBox face_center cube
	)
	fn hideOutsideBox =
	(
		if cube == undefined or models.count == 0 do return false
		pbar_objs.value = 0
		local cnt = 1
		for o in models do
		(
			cnt +=1
			pbar_faces.value = 0
			local faces_for_hide = #{}
			for f=1 to o.numfaces do 
			(
				if not isFaceInBox o f cube do append faces_for_hide f
				pbar_faces.value = 100/o.numfaces * f
			)  
			polyop.setHiddenFaces o faces_for_hide
			pbar_objs.value = 100/models.count * cnt
		)
		completeRedraw()
	)
	on btn_box    pressed do (cube = getCube())
	on btn_objs   pressed do (models = getModels())
	on btn_hide   pressed do (undo "Hide Outside" on hideOutsideBox())
	on btn_unhide pressed do (resetBars(); undo "Unhide All" on (for o in models do o.unhideAll #Face) )

)
createDialog hideGeomOutsideBoxDialog