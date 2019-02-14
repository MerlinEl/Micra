--ooooooooooooooo--
--                      --
--   Gallery 3D    --
--                      --
--ooooooooooooooo--
--------------------------------------
-- STANDALONE version 2018 --
--------------------------------------

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
-- Shortcut only
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~--
fn runGallery3D = (

	local dir = pathConfig.removePathLeaf Micra.RootDir + "\\Gallery3D"
	local fpath = dir + "\\" + "Gallery3D_v1.60.ms"	
	format "does file [%] exists:%\n" fpath (doesFileExist fpath)
	if doesFileExist fpath do fileIn (fpath)
)
runGallery3D()