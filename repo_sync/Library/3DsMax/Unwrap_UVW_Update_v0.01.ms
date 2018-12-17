(
	fn downloadFile source destination = --"http://web/data.zip" "C:\\temp\\data.zip"
	(
		local web_client_object = dotNetObject "System.Net.WebClient"
		try 
		(
			web_client_object.downloadFile source destination
		)
		catch (print "download failed"; return false)
		(print "done"; return true)
	)
	
	--local source  = "http://czh-fs-38/dokuwiki/lib/exe/fetch.php?media=silent_hill:art_tools:3ds_max_9_unwarpuvw_update.zip"
	--local destination = GetDir #scripts + "\\fetch.php?media=silent_hill:art_tools:3ds_max_9_unwarpuvw_update.zip"
	
	local source = "http://www.harajdadent.hu/image/aple.jpg"
	local destination = GetDir #scripts + "\\aple.jpg"
	downloadFile source destination
)