	Global matMixDdata = #()
	fn getDifuseFromMixRecursive mat =
	(
		if classof mat.map1 == Bitmaptexture then
		(
			matMixDdata += #(filenameFromPath mat.map1.filename)
		)
		else if classof mat.map1 == Mix do
		(
			getMixDataRecursive mat.map1
		)
		
		if classof mat.map2 == Bitmaptexture then
		(
			matMixDdata += #(filenameFromPath mat.map2.filename)
		)
		else if classof mat.map2 == Mix do
		(
			getDifuseFromMixRecursive mat.map2
		)
	)
	
	(getDifuseFromMixRecursive meditMaterials[1][2].diffusemap)