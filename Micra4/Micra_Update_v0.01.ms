--------------------------------------------------------------------------------
/* mcUpdater by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct MICRA_UPDATER_STRUCTURE	(
	
	--variables
	server_dir = "https://github.com/MerlinEl/Micra/tree/master/Micra4_Release/",
	server_xml = "https://raw.githubusercontent.com/MerlinEl/Micra/master/Micra4_Release/update.xml",
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	fn readXml url = (
	
		local spm = dotnetclass "System.Net.ServicePointManager"
		spm.SecurityProtocol = spm.SecurityProtocol.Tls12
		try (
		
			local request = (dotNetClass "System.Net.WebRequest").Create url
			request.Method = "GET"
			request.Timeout = 1000
			request.UserAgent = "3ds Max"
			local response = request.getResponse()
			local responseStream = response.GetResponseStream()
			local encodingClass = dotNetClass "System.Text.Encoding"
			local encoding = encodingClass.GetEncoding "utf-8"
			local readStream = dotNetObject "System.IO.StreamReader" responseStream encoding
			local webanswer = readStream.ReadToEnd()
			readStream.Close()
			response.Close()
			return webanswer
			
		) catch (
		
			print (getCurrentException())
		)
	),
	fn updateMicra = (
	
	
		format "Micra Updating....\n"
	),
	fn checkForUpdates = (
		
		--get local micra version
		local local_version = mcFile.readSettings Micra.DefaultSettings "SETTINGS/Micra/version"
		--get server micra version
		local xml = mcXML()
		xml.fromString (readXml server_xml)
		local xml_node = xml.getNode ("//UPDATE/VERSIONS")
		local last_entry = (xml_node.getChildren())[1]
		--format "xml:%\n" (xml.toString())
		--format "nodes:%\n" last_entry
		local server_version = last_entry.getAttribute "version"
		format "Micra > versions compare > LOCAL:% SERVER:%\n" local_version server_version
		if ((execute local_version) >= (execute server_version)) then (
		
			messageBox "Micra is up do date. Nothing new is aviable. Have a nice day :-)" title:micra.version
		) else ( 
		
			updateMicra()
		)
	),
	/**
	*@Example
		download "https://raw.githubusercontent.com/MerlinEl/Micra/master/Micra4_Release/update.xml" (Micra.TempDir+"update.xml")
	*/
	fn download source_url target_file = (
		
		if doesFileExist target_file do deleteFile target_file --delete old file
		--download new file
		local ServicePointManager = dotNetClass "System.Net.ServicePointManager"
		local SecurityProtocolType = dotNetClass "System.Net.SecurityProtocolType"
		ServicePointManager.Expect100Continue = true --using System.Net
		ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 --Use SecurityProtocolType.Ssl3 if needed for compatibility reasons
		local web = dotNetObject "System.Net.WebClient"
		web.DownloadFile (source_url) target_file
		format "server_dir:% target_file:% downloaded:% \n" server_dir target_file (doesFileExist target_file)
	)
	/*<end>*/
)	
 --create instance
Global mcUpdater = mcStructMan.instanceStructure MICRA_UPDATER_STRUCTURE "mcUpdater"



/*
http://github.com/user/repository/ -to-> http://github.com/user/repository/archive/master.zip

To download your repository as zip file via curl:

curl -L -o master.zip http://github.com/zoul/Finch/zipball/master/
If your repository is private:

curl -u 'username' -L -o master.zip http://github.com/zoul/Finch/zipball/master/



Got it! Super easy when I knew what to look for. Ill edit this with details when i get home so everyone can have it.

Thanks a ton dub! Your definately the man! 

EDIT: Here is what i did to get it working. 

uploadfile = "c:/testFile.txt" -- FILE TO BE UPLOADED stored in variable

--DOWNLOAD FROM FTP
web = dotNetObject "System.Net.WebClient" -- open dot net web client for downloading files

web.DownloadFile "http://www.YourWebSite.com/test/newtestFile.txt" "c:/newtestFile.txt" -- website url and directory as well as directory of new file to be downloaded

--UPLOAD FROM FTP
Web.Credentials = dotnetObject "System.Net.NetworkCredential" "user" "password" -- ftp username and password
theUri = dotnetObject "System.Uri" ("ftp://YourWebSite.com/test/testfile.txt")

web.UploadFileAsync theUri uploadfile -- upload file to ftp


*/
/*
			--get server file
			local server_dir = "r:\\Resources\\Resources_new\\Micra\\"
			local server_file = server_dir + "Micra4.zip"
			local app_7z = "C:\\Windows\\System32\\7za.exe"
			local micra_folder = Micra.RootDir
			--OLD> local update_file = getDir #scripts+"\\Micra4.zip"
			local update_file = getDir #userScripts+"\\Micra4.zip"
			local backup_folder = substring micra_folder 1 (micra_folder.count-1) +"_Backup\\" --remove last slash and add _backup
			
			if not doesFileExist server_dir do (MessageBox "Server is not Accessible, try later..." title:" Micra:"; return false)
			if not doesFileExist server_file do (MessageBox "No updates found...." title:" Micra:"; return false)
			if not doesFileExist app_7z do copyFile (micra_folder+"App\\7za.exe") app_7z
			if not doesFileExist app_7z do return false
				
			--download new update from server
			deleteFile update_file
			copyFile server_file update_file
			if not doesFileExist update_file do (MessageBox "Unable Download New Update...Installation Aborted" title:" Micra:"; return false)
			
			--backup old Micra folder to Micra_backup
			if not doesFileExist backup_folder then makeDir backup_folder else delDirectoryContent backup_folder
			if not doesFileExist backup_folder do (MessageBox "Unable Create Micra Backup. Installation Aborted" title:" Micra:"; return false)
			treeCopy micra_folder backup_folder
			local files = getFiles (backup_folder+"*.*")
			if files.count == 0 do  (MessageBox "Unable Create Micra Backup. Installation Aborted" title:" Micra:"; return false)
			
			--empty Micra folder
			delDirectoryContent micra_folder
			
			--extract new update in to empty micra folder
			local cmd = (app_7z + " x \"" +update_file+ "\" -o\""+micra_folder+"\"")
			DOSCommand cmd
			--restore user settings
			local user_folder = micra_folder+"User\\"
			local backup_user_folder =  backup_folder+"User\\"
			renameFile user_folder (substring user_folder 1 (user_folder.count-1)+ "_Default" )
			makeDir user_folder
			treeCopy backup_user_folder user_folder
			--Copy Micra_Macro.mcr to max  -- add version checker 
			if doesFileExist Micra.Macro do deleteFile Micra.Macro
			copyFile (Micra.RootDir+"Micra_Macro.mcr") Micra.Macro
			--format "bk2:%\tuser:%\n" backup_user_folder user_folder
			--restart Max
			MessageBox  "Update has ben Succesfull! Please restart the 3DsMax" title:" Micra:-)"
			
*/			
			
			/*
			--check date and time
			if doesFileExist update_file then
			(
				if getFileModDate update_file == getFileModDate server_file 
				then (MessageBox "New updates not found...." title:" Micra:"; return false)       
				else deleteFile update_file
			)
*/