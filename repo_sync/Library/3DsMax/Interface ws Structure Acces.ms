		fn showMenu lbl = --"Show RC Menu"
		(
			fun.selectedLbl = lbl
			print (classof fun.selectedLbl)
			rcMenu thumbMenu
			(
				local lbl = ""
				menuItem new_1 "Add To Scene..."
				separator file_menu_1
				menuItem new_2 "Rename ..."
				menuItem new_3 "Delete..."
				on thumbMenu open do lbl = fun.selectedLbl.text
				on new_1 picked   do format "Add To Scene... %\n" lbl --mergeModels()
				on new_2 picked   do format "Rename... %\n" lbl
				on new_3 picked   do format "Delete... %\n" lbl -- deleteFromGallery()
			)
			PopupMenu thumbMenu
		)