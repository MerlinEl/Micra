--ooooooooooooooo--
--                      --
--   3D Gallery    --
--                      --
--ooooooooooooooo--
--------------------------------------
-- STANDALONE version 2018 --
--------------------------------------

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- Shortcut only
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
fn runGallery3D = (

	local dir = pathConfig.removePathLeaf (mcPath()) + "\\3DGallery"
	local fpath = dir + "\\" + "3DGallery_v1.60.ms"	
	format "does file [%] exists:%\n" fpath (doesFileExist fpath)
	if doesFileExist fpath do fileIn (fpath)
)
runGallery3D()