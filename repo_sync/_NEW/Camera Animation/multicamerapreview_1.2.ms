-- MCP v.1 (2011.03.17) by Anubis (project3d.narod.ru)
-- v.1.1 (2011.04.05) - added auto-set camera range using it name
-- v.1.2 (2013.02.04) - added Cancel (via ESC key)
-- for example:
-- if your camera name is "Cam_[50-400]" it range will be set to 50-400.
-- for more customization - edit 'charsSeparator' local variable.
if classOf roMultiCameraPreview == RolloutClass do
	DestroyDialog roMultiCameraPreview
rollout roMultiCameraPreview "Multi Camera Preview"
(
	local outFile -- video/bitmap sequence
	local dataSet = #() -- cameras settings
	local data = #(AnimationRange, 1) -- default camera settings

	-- insert more chars if you need different name convention
	-- [!] using space (" ") is not good idea though
	-- because will complicate the usage of GetNodeByName() function
	local charsSeparator = "-_[]()#" -- for camera names split
	
	-- [!] this chars ("L","P","s","t","f") return 0 when casted to integer
	fn isNumberChar char = (char >= "0" and char <= "9")
	fn stringToInteger str = (
		result = case str.count of (
			0 : undefined
			1 : if isNumberChar str then str as integer else undefined
			default : str as integer
		)
	)
	-- set the cam's range automat. from their names (requested feature)
	fn setCamRange cam = (
		local range = #(AnimationRange, 1)
		local spCamName = filterString cam.name charsSeparator
		if spCamName.count > 1 do (
			vals = #(
				stringToInteger spCamName[spCamName.count-1], 
				stringToInteger spCamName[spCamName.count]
			)
			if vals[1] != undefined and vals[2] != undefined do (
				sort vals -- be sure no reverse interval passed
				range = #((interval vals[1] vals[2]), 1)
			)
		)
		append dataSet range
	)
	
	fn camFilt obj = isKindOf obj Camera and not isKindOf obj targetObject
	
	ListBox scnCamsList width:182 height:12 pos:[7,17]
	button btnAdd "A+" width:30 height:20 pos:[7,184]
	button btnAddAll "A++" width:30 height:20 pos:[37,184]
	button btnRem "R-" width:30 height:20 pos:[67,184]
	button btnRemAll "R--" width:30 height:20 pos:[97,184]
	button btnMoveUp "Up" width:30 height:20 pos:[127,184]
	button btnMoveDn "Dn" width:30 height:20 pos:[157,184]
	GroupBox group1 "Scene Cameras" pos:[3,3] width:190 height:204
	
	button btnSaveAs "Save Preview As..." width:140 pos:[202,17]
	GroupBox group2 "General Settings" pos:[195,3] width:155 height:40
	
	spinner spnFrom "From: " type:#integer range:[-100000,100000,AnimationRange.start] width:68 pos:[242,77]
	spinner spnTo "  To: " type:#integer range:[-100000,100000,AnimationRange.end] width:68 pos:[242,100]
	GroupBox group3 "Camera Settings" pos:[195,45] width:155 height:134
	
	spinner spnNthFrm "Nth Frame: " type:#integer range:[1,1000,1] width:68 pos:[242,130]
	button btnApply "Set To Selected" width:140 pos:[202,155]
	GroupBox group31 "Range" pos:[200,60] width:145 height:60
	
	button btnMakePreview "Make Preview" width:140 pos:[202,184]
	
	--// Events
	on scnCamsList selected idx do (
		local data = dataSet[idx]
		spnFrom.value = data[1].start
		spnTo.value = data[1].end
		spnNthFrm.value = data[2]
	)
	on btnAdd pressed do (
		obj = selectByName title:"Select Camera" filter:camFilt showHidden:on single:on
		if isValidNode obj do (
			append scnCamsList.items obj.name; scnCamsList.items = scnCamsList.items
			--append dataSet data -- old method (using animationRange by default)
			setCamRange obj -- the new function
		)
	)
	on btnAddAll pressed do (
		allCams = for c in cameras where not isKindOf c targetObject collect c.name
		join scnCamsList.items allCams; scnCamsList.items = scnCamsList.items
		--for i in allCams do append dataSet data -- old method (using animationRange by default)
		for i in allCams do setCamRange (GetNodeByName i) -- the new function
	)
	on btnRem pressed do (
		local idx = scnCamsList.selection
		if idx > 0 do (
			deleteItem scnCamsList.items idx; scnCamsList.items = scnCamsList.items
			deleteItem dataSet idx
		)
	)
	on btnRemAll pressed do (scnCamsList.items = #(); dataSet = #())
	on btnMoveUp pressed do (
		local idx = scnCamsList.selection
		if idx > 1 do (
			swap scnCamsList.items[idx] scnCamsList.items[idx-1]
			scnCamsList.items = scnCamsList.items
			swap dataSet[idx] dataSet[idx-1]
			scnCamsList.selection -= 1
		)
	)
	on btnMoveDn pressed do (
		local idx = scnCamsList.selection
		if idx < scnCamsList.items.count do (
			swap scnCamsList.items[idx] scnCamsList.items[idx+1]
			scnCamsList.items = scnCamsList.items
			swap dataSet[idx] dataSet[idx+1]
			scnCamsList.selection += 1
		)
	)
	
	on btnSaveAs pressed do (outFile = selectSaveBitMap())
	on btnApply pressed do (
		local idx = scnCamsList.selection
		if idx > 0 do (
			local strFrm = spnFrom.value, endFrm = spnTo.value
			if strFrm >= endFrm then
				messageBox "No reverse interval pleace!" title:"Help" beep:off
			else (
				dataSet[idx] = #((interval strFrm endFrm), spnNthFrm.value)
			)
		)
	)
	on btnMakePreview pressed do (
		if dataSet.count > 0 and outFile != undefined then (
			vpt = viewport.GetType()
			vpc = if vpt == #view_camera then getActiveCamera() else null
			vtm = #(viewport.getTM(),viewport.GetFOV())
			
			setWaitCursor()
			vps = getViewSize()
			img = Bitmap vps[1] vps[2] filename:outFile
			frmCount = 0 -- the frame number is 0-based
			-- // Brazil Main_Camera issue FiX
			if vpt != #view_camera or vpt != #view_persp_user do (
				cam = GetNodeByName scnCamsList.items[1]
				if classOf cam == Main_Camera do
					viewport.setCamera cam; redrawViews()
			)
			-- // render cams procedure ...
			for i = 1 to dataSet.count \
			while not keyboard.escPressed do (
				cam = GetNodeByName scnCamsList.items[i]
				if isValidNode cam do (
					viewport.setCamera cam; redrawViews()
					local sFrm = dataSet[i][1].start
					local eFrm = dataSet[i][1].end
					local step = dataSet[i][2]
					for t = sFrm to eFrm by step \
					while not keyboard.escPressed do (
						sliderTime = t
						copy (gw.getViewportDib()) img
						save img frame:frmCount
						frmCount += 1
					)
				)
			)
			close img -- free from memory
			setArrowCursor()
			
			if vpc != null then viewport.setCamera vpc
				else if isKindOf vpt Name and vpt != #view_none do (
					viewport.setType vpt
					if vpt == #view_persp_user do (
						viewport.setTM vtm[1]
						if (maxVersion())[1] >= 10000 do -- if Max2008+
							viewport.SetFOV vtm[2]
					)
				)
			--shellLaunch outFile "" -- play the video
		) else (
			local msg = "Missing setup:\n\n"
			if dataSet.count == 0 do append msg "[*] No scene cameras\n"
			if outFile == undefined do append msg "[*] Output file not set\n"
			messageBox msg title:"Help" beep:off
		)
	)
)
createDialog roMultiCameraPreview 355 210 \
style:#(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)
