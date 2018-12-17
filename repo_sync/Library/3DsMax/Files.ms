ShellLaunch "explorer.exe" (pathConfig.getCurrentProjectFolder())

getThisScriptFilename()
getSourceFileName()

for i = 1 to symbolicPaths.numPaths() do 
format "% : %\n" i (symbolicPaths.getPathName i)

symbolicPaths.isPathName "$map"
symbolicPaths.numUserPaths()
symbolicPaths.expandFileName <filename> --Returns expanded file nane

PlaneMap = getOpenFileName caption:"Select Map"  \ 
filename:maxfilepath \
types:"Targa (*.tga)|*.tga|Jpeg (*.jpg)|*.jpg|Tiff (*.tif)|*.tif|All (*.*)|*.*|"


-- function to create a directory if it does not already exist. 
-- Returns true if directory existed or was created, false if directory could not be created
rttt = RTT_methods_struct()
rttt.ValidateDirectory "C:\\temp/test\\01"


--mergr from network
mergemaxfile @"\\my_server\myproject\mergefile.max" #("Box01")

getSavePath caption:" Chose Dir..." initialDir:(getDir #maxroot)


getOpenFileName [ caption:<title> ] \
[ filename:<seed_filename_string> ] \
[ types:<description1>|<pattern1>|<description2>|<pattern2>|...| ]


selectBitmap()

getSaveFileName [ caption:<title>] \
[ filename:<seed_filename_string> ] \
[ types:<description1>|<pattern1>|<description2>|<pattern2>|...| ]

getOpenFileName caption: " Chose Dir..." filename:(MPath()+"*.ms") types:"Script files: [*.ms, *.mcr]"

getOpenFileName caption: "Merge File" types:"3ds Max (*.max)|*.max"

fileOpenMatLib() -- material library


autoBackup.time
autoBackup.enabled

sysInfo.windowsdir
sysInfo.systemdir
sysInfo.tempdir
sysInfo.currentdir
sysInfo.username
sysInfo.computername
sysInfo.cpucount
sysInfo.desktopSize
sysInfo.desktopBPP
sysInfo.MAXPriority -- are #high, #normal, and #low
sysinfo.getLanguage()
sysinfo.getSystemMemoryInfo()
sysinfo.getMAXMemoryInfo()
systemTools.GetScreenWidth()
systemTools.GetScreenHeight()
systemTools.IsWindows98or2000() --Returns true if the OS is Windows98 or Win2000
systemTools.IsWindows9x() --Returns true if the OS is a Win9x flavor
systemTools.IsDebugging() --Returns true if running in a debugger
maxversion()--integers like #(3000, 6, 0) with 3ds Max release number, max API number, revision number of the SDK. 
----------------------------
--Write in file--------------------
f = createFile "mithrilium.tmp"
format "%:%.%" "Vaha" "120" "kg" to:f
close f

/*
edit "mithrilium.tmp"
*/
--Write in file---------------------
scriptsPath
getFileSize "E:/Micra/Micra_Mirror.ms"  --getFileSize <filename_string>
getDirectories "E:/Micra"				--getDirectories <wild_card_directory_name_string>
copyFile "Micra_Run.ms" "Micra_Run2.ms" --copyFile <existing_filename_string> <new_filename_string>
makeDir "E:/Micra/test"        		    --makeDir <directory_path_string>
makeDir dir all:true -- make's full path tree in HD
getFiles "E:/Micra/*.ms" 				--getFiles <wild_card_filename_string>
createfile "E:\\Micra\\test.ms"
deleteFile "test.ms"					--deleteFile <filename_string>
renameFile "test.ms" "test2.ms"			--rename <existing_filename_string> <new_filename_string>
doesFileExist "E:/Micra/Micra_Run.ms"   --doesFileExist <filename_string>
edit "E:\\Micra\\test.ms"
include "test.ms" 						--include <"filename_string">
include "test.ms" + include "test2.ms"  --include mutiple files
maxFilePath --display path of max file is opened
maxFileName --display name of max file is opened

--Check file num in dir
if (getFiles "E:/Micra/*.ms").count == 0 then (print "File missing") else ((getFiles "E:/Micra/*.ms").count)
--Delete files type in dir
for f in getFiles "E:/foo/*.jpg" do deleteFile f

Expressions=amMicra_Run.ms--path

file="E:\\Micra\\Micra_Run.ms"
filenameFromPath file -- returns: "myImage.jpg"
getFilenamePath file  -- returns: "g:\subdir1\subdir2\"
getFilenameFile file  -- returns: "myImage"
getFilenameType file  -- returns: ".jpg"

fn existFile fName = (getfiles fname).count != 0 --Function:
if existFile "E:/Micra/test2.ms" then 20 else 40 --Call:

loadMaterialLibrary "E:\Micra\Matlib\Merlin.mat"
saveMaterialLibrary "E:\Micra\Matlib\Merlin.mat"
fileSaveAsMatLib()
getMatLibFileName()


getFileModDate <filename_string> --Returns a String value containing the modification date for the specified file, for example "1/29/99 1:52:05 PM".
getFileCreateDate <filename_string> --Returns a String value containing the creation date for the specified file.

--------------------------------------------------------------
getFileAttribute <filename_string> <attribute>				--
setFileAttribute <filename_string> <attribute> <boolean>	--
															--
#readOnly													--
#hidden														--
#system														--
#directory													--
#archive													--
#temporary													--
#normal														--
--------------------------------------------------------------
getFileAttribute "E:\\Micra\\test2.ms" #readOnly  --check if read only is true
setFileAttribute "E:\\Micra\\test2.ms" #readOnly on --read only turn on
setFileAttribute "E:\\Micra\\test2.ms" #readOnly off --read only turn off
--------------------------------------------------------------

GetINISetting "c:/3dsmax6/3dsmax.ini" "Directories" "Scenes"
setINISetting "c:/3dsmax6/3dsmax.ini" "Directories" "Scenes" "c:/3dsmax/scenes"
delIniSetting <filename_string> <section_string> <key_string> --Deletes the specified key from the supplied section of the given INI file.
delIniSetting <filename_string> <section_string>  --Deletes the section and all keys in the section of the given INI file.

--************************************************************************************--
----------------------------------------------------------------------------------------
Here is some code that creates an encrypted lock ID file in some authorization process.
----------------------------------------------------------------------------------------
f = createFile "lock.tmp"
format "%" hardwareLockID to:f
close f
encryptFile "lock.tmp" "lock.dat" 5476557
deleteFile "lock.tmp"
----------------------------------------------------------------------------------------
The following code can be used to read and check the lock ID 
----------------------------------------------------------------------------------------
f = openEncryptedFile "lock.dat" 5476557
id = readValue f
close f
if id != hardwareLockID then
	(
	message "Lock ID's don't match"
	return 0
	)
----------------------------------------------------------------------------------------
--************************************************************************************--


/*
fname=getsavefilename title:"save hierarchy" filename:"hierarchy.ms" types:"maxscript(*.ms)|*.ms|All|*.*|"
if fname==undefined then exit


filePos <filestream> --retrieve the current offset into the file



p = getSavePath()

getSaveRequired()
------------------
doesFileExist "Micra_Functions"
-------------
if (getfiles "Micra_Functions").count != 0 then
*/

/*
f = createFile "lock.tmp"
format "%" hardwareLockID to:f
close f
*/

/*
--Collect data
datastring=""
for obj in selection do
(
	if obj.parent!=undefined then
		datastring=datastring+"$'"+obj.name+"'.parent=$'"+obj.parent.name+"'\n"
)
--write out datastring
createfile fname
s=openfile fname mode:"w"
format "%" datastring to:s
close s
datastring=undefined
*/


f= openFile "Micra_Cloner.ms" mode:"r+"
d = (openFile(filein "Micra_Cloner.ms")mode:"r+")
getFilenamePath "Micra_Cloner.ms"
getFilenameType "Micra_Cloner.ms"
filenameFromPath "Micra_Cloner.ms"
getFilenameFile "Micra_Cloner.ms"
include "Micra_Cloner.ms"
sysInfo.currentdir
--------------------------------------------
AutExe = "\n fn mPath=("+p +")"
AutExe = "\n fn mPath=(\""+p+"\")"
AutExe = "\n fn mPath=(\""+p+"\\\")"
--------------------------------------------
for i=1 to 8 do (if i == 5 do continue; print i) -- prints 1..4, 6..8
while not eof f do -- read until reach end of file
(
local line=readline f -- read in a line
if line[1] == "-" do continue -- if comment, skip to next line
line1=parser1 line -- call function parser1
processobjs line1 -- call function processobjs
)
------------------------
getDir #maxData == --C:\Documents and Settings\rbaca\Local Settings\Application Data\Autodesk\3dsmax\9 - 32bit\enu

GetDir <filetype_name>
#autoback
#defaults
#drivers
#export
#expression
#font
#help
#image
#import
#matlib
#maxroot
#maxstart
#plugcfg
#preview
#scene
#scripts
#sound
#startupScripts
#ui
#vpost
------------------------


DOSCommand "delete c:\\temp\\foo.dat"
DOSCommand "del D:\\3dsmax7\\shaders\\.svn\\*.*"

--del all files in all dirs
DOSCommand "del  E:\\Micra3_Backe\\*.* /s/q"
--del all dirs and files
DOSCommand "RD E:\\Micra3_Baki\\ /s /q"

recycle_bin= (getDirectories "C:\\RECYCLER\\*")[1]
doesFileExist recycle_bin
getFiles  (recycle_bin+"*.*")


f_1="C:\\temp\\myFile.txt"
d_1= (getDirectories "C:\\RECYCLER\\*")[1] + (filenameFromPath f_1)
DOSCommand ("move /Y"+" "+d_1 +" "+f_1)


vert_array = #()
face_array = #()
in_name = ((GetDir #export)+"/testmesh.dat")
in_file = openFile in_name
if in_file != undefined then
(
	num_verts = readValue in_file 
	num_faces = readValue in_file 
	vert_array.count = num_verts
	face_array.count = num_faces
	for v = 1 to num_verts do
	(
	vert = readValue in_file
	vert_array[v] = vert
	)
	for f = 1 to num_faces do
	(
		face = readValue in_file
		face_array[f] = face
	)
	close in_file
	new_mesh = mesh vertices:vert_array faces:face_array
)


(
	local f , str, line, lineNum
	
	f = openFile (mpath()+"test.ms")
	str = "fn mFilterPath pth ="--"LocalTime"
	lineNum = 0
	while not eof f do -- read until reach end of file
	(
	line = readline f -- read in a line
	lineNum+=1
	if line == str then
	(
		format "The string: %%% in line: % "  "\"" line "\"" lineNum
	)
	else ()
	)
	close f
)


(
	local f , str, line, num
	
	f = openFile (mpath()+"test.ms")
	str = "LocalTime"
	num = 0
	while not eof f do -- read until reach end of file
	(
		line = readline f -- read in a line
		num+=1
		
		if (findString line str) != undefined do
		(
			format "The string:%%%  \nfounded in line: % \n% "  "\"" str "\"" line  ("("+ num as string +")")
		)
	)
	close f
)

	fn getFileText fPath =
	(
		if not doesFileExist fPath do return ""
		local data = ""
		local f = openFile fPath mode:"r"
		while not eof f do
		(
			data += (readLine f) +"\n"
		)
		flush f
		close f
		return data
	)
	
	
fn returnForwardSlashPath thePath =
(
	local newPath = thePath
	if (classOf thePath) == String then 
	(
		for i = 1 to thePath.count do (
		if (substring thePath i 1) == "\\" then
		newPath[i] = "/"
		)
	)
	return newPath
)
returnForwardSlashPath "c:\\re\\dfsdfds"




fn loadPresetFile buffer:undefined filename: =
(
 if filename == unsupplied do filename = getOpenFilename caption:"Pick a preset file" types:"Render Preset File (*.rps)|*.rps"
 if filename != undefined do
 (
  local ss = fopen filename "rb"
  if ss != undefined do 
  (
   buffer = #()
   while (val = ReadByte ss #unsigned) != undefined and not keyboard.escpressed do
   (
	append buffer val
   )
   fflush ss
   fclose ss
  )
 )
 buffer
)
fn savePresetFile buffer:undefined filename: = if iskindof buffer Array do 
(
 if filename == unsupplied do filename = getSaveFilename caption:"Pick a preset file" types:"Render Preset File (*.rps)|*.rps"
 if filename != undefined do
 (
  local ss = fopen filename "wb"
  if ss != undefined do 
  (
   for b in buffer do WriteByte ss b
   fflush ss
   fclose ss
  )
 )
 filename
)

------------------------------------------------------

f = openfile (MPath()+"Micra.ini")
while not eof f do -- read until reach end of file
(
	line=readline f
	print line
)

------------------------------------------------------

f = openfile (MPath()+"Micra.ini")
while not eof f do -- read until reach end of file
(
	line=readline f
	--if line[1] == "[DefaultPath]" do print f
	if line == "[DefaultPath]" then print "Found" else print "Not Found"
)
------------------------------------------------------


--Recursive fn for Copy Dir Tree
	fn copyAllDirsWithFiles inpath outpath = --recursive fn for copyDirTree
	(
		if not doesFileExist outpath do try (makeDir outpath) catch (return false)
		local the_dirs = getDirectories (inpath+"*.*")
		for in_d in the_dirs do
		(
			local out_d = 
			(
				local dir_elements = (filterString in_d "\\")
				local last_dir = dir_elements[dir_elements.count]
				outpath+last_dir+"\\"
			)
			
			makeDir out_d

			local the_files = getFiles (in_d+"*.*")
			for in_f in the_files do 
			(
				local out_f = out_d + filenameFromPath in_f
				copyFile in_f out_f
			)
			--recursive call
			mcFile.copyAllDirsWithFiles in_d out_d
		)
	),
	fn copyDirTree inpath outpath owerwrite:false =
	(
		--check path end slash
		trimRight inpath "c:\\temp/" "\\/"
		trimRight outpath "c:\\temp/" "\\/"
		inpath  += "\\"
		outpath += "\\"
		
		--if inpath [inpath.count ] != "\\" do inpath  += "\\"
		--if outpath[outpath.count] != "\\" do outpath += "\\"
		
		--check paths
		if not doesFileExist inpath do return false
		if not doesFileExist outpath do try (makeDir outpath) catch (return false)
		
		--copy main dir files
		local the_files = getFiles (inpath+"*.*")
		for in_f in the_files do 
		(
			local out_f = outpath + filenameFromPath in_f
			copyFile in_f out_f
		)
		--copy subdirs and files
		mcFile.copyAllDirsWithFiles inpath outpath
		return OK
	),