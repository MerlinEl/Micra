
-- macroScript Layer_Manager_RCMenu category:"REZN8 Tools" tooltip:"Layer_Manager_RCMenu"
(
		global LayerRCMenu
		Function MakeRCMenu =
		(	
			if selection.count == 0 or LM == undefined do return false
			Local GroupNames=#()
			Local GroupIndx = #()
			Local GroupIDs=#()
			Local ObjIds = #()
			--get the group names and the index numbers
			for L = 1 to LM.Layers.count do
			(
				if LM.Layers[L].isGroupHead == false then
				(
					append GroupNames LM.Layers[L].LayerName
					append GroupIndx L
					append GroupIDs LM.Layers[L].ID
				)

			)
			for o in selection do 
			(
				local info = (getappdata o 9901)
				if info == undefined then append ObjIds LM.Layers[1].ID
				else append ObjIds (info as integer)
			)
			
			--build a select string
			Local Select_Str = ""
			for i in ObjIds do
			(
				local info = finditem GroupIDs i
				Select_Str += ("selectmore (LM.GetLayerObjects " + info as string +" ) \n")
			)
			
			rci = RCMenuCreator "LayerRCMenu" 
			rci.begin()
			rci.addMenuItem #addSelToLay "Make New Layer From Selected"
			rci.addHandler #addSelToLay #picked codeStr:"LM.AddNewLayer();LM.AddObjectsToLayer LM.Layers.count ($Selection as array);destroyDialog LM_Roll;LM.UI.MakeRollout();CreateDialog LM_NewLayerRoll modal:true"
			rci.addMenuItem #selectLay "Select Layer"
			rci.addHandler #selectLay #picked codeStr:("DisableSceneRedraw();"+Select_Str+";EnableSceneRedraw()")
			rci.addSeperator #sep1
			for L = 1 to GroupNames.count do
			(
				--menu item
				if (finditem ObjIds GroupIds[L]) > 0 then Str = "checked: true"
				else Str = "checked:false"
				rci.addMenuItem (("miGrp"+L as string)as name)  (GroupNames[L] as name) paramStr:Str
				--menu item picked
				rci.addHandler (("miGrp"+L as string)as name) #picked codeStr:("LM.AddObjectsToLayer "+GroupIndx[L] as string +" ($Selection as array)")
			)
			rci.end()
			print rci.def
		)
		
		MakeRCMenu()
		if LayerRCMenu != undefined do PopupMenu LayerRCMenu
)
