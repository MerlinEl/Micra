--------------------------------------------------------------------------------
/* mcUpdater by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
	mcFile
	mcArray
	mcDate
	mcCall
	mcZip
*
*@Used Objects
	mcObject
	mcItem
*
*@Usage
	if mcUpdater == undefined do mcFile.fileInVersion "Micra_Update" --load class if is not accessible
	mcUpdater.updateMicra #commit
	mcUpdater.updateMicra #update
*
*@Example	
	undefined
*
*/
struct MICRA_UPDATER_STRUCTURE	(
	
	--variables
	WebClient,
	server_version = "undefined",
	user_dir   = (pathConfig.removePathLeaf Micra.UserDir) + "\\",
	--server_dir = "https://github.com/MerlinEl/Micra/tree/master/Micra4_Release/",
	server_dir = "https://github.com/MerlinEl/Micra/raw/master/Micra4_Release/",
	server_xml = "https://raw.githubusercontent.com/MerlinEl/Micra/master/Micra4_Release/update.xml",
	local_dir  = (pathConfig.removePathLeaf Micra.RootDir) + "\\Micra4_Release\\",
	local_xml  = local_dir + "update.xml",
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
	/**
	*@Usage > Remove all Except User directory
	*/
	fn deleteOldVersionFiles = (

		local excluded_folders_and_files = #("User", "_New", "Temp") --for now, later will be optimalized
		mcFile.deleteDirectoryContent Micra.RootDir exclude:excluded_folders_and_files verification:"Actions.xml"
	),
	fn downloadProgress s a = (mcPopUp.progeressbar a.ProgressPercentage msg:"Downoading Update:"),
	fn downloadCompleted s a = (
	
		mcPopUp.progeressbar 100 msg:"Downoading Finished:" close:true
		dotNet.removeEventHandler mcUpdater.WebClient "DownloadProgressChanged" mcUpdater.downloadProgress
		dotNet.removeEventHandler mcUpdater.WebClient "DownloadFileCompleted" mcUpdater.downloadCompleted
		local local_file  = mcUpdater.user_dir+"Micra.zip"
		if not (doesFileExist local_file) do (
		
			MessageBox "Unable Download Micra's Update. Please contact MerlinEl for help." title:Micra.version
			return false
		)
		format "New Micra v.% was downloaded to:%.\n" mcUpdater.server_version local_file
		--delete old Micra files
		deleteOldVersionFiles()
		--extract Micra zip
		mcZip.unzip local_file Micra.RootDir override:true
		deleteFile local_file	
		--update "SETTINGS/Micra/version"
		mcFile.saveSettings Micra.DefaultSettings "SETTINGS/Micra/version" mcUpdater.server_version		
		--restart Micra
		Micra.reload()
		MessageBox  "Update Finished Succesfull! Enjoy you work!" title:Micra.version
	),
	fn getLatestIndex = (
	
		local latest_version = mcFile.readSettings local_xml "UPDATE/VERSIONS" type:"latest" --"4.25"
		local all_versions = for i=1 to 8 collect mcFile.readSettings local_xml ("UPDATE/VERSIONS/"+"item_"+i as string) type:"version"
		local latest_index = findItem all_versions latest_version
		--format "getLatestIndex > latest_version:% all_versions:% latest_index:%\n" latest_version all_versions latest_index
		latest_index
	),
	/**
	*@Usage > Download file from url with progress bar
	*/
	fn download source_url target_file = (
		
		if doesFileExist target_file do deleteFile target_file --delete old file
		--download new file
		local ServicePointManager = dotNetClass "System.Net.ServicePointManager"
		local SecurityProtocolType = dotNetClass "System.Net.SecurityProtocolType"
		ServicePointManager.Expect100Continue = true --using System.Net
		ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 --Use SecurityProtocolType.Ssl3 if needed for compatibility reasons
		
		format "Micra Updating.... \ndownloading:[ % ] to:[ % ]\n" source_url target_file
		WebClient = dotNetObject "System.Net.WebClient"
		--WebClient.DownloadFile source_url target_file
		dotNet.addEventHandler WebClient "DownloadProgressChanged" downloadProgress
		dotNet.addEventHandler WebClient "DownloadFileCompleted" downloadCompleted
		WebClient.DownloadFileAsync (dotNetObject "System.Uri" source_url) target_file
		WebClient.dispose()
	),
	/**
	*@Usage > Create new micra version and upload it to GITHUB
	*@Example
		if mcUpdater == undefined do mcFile.fileInVersion "Micra_Update" --load class if is not accessible
		mcUpdater.uploadMicra()
	*/
	fn uploadMicra = (
			
		if not (queryBox "You are sure to Upgrade Micra?" title:micra.version) do return false
		--get local micra version and increase it
		local local_version = mcFile.readSettings Micra.DefaultSettings "SETTINGS/Micra/version"
		local new_version = mcMath.versionUp (execute local_version)
format "Update current version:% to %\n" local_version new_version
		--register micra version to Settings.xml
--mcFile.saveSettings Micra.DefaultSettings "SETTINGS/Micra/version" (new_version as string)		
		--register micra version to Update.xml (max 8 backups)
		local last_index = getLatestIndex()
		local next_index = if last_index < 8 then last_index+1 else 1 --cyclic indexing
		local current_date = (mcDate.current()).toStringSimple()
format "last_index:% next_index:% current_date:%\n" last_index next_index current_date
		local node_attribs = (mcObject.new()).addMore #(

			mcItem "version" (new_version as string), 
			mcItem "date" current_date
		)
format "downloadMicra > Debug > Stop."
return OK
		mcFile.saveSettings local_xml ("UPDATE/VERSIONS/item_"+next_index as string) node_attribs type:"attribs"
		mcFile.saveSettings local_xml "UPDATE/VERSIONS/last_index" (next_index as String)
		--pack micra in to zip file with version
		local excluded_folders_and_files = #("old", "Orien_Star", "rene.baca", "Temp", "_New") --for now, later will be optimalized
		mcZip.zip Micra.RootDir (local_dir+"Micra4_"+next_index as String+".zip") override:true exclude:excluded_folders_and_files
		--final msg
		messageBox ("Micra is upgraded from  [ v."+local_version as String+" ] to  [ v."+new_version as String+" ]\nTo complete upgrade commit files on Github :-)") title:micra.version
	),
	fn downloadMicra version = ( --download Micra.zip to Micra/User directory
		
		local fname = "Micra4_"+version+".zip"
		local source_url = server_dir+fname
		local local_file  = user_dir+"Micra.zip"
format "downloadMicra > fname:% source_url:% local_file:%\n" fname source_url local_file
format "downloadMicra > Debug > Stop."
return OK
		download source_url local_file --after finished continue at > downloadCompleted  
	),
	fn getMicraVersion = (
		
		Global mcUpdateMicraDialog
		if mcUpdateMicraDialog != undefined do DestroyDialog mcUpdateMicraDialog
		rollout mcUpdateMicraDialog (micra.version + " Update:")  width:232 height:228 (
			
			GroupBox 'grp1' "" pos:[4,4] width:224 height:188 align:#left
			listbox 'lbx_versions' "Server Versions:" pos:[8,44] width:212 height:9 align:#left
			label 'lbl_you_version' "You Version:" pos:[8,16] width:216 height:20 align:#left
			button 'btn_get' "Get" pos:[4,196] width:108 height:28 align:#left
			button 'btn_abort' "Cancel" pos:[116,196] width:108 height:28 align:#left
			local accepted = true
			fn getSlectedVersion = (
				
				local selected_text = lbx_versions.selected	
				(filterString selected_text " ")[1]
			)
			on mcUpdateMicraDialog open do (
							
				--get local micra version
				local local_version = mcFile.readSettings Micra.DefaultSettings "SETTINGS/Micra/version"
				lbl_you_version.text = "You Version: " + local_version
				--get server micra version
				local xml = mcXML()
				xml.fromString (readXml server_xml)
				local versions_node = xml.getNode "//UPDATE/VERSIONS"
				local server_version = versions_node.getAttribute "latest"
				local all_versions = versions_node.getChildrenNames()
				format "Micra > versions compare > LOCAL:% SERVER:%\n" local_version server_version
				local items = #()
				for n in all_versions do ( --TODO use listbox grid to add index of each version also date
				
					local item = xml.getNode ("//UPDATE/VERSIONS/"+n)
					local version = item.getAttribute "version"
					local date = mcString.replaceAll (item.getAttribute "date") "_" "."
					append items ("v"+version+"      "+date)
				)
				lbx_versions.items = mcArray.reverseArray (sort items)
			)
			on btn_get pressed  do
			(
				accepted = true
				DestroyDialog mcUpdateMicraDialog
			)
			on btn_abort pressed  do
			(
				accepted = false
				DestroyDialog mcUpdateMicraDialog
			)
		)
		CreateDialog mcUpdateMicraDialog modal:true
		
		if not mcUpdateMicraDialog.accepted do return false 
		local version = mcUpdateMicraDialog.getSlectedVersion()
		format "Selected version:%\n" version
		downloadMicra version
	),
	fn sendMicraVersion = (
	
		local pass = mcPopup.textBox title:"Admin password:"
		if pass == undefined or findString pass "orien" == undefined do return false
		uploadMicra()
	),
	fn updateMicra action = (
		
		case action of (
		
			#commit: sendMicraVersion() 
			#update: getMicraVersion()
			#downgrade:	()
			#install:	()
		)
	)
	/*<end>*/
)	
 --create instance
Global mcUpdater = mcStructMan.instanceStructure MICRA_UPDATER_STRUCTURE "mcUpdater"

/* test
/*
REPLACING METHOD (last_index) with (attribute latest:version)
			
xm = mcXML "D:\\ReneBaca\\3DsMax\\Micra\\Micra4_Release\\update.xml"
ver = xm.getNode "//UPDATE/VERSIONS"
ver.getAttribute "latest" --"4.25"
ver.getChildrenNames() --#("item_1", "item_2", "item_3", "item_4", "item_5", "item_6", "item_7", "item_8")


mcZip.zip (Micra.RootDir+"Temp\\source_files\\") (Micra.RootDir+"Temp\\zip_dir\\Micra4_1.zip") override:true
mcZip.unzip (Micra.RootDir+"Temp\\zip_dir\\Micra4_1.zip") (Micra.RootDir+"Temp\\extract_files\\") override:true

		if mcUpdater == undefined do mcFile.fileInVersion "Micra_Update" --load class if is not accessible
		mcUpdater.upload()
*/


/*
public void BeginDownload(RemoteFileInfo fileInfo, string destPath)
		{
			try
			{
				var localFileInfo = new FileInfo(destPath);
				if (localFileInfo.Exists)
				{
					if (Sha1VerifyFile(destPath, fileInfo.Sha1Hash))
					{
						var newEvt = new AsyncCompletedEventArgs(null, false, null);
						DownloadFileCompleted(this, newEvt);
						return; //already have the file with correct contents on disk
					}
				}
			}
			catch (Exception ex)
			{
				var newEvt = new AsyncCompletedEventArgs(ex, false, null);
				DownloadFileCompleted(this, newEvt);
				return; //something failed when trying to hash file
			}

			if (_wc != null)
			{
				_wc.CancelAsync();
				_wc.Dispose();
				_wc = null;
			}

			_wc = new CustomWebClient(Timeout);
			_wc.DownloadProgressChanged += (sender, evt) => { DownloadProgressChanged(sender, evt); };
			_wc.DownloadFileCompleted += (sender, evt) =>
			{
				using (var wc = (WebClient) sender)
				{
					if (evt.Cancelled || evt.Error != null)
					{
						DownloadFileCompleted(sender, evt);
						return;
					}

					try
					{
						if (!Sha1VerifyFile(destPath, fileInfo.Sha1Hash))
							throw new Exception("Hash mismatch after download");
					}
					catch (Exception ex)
					{
						var newEvt = new AsyncCompletedEventArgs(ex, false, evt.UserState);
						DownloadFileCompleted(sender, newEvt);
						return;
					}

					DownloadFileCompleted(sender, evt);
				}
				_wc = null;
			};

			_wc.DownloadFileAsync(new Uri(fileInfo.Url), destPath);
		}
		
EDIT: Here is what i did to get it working.

uploadfile = "c:/testFile.txt" -- FILE TO BE UPLOADED stored in variable

--DOWNLOAD FROM FTP
web = dotNetObject "System.Net.WebClient" -- open dot net web client for downloading files

web.DownloadFile "http://www.YourWebSite.com/test/newtestFile.txt" "c:/newtestFile.txt" -- website url and directory as well as directory of new file to be downloaded

--UPLOAD FROM FTP
Web.Credentials = dotnetObject "System.Net.NetworkCredential" "user" "password" -- ftp username and password
theUri = dotnetObject "System.Uri" ("ftp://YourWebSite.com/test/testfile.txt")

web.UploadFileAsync theUri uploadfile -- upload file to ftp 


	fn getMicraVersion = (
		
		--get local micra version
		local local_version = mcFile.readSettings Micra.DefaultSettings "SETTINGS/Micra/version"
		--get server micra version
		local xml = mcXML()
		xml.fromString (readXml server_xml)
		local xml_node = xml.getNode ("//UPDATE/VERSIONS")
		local last_entry = (xml_node.getChildren())[1]
		--format "xml:%\n" (xml.toString())
		format "nodes:%\n" last_entry
		local server_version = last_entry.getAttribute "version"
		format "Micra > versions compare > LOCAL:% SERVER:%\n" local_version server_version
		if ((execute local_version) >= (execute server_version)) then (
		
			messageBox "Micra is up do date. Nothing new is aviable. Have a nice day :-)" title:micra.version
		) else ( 
		
			updateMicra()
		)
	),



		--getCurrent Version
		local current_version = mcFile.readSettings local_xml "UPDATE/VERSIONS/current_version" type:"version"
		--store it as backup version
		mcFile.saveSettings local_xml ("UPDATE/VERSIONS/old_version") as string) node_attribs type:"attribs"



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