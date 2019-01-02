/*
Create MaxScript .api file for use with the automcomplete feature of the MaxScript editor.
Created by:
James Haywood
http://apps.jhaywood.com/blog/
in some cases the .api file will not be created in MaxRoot folder becuase of Windows UAC settings
you can add you path and after creation copy "maxscript.api" file to maxroot directory
*/
fn createAPIfile folder: =
(
	local filteredSS = stringstream ""
	local ss = stringstream ""
	apropos "" to:ss
	seek ss 0
	while not eof ss do
	(
		l = readLine ss
		if matchPattern l pattern:"*#struct:*" then
		(
			n = (filterString l " ")[1] ; l = readLine ss
			while matchPattern l pattern:"*public,*" do
			(
				format "%.%\n" n (trimLeft (filterString l ":")[1] " ") to:filteredSS
				l = readLine ss
			)
		)
		else if matchPattern l pattern:"*(const *" do (format "%\n" (filterString l " ")[1] to:filteredSS)
	)
	local filePath = if folder == unsupplied then getDir #maxRoot + @"\maxscript.api" else folder + @"\maxscript.api"
	if not doesFileExist filePath do (createFile filePath)
	if getFileAttribute filePath #readOnly do (setFileAttribute filePath #readOnly false)
	local fStream = openFile filePath mode:"w+"
	format "%" (filteredSS as string) to:fStream
	close fStream ; edit filePath
)
--createAPIfile()
--if you have problem unmark next line and change path
createAPIfile folder:(@"D:\")