
-----------------------------
-- Dynamic Rollout Creator --
-----------------------------
--       30.05/2008        --
-----------------------------
Global mcDialogEditMode
Global mcMarkedButton = #()
Global mcCreateDinamicDialog
Global mcDialog
Global mcMicraDialog
Global mcDialogSnap

struct mcDialog
(
	--load icon from file
	fn getIconFromFile imgFile icNum icSize:24 imgSize:480 =
	(
		local icn       = bitmap icSize icSize color:white
		if not doesFileExist imgFile or icNum == undefined or icNum < 1 do return icn
		local imgLib    = openBitMap imgFile
		local icnCount  = imgSize/icSize
		icNum -= 1
		local X = (mod icNum icnCount)
		local Y = (icNum / icnCount)
		
		local pix_x = X * icSize
		local pix_y = Y * icSize
		
		for i=0 to icSize do
		(
			local pix = getPixels imgLib [pix_x , pix_y + i] icSize 
			setpixels icn [0,i] pix
		)
		close imgLib
		return icn
	),
	--hilight button
	fn higlightButton icn col =
	(
		--draw lines
		for i=1 to 22 do
		(
			setpixels icn [i, 1] #(col) --top
			setpixels icn [i,22] #(col) --bottom
			setpixels icn [1, i] #(col) --left
			setpixels icn [22,i] #(col) --right
		)
		return icn
		--display icn
	),
	--Button Link
	fn dialogButtonLink dia_str btn_str mouse_btn: =
	(
		local editMode = mcDialogEditMode != undefined and mcDialogEditMode.isDisplayed and 
						 mcDialogEditMode.ckb_acti.checked
		local enabled  = doesFileExist Micra.TempProfileIni and doesFileExist Micra.ActionsIni and 
						 doesFileExist Micra.IconI and doesFileExist Micra.ActionsHelpIni
		if not enabled do return false
		local key  = getIniSetting Micra.TempProfileIni "Buttons" btn_str
		
		-->Edit mode switch
		if not mouse_btn == #rc do
		(
			--format "edit mode >> dialog_str:%\tbutton_str:%\tbutton:%\n" dia_str btn_str (execute (dia_str+"."+btn_str))
			local data
			local heads = getIniSetting Micra.ActionsIni
			for i in heads where getIniSetting Micra.ActionsIni i key != "" do data = getIniSetting Micra.ActionsIni i key
			if data != undefined do data = execute data
			if classof data  != array then data = #(1)
			
			if editMode
			then
			(
				local icn           = bitmap 24 24 color:white --mcDialog.getIconFromFile Micra.IconI (data[1]-1)
				local iconHilighted = mcDialog.higlightButton icn green
				local btn           = (execute (dia_str+"."+btn_str))
				btn.images          = #(iconHilighted, undefined, 1,1,1,1,1 )
				--format "old:%\n" mcMarkedButton
				
				-->
				if mcMarkedButton.count == 2 do 
				(
					mcMarkedButton[2].images = mcCall.getIcon mcMarkedButton[1]
				)    
				mcMarkedButton     = #(data[1],btn)
				
				-->remove Icon and Action from Ini
				if keyboard.altPressed do mcDialogEditMode.theSubRollout.EditActions.btn_rem.pressed() --mcDialogEditMode.btn_rem.pressed()
			)
			else
			(
				--format "data:%\n" (classof data[2])
				-->execute Action
				local action = data[2]
				if action != undefined do try (execute action) catch (format "error okurek!!!: %\n" action)
			)
		)
		--> Show help diaolg in Right Click Button
		if keyboard.controlPressed and mouse_btn == #rc do
		(
			local click_pos = mouse.screenpos
			if key == undefined do return false
			local ActionHelpData  = undefined
			local ActionHelpHeads = getIniSetting Micra.ActionsHelpIni
			for i=1 to ActionHelpHeads.count where (findItem (getIniSetting Micra.ActionsHelpIni ActionHelpHeads[i]) key) != 0 do
			(
				ActionHelpData = getIniSetting Micra.ActionsHelpIni ActionHelpHeads[i] key
			)
			--format "ActionHelpKey:%\tActionHelpData:%\n" ActionHelpKey ActionHelpData
			if ActionHelpData != undefined do 
			(
				mcCall.popUp ActionHelpData 10 dPos:[click_pos.x, click_pos.y - 50]
			)
		)
	),
	--Icon Link
	fn dialogButtonIcon btStr =
	(
		local blank = #(bitmap 24 24, bitmap 24 24 color:white,1,1,1,1,1)
		if not doesFileExist Micra.TempProfileIni do return blank
		if not doesFileExist Micra.IconI or not doesFileExist Micra.IconM do return blank
		-->get icnum from Micra.TempProfileIni
		if btStr != undefined do icNum = (getIniSetting Micra.TempProfileIni "Icons" btStr) as integer
		if icNum < 2 do return blank
		local icon = mcDialog.getIconFromFile Micra.IconI icNum
		local mask = mcDialog.getIconFromFile Micra.IconM icNum
		return #(icon, mask, 1, 1, 1, 1, 1)
		--format "icon:%\t mask:%\t maxn:%\t btStr:%\t icNum:%\n" icon mask maxn btStr icNum
		--#("E:\Micra\mcIcons_24i.bmp", "E:\Micra\mcIcons_24m.bmp", 100, 2, 2, 2, 2)
	)
)
--(dNameStr = "mcObjDialog"), (dMask = "A","B","C","D"...), ( w  h = width & height), (btnCount = number )
fn mcCreateDinamicDialog dNameStr btnVH:undefined =  
(
	if btnVH == undefined do btnVH = (mcCall.getIniDataFromArray Micra.TempProfileIni "Properties_1" dNameStr 5)
	if btnVH == undefined do return false
	local dMask    = dNameStr[dNameStr.count]
	local pos      = [8,18] 
	local btnPos   = pos 
	local btnSize  = [24,24]
	local btnCount = (btnVH.x * btnVH.y) as integer
	local dWidth   = ((btnVH.x*btnSize[1])+16) as integer
	local dHeight  = ((btnVH.y*btnSize[2])+26) as integer
	local dPos     = (mcCall.getIniDataFromArray Micra.TempProfileIni "Properties_1" dNameStr 2) as string
	local dTitle   = (mcCall.getIniDataFromArray Micra.TempProfileIni "Properties_1" dNameStr 4)
	--local bTooltip = (mcCall.getIniDataFromArray Micra.TempProfileIni "Buttons" dNameStr 3)
	--if bTooltip == undefined do bTooltip = ":"
	-------------------------------------------
	--> 2 btn to V & 6 btn to H  =  dialog size
	-------------------------------------------

	--> 
	local exe = "\n"
	exe += "if "+dNameStr+" != undefined then destroyDialog "+dNameStr+"\n"
	-->Strat
	exe += "rollout "+dNameStr+" \"\" "+"width:"+dWidth as string+" height:"+dHeight as string+"\n"
	exe += "(\n"
	-->Rollout
	exe += "\tlocal dMove = false , DmPos , spnV , spnH\n"
	exe += "\tGroupBox grp_n \""+dTitle+"\" pos:[4,4] width:"+(dWidth - 8) as string +" height:"+(dHeight - 8) as string +"\n"
	exe += "\tbutton btn_menu "+" \"-\" "+"pos:["+(dWidth - 15) as string+",4] width:12 height:12 toolTip:\"_Minimize_\"\n"
	for i=1 to btnCount do 
	(
		--> buttnos
		local bTooltip = getIniSetting Micra.TempProfileIni "Buttons" ("btn_"+dMask+ i as string)
		if bTooltip == undefined do bTooltip = ":"
		exe += "\tbutton btn_"+dMask+ i as string +" \"\" "+"pos:"+btnPos as string +"width:24 height:24 "+
		"images:(mcDialog.dialogButtonIcon \"btn_"+dMask+ i as string +"\" ) toolTip:"+" \""+bTooltip+"\" \n"
		--next pos  X	
		btnPos += [btnSize.x,0]
		--next line Y 
		if (btnPos.x+btnSize.x) > dWidth then btnPos = [pos.x ,btnPos.y+btnSize.y]
		--> actions
		exe += "\ton btn_"+dMask+ i as string +" pressed    do (mcDialog.dialogButtonLink \""+dNameStr+"\" \"btn_"+dMask+ i as string+"\")\n"
		exe += "\ton btn_"+dMask+ i as string +" rightclick do (mcDialog.dialogButtonLink \""+dNameStr+"\" \"btn_"+dMask+ i as string+"\" mouse_btn:#rc)\n"
		--format "Pos:%\n" btnPos		
	)
	-->Dialog
	exe += "\ton "+dNameStr+" close do (mcCall.saveIniDialog \""+dNameStr+"\" \"Properties_1\" active:false ; mcMarkedButton = #())\n"
	------"\ton "+dNameStr+" close do (mcCall.saveIniDialog \""+dNameStr+"\" \"Properties_1\" active:(not mcMicraDialog.isDisplayed) ; mcMarkedButton = #())\n"
	exe += "\ton "+dNameStr+" rbuttonup pos   do(destroyDialog "+dNameStr+")\n"
	exe += "\ton "+dNameStr+" lbuttondown pos do(dMove = true ; DmPos = pos; if not keyboard.shiftPressed do pushprompt \"Pres Shift To Move...\")\n"
	exe += "\ton "+dNameStr+" lbuttonup pos   do(dMove = false; pushprompt \"\")\n"
	exe += "\ton "+dNameStr+" mouseMove pos do\n"
	exe += "\t(\n"
	exe += "\t\tif dMove and keyboard.shiftPressed do mcDialogSnap "+dNameStr+" DmPos\n"
	exe += "\t)\n"		
	--> Actions
	exe += "\ton btn_menu pressed do DestroyDialog "+dNameStr+"\n"
	-->End
	exe += ")\n"
	if dPos != "" or dPos != undefined
	then (exe += "createdialog "+dNameStr+" Pos:"+dPos+" style:#(#style_border)\n")
	else (exe += "createdialog "+dNameStr+" style:#(#style_border)\n")
	
	--format "dPos:%\n" dPos
	--format exe
	execute exe
)

--mcCreateDinamicDialog "Test_Dyna" "A" 6 2 


/*
	-->Dialog
	on mcDialog_01 open do
	(
		mcSetButtonPos  "modDialog" "btn_H"
	)
	[Buttons]
--Buton Marker
fn markButton btn =
(
	if not doesFileExist Micra.TempProfileIni do return false
)

(
	local editMode = mcDialogEditMode != undefined and mcDialogEditMode.isDisplayed
	if editMode do markButton (dNameStr + "btn_"+dMask+ i as string)
) 
*/

