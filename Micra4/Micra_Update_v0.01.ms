--------------------------------------------------------------------------------
/* mcUpdater by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcStructMan
	mcFile
	mcDate
*
*@Used Objects
	mcObject
	mcItem
*
*@Usage
	if mcUpdater == undefined do mcFile.fileInVersion "Micra_Update" --load class if is not accessible
	mcUpdater.uploadMicra()
	mcUpdater.downloadMicra #update
*
*@Example	
	undefined
*
*/
struct MICRA_UPDATER_STRUCTURE	(
	
	--variables
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
	fn downloadZipFile source_url target_file = ( 
		
			if doesFileExist target_file do deleteFile target_file --delete old file
		--download new file
		local ServicePointManager = dotNetClass "System.Net.ServicePointManager"
		local SecurityProtocolType = dotNetClass "System.Net.SecurityProtocolType"
		ServicePointManager.Expect100Continue = true --using System.Net
		ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 --Use SecurityProtocolType.Ssl3 if needed for compatibility reasons
		
		local web = dotNetObject "System.Net.WebClient"
		web.Headers.Add "Accept: text/html, application/xhtml+xml, */*"
		web.Headers.Add "User-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)"
/*

fn  Completed s e =(
	web = null
	MessageBox  "Download completed!"
)
local se = dotnetObject "System.Object"
web.DownloadFileCompleted += new AsyncCompletedEventHandler(Completed);

}*/
		-- dotnetObject "System.Object" 
		-- dotnetClass "System.ComponentModel.AsyncCompletedEventArgs"
		--DownloadFileCompleted <System.Object>sender <System.ComponentModel.AsyncCompletedEventArgs>e = ( ... )
		--local newEvt = new AsyncCompletedEventArgs(ex, false, null);
		fn DownloadFileCompleted s a = (
			
			format "completed s:% a:%\n" s a
		)
		web.DownloadFileCompleted DownloadFileCompleted
		web.DownloadFileAsync (dotnetObject "System.Uri" source_url) (dotnetObject "System.String" target_file)

		
		--request = (dotNetClass "system.Net.WebRequest").create m  	
		--request.Timeout = 1000
		--request.dispose()
		format "source_url:%\ntarget_file:%\ndownloaded:%\n" source_url target_file (doesFileExist target_file)
	
	/*
		local web = dotNetObject "System.Net.WebClient"
		fn downloadCompleted s e = (
			
		  web.dispose()
		  web = null
		  MessageBox "Download completed!"
		)
		web.DownloadFileCompleted += AsyncCompletedEventHandler(Completed) 
		web.DownloadFileAsync source_url target_file

protected void DownloadFiles(object sender, EventArgs e)
{
    using (ZipFile zip = new ZipFile())
    {
        zip.AlternateEncodingUsage = ZipOption.AsNecessary;
        zip.AddDirectoryByName("Files");
        foreach (GridViewRow row in GridView1.Rows)
        {
            if ((row.FindControl("chkSelect") as CheckBox).Checked)
            {
                string filePath = (row.FindControl("lblFilePath") as Label).Text;
                zip.AddFile(filePath, "Files");
            }
        }
        Response.Clear();
        Response.BufferOutput = false;
        string zipName = String.Format("Zip_{0}.zip", DateTime.Now.ToString("yyyy-MMM-dd-HHmmss"));
        Response.ContentType = "application/zip";
        Response.AddHeader("content-disposition", "attachment; filename=" + zipName); 
        zip.Save(Response.OutputStream);
        Response.End();
    }
}

	*/
	
	
/*
protected void DownloadFile(string name)
    {
        string _path = Request.PhysicalApplicationPath + "CV/" + name;
        System.IO.FileInfo _file = new System.IO.FileInfo(_path);
        if (_file.Exists)
        {
            Response.Clear();
            Response.AddHeader("Content-Disposition", "attachment; filename=" + _file.Name);
            Response.AddHeader("Content-Length", _file.Length.ToString());
            Response.ContentType = "application/octet-stream";
            Response.WriteFile(_file.FullName);
            Response.End();
        }
        else
        {
            ClientScript.RegisterStartupScript(Type.GetType("System.String"), "messagebox", "&lt;script type=\"text/javascript\"&gt;alert('File not Found');</script>");
        }
    }
*/
/*
response.ContentType = "application/zip";
response.AddHeader("content-disposition", "attachment; filename=" + outputFileName);
using (ZipFile zipfile = new ZipFile()) {
  zipfile.AddSelectedFiles("*.*", folderName, includeSubFolders);
  zipfile.Save(response.OutputStream);
}
	*/
		/*protected void Page_Load(object sender, EventArgs e)
		{
			Response.Clear();
			Response.BufferOutput = false;
			Response.ContentType = "application/zip";
			Response.AddHeader("content-disposition", "attachment; filename=pauls_chapel_audio.zip");

			using (ZipFile zip = new ZipFile())
			{
				zip.CompressionLevel = CompressionLevel.None;
				zip.AddSelectedFiles("*.mp3", Server.MapPath("~/content/audio/"), "", false);
				zip.Save(Response.OutputStream);
			}

			Response.Close();
		}*/
	),
	/**
	*@Example
		if mcUpdater == undefined do mcFile.fileInVersion "Micra_Update" --load class if is not accessible
		mcUpdater.download "https://raw.githubusercontent.com/MerlinEl/Micra/master/Micra4_Release/update.xml" (Micra.TempDir+"update.xml")
	*/
	fn download source_url target_file = (
		
		if doesFileExist target_file do deleteFile target_file --delete old file
		--download new file
		local ServicePointManager = dotNetClass "System.Net.ServicePointManager"
		local SecurityProtocolType = dotNetClass "System.Net.SecurityProtocolType"
		ServicePointManager.Expect100Continue = true --using System.Net
		ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 --Use SecurityProtocolType.Ssl3 if needed for compatibility reasons
		
		local web = dotNetObject "System.Net.WebClient"
		web.DownloadFile source_url target_file
		--request = (dotNetClass "system.Net.WebRequest").create m  	
		--web.Timeout = 1000
		web.dispose()
		format "source_url:%\ntarget_file:%\ndownloaded:%\n" source_url target_file (doesFileExist target_file)
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
		mcFile.saveSettings Micra.DefaultSettings "SETTINGS/Micra/version" (new_version as string)		
		--register micra version to Update.xml (max 8 backups)
		local last_index = execute (mcFile.readSettings local_xml "UPDATE/CURRENT/last_index")
		local next_index = if last_index < 8 then last_index+1 else 1 --cyclic indexing
		local current_date = (mcDate.current()).toStringSimple()
format "last_index:% next_index:% current_date:%\n" last_index next_index current_date
		local node_attribs = (mcObject.new()).addMore #(

			mcItem "version" (new_version as string), 
			mcItem "date" current_date
		)
		mcFile.saveSettings local_xml ("UPDATE/VERSIONS/item_"+next_index as string) node_attribs type:"attribs"
		mcFile.saveSettings local_xml "UPDATE/CURRENT/last_index" (next_index as String)
		--pack micra in to zip file with version
		local excluded_folders_and_files = #("old", "Orien_Star", "rene.baca", "Temp", "_New") --for now, later will be optimalized
		mcZip.zip Micra.RootDir (local_dir+"Micra4_"+next_index as String+".zip") override:true exclude:excluded_folders_and_files
		--final msg
		messageBox ("Micra is upgraded from  [ v."+local_version as String+" ] to  [ v."+new_version as String+" ]\nTo complete upgrade commit files on Github :-)") title:micra.version
	),
	fn updateMicra zip_file = (
	
	
		--download Micrs4_?(1-8).zip to Micra/User directory
		local source_url = server_dir+zip_file
		local local_file  = user_dir+zip_file--"Micra.zip"
		--format "Micra Updating.... \ndownloading:[ % ] to:[ % ]\n" source_url local_file
		download source_url local_file  
		--downloadZipFile source_url local_file  
		--delete old Micra files
--deleteOldVersionFiles()
		--extract Micra zip
		
		--update "SETTINGS/Micra/version"
		
		--restart Micra
		
		--restart Max ??? maybe
		--MessageBox  "Update has ben Succesfull! Please restart the 3DsMax" title:" Micra:-)"
	),
	fn checkForUpdates = (
		
		--get local micra version
		local local_version = mcFile.readSettings Micra.DefaultSettings "SETTINGS/Micra/version"
		--get server micra version
		local xml = mcXML()
		xml.fromString (readXml server_xml)
		local xml_current = xml.getNode ("//UPDATE/CURRENT/last_index")
		local last_index  = xml_current.getAttribute "val"
		local xml_version = xml.getNode ("//UPDATE/VERSIONS/item_"+last_index)
		local server_version = xml_version.getAttribute "version"
		format "last_index:% server_version:%\n" last_index server_version
		format "Micra > versions compare > LOCAL:% SERVER:%\n" local_version server_version
		if ((execute local_version) >= (execute server_version)) then (
		
			messageBox "Micra is up do date. Nothing new is aviable. Have a nice day :-)" title:micra.version
		) else ( 
		
			updateMicra ("Micra4_"+(last_index as String)+".zip")
		)
	),
	fn downloadMicra action = (
		
		case action of (
		
			#update:	checkForUpdates()
			#downgrade:	()
			#install:	()
		)
	)
	/*<end>*/
)	
 --create instance
Global mcUpdater = mcStructMan.instanceStructure MICRA_UPDATER_STRUCTURE "mcUpdater"

/* test

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


	fn checkForUpdates = (
		
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