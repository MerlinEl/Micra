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
	mcNet
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
	debug = true,
	WebClient,
	chossen_version = "undefined",
	user_dir   = (pathConfig.removePathLeaf Micra.UserDir) + "\\",
	server_dir = "https://github.com/MerlinEl/Micra/raw/master/Micra4_Release/",
	server_xml = "https://raw.githubusercontent.com/MerlinEl/Micra/master/Micra4_Release/update.xml",
	local_dir  = (pathConfig.removePathLeaf Micra.RootDir) + "\\Micra4_Release\\",
	local_xml  = local_dir + "update.xml",
	--functions
	fn getSource = getSourceFileName(), --get path of this script
	/**
	*@Usage > Remove all Except User directory
	*/
	fn emptyMicraFolder exclude_folders_and_files:#() = (

		mcFile.deleteDirectoryContent Micra.RootDir exclude:exclude_folders_and_files verification:"Actions.xml"
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
		if mcUpdater.debug do format "mcUpdater > downloadCompleted > New Micra v% was downloaded to:%\n" mcUpdater.chossen_version local_file	
		--delete old Micra files
		if mcUpdater.debug do format "mcUpdater > downloadCompleted > delete old Micra files.\n"
		mcUpdater.emptyMicraFolder exclude_folders_and_files:#("User", "_New", "Temp", "App") --app must stay there is 7zip.exe
		--extract Micra zip
		if mcUpdater.debug do format "mcUpdater > downloadCompleted > unzip new Micra files...\n\tfrom:%\n\tto:%\n" local_file Micra.RootDir
--TODO make callback to wait for unzip done
		mcZip.unzip local_file Micra.RootDir override:true exclude:#("App") --extract zip file (exclude can't override self 7zip.exe)
		--update "SETTINGS/Micra/version"
		mcFile.saveSettings Micra.DefaultSettings "SETTINGS/Micra/version" mcUpdater.chossen_version --register downloaded version	
		--restart Micra
		if mcUpdater.debug do format "mcUpdater > downloadCompleted > reloading Micra.\n"
		Micra.reload()
		MessageBox  "Update was finished Succesfully! Enjoy you work!" title:Micra.version
	),
	fn getLatestIndex = (
	
		local latest_version = mcFile.readSettings local_xml "UPDATE/VERSIONS" type:"latest" --"4.25"
		local all_versions = for i=1 to 8 collect mcFile.readSettings local_xml ("UPDATE/VERSIONS/"+"item_"+i as string) type:"version"
		findItem all_versions latest_version --latest_index
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
		
		if debug do format "mcUpdater > download > Micra Downloading.... \n\tfrom:[ % ]\n\tto:[ % ]\n" source_url target_file
		/*
			mcEvents.registerEvent "FileWasDownloaded" fileDownloaded
			mcNet.DownloadFile source_url target_file
		
		*/
		WebClient = dotNetObject "System.Net.WebClient"
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
		local new_version = (mcMath.versionUp (execute local_version)) as string
		if debug do format "mcUpdater > uploadMicra > Update current version:% to %\n" local_version new_version
		--register micra version to Settings.xml
		mcFile.saveSettings Micra.DefaultSettings "SETTINGS/Micra/version" (new_version as string)		
		--register micra version to Update.xml (max 8 backups)
		local last_index = getLatestIndex()
		local next_index = if last_index < 8 then last_index+1 else 1 --cyclic indexing
		local oldest_version = mcFile.readSettings local_xml ("UPDATE/VERSIONS/item_"+next_index as String) type:"version"
		local current_date = (mcDate.current()).toStringSimple()
		if debug do format "mcUpdater > uploadMicra > last_index:% next_index:% current_date:% oldest_version:%\n" last_index next_index current_date oldest_version
		local node_attribs = (mcObject.new()).addMore #(

			mcItem "version" new_version, 
			mcItem "date" current_date
		)
		mcFile.saveSettings local_xml ("UPDATE/VERSIONS/item_"+next_index as string) node_attribs type:"attribs" --override version at next index 
		mcFile.saveSettings local_xml "UPDATE/VERSIONS" new_version type:"latest" --set new version as latest
		--pack micra in to zip file with version
		local excluded_folders_and_files = #("old", "Orien_Star", "rene.baca", "Temp", "_New") --for now, later will be optimalized
		mcZip.zip Micra.RootDir (local_dir+"Micra4_v"+new_version+".zip") override:true exclude:excluded_folders_and_files
		--delete oldest zip version to keep max 8 backups
		local oldest_zip_file = local_dir+"Micra4_v"+oldest_version+".zip"
		if debug do format "mcUpdater > uploadMicra > deleting oldest backup:%\n" oldest_zip_file
		if doesFileExist oldest_zip_file do deleteFile oldest_zip_file
		--final msg
		messageBox ("Micra is upgraded from  [ v"+local_version+" ] to  [ v"+new_version+" ]\nTo complete upgrade commit files on Github :-)") title:micra.version
	),
	fn downloadMicra version = ( --download Micra.zip to Micra/User directory
		
		local fname = "Micra4_"+version+".zip"
		local source_url = server_dir+fname
		local local_file  = user_dir+"Micra.zip"
		download source_url local_file --continue at > downloadCompleted  
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
			local accepted = false
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
				local xml_str = mcNet.readFile server_xml
				format "getMicraVersion > xml_str:%\n" xml_str
				if xml_str == undefined do (

					format "mcUpdater > getMicraVersion > Unable to Read:[ % ]\n" server_xml
					return false
				)
				xml.fromString xml_str

				local versions_node = xml.getNode "//UPDATE/VERSIONS"
				local server_version = versions_node.getAttribute "latest"
				local all_versions = versions_node.getChildrenNames()
				if debug do format "mcUpdater > getMicraVersion > versions compare > LOCAL:% SERVER:%\n" local_version server_version
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
		chossen_version = mcUpdateMicraDialog.getSlectedVersion()
		if debug do format "mcUpdater > getMicraVersion > Selected version:%\n" chossen_version
		downloadMicra chossen_version
	),
	fn sendMicraVersion = (
	
		local typed_text = mcPopup.textBox title:"Type Password:" crypt:true
		if typed_text == undefined or typed_text != "orien" do return false
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


/*
TODO > COMMIT TO GITHUB maybe????
*/