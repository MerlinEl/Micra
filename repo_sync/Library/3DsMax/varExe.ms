
/*
--unString
--inString

--create a string library	
	varExe = "\n
\n"

--add items to library
varExe += "arabela"

varExe += "\ DestroyDialog mcDialog
\n"


--add variable to library
varExe += "
	for i = 1 to objects.count do 
		(
		print i
		)
\n"
*/


/*
-----------------------------------------
	varExe = "\n
\n"

varExe += "setDialogPos mcDialog [34,56]
\n"
mover = format "%" varExe
-----------------------------------------
*/






-- set global var for rollout function
global fnCreateMSPRollout

-- create the rollout
function fnCreateMSPRollout argPos: argProps: argLastMod: = (

	-- 'show properties' is default off
	if argProps == unsupplied then argProps = false;
	
	-- initialize dialog size
	local dialogSize = [0, 270]
	if argProps then (
		dialogSize.x = 462
	) else (
		dialogSize.x = 170
	)
	
	if selection.count == 1 and issubselenabled() then with undo off (

		-- jump to modify mode
		disablesceneredraw()
		max modify mode
	
		local i
		local rolMain
		local curmod, curmodname, curmodindex, varSubLevels, curModEnabled, curSubLevel
		
		-- customizable treeview text colors
		local colModifiers = #("(color 0 0 0)", "(color 200 100 0)")
		local colSubLevel = #("(color 0 0 0)", "(color 0 100 200)")

		-- get current modifier & subobjectlevel
		curMod = modpanel.getcurrentobject()

		if curMod == undefined then (
			-- unable to get current modifier.. exit
			enablesceneredraw()
			return false
		)
		if curMod != $.baseobject then (
			curModIndex = modpanel.getmodifierindex $ curMod
			curModEnabled = curMod.enabled
		) else (
			curModIndex = 0
			curModEnabled = true
		)
		curSubLevel = subobjectlevel

		if argLastMod == unsupplied then argLastMod = curModIndex
		
		-- create rollout string
		local varExe = "(\n
local rolMain
local varSelectedProp
global closeMSPDialog
global startMSPTimer\n\n"
		
				-- setup dialog position
		if argPos != unsupplied then (
			varExe += "local dialogPos = [" + argPos.x as string + ", " + argPos.y as string + "]"
		) else (
			varExe += "local dialogPos = [mouse.screenpos.x - " + (dialogSize.x / 2) as string + ", mouse.screenpos.y - 30]"
		)
		varExe += "
	if dialogPos.x < 0 then dialogPos.x = 0
	if dialogPos.x + " + (dialogSize.x + 6) as string + " > systemtools.getscreenwidth() then dialogPos.x = systemtools.getscreenwidth() - " + 
(dialogSize.x + 6) as string + "
	if dialogPos.y < 0 then dialogPos.y = 0
	if dialogPos.y + " + (dialogSize.y + 50) as string + " > systemtools.getscreenheight() then dialogPos.y = systemtools.getscreenheight() - " + 
(dialogSize.y+ 50) as string + "
\n"

	-- functions
	varExe += "\tfn closeMSPDialog argRestart: argProps: resetPos: argLastMod: = (
	if resetPos == unsupplied then resetPos = dialogPos else resetPos = unsupplied
	callbacks.removescripts id:#MvH_QSO
	destroydialog rolMain
	if argRestart == true then (fnCreateMSPRollout argPos:resetPos argProps:argProps argLastMod:argLastMod)
)

fn startMSPTimer = ( rolMain.tmrRestart.active = true )
\n"
	
	-- start rollout
	varExe += "rollout rolMain \"Modify Stack\" width:" + dialogSize.x as string + " height:" + dialogSize.y as string + " (
	activeXControl tvStack \"MSComctlLib.TreeCtrl\" width:160 height:240 offset:[-8, 0]
	activeXControl imageList \"MSComctlLib.ImageListCtrl\" width:0
	checkbutton btnEndResult images:#(\"$ui\\icons\\MvH Tools_Modify Stack Popup_i.bmp\", undefined, 5, 1, 2, 2, 2) width:18 height:18 align:#left 
offset:[-8, -20] checked:" + showendresult as string + " tooltip:\"Show end result on/off toggle\"
	button btnRemove images:#(\"$ui\\icons\\MvH Tools_Modify Stack Popup_i.bmp\", undefined, 5, 3, 4, 4, 4) width:18 height:18 align:#left 
offset:[15, -23] enabled:" + (curModIndex != 0) as string + " tooltip:\"Remove modifier from the stack\"
	button btnHelp images:#(\"$ui\\icons\\MvH Tools_Modify Stack Popup_i.bmp\", undefined, 5, 5, 5, 5, 5) width:18 height:18 align:#left 
offset:[38, -23] tooltip:\"Help!\"
	timer tmrRestart interval:250 active:false
	
	on tmrRestart tick do (
		tmrRestart.active = false
		closeMSPDialog argProps:" + argProps as string + " argRestart:(modpanel.getcurrentobject() != undefined)
	)
	
	on btnEndResult changed state do ( showendresult = state )
	on btnRemove pressed do (
		undo \"Delete Modifier\" on (
			deletemodifier $ (modpanel.getcurrentobject())
		)
		closeMSPDialog argProps:" + argProps as string + " argRestart:true --keyboard.shiftpressed
	)
	on btnHelp pressed do (
		messagebox \"Modify Stack Popup\nZZZZZZZZZZZZZZZZ
version: 1.0
© 2002 Martijn van Herk\n\n
Some tips:\nZZZZZZZZ
Press CONTROL and click on a modifier
to disable/enable it.\n
Press CONTROL+SHIFT and click on a modifier
to disable/enable it in the viewports.\n
Press SHIFT while clicking on a subobject level
to leave the dialog open.\" title:\"Help / About\"
	)
	"
	
	-- show props button
	local propsCaption = " \"Params >\" "
	if argProps then propsCaption = " \"< Params\" "
	varExe += "button btnShowProps" + propsCaption + "width:55 height:18 align:#left offset:[97, -23]
on btnShowProps pressed do (
	closeMSPDialog argRestart:true argProps:(not " + argProps as string + ")
)\n\n"
		
	-- show properties
	if argProps then (
		varExe += "
activexcontrol lstProps \"{BDD1F04B-858B-11D1-B16A-00C0F0283628}\" width:290 height:240 pos:[170, 4]
label propLabel \"Select a property\" align:#right pos:[274, 250]
spinner propFloat \"\" fieldwidth:87 pos:[359, 249] range:[-1000000, 1000000, 0] visible:false
on propFloat changed val do (
	local varMod = execute varSelectedProp.listsubitems[2].tag
	local varProp = varSelectedProp.tag as name
	try (
		setproperty varMod varProp val
		varSelectedProp.listsubitems[1].text = val as string
		varSelectedProp.listsubitems[1].tooltiptext = varSelectedProp.listsubitems[1].text
	) catch ()
)
spinner propInteger \"\" fieldwidth:87 type:#integer pos:[359, 249] range:[-1000000, 1000000, 0] visible:false
on propInteger changed val do (
	local varMod = execute varSelectedProp.listsubitems[2].tag
	local varProp = varSelectedProp.tag as name
	try (
		setproperty varMod varProp val
		varSelectedProp.listsubitems[1].text = val as string
		varSelectedProp.listsubitems[1].tooltiptext = varSelectedProp.listsubitems[1].text
	) catch ()
)
checkbox propBoolean \"\" width:100 height:18 pos:[359, 249] visible:false
on propBoolean changed state do (
	local varMod = execute varSelectedProp.listsubitems[2].tag
	local varProp = varSelectedProp.tag as name
	try (
		setproperty varMod varProp state
		varSelectedProp.listsubitems[1].text = state as string
		varSelectedProp.listsubitems[1].tooltiptext = varSelectedProp.listsubitems[1].text
	) catch ()
)
mapbutton propTexturemap \"\" width:100 height:18 pos:[359, 249] visible:false
on propTexturemap picked map do (
	local varMod = execute varSelectedProp.listsubitems[2].tag
	local varProp = varSelectedProp.tag as name
	try (
		setproperty varMod varProp map
		varSelectedProp.listsubitems[1].text = map as string
		varSelectedProp.listsubitems[1].tooltiptext = varSelectedProp.listsubitems[1].text
	) catch ()
)
"
	)

createdialog rolMain pos:[dialogPos.x, dialogPos.y] style:#(#style_toolwindow, #style_sysmenu)