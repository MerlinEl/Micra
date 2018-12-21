--Branko October 2, 2013 7:12 AM
fn createMxsAPI filePath:(getDir #maxRoot + @"\maxscript.api") showInEditor:on = (

	local dnSW = dotNetClass "System.IO.StreamWriter" 
	local dnFile = dotnetClass "System.IO.File" 
	local mxsAPI = dotNetObject dnSW (dnFile.Create filePath) 
	local filteredSS = stringstream ""
	local ss = stringstream "" 
	apropos "" to:ss
	seek ss 0 
	while not eof ss do ( 
		
		local theLine = readLine ss 
		if matchPattern theLine pattern:"*#struct:*" then ( 
			
			local theWord = (filterString theLine " ")[1] 
			theLine = readLine ss 
			while matchPattern theLine pattern:"*public,*" do ( 
				
				mxsAPI.WriteLine (theWord+"."+(trimLeft (filterString theLine ":")[1] " ")) 
				theLine = readLine ss 
			) 
		) else if matchPattern theLine pattern:"*(const *" do (
			
			mxsAPI.WriteLine ((filterString theLine " ")[1])
		) 
	) 
	mxsAPI.Close() 
	mxsAPI.Dispose() 
	if showInEditor do edit filePath 
) 
--create api file here > "C:\Program Files\Autodesk\3ds Max 2014\\maxscript.api"
createMxsAPI showInEditor:on