if mcGeometryBuilderDialog != undefined do destroyDialog mcGeometryBuilderDialog
rollout mcGeometryBuilderDialog "Plygon Builder:" width:336 height:68
(
	GroupBox 'grp1' "Actions:" pos:[4,4] width:328 height:56 align:#left
	button 'btn_create_polygon' "Create Polygon" pos:[12,24] width:132 height:28 align:#left
	button 'btn_flip_faces' "Flip Faces" pos:[256,24] width:68 height:28 align:#left
	radioButtons 'rdo_sort_order' "Sort order " pos:[152,20] width:101 height:30 labels:#("CW", "CCW") columns:2 align:#left
	local active_obj
	fn createPolygonFromPoints obj = (
		
		local sel_verts = polyOp.getVertSelection obj
		local polygon_points = for vi in sel_verts collect  (polyOp.getVert obj vi)
		local sort_style = if rdo_sort_order.state == 2	then #reverse else #none
		active_obj = mcPoly.createPolygonObj polygon_points  sortStyle:sort_style
	)
	fn createPolygonBetweenEdges obj = (
		
		local sel_edges = polyOp.getEdgeSelection obj
		local polygon_points =  #()
		for ei in sel_edges do (

			local everts = (polyOp.getEdgeVerts obj ei) as array
			append polygon_points (polyOp.getVert obj everts[1])
			append polygon_points (polyOp.getVert obj everts[2])
		)
		local sort_style = if rdo_sort_order.state == 2	then #reverse else #none
		active_obj = mcPoly.createPolygonObj polygon_points sortStyle:sort_style
	)
	fn createPolygon = (
		
		local obj = selection[1]
		local slev = subObjectLevel
		if slev != 1 and slev != 2 do return false 
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		case slev of (
			
			1 : createPolygonFromPoints obj
			2 : createPolygonBetweenEdges obj
		)
		subObjectLevel = slev
	)
	fn flipFaces = (
		
		local slev = subObjectLevel
		if active_obj == undefined do active_obj = selection[1]
		--format "active obj :%\n" active_obj
		local normalMod = normalModifier()
		normalMod.flip = true	
		addModifier active_obj normalMod
		convertToPoly active_obj
		if slev != undefined do subObjectLevel = slev
	)

	on btn_create_polygon pressed do undo "Create Polygon" on createPolygon()
	on btn_flip_faces pressed do undo "Flip Faces" on flipFaces()
)
createDialog mcGeometryBuilderDialog