(
 	local macro = "$userMacros\\UVW Unwrap-straightenUVstrip.mcr"
 	if doesFileExist macro do 
 	(
 		fileIn macro
 
		if (theMenu = menuMan.findMenu "UVW Unwrap - UVW Mapping") != undefined do
 		(
 			local num = theMenu.numItems()
 			local noItem = true
 			local theTitle = "Straighten UV Strip..."
 			
 			for i = 1 to num while noItem do noItem = ((theMenu.getItem i).getTitle() != theTitle)
 					
 			if noItem do
 			(
 				if not (theMenu.getItem num).getIsSeparator() do
 				(
 					local theSep = menuMan.createSeparatorItem()
 					theMenu.addItem theSep -1
 				)
 				local theItem = menuMan.createActionItem "straightenUVstrip" "UVW Unwrap"
 				theItem.setTitle theTitle
 				theItem.setUseCustomTitle true
 				theMenu.addItem theItem -1
 				menuMan.updateMenuBar()
 			)
 		)
 	)
 )
