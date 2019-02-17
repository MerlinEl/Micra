--------------------------------------------------------------------------------
/* mcDialog by Orien 2019 */
--------------------------------------------------------------------------------
/*
*@Used Structures
	mcScreen
	mcMath
	Micra
	mcDotnet
*
*@Used Objects
	mcRect
*
*/
Struct MICRA_DIALOG (

	fn getSource = getSourceFileName(), --get path of this script
	--> TODO test > Make grid with size 01  to snap dialogs, Rene (2018)
	fn snapForm formA pos =
	(
		if classOf formA != dotNetObject or pos == undefined do return false
		
		local formA_newpos = mouse.screenpos - pos
		--round pos to grid size
		formA_newpos.x = mcMath.roundToInt formA_newpos.x 10
		formA_newpos.y = mcMath.roundToInt formA_newpos.y 10

		--format "snapForm form:% pos1:%\n" formA.name formA_newpos
		
		--final move action
		formA.location = mcDotnet.dPoint [formA_newpos.x, formA_newpos.y]
	),	
	/*
	* mcDialog.snapForm
	*/
	fn snapForm_old formA pos =
	(
		if classOf formA != dotNetObject or pos == undefined do return false
		local current_monitor = 1 --mcScreen.active() //causing ** system exception **
		local desktop_size = mcScreen.fullsize()
		desktop_size.y = (mcScreen.size num:current_monitor).y --sysInfo.DesktopSize
		local desktop_pos = mcScreen.pos num:current_monitor --[0, 0]
		local formA_pos = [formA.location.x, formA.location.y] --A form pos
		local formA_size = [formA.width, formA.height] --A form size
		local desktop_rect   = mcRect mi:desktop_pos ma:desktop_size --min/max from windows size
		local formA_rect   = mcRect (p=copy formA_pos) (p+formA_size+[0,4])--min max from picked form
		
		--get bounds rect from picked form
		local x = formA_rect.mi.x
		local y = formA_rect.mi.y
		
		--Zadr
		local formA_newpos = mouse.screenpos - pos
		--round pos to grid size
		--format "form pos A:%\n" formA_newpos
	formA_newpos.x = (mcMath.roundToInt formA_newpos.x 10)+2 -- 2(border size)
	formA_newpos.y = (mcMath.roundToInt formA_newpos.y 10)+2
		--formA_newpos.x = mcMath.roundToEven formA_newpos.x
		--formA_newpos.y = mcMath.roundToEven formA_newpos.y
		--format "form pos B:%\n" formA_newpos
		--fill rect
		formA_rect.mi.x = formA_newpos.x
		formA_rect.ma.x = x + formA_size.x
		formA_rect.mi.y = formA_newpos.y
		formA_rect.ma.y = y + formA_size.y
		
		local sDist = desktop_rect.ma.x / 200-- set snap distance
		
		--get visible form names
		local all_forms = mcFile.readSettings Micra.UserProfile "Properties_1" type:"keys"
			 join all_forms (mcFile.readSettings Micra.UserProfile "Properties_2" type:"keys")
		local visible_forms = for i in all_forms where (execute ("classOf "+ i +"== dotNetObject")) and (execute(i+".Visible")) collect i
		
		for i in visible_forms do
		(
			local formB = (execute i)
			local formB_pos  = [formB.location.x, formB.location.y]
			local formB_size = [formB.width, formB.height]
			--min max from B (visible) forms
			local formB_rect = mcRect formB_pos (formB_pos+formB_size)
			
			--Left
			if formA_rect.mi.x < formB_rect.ma.x+sDist and formA_rect.mi.x > formB_rect.ma.x-sDist and 
			formA_rect.ma.y > formB_rect.mi.y and formA_rect.mi.y < formB_rect.ma.y
			then formA_rect.mi.x = formB_rect.ma.x
			--Zadr???
			formA_rect.ma.x = formA_rect.mi.x + formA_size.x
			--Right
			if formA_rect.ma.x > formB_rect.mi.x-sDist and formA_rect.ma.x < formB_rect.mi.x+sDist and 
			formA_rect.ma.y > formB_rect.mi.y and formA_rect.mi.y < formB_rect.ma.y
			then formA_rect.mi.x = (formB_rect.mi.x-formA_size.x)
			--Top
			if formA_rect.ma.y > formB_rect.mi.y-sDist and formA_rect.ma.y < formB_rect.mi.y+sDist and 
			formA_rect.ma.x > formB_rect.mi.x and formA_rect.mi.x < formB_rect.ma.x 
			then formA_rect.mi.y = (formB_rect.mi.y-formA_size.y)
			--Zadr
			formA_rect.ma.y = formA_rect.mi.y + formA_size.y
			--Bottom
			if formA_rect.mi.y < formB_rect.ma.y+sDist and formA_rect.mi.y > formB_rect.ma.y-sDist and 
			formA_rect.ma.x > formB_rect.mi.x and formA_rect.mi.x < formB_rect.ma.x 
			then formA_rect.mi.y = formB_rect.ma.y
		)

		--if is in Left bound
		if formA_rect.mi.x < desktop_rect.mi.x+sDist 
		then x = 0 
		else 
		--if is in Right bound
		if formA_rect.mi.x+formA_size.x > desktop_rect.ma.x-sDist 
		then x = (desktop_rect.ma.x-formA_size.x) 
		else x = formA_rect.mi.x		
		--if is in Top bound
		if formA_rect.mi.y < desktop_rect.mi.y+sDist 
		then y = 0 
		else 
		--if is in Bottom bound
		if formA_rect.mi.y+formA_size.y > desktop_rect.ma.y-sDist 
		then y = (desktop_rect.ma.y-formA_size.y)
		else y = formA_rect.mi.y
		
		--final move action
		if (formA_pos.x != x or formA_pos.y != y) do formA.location = mcDotnet.dPoint [x, y]
	),
	/*
	* mcDialog.snapDialog
	*/
	fn snapDialog dia pos = (	
	
		if dia == undefined or classOf dia != RolloutClass or pos == undefined do return false
		local current_monitor = mcScreen.active()
		local desktop_size = mcScreen.fullsize()
		desktop_size.y = (mcScreen.size num:current_monitor).y --sysInfo.DesktopSize
		desktop_size -= 6
		local desktop_pos = (mcScreen.pos num:current_monitor) --[0, 0]
		--local desktop_size = sysInfo.DesktopSize - 6
		--local desktop_pos = [4, 4]
		local dialogA_pos = (getDialogPos  dia)-- position from picked dialog 
		local dialogA_size = (getDialogSize dia)-- size from picked dialog
		local rect_desktop   = mcRect mi:desktop_pos ma:desktop_size--min/max from windows size
		local rect_dialogA   = mcRect (p=copy dialogA_pos) (p+dialogA_size+[0,4])--min max from picked dialog
		
		--get bounds rect from picked dialog
		local x = rect_dialogA.mi.x
		local y = rect_dialogA.mi.y
		
		--Zadr???
		local dialogA_newpos = mouse.screenpos - pos
		rect_dialogA.mi.x = dialogA_newpos.x
		rect_dialogA.ma.x = x + dialogA_size.x
		rect_dialogA.mi.y = dialogA_newpos.y
		rect_dialogA.ma.y = y + dialogA_size.y + 4
		
		local sDist = rect_desktop.ma.x / 200-- set snap distance
		
		--get visible Dialog names
		local dialogs_names	= mcFile.readSettings Micra.UserProfile "Properties_1" type:"keys"
		join dialogs_names (mcFile.readSettings Micra.UserProfile "Properties_2" type:"keys")	 
		local visDialogs = for i in dialogs_names where (execute (i+" != undefined")) and (execute ("classOf "+ i +" == RolloutClass")) and (execute(i+".isDisplayed")) collect i

		for i in visDialogs do
		(
			local dialogB_name = (execute i)
			local dialogB_pos  = (getDialogPos  dialogB_name)
			local dialogB_size = (getDialogSize dialogB_name)
			--min max from B (visible) dialogs
			rect_dialogB = mcRect dialogB_pos (dialogB_pos+dialogB_size+[0,4])
			
			--Left
			if rect_dialogA.mi.x < rect_dialogB.ma.x+sDist and rect_dialogA.mi.x > rect_dialogB.ma.x-sDist and 
			rect_dialogA.ma.y > rect_dialogB.mi.y and rect_dialogA.mi.y < rect_dialogB.ma.y
			then rect_dialogA.mi.x = rect_dialogB.ma.x+6
			--Zadr???
			rect_dialogA.ma.x = rect_dialogA.mi.x + dialogA_size.x
			--Right
			if rect_dialogA.ma.x > rect_dialogB.mi.x-sDist and rect_dialogA.ma.x < rect_dialogB.mi.x+sDist and 
			rect_dialogA.ma.y > rect_dialogB.mi.y and rect_dialogA.mi.y < rect_dialogB.ma.y
			then rect_dialogA.mi.x = (rect_dialogB.mi.x-dialogA_size.x)-6
			--Top
			if rect_dialogA.ma.y > rect_dialogB.mi.y-sDist and rect_dialogA.ma.y < rect_dialogB.mi.y+sDist and 
			rect_dialogA.ma.x > rect_dialogB.mi.x and rect_dialogA.mi.x < rect_dialogB.ma.x 
			then rect_dialogA.mi.y = (rect_dialogB.mi.y-dialogA_size.y)-6
			--Zadr???
			rect_dialogA.ma.y = rect_dialogA.mi.y + dialogA_size.y
			--Bottom
			if rect_dialogA.mi.y < rect_dialogB.ma.y+sDist and rect_dialogA.mi.y > rect_dialogB.ma.y-sDist and 
			rect_dialogA.ma.x > rect_dialogB.mi.x and rect_dialogA.mi.x < rect_dialogB.ma.x 
			then rect_dialogA.mi.y = rect_dialogB.ma.y+2
		)

		--if is in Left bound
		if rect_dialogA.mi.x < rect_desktop.mi.x+sDist 
		then x = 0 
		else 
		--if is in Right bound
		if rect_dialogA.mi.x+dialogA_size.x > rect_desktop.ma.x-sDist 
		then x = (rect_desktop.ma.x-dialogA_size.x) 
		else x = rect_dialogA.mi.x		
		--if is in Top bound
		if rect_dialogA.mi.y < rect_desktop.mi.y+sDist 
		then y = 0 
		else 
		--if is in Bottom bound
		if rect_dialogA.mi.y+dialogA_size.y > rect_desktop.ma.y-sDist 
		then y = (rect_desktop.ma.y-dialogA_size.y)
		else y = rect_dialogA.mi.y
		
		--final move action
		if (dialogA_pos.x != x or dialogA_pos.y != y) do setDialogPos dia [x, y]
	)
	/*<end>*/
)
 --create instance
Global mcDialog = mcStructMan.instanceStructure MICRA_DIALOG "mcDialog"
