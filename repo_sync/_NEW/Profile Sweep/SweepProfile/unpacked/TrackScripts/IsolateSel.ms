(
local HideObjects
local XrefCount = xrefs.getXRefFileCount()
local inipath=getFilenamePath (getsourceFileName()) + "\\TrackScripts.ini"
local floatpos
if doesFileExist inipath then floatpos= execute (getinisetting inipath "IsolateSelection" "FloatPos")
	else floatpos = [100,100]
local XrefState = #()
if fileProperties.findProperty #custom "XrefState"!=0 then
	(
	XrefState=(execute (fileProperties.getPropertyValue #custom (fileProperties.findProperty #custom "XrefState")))
	)
rollout IsolateSel "Warning: Isolated Selection" width:88 height:26
(
	checkbutton chkIso "Isolation Mode" pos:[2,3] width:81 height:19 highlightColor:(color ((colorman.getcolor #activecommand).x *255) ((colorman.getcolor #activecommand).y *255)((colorman.getcolor #activecommand).z *255)) checked:true

on chkIso changed state do destroyDialog IsolateSel

on IsolateSel close do(
			setinisetting inipath "IsolateSelection" "FloatPos" (GetDialogPos(IsolateSel)as string)
			try HideObjects = selectionSets["HideObjects"] catch()
			try unhide HideObjects catch()
			for i in selectionSets.count to 1 by -1 do try(
			if (getNamedSelSetName i)== "HideObjects" then
			deleteItem SelectionSets i
			if XrefCount > 0 do for i in 1 to XrefCount do ((xrefs.getXRefFile i).hidden = (XrefState[i]))
			fileProperties.deleteProperty #custom "XrefState"
			IsolateSel=undefined
			) catch()
		)

on IsolateSel open do (
	if (selectionSets["HideObjects"]==undefined) then(
		HideObjects = for i in objects where i.isSelected==false and i.isHidden==false and i.isFrozen==false collect i
		if XrefCount > 0 do
			(
			XrefState = for i in 1 to XrefCount collect (xrefs.getXRefFile i).hidden
			fileProperties.addProperty #custom  "XrefState" (XrefState as string)
			for i in 1 to XrefCount do (xrefs.getXRefFile i).hidden = true
			)
		hide HideObjects
		selectionSets["HideObjects"] = HideObjects
-- 		Max tool zoomextents
		)else(
				HideObjects = selectionSets["HideObjects"]
				unhide HideObjects
				if XrefCount > 0 do for i in 1 to XrefCount do ((xrefs.getXRefFile i).hidden = (XrefState[i]))
				fileProperties.deleteProperty #custom "XrefState"
				for i in selectionSets.count to 1 by -1 where (getNamedSelSetName i)== "HideObjects" do (deleteItem SelectionSets i)
				destroyDialog IsolateSel
		)
	)
)
createdialog IsolateSel pos:floatpos style:#(#style_toolwindow, #style_sysmenu)
)
