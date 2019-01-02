/***
Create MaxScript .api file for use with the automcomplete feature of the MaxScript editor.

Created by:
James Haywood
http://apps.jhaywood.com/blog/
***/
(
	filteredSS = stringstream ""
	ss = stringstream ""
	user_dir = pathConfig.removePathLeaf (getDir #userScripts)
	filePath = user_dir +  "\\maxscript.api"
	
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
				format "%.%\n" n (trimLeft (filterString l ":")[1] " ") to:filteredSS
				l = readLine ss
			)
		)
		else if matchPattern l pattern:"*(const *" then
		(
			format "%\n" (filterString l " ")[1] to:filteredSS
		)
	)
	
	--filePath = getDir #maxRoot + @"\maxscript.api"
	if not doesFileExist filePath then 
	(
		createFile filePath
	)
	if getFileAttribute filePath #readOnly then
	(
		setFileAttribute filePath #readOnly false
	)
	fStream = openFile filePath mode:"w+"
	format "%" (filteredSS as string) to:fStream
	close fStream
	edit filePath
)