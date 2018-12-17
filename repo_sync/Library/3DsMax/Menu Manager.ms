Menu Manager 

menuMan.loadMenuFile "file.mnu" 

This loads a new menu file with the given name. It looks in the current "UI" directory for the file. It return true if successful, and false if not. 

menuMan.saveMenuFile "file.mnu" 

This saves a new menu file with the given name. It saves it in the current "UI" directory. 

menuMan.getMenuFile() 

Returns the full path to the current menu file. 

menuMan.updateMenuBar() 

This updates the main menu bar with any changes that have been made. This MUST be called after changing anything on the main menu bar. 

menuMan.registerMenuContext contextId 

This call is used to register menu extensions. The "contextId" is a random 32-bit integer. It can be generated using the "genclassid()". This function registers an extension with the menu manager that is remembered permanently. It returns true the first time the extension is registered, and false every time thereafter. This is saved in the MaxMenu.mnu file, so it is sticky from session to session. This is used so that scripts can add items and sub-menus MAX's main menu bar and quad menus. See the sample scripts below for the proper usage. 

menuMan.findMenu "menuName" 

This function returns the menu with the given name. It returns "undefined" if no menu exists in the menu manager with the given name. This requires the full name of the menu, including and "&" characters that might be in the name. 

Example: 

helpMenu = menuMan.findMenu "&Help" 

Retrieve 3ds max’s help menu. 

menuMan.findQuadMenu "quadMenuName" 

This method works like "findMenu" but it gets quad menus instead of menus. 

menuMan.unRegisterMenu menu 

This method removes a menu from the menu manager. 

Warning: Use extreme caution when using this method! If you unregister a menu that is used as a sub-menu, or in a quad menu, or the main menu bar, you will corrupt your 3ds max installation. 

menuMan.unRegisterQuadMenu quadMenu 

This method works like "unregisterMenu" but for quad menus. 

menuMan.createMenu "name" 

This method creates a new, empty menu with the given name. 

menuMan.createQuadMenu "name" "quad1Name" "quad2Name" "quad3Name" "quad4Name" 

This method creates a new, empty quad menu. It contains, 4 empty menus, one for each quad. 

menuMan.createSubMenuItem "name" subMenu 

This method creates a new sub-menu item that can be added to a menu. It uses the given "name" and it displays the given sub-menu. 

menuMan.createSeparatorItem() 

This method creates a new menu separator that can be added to a menu. 

menuMan.createActionItem "macroScriptName" "macroScriptCategory" 

This method creates a new menu item that can be added to a menu. The item is an action that executes the macro script with the given name and category. This returns "undefined" if there is no macroScript with the given name and category. 

menuMan.setViewportRightClickMenu which quadMenu 

This method sets the viewport right click menu to be the given quad menu. The value of "which" can be one of the following: 

#nonePressed 

#shiftPressed 

#altPressed 

#controlPressed 

#shiftAndAltPressed 

#shiftAndControlPressed 

#controlAndAltPressed 

#shiftAndAltAndControlPressed 

The following example sets the default (no keys pressed) quad menu the "Modeling 2". The menu name must be a quad menu that is listed in the "Quads" customization dialog, and the name must match exactly, including capitalization. menuMan.SetViewportRightClickMenu returns FALSE if you try to set the viewport right-click menu to a menu that is not allowed. 

Example: 

menuMan.setViewportRightClickMenu #nonePressed "Modeling 2" 

menuMan.getViewportRightClickMenu which 

Retrieves the quad menu used for right-clicking in the viewport. The "which" parameter can be one of the following: 

#nonePressed 

#shiftPressed 

#altPressed 

#controlPressed 

#shiftAndAltPressed 

#shiftAndControlPressed 

#controlAndAltPressed 

#shiftAndAltAndControlPressed 

menuMan.getMainMenuBar() 

Returns the menu being used as MAX's main menu bar. 

menuMan.setMainMenuBar menu 

Sets the menu being used as MAX's main menu bar. You must call "menuMan.updateMenuBar()" in order to see the result. 

menuMan.getShowAllQuads quadMenu 

Gets the "show all quads" setting for the given quad menu. 

menuMan.setShowAllQuads quadMenu value 

This sets the "show all quads" flag for the given quad menu. "value" can be true or false. 

menuMan.getQuadMenuName quadMenu 

This returns the name of the given quad menu. 

menuMan.setQuadMenuName quadMenu "name" 

This sets the name of the give quad menu. 

menuMan.numMenus() 

Returns the total number of menus in registered with the menu manager. 

menuMan.getMenu index 

Retrieves the "index"th menu in the menu manager. This is a 1-based index. 

menuMan.numQuadMenus() 

Returns the total number of quad menus registered with the menu manager. 

menuMan.getQuadMenu index 

Retrieves the "index"th quad menu in the menu manager. This is a 1-based index. 

