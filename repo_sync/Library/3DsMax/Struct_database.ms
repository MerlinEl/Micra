(
	fn collectModelData =
	(
		local build_start = timestamp()
		
		local obj = selection[1]
		if obj == undefined do return undefined 
		if classOf obj.baseObject != Editable_Poly do return undefined 
		--define structures
		struct MODEL_DATA (faces, edges, verts)
		struct FACE_DATA (E=#{}, V=#{})
		struct EDGE_DATA (F=#{}, V=#{})
		struct VERT_DATA (F=#{}, E=#{})
		--define element arrays
		local fd=#()
		local ed=#()
		local vd=#()
		--collect data
		progressStart " Collecting Object Data:"
		for f=1 to obj.faces.count do if not getProgressCancel() do
		(
			--collect face references
			local edges = polyop.getEdgesUsingFace obj f
			local verts = polyop.getVertsUsingFace obj f
			fd += #(FACE_DATA E:edges V:verts)
			--collect edge references
			for e in edges do
			(
				local verts = polyop.getVertsUsingEdge obj e
				if ed[e] != undefined -- append new elements to struct
				then
				(
					ed[e].f+=#{f}
					ed[e].v+=verts
				)
				else  
				( 
					ed[e] = EDGE_DATA F:#{f} V:verts 
				) 
				--collect vert references
				for v in verts do
				(
					if vd[v] != undefined -- append new elements to struct
					then
					(
						vd[v].f+=#{f}
						vd[v].e+=#{e}
					)
					else
					(
						vd[v] = (VERT_DATA F:#{f} e:#{e})
					)
				)
			)
			progressUpdate (100.*f/obj.faces.count)
		)
		progressEnd()
		--format "fd:%\n" fd
		--format "ed:%\n" ed
		--format "vd:%\n" vd
		local build_end = timestamp()
		format "Faces Count:%\tBuild Time:%sec\n" obj.faces.count ( (build_end - build_start) / 1000.0 )
		return (MODEL_DATA fd ed vd)
	)
	
	with redraw off
	(
		local model_data = collectModelData()
		if model_data != undefined do
		(
			--model_data.Faces[2].e -- get edgesUsingFace
			--model_data.Edges[2].v -- get vertsUsingEdge
			
			--atd...
		)
	)
)
