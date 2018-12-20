fn CollapseGeometry obj_arr = (
	with undo off with redraw off (

		local geom_arr = for o in obj_arr where superClassOf o == GeometryClass collect o
		if geom_arr.count < 2 do return undefined
		local sel_count = geom_arr.count
		local single_model = Editable_Mesh()
		local iterationStart=timestamp()
		local cnt = 1
		while cnt <= geom_arr.count do (
			
			local o = geom_arr[cnt]
			convertToMesh o --collapse stack and break instance link
			meshop.attach single_model o
			format "progress:[% / %] TotalTime:[%s] IterationTime:[%s] \n" cnt sel_count (timestamp()*.001) ((timestamp()-iterationStart)*.001)
			cnt += 1
		)
		CenterPivot  single_model
		return single_model
	)
)
CollapseGeometry (selection as Array)