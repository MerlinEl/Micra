Global DDS_MANAGER


struct DDS_MANAGER (

	app = getFilenamePath  (getSourceFileName()) + "texconv32.exe",
	fn createDDSFile save_dir file_name size_w size_h bg_color = (

		local bmp_path = save_dir + file_name + ".bmp"
		local temp_b = bitmap size_w size_h filename:(bmp_path) color:bg_color
		save temp_b; close temp_b
		local cmd = app + " " + bmp_path + " -ft dds -o " + save_dir
		format "createDDSImage >\n\tcmd:%\n" cmd
		HiddenDOSCommand cmd startpath:save_dir exitCode:&exitcode --donotwait:true 
		if doesFileExist bmp_path do deleteFile bmp_path --remove temporalily image
		exitcode == 0
	)
)



/*
dm = DDS_MANAGER()
dm.createDDSFile @"c:\temp\" "test_file8" 512 240 gray
*/

