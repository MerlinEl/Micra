------------------------------------------------------------------------------
-- LS3DSmartExport.ms
--
-- Illusion Softworks
-- http://www.illusionsoftworks.com
-- Copyright (c) 2004-2011 Illusion Softworks. All Rights Reserved
--
-- By Vladimir Zadrazil, Jiri Bicik, Jan Benes
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- CHANGES
------------------------------------------------------------------------------
-- fn getExportPath()
-- fn getModelPathFromProps()
-- fn browseForModelPath()
-- uprava dialogu aby byl schopen zaznamenat zmenu cesty provedenou primo na exportni node a aby do ni byl schopen sam zapat zmenu provedenou v dialogu
-- nahrazeni AxctiveX za .NET pro 64bit maxe
-- fix bugu #771
-- pridan ls3dSmartExport_debug parametr pro zakomentovani vsech debug vypisu

------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- TODO
------------------------------------------------------------------------------
-- kontrola prejmenovani modelu
-- kontrola existenece exportovaci cesty
-- smazani dat pro neexistujici model
-- pridani cesty pro xda

------------------------------------------------------------------------------
-- GLOBALS
------------------------------------------------------------------------------

global ls3dSmartExport_debug = false

global LS3DSmartExportVersion
global gLS3DSmartExport		= undefined
global gLS3DSmartExportUI	= undefined
global LS3DSmartExportSystemEvents = dotNetClass "Microsoft.Win32.SystemEvents"

------------------------------------------------------------------------------
-- DIALOG
------------------------------------------------------------------------------

rollout dlgLS3DSmartExport "" width:700
(
	local iniFile			= (LS3DGUP.LS3DGUP.UtilsPath + "\\LS3DSmartExport.ini")
	local iniSection		= "General"
	
	-- locals
	local mousePos			= [0,0]
	local profiles			= #()
	local itemTmp			= undefined
	local activeProfile
	
	local listWidth			= 700
	local listHeight		= 17 + 17 * 10
	local nameWidth			= 125
	local profileWidth		= 125
	local extColWidth		= 125
	local pathWidth			= listWidth - nameWidth - profileWidth - extColWidth - 17
	
	local minDlgSize 		= [684, 197]
	
	local normalForeColor	= (dotNetClass "System.Drawing.Color").Black
	local errorForeColor	= (dotNetClass "System.Drawing.Color").Blue
--	local errorForeColor	= color 0 0 255

	-- UI definition
	dotNetControl dnListView "System.Windows.Forms.ListView"  pos:[0,0] width:listWidth height:listHeight
--	activeXControl	dnListView	"MSComctlLib.ListViewCtrl" pos:[0,0] width:listWidth height:listHeight
	checkbox		chkCheckAll	"Check/Uncheck All"
	button			btnConfig	"Configure Profiles" width:100 align:#left across:5
	label			lblProfile	"" width:200 offset:[-10,4] align:#left
	button			btnCheckSel	"Check Selected" width:100 align:#right
	button			btnExport	"EXPORT" width:100 align:#right
	button			btnClose	"Close" width:100 align:#right
	
	-- methods
	fn initListView lv =
	(
		LV_FIRST			= 0x1000
		LV_SETCOLUMNWIDTH	= (LV_FIRST + 30) 

		lv.gridLines		= true  
--		lv.View				= #lvwReport  
		lv.View				= (dotNetClass "System.Windows.Forms.View").Details  
		lv.fullRowSelect	= true 
		lv.checkboxes		= true
--		lv.Appearance		= #ccFlat -- #cc3D
--		lv.BorderStyle		= #ccNone -- #ccFixedSingle )
		lv.BorderStyle		= (dotNetClass "System.Windows.Forms.BorderStyle").None
		lv.LabelWrap		= true
--		lv.FlatScrollBar	= true
--		lv.backColor		= color 225 215 210
--		lv.Sorted			= true
		lv.Sorting		= (dotNetClass "System.Windows.Forms.SortOrder").Ascending
--		lv.LabelEdit		= #lvwManual --#lvwAutomatic
		lv.LabelEdit		= true
		lv.HotTracking		= true
		
		layoutDef = #(#("Model Name", nameWidth), #("Export Profile", profileWidth), #("Path", pathWidth), #("External Collisions", extColWidth))
		
		for i in layoutDef do
		(
			lv.Columns.add i[1] i[2]
		)
			
/*		for n = 1 to layoutDef.count do
		(
			
			column = lv.ColumnHeaders.add() 
			column.text = layoutDef[n][1]

			windows.sendMessage lv.hwnd LV_SETCOLUMNWIDTH (n-1) layoutDef[n][2]
		) 
*/
	) 
	
	fn updateColUI item =
	(
		local node = getnodebyname item.Subitems.Item[0].Text
		local colSubItem = item.Subitems.Item[3]
		local curFont = colSubItem.Font
		if(node.GenerateCollisions) then
		(
			colSubItem.Text = node.OutputName as String
			--colSubItem.Font	= dotNetObject  "System.Drawing.Font" curFont (curFont.Style.Underline)
			--colSubItem.Font = colSubItem.Font.Style.Underline
		)
		else
		(
			colSubItem.Text = "-"
			--colSubItem.Font	= dotNetObject  "System.Drawing.Font" curFont (curFont.Style.Regular)
			--colSubItem.Font = colSubItem.Font.Style.Regular
		)
	)

	fn addItem node =
	(
		path = hint = gLS3DSmartExport.getModelPathFromProps node.name
		profileID	= gLS3DSmartExport.getModelProfileFromProps node.name
		foreColor	= normalForeColor
		bold		= false
		profile		= ""
		
		if (path == "") then
		(	-- say we have no path specified
			foreColor	= errorForeColor
			bold		= true
			path		= "== no path specified =="
			hint		= "Double click to browse ..."
		)
		else
		(	-- append this path to the array
			gLS3DSmartExport.addLastPath path
		)
		
		if (profileID < 0) then
			profile = activeProfile + " [active]"
		else
			profile = profiles[profileID + 1]
		
		-- add model name
		listItem			= dnListView.Items.add(node.name)
		listItem.checked	= gLS3DSmartExport.getCanExportFromProps node.name
		listItem.foreColor	= foreColor
--		listItem.font.bold		= bold
		listItem.tag		= node.handle
--		listItem.text		= node.name
--		listItem.ToolTipText = listItem.text
		
		-- add profile name
		subItem				= listItem.SubItems.add(profile)
		subItem.ForeColor	= normalForeColor
--		subItem.font.Bold		= false
--		subItem.text		= profile
--		subItem.ToolTipText	= profile

		-- add path
		subItem				= listItem.SubItems.add(path)
		subItem.ForeColor	= foreColor
--		subItem.font.Bold		= bold
--		subItem.text		= path
--		subItem.ToolTipText	= hint

		-- add ext col
		subItem				= listItem.SubItems.add("-")
		updateColUI listItem
	)
	
	fn fillItems =
	(
--		dnListView.ListItems.Clear()
		dnListView.Items.Clear()
		
		local sel = $helpers
		for n in sel do
			if (classof n) == LS3DModel do
				addItem n
	)
	
	fn getExportProfiles =
	(
		local current	= LS3DGUP.XDSExporter.GetSelectedProfile()
		local count		= LS3DGUP.XDSExporter.GetProfileCount()
		local name

		-- clear old data
		profiles = #()

 		-- collect profiles		
		for n = 0 to count - 1 do 
		(
			LS3DGUP.XDSExporter.SelectProfile n
			name = ((n as string) + ": " + LS3DGUP.XDSExporter.ProfileName)
			if (n == current) do
				activeProfile = name
			append profiles name
		)
		
		-- select old profile
		LS3DGUP.XDSExporter.SelectProfile current
	)

	fn getExportPath =
	(
		if itemTmp == undefined do return OK

		-- get new path from props
		local path = gLS3DSmartExport.getModelPathFromProps itemTmp.Item.SubItems.Item[0].Text
		
		-- no path was specified
		if (path == "") do
		(
			itemTmp = undefined
			return OK
		)

		-- update item text
		--itemTmp.foreColor	= normalForeColor
		--itemTmp.bold		= false
		itemTmp.Item.SubItems.Item[2].Text		= path
		--itemTmp.ListSubItems[2].ToolTipText	= path
		--itemTmp.ListSubItems[2].ForeColor	= normalForeColor
		--itemTmp.ListSubItems[2].Bold		= false
	
		itemTmp = undefined
	)
	
	fn createRmcMenuName listViewHitTestInfo =
	(
		-- get mouse pos
		local pos = mouse.screenpos
		
		-- create rmc menu code
		str  = "rcmenu rcmXDSExportName\n"
		str += "(\n"
		str += "  fn selectNode =\n"
		str += "  (\n"
		str += "   obj = getnodebyname \"" + listViewHitTestInfo.Item.Subitems.Item[0].Text + "\"\n"
		str += "   select obj\n"
		
		--str += "    select (maxOps.getNodeByHandle " + (listViewHitTestInfo.tag as string) + ")\n"
		str += "  )\n"
		str += "\n"

		-- add menu items
		str += "  menuItem 'Select' \"Select\"\n"
		str += "  on 'Select' picked do selectNode()\n"

		-- add rest of code
		str += "\n"
		str += "  on rcmXDSExportName open do\n"
		str += "  (\n"
		str += "  )\n"
		str += ")\n"
		str += "\n"
		str += "popUpMenu rcmXDSExportName pos:" + pos as string + "\n"

		execute str		
	)
	
	fn createRmcMenuProfile listViewHitTestInfo =
	(
		if (ls3dSmartExport_debug == true) then format "createRmcMenuProfile \n =========================\n"
		if (ls3dSmartExport_debug == true) then showproperties listViewHitTestInfo
	
		-- get mouse pos
		local pos = mouse.screenpos
		
		-- save this listViewHitTestInfo temporary
		itemTmp = listViewHitTestInfo
		
		if (listViewHitTestInfo.Item == undefined) then 
		(
			format "createRmcMenuProfile.item undefined param !!!\n"
			return 0
		)
		
		-- create rmc menu code
		str  = "rcmenu rcmXDSExportProfiles\n"
		str += "(\n"
		str += "  fn setProfile profileID =\n"
		str += "  (\n"
		str += "    gLS3DSmartExport.setModelProfileFromProps \"" + listViewHitTestInfo.Item.SubItems.Item[0].Text + "\" profileID\n"
		str += "    dlgLS3DSmartExport.updateProfileName \"" + listViewHitTestInfo.Item.SubItems.Item[0].Text + "\"\n"
		str += "  )\n"
		str += "\n"

		-- add menu items		
/*		removal of Active profile from UI
		str += "  menuItem 'Active Profile' \"Active Profile\"\n"
		str += "  on 'Active Profile' picked do setProfile -1\n"
		str += "  separator spr01\n"
/**/
		for n = 1 to profiles.count do
		(
			if (findString profiles[n] "???" != undefined) do continue
			str += "  menuItem '" + profiles[n] + "' \"" + profiles[n] + "\"\n"
			str += "  on '" + profiles[n] + "' picked do setProfile " + ((n - 1) as string) + "\n"
		)
		
		-- add rest of code
		str += "\n"
		str += "  on rcmXDSExportProfiles open do\n"
		str += "  (\n"
		str += "  )\n"
		str += ")\n"
		str += "\n"
		str += "popUpMenu rcmXDSExportProfiles pos:" + pos as string + "\n"
		
--		if (ls3dSmartExport_debug == true) then format str
		execute str
	)
	
	fn doubleSlashes myPath =
	(
		count = myPath.count - 1
		added = false
		for index = 1 to count do
		(
			if (not added) then
			(
				if (myPath[index] == "\\") then
				(
					if (myPath[index + 1] != "\\") then
					(
						part1 = substring myPath 1 index
						part2 = substring myPath (index+1) -1
						newPath = part1 + "\\"
						newPath = newPath + part2
						myPath = newPath
						added = true				-- tohle skipne dalsi index
						count = count + 1
					)
				)
			) else added = false		
		)
		-- jeste specialne vyresim posledni dvojici lomitek
		if (myPath[myPath.count] == "\\") then
		(
			if (myPath[myPath.count - 1] != "\\") then
			(
				myPath = myPath + "\\"
			)
		)		
		return myPath
	)
	
	fn createRmcMenuPath listViewHitTestInfo =
	(
		if (ls3dSmartExport_debug == true) then format "createRmcMenuPath listViewHitTestInfo % \n" listViewHitTestInfo
		-- get mouse pos
		local pos = mouse.screenpos
		
		-- save this listViewHitTestInfo temporary
		itemTmp = listViewHitTestInfo
		if (ls3dSmartExport_debug == true) then showproperties listViewHitTestInfo

		-- create rmc menu code
		str  = "rcmenu rcmXDSExportPath\n"
		str += "(\n"
		str += "  fn browse =\n"
		str += "  (\n"
		str += "    gLS3DSmartExport.browseForModelPath \"" + listViewHitTestInfo.Item.SubItems.Item[0].Text + "\"\n"
		str += "    dlgLS3DSmartExport.getExportPath()\n"
		str += "  )\n"
		str += "  fn setPath path =\n"
		str += "  (\n"
		str += "    gLS3DSmartExport.setModelExportPath \"" + listViewHitTestInfo.Item.SubItems.Item[0].Text + "\" path\n"
		str += "    dlgLS3DSmartExport.getExportPath()\n"
		str += "  )\n"
		str += "\n"

		-- add menu items
		str += "  menuItem 'Browse ...' \"Browse ...\"\n"
		str += "  on 'Browse ...' picked do browse()\n"
		str += "  separator spr01\n"
		for n = 1 to gLS3DSmartExport.lastPaths.count do
			if gLS3DSmartExport.lastPaths[n] != "" do
			(
				myPath = gLS3DSmartExport.lastPaths[n]
				myPath = doubleSlashes myPath
				if (ls3dSmartExport_debug == true) then format "myPath after change >> %" myPath
				str += "  menuItem '" + n as string + "' \"" + n as string + ". " + myPath + "\"\n"
				str += "  on '" + n as string + "' picked do setPath \"" + myPath + "\"\n"
			)
		
		-- add rest of code
		str += "\n"
		str += "  on rcmXDSExportPath open do\n"
		str += "  (\n"
		str += "  )\n"
		str += ")\n"
		str += "\n"
		str += "popUpMenu rcmXDSExportPath pos:" + pos as string + "\n"
			
		if (ls3dSmartExport_debug == true) then print str
		execute str		
	)
	
	fn updateProfileName modelName =
	(
		if itemTmp == undefined do return OK
		
		-- get profile info
		local ext = ""
		local profileID = gLS3DSmartExport.getModelProfileFromProps modelName
		
		-- get current active profile if needed
		if (profileID < 0) do
		(
			profileID = LS3DGUP.XDSExporter.GetSelectedProfile()
			ext = " [active]"
		)
		
		-- set profile text
		itemTmp.Item.Subitems.Item[1].Text		= profiles[profileID + 1] + ext
		--itemTmp.ListSubItems[1].ToolTipText	= profiles[profileID + 1] + ext
		
		itemTmp = undefined
	)
	
	fn hitTest left right =
	(
		if mousePos.x >= left and mousePos.x <= right do
			return true
			
		return false
	)
	
	fn getSubItem item =
	(
		multi = 26
		if (ls3dSmartExport_debug == true) then format "GetSubItem mouse pos %\n" mousePos.x 
		
		
		nameLeft	 = dnListView.Left
		nameRight	 = nameLeft + dnListView.Columns.Item[0].Width
		profileLeft	 = nameRight
		profileRight = profileLeft + dnListView.Columns.Item[1].Width
		pathLeft	 = profileRight
		pathRight	 = pathLeft + dnListView.Columns.Item[2].Width
		colLeft	 = pathRight
		colRight	 = colLeft + dnListView.Columns.Item[3].Width

		if (ls3dSmartExport_debug == true) then format "nameLeft %     profileleft %    pathLeft %    colLeft %\n" nameLeft ProfileLeft pathLeft colLeft
		
		if hitTest nameLeft nameRight == true then
			return #name
		else
		if hitTest profileLeft profileRight == true then
			return #profile
		else
		if hitTest pathLeft pathRight == true then
			return #path
		else
		if hitTest colLeft colRight == true then
			return #col
	)
	
	fn updateCheckBoxSelect =
	(
		count	= dnListView.Items.count
		checked	= 0
		
--		for item in dnListView.ListItems do
		--if (ls3dSmartExport_debug == true) then format "Items in list: %\n" count as string
		
--		for item in dnListView.Items do
		if count > 0 then
		(	
			for i = 1 to count do
			(
--				item = dnListView.Items.Item[i]
				if dnListView.Items.Item[i - 1].checked == true do --indexing from 0 or 1?
				(
					checked += 1
				)
			)
		)
		
		if (checked == count) then
			chkCheckAll.tristate = 1
		else
		if (checked == 0) then
			chkCheckAll.tristate = 0
		else
			chkCheckAll.tristate = 2
	)
	
	fn updateUI =
	(
		if (LS3DGUP == undefined) do return()
		
		-- display revision number
		local version = if (LS3DSmartExportVersion == undefined) then 0.0 else LS3DSmartExportVersion
		dlgLS3DSmartExport.title = "LS3D Smart Export Options [" + LS3DGUP.GetRevision() as string + "] v" + version as string
		
		-- display active profile
		lblProfile.text = "Active: " + ((LS3DGUP.XDSExporter.GetSelectedProfile() as string) + ": " + LS3DGUP.XDSExporter.ProfileName)
		
		-- collect profiles
		getExportProfiles()
		
		-- fill list view
		fillItems()
		
		-- update selection checker
		updateCheckBoxSelect()
	)
	
	fn ondnListViewDblClick =
	(
		if (ls3dSmartExport_debug == true) then format "ondnListViewDblClick pos %  %" mousePos.x mousePos.y
		
		listViewHitTestInfo = dnListView.HitTest (mousePos.x) (mousePos.y)
		if (listViewHitTestInfo == undefined) do return OK
		
		subItemName = getSubItem listViewHitTestInfo
		
		case subItemName of
		(
			#name : -- select model
			(				
				obj = getnodebyname  listViewHitTestInfo.Item.Subitems.Item[0].Text
				select obj
			)
			#profile :
			(	
				gLS3DSmartExport.setModelProfileFromProps listViewHitTestInfo.Item.Subitems.Item[1].Text -1
				itemTmp = listViewHitTestInfo
				updateProfileName listViewHitTestInfo.Item.Subitems.Item[1].Text
			)
			#path: -- set export path
			(	
				itemTmp = listViewHitTestInfo
				
				if (ls3dSmartExport_debug == true) then showproperties listViewHitTestInfo
				item = listViewHitTestInfo.Item
				
				if item == undefined then
				(
					format "Nothing selected \n"
					return true
				)
				
				if (ls3dSmartExport_debug == true) then showproperties item
				
				
				gLS3DSmartExport.browseForModelPath listViewHitTestInfo.Item.Subitems.Item[0].Text
				getExportPath()
			)
		)
		
		-- clear mouse data
		mousePos 	= [0,0]
		mouseButton = 0
	)
	
	-- handler methods
	fn ondnListViewMouseDown val =
	(
		--if (ls3dSmartExport_debug == true) then format "in mousedown handler: arg: %\n" val
		--if (ls3dSmartExport_debug == true) then format "showproperties:\n"
		--if (ls3dSmartExport_debug == true) then showproperties val
	 	
		mousePos	= [val.X, val.Y]
		mouseButton = val.Button
		
		button = val.Button
		x = val.X
		y = val.Y
		if (ls3dSmartExport_debug == true) then format "ondnListViewMouseDown: button % x % y % \n" button x y
	)
		
	fn enableCol listViewHitTestInfo =
	(
		local node = getnodebyname listViewHitTestInfo.Item.Subitems.Item[0].Text
		node.GenerateCollisions = not node.GenerateCollisions
		updateColUI listViewHitTestInfo.Item
	)
	
	fn selectCol listViewHitTestInfo =
	(
		local name = getnodebyname listViewHitTestInfo.Item.Subitems.Item[0].Text
		select name
	)
	
	fn onDlgResize size =
	(
		if size.x < minDlgSize.x then size.x = minDlgSize.x
		if size.y < minDlgSize.y then size.y = minDlgSize.y
		dlgLS3DSmartExport.width = size.x
		dlgLS3DSmartExport.height = size.y
		dnListView.width = size.x - 0
		dnListView.height = size.y - 51
		chkCheckAll.pos.y = size.y - 46
		btnConfig.pos.y = size.y - 26
		lblProfile.pos.y = size.y - 22
		btnCheckSel.pos.y = size.y - 26
		btnClose.pos.y = size.y - 26
		btnExport.pos.y = size.y - 26
		--format "New size: %\n" size
	)	
	
	fn loadSettings =
	(
		local width = execute(getINISetting iniFile iniSection "width")
		if width == OK then width = 800
		local height = execute(getINISetting iniFile iniSection "height")
		if height == OK then height = 150
		local size = [width, height]
		onDlgResize size

		for i = 0 to (dnListView.Columns.Count - 1) do
		(
			local propertyName = "column_" + (i as string)
			local columnWidth = execute(getINISetting iniFile iniSection propertyName)
			if columnWidth == OK then
			(
				columnWidth = 125
				if i == 1 then columnWidth = 170
				if i == 2 then columnWidth = 360
			)
			dnListView.Columns.Item[i].width = columnWidth
			--format "Comun index: %, New width: %\n" i dnListView.Columns.Item[i].width
		)
	)
	
	fn saveSettings =
	(
		setINISetting iniFile iniSection "width" (dlgLS3DSmartExport.width as string)
		setINISetting iniFile iniSection "height" (dlgLS3DSmartExport.height as string)
		--format "count = %\n" dnListView.Columns.Count
		for i = 0 to (dnListView.Columns.Count - 1) do
		(
			local propertyName = "column_" + (i as string)
			setINISetting iniFile iniSection propertyName (dnListView.Columns.Item[i].width as string)
			--format "Comun index: %, Width: %\n" i dnListView.Columns.Item[i].width
		)
	)
	
	fn ondnListViewMouseUp val =
	(
		buttonValue = val.Button.value__
		x = val.X
		y = val.Y
		
		if (ls3dSmartExport_debug == true) then format "ondnListViewMouseUp: button.value__ % x % y % \n" buttonValue x y
		--if (ls3dSmartExport_debug == true) then showproperties val.Button
		
		mousePos = [x,y]
		item = dnListView.HitTest (mousePos.x) (mousePos.y)
		if (item == undefined) do return OK
		if (item.Item == undefined) do return OK
			
		subItemName = getSubItem item
		if (ls3dSmartExport_debug == true) then format "subitemname % \n" subItemName
		
		case subItemName of
		(
			#name :
			(
				if (buttonValue == val.Button.Right.value__) then
				(
					createRmcMenuName item
				)
			)
			#profile : -- set export profile
			(	
				if (buttonValue == val.Button.Right.value__) then
				(
					createRmcMenuProfile item
				)
			)
			#path: -- set export path
			(	
				if (buttonValue == val.Button.Left.value__) then
				(			
					ondnListViewDblClick()
				)
				else
				(
					if (buttonValue == val.Button.Right.value__) then
					(			
						createRmcMenuPath item
					)				
				)
				--createRmcMenuPath item
			)
			#col :
			(
				if (buttonValue == val.Button.Left.value__) then
				(
					enableCol item
				)
				else if (buttonValue == val.Button.Right.value__) then
				(
					selectCol item
				)
			)
		)
		
		-- clear mouse data
		mousePos 	= [0,0]
		mouseButton = 0
	)

	fn ondnListViewItemCheck itemCheckEventArgs  updateChecker:true =
	(
		local checked = (itemCheckEventArgs.NewValue.value__ == (dotNetClass "System.Windows.Forms.CheckState").Checked.value__)
		gLS3DSmartExport.setCanExportToProps dnListView.Items.Item[itemCheckEventArgs.Index].SubItems.Item[0].Text checked
				
		if (updateChecker == true) do
			updateCheckBoxSelect ()
	)
	
	fn ondnListViewItemCheckExt index checked updateChecker:true =
	(
		gLS3DSmartExport.setCanExportToProps dnListView.Items.Item[index].SubItems.Item[0].Text checked
				
		if (updateChecker == true) do
			updateCheckBoxSelect ()
	)
	
	fn onChkCheckAllChecked state =
	(
--		for item in dnListView.ListItems do
		if dnListView.Items.count > 0 then
		(
			--for item in dnListView.Items do
			--(
			--	item.checked = state
			--	ondnListViewItemCheck item updateChecker:false
			--)

			--for item in dnListView.ListItems do
			--(
			--	if (item.text != n.name) do continue				
			--	item.checked = true
			--	ondnListViewItemCheck item updateChecker:false
			--)			
			
			for i = 1 to dnListView.Items.count do
			(
				if (ls3dSmartExport_debug == true) then format "Checked: % to %\n" dnListView.Items.Item[i - 1].SubItems.Item[0].Text state
				dnListView.Items.Item[i - 1].checked = state --indexing from 0 or 1?
				ondnListViewItemCheckExt (i - 1) state updateChecker:true
			)
		)
	)
	
	fn onBtnConfigPressed =
	(
		-- run export profiles config
		macros.run "LS3D Engine" "LS3DExportProfilesDialog"
		updateUI()
	)
	
	fn onBtnCheckSelPressed =
	(
		local sel	= selection as array
		local names	= #()
	
		onChkCheckAllChecked false
	
		-- browse for all paths
		for n in sel do
		(
			if (classof n) != LS3DModel do continue
			
			for i = 1 to dnListView.Items.count do
			(
				if (dnListView.Items.Item[i - 1].SubItems.Item[0].Text != n.name) do continue
				
				dnListView.Items.Item[i - 1].checked = true --indexing from 0 or 1?
				ondnListViewItemCheckExt (i - 1) true updateChecker:true
			)
			
			--for item in dnListView.ListItems do
			--(
			--	if (item.text != n.name) do continue
			--	item.checked = true
			--	ondnListViewItemCheck item updateChecker:false
			--)
		)
		
		updateCheckBoxSelect()
	)
	
	fn onBtnExportPressed =
	(
		-- close dialog
		btnClose.pressed()
		-- export scene
		gLS3DSmartExport.exportScene()
	)
	
	fn onBtnClosePressed =
	(
		saveSettings()
		destroyDialog dlgLS3DSmartExport
	)
	
	fn onDlgLS3DSmartExportOpen =
	(
		-- init and fill list view
		initListView dnListView

		loadSettings()
		-- update UI
		updateUI()
		
		-- set focus to the list view
		setFocus dnListView
	)
	
	fn onDlgLS3DSmartExportOkToClose =
	(
		-- ok, close this dialog
		return true
	)

	
	-- handlers
--	dotnet.addeventhandler dnListView "ItemCheck" ondnListViewItemCheck item
	on dnListView	MouseDown	val do ondnListViewMouseDown val
	on dnListView	MouseUp		val do ondnListViewMouseUp val
	--on dnListView	MouseUp		do ondnListViewDblClick()
	on dnListView	ItemCheck item	do ondnListViewItemCheck item
	on chkCheckAll	changed state	do onChkCheckAllChecked state
	on btnConfig	pressed			do onBtnConfigPressed()
	on btnCheckSel	pressed			do onBtnCheckSelPressed()
	on btnExport	pressed			do onBtnExportPressed()
	on btnClose		pressed			do onBtnClosePressed()
	on dlgLS3DSmartExport	open				do onDlgLS3DSmartExportOpen()
	on dlgLS3DSmartExport	oktoclose			do onDlgLS3DSmartExportOkToClose()	
	on dlgLS3DSmartExport 	resized 	size 	do onDlgResize size
)

------------------------------------------------------------------------------
-- MAIN OBJECT
------------------------------------------------------------------------------

struct sXDSExport
(
	namePrefix			= "ls3d_",
	pathPropSuffix		= "_path",
	profilePropSuffix	= "_profile",
	exportPropSuffix	= "_export",
	lastPaths			= #(),
	exportErrors		= #(),
	exportWarnings		= #(),
	exported			= 0,
	oldSelection		= #(),
	oldCommandMode		= #create,
	logFilename			= "C:\LS3DSmartExport.log",
	---------------------------------------------------------------
	fn getEnginePath = try
	(
		local enginePath = ""
		
		local enginePaths = filterString LS3DGUP.LS3DGUP.utilsPath "\\/"
		for p in enginePaths do if p != "_utils" do enginePath += p + "\\"
		enginePath += "edit"

		return enginePath
	) catch (
		return "C:"
	),
	fn getExportPath = try
	(
		local enginePath = LS3DGUP.LS3DGUP.EnginePath
		/*local enginePath = ""
		
		local enginePaths = filterString LS3DGUP.LS3DGUP.outputPath "\\/"
		for p in enginePaths do if p != "edit" do enginePath += p + "\\"
		enginePath += "edit"
		*/
		return enginePath
	) catch (
		return "C:"
	),
	---------------------------------------------------------------
	fn log str =
	(
		if (doesFileExist logFilename) == false do
		( -- create file
			createFile logFilename
		)
		
		local text = maxFilePath + maxFileName
		if (text.count == 0) do
			text = "Unknown Max File"
		text = localTime + " " + text + " : " + str
		
		-- open file
		local file = openFile logFilename mode:"a"
		
		-- print to listener
		if (ls3dSmartExport_debug == true) then format "%\n" text
		
		-- print to file
		if (ls3dSmartExport_debug == true) then format "%\n" text to:file
		
		-- cloase file
		close file
	),
	---------------------------------------------------------------
	fn selectHierarchy node =
	(
		local nodeList = #(node)
	
		-- collect all nodes
		for n in node.children do
			join nodeList (selectHierarchy n)

		return nodeList
	),
	---------------------------------------------------------------
	fn addLastPath path =
	(
		local canAdd = 0
		
		-- check if specified path is in array
		for n = 1 to lastPaths.count do
			if lastPaths[n] == path do
			(
				canAdd = n
				exit
			)
		
		if (ls3dSmartExport_debug == true) then format "addLastPath>path = %\n" path
			
		if canAdd == 0 then
		(	-- add new path
			if (lastPaths.count < 10) do
				lastPaths[lastPaths.count+1] = ""

			for n = lastPaths.count to 2 by -1 do
				lastPaths[n] = copy lastPaths[n-1]
			
			lastPaths[1] = copy path
		)
		else
		(
			if (canAdd > 1) then
			(	-- switch first and specified path
				path = copy lastPaths[1]
				lastPaths[1] = copy lastPaths[canAdd]
				lastPaths[canAdd] = path
			)
		)
	),
	---------------------------------------------------------------
	fn getModelPathFromProps modelName =
	(
		local pathName		= namePrefix + modelName + pathPropSuffix
		local enginePath	= getExportPath()
		--local enginePath	= getEnginePath()
		local modelPathProp = fileProperties.findProperty #custom pathName

		-- get path first from LS3D node
		node = getnodebyname modelName
		if (classof node != LS3DModel) then (
			messagebox ("Found geometry with the same name as model node. That is not allowed. Please rename: " + node as string)
			return ""
		)
		modelPath = node.OutputPath
		if modelPath != undefined then
		(
			path = enginePath -- + "\\"
			path = path + modelPath
			if (ls3dSmartExport_debug == true) then print path
			return path
		)
		else
		(
			if modelPathProp != 0 then
			(
				-- get path info
				modelPath = fileProperties.getPropertyValue #custom modelPathProp
	
				-- complete relative path if needed
				if (modelPath.count == 0) or (modelPath[1] == "\\") do
					return (enginePath + modelPath)
					
				return modelPath
			)
		)

		return ""
	),
	---------------------------------------------------------------
	fn getModelProfileFromProps modelName =
	(
		local profileName		= namePrefix + modelName + profilePropSuffix
		local modelProfileID	= fileProperties.findProperty #custom profileName
		
		if (ls3dSmartExport_debug == true) then 
			format "getModelProfileFromProps> profileName: %     modelProfileID: %\n" profileName modelProfileID
		
		-- get profile info
		if modelProfileID != 0 then (
			local profileValue = fileProperties.getPropertyValue #custom modelProfileID
			if (profileValue < 0) then profileValue = 0				-- if profile is saved as Active - select 00 - Production
			return profileValue
		)
		return 0		-- if there is no value saved use 00 - Production
		--return -1		-- Original -1 for Active profile
	),
	---------------------------------------------------------------
	fn getCanExportFromProps modelName =
	(
		local exportName = namePrefix + modelName + exportPropSuffix
		local modelExportProp = fileProperties.findProperty #custom exportName

		-- get export flag from props
		if modelExportProp != 0 then
			return fileProperties.getPropertyValue #custom modelExportProp

		return true
	),
	---------------------------------------------------------------
	fn setModelProfileFromProps modelName profileID =
	(
		local profileName = namePrefix + modelName + profilePropSuffix
	
		-- add path to file properties
		fileProperties.addProperty #custom profileName profileID
		if (ls3dSmartExport_debug == true) then format "setModelProfileFromProps> profileName: %     profileID: %\n" profileName profileID
		
		setSaveRequired true
	),
	---------------------------------------------------------------
	fn setCanExportToProps modelName state =
	(
		local exportName = namePrefix + modelName + exportPropSuffix

		-- add path to file properties
		fileProperties.addProperty #custom exportName state
		setSaveRequired true
	),	
	---------------------------------------------------------------
	fn setModelExportPath modelName path =
	(
		local pathName	 = namePrefix + modelName + pathPropSuffix
		local enginePath = getEnginePath()

		-- cut engine path from specified xds path
		if ((findString path enginePath) != undefined) do
			path = subString path (enginePath.count + 1) -1
		
		-- add path to file properties
		fileProperties.addProperty #custom pathName path
		setSaveRequired true
		
		-- add path to LS3D node
		node = getnodebyname modelName
		path = path + "\\"		
		node.OutputPath = path
	),
	---------------------------------------------------------------
	fn browseForModelPath modelName =
	(
		local pathName	 = namePrefix + modelName + pathPropSuffix
		local enginePath	= getExportPath()
--		local enginePath = getEnginePath()
		local modelPath	 = getModelPathFromProps modelName
		-- check if the modelPath is correct	
		if (modelPath == "" and lastPaths.count > 0) do
			modelPath = lastPaths[1]
		if (modelPath == "") do
			modelPath = enginePath + "\\"
		
		-- browse for path
		local path = getSavePath caption:("Select Folder for '" + modelName + ".xds':") initialDir:enginePath
		if path == undefined do return false
			
		-- cut engine path from specified xds path
		if ((findString path enginePath) != undefined) do
			path = subString path (enginePath.count + 1) -1
		
		-- save this path		
		addLastPath path

		-- add path to the file props
		setModelExportPath modelName path
		
		return true
	),
	---------------------------------------------------------------
	fn browseForPaths =
	(
		local sel = $helpers
		
		-- browse for all paths
		for n in sel do
			if (classof n) == LS3DModel do
				browseForModelPath n.name
	),
	---------------------------------------------------------------
	fn exportModel modelName nodeList exportAll:false =
	(
		local currentProfile = LS3DGUP.XDSExporter.GetSelectedProfile()
		local currentPath	 = LS3DGUP.XDSExporter.Path
		local supressPrompts = LS3DGUP.XDSExporter.SupressPrompts
		local exportSelected = LS3DGUP.XDSExporter.ExportSelected
		
		-- check if we can export specified model
		modelCanExport = getCanExportFromProps modelName
		if (ls3dSmartExport_debug == true) then format "Model can Export: %\n" modelCanExport
		if (exportAll == false) and (modelCanExport == false) do
			return true
			
		-- get model path
		modelPath = getModelPathFromProps modelName
--		modelPath = modelPath + "\\"
		if (modelPath == "") do
		(
			append exportErrors #(nodeName, "There is no valid path specified for '" + modelName + "' ..!")
--			if (ls3dSmartExport_debug == true) then format "Error: %\n" exportErrors[exportErrors.count][2]
			return false
		)
		
		-- get model profile
		modelProfile = getModelProfileFromProps modelName
		if (modelProfile < 0) do
		(
			append exportWarnings #(nodeName, "Model '" + modelName + "' hasn't set export profile, current active (#" + currentProfile as string + ") is used.")
			modelProfile = currentProfile
		)
		
		-- export model
		if (ls3dSmartExport_debug == true) then format "Exporting : %\n" (modelPath + modelName + ".xds")
--		if (ls3dSmartExport_debug == true) then format "Exporting : %\n" (modelPath + "\\" + modelName + ".xds")
		try
		(	-- set up export
			LS3DGUP.XDSExporter.SelectProfile modelProfile
--			LS3DGUP.XDSExporter.SetNodeList nodeList
			LS3DGUP.XDSExporter.Path			= modelPath
			if (ls3dSmartExport_debug == true) then print LS3DGUP.XDSExporter.Path
			LS3DGUP.XDSExporter.SupressPrompts	= true
			LS3DGUP.XDSExporter.ExportSelected	= true
			-- export
			LS3DGUP.XDSExporter.Export()
		)
		catch
		(	-- something bad happend
			local text = "Export was unsuccessful.\n\n From now, Max may be unstable.\n\nSave your work and restart Max."
			text += getCurrentException()
			messagebox text title:"Export to XDS"
			throw()
		)
		
		-- select old profile & settings
		LS3DGUP.XDSExporter.SelectProfile currentProfile
		LS3DGUP.XDSExporter.Path			= currentPath
		LS3DGUP.XDSExporter.SupressPrompts	= supressPrompts
		LS3DGUP.XDSExporter.ExportSelected	= exportSelected

		-- increase exported counter
		exported += 1
		
		-- done
		return true
	),
	---------------------------------------------------------------
	fn ResetSettings =
	(
		-- set old command mode back
		setCommandPanelTaskMode oldCommandMode
		
		-- set selection back
		if (oldSelection.count == 0) then
			clearSelection()
		else
			select oldSelection
	),
	---------------------------------------------------------------
	fn SaveSettings =
	(
		oldSelection	= selection as array
		oldCommandMode	= getCommandPanelTaskMode()
	),
	---------------------------------------------------------------
	fn openDialog =
	(
		gLS3DSmartExportUI = createDialog dlgLS3DSmartExport modal:true style:#(#style_titlebar, #style_resizing)
	),
	---------------------------------------------------------------
	fn exportScene quietMode:false exportAll:false =
	(
		local ret = true
		
		-- get settings
		SaveSettings()
		
		local sel = $helpers
		local modelPath
		
		-- reset exportet counter
		exported = 0
		
		-- clear old export errros data
		exportWarnings = #()
		exportErrors = #()
	
		-- set create command mode
		setCommandPanelTaskMode #create
		
		-- export all models
		protection = LS3DGUP.EA.GetClearProtection()
		LS3DGUP.EA.Clear()
		LS3DGUP.EA.SetClearProtection true

		for n in sel do
		(
			-- skin other nodes
			if (classof n) != LS3DModel do
				continue
	
			-- select nodes to be exported
			select n
		
			-- do export
			if (exportModel n.name nodeList exportAll:exportAll) == false then
			(
				if (quietMode == true) do continue

				ResetSettings()
				
				if (exportErrors.count > 0) then
					openDialog()

				return false
			)
		)
		LS3DGUP.EA.SetClearProtection protection

		ResetSettings()		

		if (quietMode == false) then
		(
			if (exported == 0 and sel.count > 0) then
			(	-- open dialog if nothig selected for export
				openDialog()
				return false
			)
			else
			if (exported == 0) do
			( -- inform that nothing was exported
				messageBox "Nothing exported." title:"LS3D Smart Export"
				ret = false
			)
		)
		else
		(
			if (exportErrors.count > 0) then
			(
				for e in exportErrors do log ("Error - " + e[2])
				ret = false
			)
			else
			if (exported == 0) then
			( -- inform that nothing was exported
				log "nothing exported"
				ret = false
			)
			
			for w in exportWarnings do log ("Warning - " + w[2])
		)	
	
		-- clean
		gc light:true
			
		-- all is done
		return ret
	),
	---------------------------------------------------------------
	fn init =
	(
		if (doesFileExist logFilename) == true do
		(
			deleteFile logFilename
		)
	)	
)

------------------------------------------------------------------------------
-- INIT
------------------------------------------------------------------------------


if (gLS3DSmartExport == undefined) do
(
	gLS3DSmartExport = sXDSExport()
	gLS3DSmartExport.init()
)


------------------------------------------------------------------------------
-- MACRO SCRIPTS
------------------------------------------------------------------------------

macroScript LS3DSmartExport
category:"LS3D Engine" 
buttonText:"Smart XDS Export" 
tooltip:"Smart XDS Export"
Icon:#("FileLinkActionItems",1)
(
	gLS3DSmartExport.exportScene()
)

macroScript LS3DSmartExportUI
category:"LS3D Engine" 
buttonText:"Smart XDS Export UI" 
tooltip:"Smart XDS Export UI"
Icon:#("FileLinkActionItems",3)
(
	gLS3DSmartExport.openDialog()
)


/*
-- Get all properties
pages = #(#summary, #contents, #custom)
for pg in pages do
(
	format "--- % ---\n" (pg as string)
	for i=1 to (fileProperties.getNumProperties pg) do
	(
		local pname = (fileProperties.getPropertyName pg i)
		local pval = (fileProperties.getPropertyValue pg i)
		format "\t% : " pname
		if (pname =="Headers") then
		(
			format "\n"
			for hdr in pval do
			(
				format "\t\t%\n" hdr
				local docs = fileProperties.getItems hdr
				if docs != undefined then
					for d in docs do format "\t\t\t%\n"d
			)
		)
		else format " %\n" pval
	)
)
*/