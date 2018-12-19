new_name = "cine_cards_playing_a_v1"
--first select (1) current model and (2) current node
fn createNewNodelFromOldOne new_name = (
	
	local sel = selection as array
	if sel.count != 2 do (
		messageBox "Noda and Model must be Selected."
		return
	)
	local ls3d_node, model
	if (classOf sel[1] == LS3DModel) then (
	
		ls3d_node = sel[1]
		model = sel[2]
	) else (
		
		ls3d_node = sel[2]
		model = sel[1]
	)
	delete model
	--importfile "D:/!2k_games/scotch/exported/"+new_name+".fbx" #noPrompt using:FBXIMP
	--error
)
createNewNodelFromOldOne "cine_cards_playing_a_v1"

--rename node and model
--link model in to node
--export node a model at given path
--save max file with new name at given path
fn prepareNewObjects new_name = (
	local sel = selection as array
	sel[1].name = "base"
	sel[2].name = new_name
	sel[1].material = meditmaterials[1]
	sel[1].parent = sel[2]
	--exportFile "C:/Users/Rene.baca/Documents/3dsMax/export" #noPrompt selectedOnly:true using:FBXEXP
	--savemaxfile "D:/!2k_games/scotch/edit/blueprints/cine/generic/" + new_name + ".max"
	print "DONE! Now reload file(add to perforce) and export it with LS3D Exporter"
)
prepareNewObjects "lh_hay_bale_single_a_v1"


export_dir_1010 = "C:\Users\Rene.baca\Documents\3dsMax\export"
shellLaunch "explorer" (export_dir_1010+"\\temp")
exportFile (export_dir_1010+"\\temp\\test.FBX") #noPrompt selectedOnly:true using:FBXEXP
importfile (export_dir_1010+"\\temp\\test.FBX") #noPrompt using:FBXIMP


/*
export_dir_1010 = "C:\Users\Rene.baca\Documents\3dsMax\export"
doscommand ("explorer "+ export_dir_1010)
shellLaunch "explorer" export_dir_1010
*/