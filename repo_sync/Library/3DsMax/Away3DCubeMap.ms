/*space_map_BK.jpg
space_map_DN.jpg		
space_map_FR.jpg
space_map_LF.jpg
space_map_RT.jpg
space_map_UP.jpg

cubemap_negX.jpg	LF (left)
cubemap_negY.jpg	DN (bottom-down)	
cubemap_negZ.jpg	FR (near-front)
cubemap_posX.jpg	RT (right)
cubemap_posY.jpg	UP (top-up)
cubemap_posZ.jpg	BK (far-back)*/

fn translateCubeMapToAway3D = (
	
	if selection.count == 0 do return false
	local cube_mat = $.material
	local reflect_mat = cube_mat.diffusemap
	local textures = reflect_mat.bitmapName    
	for f in textures do(

		local fname = getFilenameFile f
		local fpath = getFilenamePath f
		local ftype = getFilenameType f
		local pattern = substring fname (fname.count-1) fname.count --get two last letters
		
		--format "pattern:% fname:% ftype:% fpath:%\n" pattern fname ftype fpath
		
		local away_name = ""
		
		case (pattern) of (
		
			"UP": away_name += "cubemap_posY"
			"DN": away_name += "cubemap_negY"
			"LF": away_name += "cubemap_negX"
			"RT": away_name += "cubemap_posX"
			"FR": away_name += "cubemap_negZ"
			"BK": away_name += "cubemap_posZ"
			default:away_name += "none"
		)
		
		local new_f = fpath + away_name + ftype
		print ("create new file:" + new_f)
		copyFile f new_f
	)

)

translateCubeMapToAway3D()