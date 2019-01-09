Global mcDecimate
struct MICRA_DECIMATE (
	/**
		select two edges in line 
		distance between will be optimized
	*/
	fn betweenTwoEdges = (

		local poly_obj = selection[1]
		if classOf poly_obj != Editable_Poly do (
			
			messageBox "Works only in Editable_Poly" title:Micra.version
			return false
		)
		--get edges selection
		max modify mode
		if (subObjectLevel != 2) do subObjectLevel = 2
		local first_edges = polyop.getEdgeSelection poly_obj 
		local first_verts = polyop.getVertsUsingEdge poly_obj first_edges
		--selected edges must be two
		if (first_edges as array).count != 2 do (
		
			messageBox "Select two edges" title:Micra.version
			return false
		)
		--loop between two edges
		if not (PolyToolsSelect.StepLoop false) do return false --nothing was selected
		--get edges in middle
		local mid_edges = polyop.getEdgeSelection poly_obj
		mid_edges -= first_edges --remove first two edges
		poly_obj.SetSelection #edge mid_edges
		-- if there is only one middle edge, apply method > ring collapse
		if (mid_edges as array).count == 1 do (
		
		
			PolyToolsSelect.Ring()  
			undo "mcDecimate_betweenTwoEdges" on poly_obj.collapse #Edge
			return OK
		)
		--get cross edges 
		local mid_verts = polyop.getVertsUsingEdge poly_obj mid_edges --get mid edges verts
		mid_verts -= first_verts --remove fist four vertices
		local cross_edges = polyop.getEdgesUsingVert poly_obj mid_verts --get neigbour edges
		cross_edges -= mid_edges --remove mid edges
		poly_obj.SetSelection #edge cross_edges
		PolyToolsSelect.loop false --select loop for remove
		undo "mcDecimate_betweenTwoEdges" on mcAction.clean_edges()
	),
	/**
		Unchamfer v0.01
		select unwanted chamfer edge
		similar edgew will be collapsed
	*/
	fn getEdgeLen poly_obj e_index = (
	
		local everts = polyop.getEdgeVerts poly_obj e_index as array 
		local vert_1 = polyop.getVert poly_obj everts[1]
		local vert_2 = polyop.getVert poly_obj everts[2]
		local len = distance vert_1 vert_2
		len
	),
	fn similarEdges = ( --mcUnchamfer
		if selection.count > 0 and classOf selection[1] == Editable_Poly do (
			
			local poly_obj = selection[1]
			-- get selected edge (chamfer) length
			local edges = polyop.getEdgeSelection poly_obj as array
			if edges.count == 0 do return false
			local e_index = edges[1]
			local chamfer_len = getEdgeLen poly_obj e_index 
			-- get element edges
			local element_faces = polyop.getElementsUsingFace poly_obj (polyop.getFacesUsingEdge poly_obj e_index as bitarray)
			local element_edges = polyop.getEdgesUsingFace poly_obj element_faces as array
			--pick all similar edges in offset tolerance
			local offset = 0.01
			local chamfer_edges = #()
			for e in element_edges do (
			
				local e_len = getEdgeLen poly_obj e
				if e_len > chamfer_len + offset do continue
				chamfer_edges += #(e)
			)
			format "chamfer edges:%\n" chamfer_edges
			--select chamfer edges
			poly_obj.SetSelection #Edge (chamfer_edges as bitarray)
			--select chamfer ring
			poly_obj.SelectEdgeRing()
			--collapse chamfer
			undo "mcDecimate_similarEdges" on poly_obj.collapse #Edge
		)
	)
)
mcDecimate = MICRA_DECIMATE()
/*
mcDecimate.betweenTwoEdges()
mcDecimate.similarEdges()
*/

/*
	fn mcUnchamferAtBorder = (
		if selection.count > 0 and classOf selection[1] == Editable_Poly do (
			
			local poly_obj = selection[1]
			-- get selected edge (chamfer) length
			local edges = polyop.getEdgeSelection poly_obj as array
			if edges.count == 0 do return false
			local e_index = edges[1]
			local chamfer_len = getEdgeLen poly_obj e_index 
			format "edge:%  len:%\n" e_index chamfer_len 
			--get border from selected edge
			edges = polyOp.getBorderFromEdge poly_obj e_index as array
			--pick all similar edges in offset tolerance
			local offset = 0.01
			local chamfer_edges = #()
			for e in edges do (
			
				local e_len = getEdgeLen poly_obj e
				if e_len > chamfer_len + offset do continue
				chamfer_edges += #(e)
			)
			format "chamfer edges:%\n" chamfer_edges
			--select chamfer edges
			poly_obj.SetSelection #Edge (chamfer_edges as bitarray)
			--select chamfer ring
			poly_obj.SelectEdgeRing()
			--collapse chamfer
			poly_obj.collapse #Edge
		)
	)
		--poly_obj.EditablePoly.SetSelection #Edge (edges as bitarray)
		--polyop.setEdgeSelection
		
*/