Global gallery_path = (getFilenamePath (getThisScriptFilename())) 
Global user_scripts = pathConfig.GetDir #userScripts
Global gallery_ini    = user_scripts + "\\3DGallery.ini"
setIniSetting gallery_ini "Directories" "Root Dir" gallery_path

/* Macro */
MacroScript GalleryRun
category:"3DGallery"
tooltip:"Open 3DGallery"
(
	local user_scripts = pathConfig.GetDir #userScripts
	local gallery_ini    = user_scripts + "\\3DGallery.ini"
	local gallery_file = (getIniSetting gallery_ini "Directories" "Root Dir") + "3DGallery_v1.60.ms"
	if doesFileExist gallery_file then
	(
		fileIn gallery_file 
	) else (
		messagebox ("3DGallery is not found at:"+gallery_file) title:" 3DGallery"
	)
)

/*Menu*/
fn create3DGalleryMenu = (
	local theMainMenu, theMenu, theSubMenu, theAction  
	theMenu = menuMan.findMenu "3DGallery"
	if (theMenu == undefined) then (
		
		format "create 3DGallery menu\n"
		theMainMenu = menuMan.getMainMenuBar() --get the main menu bar
		theMenu = menuMan.createMenu "3DGallery" --create a menu called 3DGallery
		theSubMenu = menuMan.createSubMenuItem "Open..." theMenu --create a SubMenuItem
		theMainMenu.addItem theSubMenu (theMainMenu.numItems()+1) --add the SubMenu to the Main Menu
		-- creates a menu item that execute the macroscript "3DGalleryRun" category = "3DGallery"
		theAction = menuMan.createActionItem "GalleryRun" "3DGallery" --create an ActionItem from the MacroScript
		theMenu.addItem theAction (theMenu.numItems()+1) --add the ActionItem to the menu
		menuMan.updateMenuBar() --update the menu bar 
	) else (
		format "Menu 3DGallery already exists"
	)
)
create3DGalleryMenu()
