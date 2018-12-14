--Multi Import All *.Obj from Dir

fn MultiImportAllObj =
(
	local dir = getSavePath caption:"Chose dir for Import all obj.."
	print dir
	if dir == undefined do return false
	local files = getFiles (dir + "\\*.obj")
	format "dir:%\tfiles:%\n" dir files.count
	if files.count == 0 do return false
	for f in files do 
	try 
	(
		local objName = getFilenameFile f
		importFile f #noPrompt
		$.name = objName
	) 
	catch ()
	
	frost "Import is finished Succesfully."
)

MultiImportAllObj()
