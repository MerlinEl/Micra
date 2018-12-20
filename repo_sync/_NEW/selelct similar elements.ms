(
	fn getelements obj= (
		try (
		local f=obj.numfaces
		local eles=#()
		local done=#()
		for i=1 to f do (
			if (finditem done i)==0 then (
			case (classof obj) of (
				editable_mesh:(faces=(meshop.getElementsUsingFace obj #(i)) as array)
				editable_poly:(faces=(polyop.getElementsUsingFace obj #(i)) as array)
			)
		append eles faces
		join done faces
			)
			)
		)
		catch(eles="non poly or mesh object!")
		return eles
	)
 

	function geFacesVolumeAndCenter obj faces = 
	( 
		local Volume= 0.0 
		local Center= [0.0, 0.0, 0.0] 
		
		for f in faces do ( 
			
			Volume += polyOp.getFaceArea obj f
			local f_verts = (polyOp.getVertsUsingFace obj f) as Array
			local verts_pos_sum = [0,0,0]
			for v in f_verts do verts_pos_sum += polyop.getvert obj v
			Center += verts_pos_sum  / f_verts.count
		) 
		return #(Volume,Center) 
	)	
	
	fn selectSimilarElements obj tolerance = (

		--get volume of selected faces
		local fsel_volume = geFacesVolumeAndCenter obj  (polyOp.getFaceSelection obj as Array)
		fsel_volume = fsel_volume[1] +tolerance  --pick only volume
		--fsel_volume = fsel_volume + 10 --make some tolerance in size
		--get all face elements
		local faces_elements = getelements obj
		local similar_elements = #()
		with redraw off for i = 1 to faces_elements.count do (
		
			local el = faces_elements[i]
			--format "el:%\n" el
			local vol = geFacesVolumeAndCenter obj  el
			vol = vol[1] --pick only volume
			--format "el:% sel vol:% next vol:%\n" el fsel_volume vol
			if vol  < fsel_volume do (
				
				join similar_elements el
			)
		)
		polyOp.setFaceSelection obj similar_elements
	)
	
	local tolerance = 12
	undo "Select Similar Elements" on selectSimilarElements selection[1] tolerance
	completeRedraw()
)
	