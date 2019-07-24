
(
	
	-- Dipl.-Des. Georg Duemlein
	-- http://www.preset.de/
	
	-- 20070412	Additional Renderer Support
	--			MR Fast SSS support added 
	--			autoenable removed
	--			support for brazil 1 and brazil 2 default
	--			fixed typos in bonus tools
	-- 20070411	Additional Renderer Support
	--			Brazil (Default) support added
	--			changes in: material creation, dialogsetup
	--			MR Fast SSS support added and removed
	-- 20070329	Bonus-ToolsFixed
	-- 			FilexTypes configurable in external Setupfile
	-- 20061130	added support for different FileTypes
	--			fixed bug where renderer didn't change with autoEnable off - caused by detection of active renderer.
	--			removed wahooney ini for theAppPath
	--			enabled MR -> defaulting to scanline
	-- ToDo:
	--			combine ini read/write access
	-- ---

-- ---
	global rdg_PSD2MAT
	global rdg_renderOptions
	
	struct theFunctions (
		psdFile  = undefined,
		availLayers = #("none"),
		layerLUT = #(),
		theAppPath = undefined,
		theIniFile = getDir #plugcfg + "/rdg_tools.ini",
		theBackupState = OK,
		theAutoEnableState = OK,
		theEnabledRenderer = undefined,
		theActiveFileType = undefined,
		-- ---
		theIniFile = getDir #plugcfg + "/rdg_tools.ini",
		validRenderer = #(#("MAX Scanline", "Scanline"), #("VRay Advanced 1.5", "VRay"), #("Brazil r/s v1 (Default)", "Brazil1_default"), #("Brazil r/s v2 (Default)", "Brazil2_default"), #("MR Fast SSS", "mr_fast_sss")),
		validFileTypes = #(),
		tempMaterial = undefined,
		bmt = undefined,
		-- ---
		fn getTheRenderer = (
			optionsFile = "$scripts\\rdg-preset\\psd2mat\\rdg_psd2mat_" + validRenderer[theEnabledRenderer][2] + ".ms"
			try (
				fileIn optionsFile
				rdg_renderOptions
			)catch(
				theEnabledRenderer = 1
				theAutoEnableState = false
				messagebox "The current renderer is not supported!\n You can still generate materials for supported renderers.\n Default: Scanline.\n"
				optionsFile = "$scripts\\rdg-preset\\psd2mat\\rdg_psd2mat_" + validRenderer[theEnabledRenderer][2] + ".ms"
				fileIn optionsFile
				rdg_renderOptions
			)
			
		),
		fn getRenderID = (
			currentSystemRenderer = renderers.current
			for i = 1 to validRenderer.count do (
				if findString ((classof currentSystemRenderer) as string) validRenderer[i][1] != undefined then (
					theEnabledRenderer = i
					return i
				exit
				)
			)
		),
		fn validateLayer arg num= (
			temp2 = execute("rdg_PSD2MAT.map" + num as string)
			if availLayers.count == arg then (
				temp2.checked = temp2.enabled = false
				 
			)else(
				temp2.checked = temp2.enabled = true
			)
		),
		fn pad num len = (
			num = num as string
			while num.count < len do num = "0" + num
			num
		), 
		fn createMaterial = (
			tempMaterial = rdg_renderOptions.theMatFunc()
			theStep = 100/layerLUT.count
			thePath = getFilenamePath psdFile
			theName = getFilenameFile psdFile
			theFullPath = thePath + theName + "_files"
			
			if (getfiles theFullPath).count == 0 then (
				makeDir theFullPath
			)
			if theBackupState then (
				backupPath = theFullPath + "\\backup"
				if (getfiles backupPath).count == 0 then (w
					makeDir backupPath
				)
				backupStuff = (getFiles (theFullPath + "\\*" + validFileTypes[theActiveFileType][2]))
				format "there are % files \n" backupStuff.count
				if backupStuff.count > 0 then (
					format "backup running ... \n"
					theBackupCount = (getDirectories (backupPath + "/*") ).count
					theBackupDir = (backupPath + "\\" + (pad theBackupCount 4))
					makeDir theBackupDir
					for i = 1 to backupStuff.count do (
						copyFile backupStuff[i] (theBackupDir + "\\" + getFilenameFile backupStuff[i] + getFilenameType backupStuff[i])
					)
					format "% files backupped in %\n" backupStuff.count theBackupDir
				)
			)
			for i = 1 to layerLUT.count do (
				tempList = execute("rdg_PSD2MAT.list" + i as string)
				tempChk = execute("rdg_PSD2MAT.map" + i as string)
				if tempList.selection != tempList.items.count and tempChk.checked then(	
					bmp = bitmapLayerManager.loadLayer psdFile (tempList.selection - 1) true
  					bmp = copy bmp
					bmp.filename = theFullPath +  "\\" + theName + "_" + rdg_renderOptions.theMapNames[i] + validFileTypes[theActiveFileType][2]
					save bmp
					-- ---
					bmt = bitmapTexture filename:bmp.filename name:(theName + "_" + tempList.items[tempList.selection])
					execute("rdgPSD2MATfunctions.tempMaterial." + rdg_renderOptions.theMaps[i] + " = rdgPSD2MATfunctions.bmt")
				)
				rdg_PSD2MAT.thePBar.value = i*theStep
			)
			tempMaterial.name = theName
			MatEditor.Open()
			rdg_PSD2MAT.thePBar.value = 0
			idx = mEdit.GetActiveMtlSlot()
			mEditMaterials[idx] = tempMaterial
			-- ---
			tempMaterial = undefined
			bmt = undefined		
		),
		fn aboutThis = (
			messagebox "rdg::PSD2Mat - a pipeline tool\n2006 Dipl.-Des. Georg Duemlein (RDG)\n\nA homage to 'PSD To Material v1.0' by Keith Boshoff (Wahooney)\nAdvisor: Anselm v. Seherr - Thoﬂ (PsychoSilence)" title:"About rdg::PSD2Mat"
		),
		fn beautify = (
			toleft = #(rdg_PSD2MAT.theFile_txt, rdg_PSD2MAT.thePSDsel, rdg_PSD2MAT.action_go, rdg_PSD2MAT.action_open , rdg_PSD2MAT.thePBAR)
			for i = 1 to toleft.count do (
				tempPos = toleft[i].pos
				tempPos.x = 57
				toleft[i].pos = tempPos
				)
			rdg_PSD2MAT.height = 200 + rdg_renderOptions.theMaps.count * 25
		),
		fn mkRollout currRen = (
			rci = rolloutCreatorRDG "rdg_PSD2MAT" "RDG PSD2Mat"
			rci.begin()
			rci.openGroup "the File"
			rci.addControl #button "thePSDsel" "openPSD" paramStr:"width:140"
			rci.addControl #edittext "theFile_txt" "" paramStr:"width:144 enabled:false"
			rci.closeGroup()
			rci.openGroup ("the Maps (" +  rdg_renderOptions.theName + ")")
			for i = 1 to currRen.theMaps.count do ( 
				rci.addControl #checkbox ("map" + i as string) (currRen.theMapNames[i]) paramStr:("pos:[10," + (80 + i * 25) as string+ "] across:2")
				rci.addControl #dropdownlist ("list" + i as string) "" paramStr:("pos:[130," + (72 + i * 25) as string+ "] items: " + (availLayers as string) + " selection:1")	
			)
			rci.closeGroup()
			for i = 1 to currRen.theMaps.count do (
				rci.addHandler ("list" + i as string) #selected paramStr:"arg" filter:on codeStr:("rdgPSD2MATfunctions.validateLayer arg " + i as string)
			)

			rci.openGroup "the Actions"
			rci.addControl #button "action_go" "create Material" paramStr:"width:140 enabled:false"
			rci.addControl #progressBar "thePBAR" "" paramStr:"width:140"
			rci.addControl #button "action_open" "open File in PS" paramStr:"width:140 enabled:false"
			rci.closeGroup()
			rci.addHandler "thePSDsel" #pressed codeStr:"rdgPSD2MATfunctions.openPSD()"
			rci.addHandler "action_go" #pressed codeStr:"rdgPSD2MATfunctions.createMaterial()"
			rci.addHandler "action_open" #pressed codeStr:"rdgPSD2MATfunctions.openInPhotoshop()"
			rci.addHandler "rdg_PSD2Mat" #open codeStr:"rdgPSD2MATfunctions.beautify()"
			return rci.end()	
		),
		fn rebuildLists = (
			for i = 1 to rdg_renderOptions.theMapNames.count do (
				temp = execute("rdg_PSD2MAT.list" + i as string)
				temp2 = execute("rdg_PSD2MAT.map" + i as string)
				temp.items = availLayers
				if layerLUT[i] == -1 then (
					temp.selection = availLayers.count
					temp2.checked = temp2.enabled = false
				)else(
					temp.selection = layerLUT[i]
					temp2.checked = true
				)	
				
			)
		),
		fn analysePSD = (
			availLayers = #()
			layerLUT = #()
			numLayers = bitmapLayerManager.getLayerCount psdFile
			for layer = 0 to (numlayers-1) do (
				append availLayers (bitmapLayerManager.getLayerName psdFile layer)
			)
			append availLayers "none"
			for test = 1 to rdg_renderOptions.theTests.count do (
			 tempLevel = -1
			 for layer = 1 to availLayers.count do (
			 	if (findString  availLayers[layer] rdg_renderOptions.theTests[test]) != undefined then (
			 		tempLevel = layer
					exit
			 	)
			)
			append layerLUT tempLevel
		 )
		),
		fn openPSD = (
			oldPsdFile = psdFile
			psdFile = getOpenFileName caption:"Open PSD File..." types:"Adobe Photoshop File(*.psd)|*.psd|"
  			if psdFile == undefined then (
   				psdFile = oldPsdFile
				return undefined
			)
			rdg_PSD2MAT.action_go.enabled = true
			if theAppPath != undefined then (
				rdg_PSD2MAT.action_open.enabled = true
			)
			rdg_PSD2MAT.theFile_txt.text = filenameFromPath psdFile		
		 analysePSD();
		 rebuildLists()
		),
		fn getAppPath = (
				messageBox "You haven't set a default imaging app for rdg::PSD2Mat.\nPlease locate your imaging application executable.\nThis is only done once." title:"OpenMap Alert!"
				theAppPath = getOpenFileName caption:"Locate your Imaging App executable..." types:"Executable (*.exe)|*.exe"
				setIniSetting theIniFile "PSD2MAT" "appPath" (theAppPath as string)
		),
		fn openInPhotoshop = (
			shellLaunch theAppPath psdFile
		),
		fn helpme = (
			shelllaunch "http://www.preset.de/2007/0329/psd2mat/" ""
		),
		fn changeBackup = (
			theBackupState = not theBackupState
			setIniSetting theIniFile "PSD2MAT" "backupState" (theBackupState as string)
		),
		fn changeAutoEnable = (
			theAutoEnableState = not theAutoEnableState
			setIniSetting theIniFile "PSD2MAT" "autoenableState" (theAutoEnableState as string)
		),
		fn changeFileType newId = (
			(execute("rdgPSD2MATmenu.av_fil_" + theActiveFileType as string)).checked = false
			theActiveFileType = newId
			(execute("rdgPSD2MATmenu.av_fil_"+ theActiveFileType as string)).checked = true
			setIniSetting theIniFile "PSD2MAT" "fileType" (newId as string)
		),
		fn openBonus which = (
			thebonustools = #("psd2mat-helper.jsx", "create Scanline Material.jsx", "create Vray Material.jsx", "create Brazil_1 (Default) Material.jsx", "create Brazil_2 (Default) Material.jsx", "create MR Fast SSS Material.jsx")
	 		shelllaunch theAppPath ((GetDir #scripts) + "\\rdg-preset\\psd2mat\\Bonus\\" + thebonustools[which])
		),
		fn mkMenu = (
			availRen = for ren in validRenderer collect ren[1]
			theMenuItems = ""
			theMenuItems_2 = ""

	 		theMenuHandler = ""
			-- ---
			theMenu = "rcmenu rdgPSD2MATmenu (\n"
 			theMenu += "fn changeRenderer me = (\n rdgPSD2MATfunctions.changeRender me)\n"
			theMenu += "fn changeFileType me = (\n rdgPSD2MATfunctions.changeFileType me)\n"
			for i = 1 to availRen.count do (
				theRenderCheck = ""
				theMenuItems += "\t\tmenuItem av_ren_" + (i as string) + " \"" + availRen[i] + "\"" + theRenderCheck + "\n"
				theMenuHandler += "on av_ren_" + (i as string) + " picked do (\n"
				theMenuHandler += "\t local me = " + i as string + "\n"
				theMenuHandler += "\t -- ifav_ren_" + i as string + ".checked == true then \n"
				theMenuHandler += "\t\t -- return false\n"
				theMenuHandler += "\tchangeRenderer me\n"
				theMenuHandler += ")\n"
			)
			for i = 1 to validFileTypes.count do (
			 	theMenuItems_2 += "\t\tmenuItem av_fil_" + (i as string) + " \"" + validFileTypes[i][1] + "\"\n"
				theMenuHandler += "on av_fil_" + (i as string) + " picked do (\n"
				theMenuHandler += "\t local me = " + i as string + "\n"
				theMenuHandler += "\tchangeFileType me\n"
				theMenuHandler += ")\n"	
			)
			theMenu += "subMenu \"Settings\" (\n"
			theMenu += "\tsubMenu \"Renderer\" (\n"
			theMenu += theMenuItems 
			theMenu += "\t)\n"
			theMenu += "\tsubMenu \"File Type\" (\n"
			theMenu += theMenuItems_2
			theMenu += "\t)\n"
			theMenu += "separator backup_sep\n"
			theMenu += "\tmenuItem backup_mn \"Backup\"\n"
			theMenu += ")\n"
			theMenu += "subMenu \"Bonus\" ( menuItem bonus1_mn \"psd2mat - Template CS2\"\nmenuItem bonus2_mn \"psd2mat - Template Standard CS1\"\nmenuItem bonus3_mn \"psd2mat - Template VRay CS1\"\n\n\nmenuItem bonus4_mn \"psd2mat - Template Brazil r/s 1 (Default) CS1\"\nmenuItem bonus5_mn \"psd2mat - Template Brazil r/s 2(Default) CS1\"\n\nmenuItem bonus6_mn \"psd2mat - Template MR Fast SSS CS1\"\n)\n"
			theMenu += "subMenu \"Help\" ( menuItem help_mn \"Help\"\nmenuItem about_mn \"About\")\n"		
			theMenu += theMenuHandler
			theMenu += "on bonus1_mn picked do (rdgPSD2MATfunctions.openBonus 1)\n"
			theMenu += "on bonus2_mn picked do (rdgPSD2MATfunctions.openBonus 2)\n"
			theMenu += "on bonus3_mn picked do (rdgPSD2MATfunctions.openBonus 3)\n"
			theMenu += "on bonus4_mn picked do (rdgPSD2MATfunctions.openBonus 4)\n"
			theMenu += "on bonus5_mn picked do (rdgPSD2MATfunctions.openBonus 5)\n"
			theMenu += "on bonus6_mn picked do (rdgPSD2MATfunctions.openBonus 6)\n"
			theMenu += "on about_mn picked do (rdgPSD2MATfunctions.aboutThis())\n"
			theMenu += "on help_mn picked do (rdgPSD2MATfunctions.helpme())\n"
			theMenu += "on backup_mn picked do (rdgPSD2MATmenu.backup_mn.checked = not rdgPSD2MATmenu.backup_mn.checked; rdgPSD2MATfunctions.changeBackup() )\n"
			theMenu += "on rdgPSD2MATmenu open do ( (execute(\"rdgPSD2MATmenu.av_ren_\" + rdgPSD2MATfunctions.theEnabledRenderer as string)).checked = true \n (execute(\"rdgPSD2MATmenu.av_fil_\" + rdgPSD2MATfunctions.theActiveFileType as string)).checked = true \n rdgPSD2MATmenu.backup_mn.checked = rdgPSD2MATfunctions.theBackupState \n)\n";
			theMenu +=	")"
			return (execute(theMenu))
		),
		fn init = (
			-- openPSD()
			rdg_renderOptions = undefined
			theBackupState = execute (getIniSetting theIniFile "PSD2MAT" "backupState")
			if theBackupState == OK do theBackupState = false
			theEnabledRenderer = (getIniSetting theIniFile "PSD2MAT" "enabledRenderer") as integer
			if theEnabledRenderer == 0 then (
				theEnabledRenderer = 1
			)
			theActiveFileType = execute (getIniSetting theIniFile "PSD2MAT" "fileType")
			if theActiveFileType == OK then theActiveFileType = 1
			if validFileTypes.count == 0 then (
				optionsFile = "$scripts\\rdg-preset\\psd2mat\\rdg_psd2mat_filetypes.ms"
				fileIn optionsFile
			)
			theAppPath = getIniSetting theIniFile "PSD2MAT" "appPath"
			if theAppPath == "" or theAppPath == "undefined" then (
				getAppPath();
			)
			renderOptions = getTheRenderer()
			try(
				destroydialog rdg_PSD2MAT
			)catch()
			createDialog (mkRollout rdg_renderOptions) 255 512 100 100 menu:(mkMenu())
			tempMaterial = undefined
		),
		 fn changeRender newId = (
				theEnabledRenderer = newId
				setIniSetting theIniFile "PSD2MAT" "enabledRenderer" (newId as string)
				psdFile  = undefined
				availLayers = #("none")
				layerLUT = #()
				init()
		 )
	)
			global rdgPSD2MATfunctions = theFunctions()
			rdgPSD2MATfunctions.init()
)