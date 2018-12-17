user_file = getDir #maxData+"\\MXS_EditorUser.properties"

-- replace part of a string with another string
fn fnReplaceString argString search replace = (
	local varFind
	local varNewString
	
	-- find string
	varFind = findstring argString search
	while varFind != undefined do (
	
		-- replace string
		varNewString = ""
		if varFind > 1 then varNewString += substring argString 1 (varFind - 1)
		varNewString += replace
		varNewString += substring argString (varFind + search.count) argString.count
		argString = varNewString
		varFind = findstring argString search
	)
	
	argString
)


fn readFileToSteram fpath = --collect all data in file
(
	if not doesFileExist fpath do return false
	local f = openFile fpath
	lineNum = 0
	file_text = #()
	while not eof f do -- read until reach end of file
	(
		local line = readline f -- read in a line
		append file_text line 
		print line
	)
	flush f
	close f
	return file_text
)
--
ft = readFileToSteram user_file


fn findStringLineInFile fpath str =  --return line number
(
	if not doesFileExist fpath do return false
	local f = openFile fpath
	local lineNum = 0
	while not eof f do -- read until reach end of file
	(
		local line = readline f -- read in a line
		lineNum += 1
		if findString line str != undefined do exit
		format "current file pos:%\n" (filePos f)
		print line
	)
	flush f
	close f
	return lineNum
)
--
findStringLineInFile user_file "caret.line.back="


fn findStringPosInFile fpath str =
(
	if not doesFileExist fpath do return false
	local f = openFile fpath
	local found = SkipToString f str !=undefined
	local fpos =  filePos f
	flush f
	close f
	if found then return fpos-str.count else return undefined
)
--
findStringPosInFile user_file "caret.line.back="


fn findAndReplaceLineInFile fpath str new_line =
(
	if not doesFileExist fpath do return false
	local f = openFile fpath
	local lineNum = 0
	
)


f = openFile user_file
filePos f
readDelimitedString f "caret.line.back="
SkipToString f "caret.line.back="
flush f
close f




 findStringInFile user_file "caret.line.back="

matchpattern ft pattern:"caret.line.back=*"
findItem ft "caret.line.back=#a69186"
findString "caret.line.back=#a69186" "caret.line.back="
findString "caret.line.back=#a69186" "a69186"

s="text1"
matchPattern s pattern:"text?"-- returns true

"caret.line.back=#a69186" --horizontal line marker color
"caret.line.back.alpha=50" --horizontal line marker opacity


Global netFile = dotnetClass "IO.File"

--save:
(dotnetClass "System.IO.File").writeAllLines <filePathAsString> <yourListBox>.items
--load:
<yourListBox>.items = (dotnetClass "System.IO.File").readAllLines <filePathAsString>

mcSystem.show netFile

text_array = netFile.readAllLines user_file
print text_array

fn deleteLine f linenum = --dotNet method
(
	 local lines = netFile.ReadAllLines f
	 deleteItem lines linenum
	 netFile.WriteAllLines f lines
 )

 fn replaceLine f linenum new_str = --dotNet method
(
	 local lines = netFile.ReadAllLines f
	 lines[ linenum ] = new_str
	 netFile.WriteAllLines f lines
 )

fn findAndReplaceLine fpath str new_str = --dotNet method
(
	if fpath == undefined or not doesFileExist fpath do return false	
	local lines = netFile.ReadAllLines fpath
	for i=1 to lines.count where findString lines[ i ] str != undefined do
	(
		lines[ i ] = new_str
		netFile.WriteAllLines fpath lines
		return true
	)
	return false
 )

 old_line = "caret.line.back=" --a69186
 new_line = "caret.line.back=#11981d"
  new_line ="caret.line.back=#a69186"
 findAndReplaceLine user_file  old_line new_line
 
 
 old_line = "caret.line.back.alpha="
 new_line = "caret.line.back.alpha=80"
  new_line ="caret.line.back.alpha=20"
 findAndReplaceLine user_file  old_line new_line
 
 
 f = openFile user_file
flush f
close f
 
.[static]<System.IO.StreamWriter>AppendText <System.String>path
.[static]<System.IO.FileStream>Create <System.String>path
.[static]<System.IO.StreamWriter>CreateText <System.String>path
.[static]Delete <System.String>path
.[static]<System.IO.FileStream>OpenWrite <System.String>path
.[static]<System.Boolean>Exists <System.String>path
.[static]Replace <System.String>sourceFileName <System.String>destinationFileName <System.String>destinationBackupFileName
.[static]Replace <System.String>sourceFileName <System.String>destinationFileName <System.String>destinationBackupFileName <System.Boolean>ignoreMetadataErrors
 
 
 local myFile = (dotNetClass "System.IO.File").Create g
 myFile.close()
 dotNetObject:System.IO.FileStream
 (dotNetClass "System.IO.File").ReadAllLines g
