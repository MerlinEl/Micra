--------------------------------------------------------------------------------
/* mcDraw by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	Micra
*
*@Used Objects

*
*/
struct MICRA_DRAW (

	fn isBackface poly_obj the_face =
	(
		local v1 = (mapScreenToWorldRay mouse.pos).dir
		local v2 = (normalize (polyOp.getFaceNormal poly_obj the_face))
		if (dot v1 v2) > -0.1 then return true else return false	
	),
	fn collectFrontEdges poly_obj =
	(
		local fCount = poly_obj.Faces.count
		if fCount == 0 do return undefined
		local frontFaces = for f=1 to fCount where not (mcDraw.isBackface poly_obj f) collect f
		if frontFaces.count == 0 do return undefined
		return (polyOp.getEdgesUsingFace poly_obj frontFaces)
	),
	fn showEdgedFaces =
	(
		local poly_obj  = selection[1]
		if poly_obj == undefined or classOf poly_obj != Editable_Poly do return undefined
		--collect front edges
		local FrontEdges = mcDraw.collectFrontEdges poly_obj
		if FrontEdges == undefined do return undefined 
		gw.setTransform (Matrix3 1)
		gw.setColor #line white
		--draw lines from point
		for i in FrontEdges do 
		(
			local verts  = (polyOp.getVertsUsingEdge poly_obj i) as array
			local p1 = polyOp.getVert poly_obj verts[1]
			local p2 = polyOp.getVert poly_obj verts[2]
			gw.Polyline #(p1,p2) false
		)
		local rect = (Box2 [poly_obj.min.x,poly_obj.min.y] [poly_obj.max.x,poly_obj.max.y])
		gw.enlargeUpdateRect rect--#whole 
		gw.updateScreen()
	)
)
 --create instance
Global mcDraw = Micra.instanceStructure MICRA_DRAW "mcDraw"
