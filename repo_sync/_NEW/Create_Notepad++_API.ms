--Api to XML
/***
Create MaxScript .api file for use with the automcomplete feature of the Notepad++.

Created by:
James Haywood
http://apps.jhaywood.com/blog/
Modified by:
MerlinEl (2019)
***/
(
	local filteredSS = stringstream ""
	local ss = stringstream ""
	local user_dir = pathConfig.removePathLeaf (getDir #userScripts)
	local filePath = user_dir +  "\\maxscript.xml"
	--open XML header
	format "<?xml version=\"1.0\" encoding=\"Windows-1252\" ?>\n"  to:filteredSS
	format "<NotepadPlus>\n"  to:filteredSS
	format "\t<AutoComplete>\n"  to:filteredSS
	format "\t\t<Environment ignoreCase=\"yes\" startFunc=\"(\" stopFunc=\")\" paramSeparator=\".\" terminal=\";\" />"
	
	apropos "" to:ss
	seek ss 0
	while not eof ss do
	(
		l = readLine ss
	
		if matchPattern l pattern:"*#struct:*" then
		(
			n = (filterString l " ")[1]
			l = readLine ss
			while matchPattern l pattern:"*public,*" do
			(
				local fu = (trimLeft (filterString l ":")[1] " ")
				format "\t\t<KeyWord name=\"%.%\" />\n" n fu to:filteredSS
				l = readLine ss
			)
		)
		else if matchPattern l pattern:"*(const *" then
		(
			local fu = (filterString l " ")[1]
			format "\t\t<KeyWord name=\"%\" />\n" fu to:filteredSS
		)
	)
	
	if not doesFileExist filePath then 
	(
		createFile filePath
	)
	if getFileAttribute filePath #readOnly then
	(
		setFileAttribute filePath #readOnly false
	)
	--close XML header
	format"\t</AutoComplete>\n" to:filteredSS
	format "</NotepadPlus>\n" to:filteredSS
	
	local fStream = openFile filePath mode:"w+"
	format "%" (filteredSS as string) to:fStream
	close fStream
	--flush fStream
	--edit filePath
	ShellLaunch user_dir ""
)