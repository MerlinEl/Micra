	fn compareFN v1 v2 =
	(
		local d = v1.len - v2.len
		case of
		(
			(d < 0.): -1
			(d > 0.):  1
			default:   0
		)
	)


	fn getShortestEdge obj  =
	(
		if classOf obj != Editable_Poly do return false
		local edge_sel = polyOp.getEdgeSelection obj 
		if edge_sel.numberSet == 0 do return false
		--get edges length
		struct EDGE_DATA (num, len, verts, vertspos)
		local ED = for i in edge_sel collect 
		(
			local edge_verts = (polyOp.getVertsUsingEdge obj i) as array
			--get edge length
			local p1 = polyOp.getVert obj edge_verts[1]
			local p2 = polyOp.getVert obj edge_verts[2]
			local len = distance p1 p2
			EDGE_DATA i len edge_verts #(p1, p2)
		)
		--debug
		format "edge_data_1:%\n" ED
		
		qSort ED compareFN
		format "edge_data_2:%\n" ED
		--get shortest edge
		local shortest_ED = ED[1]
	)