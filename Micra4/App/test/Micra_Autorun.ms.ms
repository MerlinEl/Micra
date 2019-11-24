--------------------------------------------------------------------------------
/* Micra Start by Orien 2019 */
--------------------------------------------------------------------------------
(
	local loader = "E:\Aprog\Orien\Micra\Micra4\_Loader.ms"
	if doesFileExist loader then
	(
		fileIn loader
	)
	else (messagebox ("Micra4 loader is not found.") title:" Micra!")
)
