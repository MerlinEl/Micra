--creating folders in path
Global mcNewFoldersDialogLastPath
if mcNewFoldersDialogLastPath == undefined do mcNewFoldersDialogLastPath = "C:\\"


if mcNewFoldersDialog != undefined do destroyDialog mcNewFoldersDialog
rollout mcNewFoldersDialog " New Folders:" width:476 height:296
(
	GroupBox grp1 "Dir:" pos:[8,12] width:464 height:276
	
	label lbl1 "Folders List..." pos:[20,56] width:408 height:16
	label lbl6 "Subfolder List..." pos:[24,172] width:404 height:16
	
	edittext edt_dir "" pos:[16,28] width:408 height:17 enabled:false
	edittext edt_dirs "" pos:[20,72] width:408 height:88
	edittext edt_subdirs "" pos:[20,192] width:408 height:88 text:"backup\nresources\ntextures\nwork"
	
	button btn_dir "..." pos:[432,28] width:32 height:16
	button btn_make "OK" pos:[432,72] width:32 height:208
	
	button btn_clear1 "C" pos:[400,48] width:24 height:20
	button btn_clear2 "C" pos:[404,168] width:24 height:20
	fn make_dirs =
	(
		local dir         = edt_dir.text
		local dirs        = edt_dirs.text
		local subdirs     = edt_subdirs.text
		if dirs.count    == 0 do return false
		if subdirs.count != 0 do subdirs = filterstring subdirs "\n"
		
		if not doesFileExist dir do return false
		
		--create main folders
		dirs = filterstring dirs "\n"
		format "dir:%\ndirs:%\n" dir dirs
		if dirs.count == 0 do return false
		for d1 in dirs do 
		(
			makeDir (dir+d1)
			--create sub folders
			if subdirs.count != 0 do for d2 in subdirs do makeDir (dir+d1+"\\"+d2)
		)
		
	)
	
	on btn_dir pressed do
	(
		local dir    = getSavePath caption:" Chose Dir..." initialDir:mcNewFoldersDialogLastPath
		edt_dir.text = if dir != undefined 
		then 
		(
			dir+"\\" 
			mcNewFoldersDialogLastPath = dir+"\\" 
		)
		else 
		(
			""
		)
	)
	on btn_make pressed do make_dirs()
	on btn_clear1 pressed  do (edt_dirs.text = ""; setfocus edt_dirs)
	on btn_clear2 pressed  do (edt_subdirs.text = ""; setfocus edt_subdirs)
)


createDialog mcNewFoldersDialog style:#(#style_toolWindow, #style_sysMenu)

