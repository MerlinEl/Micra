--------------------------------------------------------------------------------
/* mcArray by Orien 2019 */
--------------------------------------------------------------------------------
(
	local script_dir = getFilenamePath (getSourceFileName())
	local micra_dir = pathConfig.removePathLeaf script_dir
	local loader_file = micra_dir + "\\_Loader.ms"
	format "loader_file:%\n" loader_file
	if doesFileExist loader_file then(

		fileIn  loader_file
	)
	else (

		messagebox ("Micra4 loader is not found.") title:" Micra!"
	)
)