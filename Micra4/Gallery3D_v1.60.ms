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

	local dir = mcFile.readSettings Micra.UserSettings "Gallery3D/Root_Dir"
	if dir == "" do dir = pathConfig.removePathLeaf Micra.RootDir + "\\Gallery3D" --set automatic root dir (at script loaction)
	local fpath = dir + "\\" + "Gallery3D_v1.61.ms"	
	format "does file [%] exists:%\n" fpath (doesFileExist fpath)
	if doesFileExist fpath do fileIn (fpath)
)
runGallery3D()