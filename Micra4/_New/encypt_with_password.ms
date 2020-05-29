/*
Encrypt With Password v.1 (2010-11.29) by Anubis (project3d.narod.ru)
- add password to encrypted scripts (script requested by Michele)
*/
rollout roEncWithPass "EncWithPassword"
(
	local msFile, tmpFile
	
	fn getFileSourceAsString file = (
		f = openFile file mode:"r" ; stream = ""
		while not eof f do append stream (readLine f + "\n")
		close f ; stream -- return result
	)
	
	button btnOpenFile "Choose .MS File" width:120
	edittext txtAddPass "Password: " bold:true
	group "Encrypt Version"
	(
		radioButtons rbtVers labels:#("3ds Max 2 to 9","3ds Max 9 SP1 +")
	)
	button btnEncrypt "Encrypt" width:120
	
	on btnOpenFile pressed do (
		file = getOpenFileName caption:"Open MAXScript File" \
		types:"Script files (*.ms)|*.ms|All files (*.*)|*.*|"
		if file != undefined then msFile = file else msFile = undefined
	)
	on btnEncrypt pressed do (
		if msFile == undefined or txtAddPass.text == "" then
			messageBox "Please choose file and password!"
		else (
			sourceFile = getFileSourceAsString msFile
			additionFile = 
"(
	local Password = \"" + txtAddPass.text + "\", run = false
	rollout roEnterPassword \"Enter Password\"
	(
		edittext txtPassword bold:true
		button btnOK \"OK\" width:90
		on btnOK pressed do (
			run = (Password == txtPassword.text)
			DestroyDialog roEnterPassword
		)
	)
	createDialog roEnterPassword modal:true
	
	if run do (" + sourceFile + ")
)"
			----------------------------------------------
			FilePath = getFilenamePath msFile
			tmpFile = FilePath + "tmp.ms"
			createFile tmpFile
			stream = openFile tmpFile mode:"w"
			format "%\n" additionFile to:stream
			flush stream; close stream
			encryptScript tmpFile version:(rbtVers.state-1)
			renameFile (tmpFile+"e") (msFile+"e")
			gc(); deleteFile tmpFile
		)
	)
	on roEncWithPass close do (
		if tmpFile != undefined do
			if doesFileExist tmpFile do (gc(); deleteFile tmpFile)
	)
)
createDialog roEncWithPass
