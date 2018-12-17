
--Locals:----------------------------------------
local dMove = false, DmPos


-->Dialog
on telpDialogName rbuttonup pos do (destroyDialog telpDialogName)
on telpDialogName close do ( mc2Call.saveIniDialog "telpDialogName" "Properties_2" )
-->Move Dialog Mode
on telpDialogName lbuttondown pos do(dMove = true ; DmPos = pos)
on telpDialogName lbuttonup pos   do(dMove = false)
on telpDialogName mouseMove pos do
(
	if dMove and keyboard.shiftPressed do
	(
		if mc2DialogSnappingEnabled
		then mc2DialogSnap telpDialogName DmPos
		else setDialogPos telpDialogName (mouse.screenpos - DmPos)
	)
)


mc2Call.createIniDialog "telpDialogName" "Properties_2"