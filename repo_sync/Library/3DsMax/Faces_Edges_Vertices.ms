fn mcGetFaceUsing verts obj type =
(
	local theFaceVerts = polyOp.getFacesUsingVert obj verts
	for f in theFaceVerts where 
	( 
		( (polyOp.getVertsUsingFace obj f ) * verts ).numberset == 3 
	
	) collect f
)	

(
	local theVerts = polyOp.getVertSelection $
	(mcGetFaceUsing theVerts $ #poly)
)

/*
fn mcGetFaceUsing verts obj type =
(
	local theFaceVerts = case type of
	(
		#mesh: meshOp.getFacesUsingVert obj verts
		#poly: polyOp.getFacesUsingVert obj verts
	)
	for f in theFaceVerts where 
	(
		(
			(
				case type of
				(
					#mesh: meshOp.getVertsUsingFace obj f as bitarray
					#poly: polyOp.getVertsUsingFace obj f as bitarray
				)
			)*verts
		).numberset == 3
 
	)collect f
)	


(
	local theVerts = polyOp.getVertSelection $
	(mcGetFaceUsing theVerts $ #poly)
	--local theVerts = getVertSelection $
	--(mcGetFaceUsing theVerts $ #mesh)
)
*/
