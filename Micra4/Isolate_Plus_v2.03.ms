---------------------
---------------------
--                 --
--    ISOLATE +    --
--                 --
---------------------
---------------------

Global mcisoDialog
Global mcIsolatePlus

--> Dupplicate block
if mcisoDialog != undefined and classOf mcisoDialog == RolloutClass and mcisoDialog.isDisplayed 
then 
(
	destroyDialog mcisoDialog
)
else
(
----------------------------------------------------------------------------
/* Dialog */
----------------------------------------------------------------------------	
rollout mcisoDialog " Isolate+  v2.03" width:140 height:400
(			
	-->Locals:-----------------------------------------------------------------
	local dMove = false , DmPos
	--Menu:---------------------------------------------------------------------
	multiListBox LBox "" pos:[4,52] width:132 height:22 items:#("")
	button btn_I2 "Zoom Extens:" pos:[24,4] width:92 height:20 toolTip:"Zoom Extens"		
	button btn_I3 "All" pos:[4,350] width:44 height:20 toolTip:"Select All"
	button btn_I4 "None" pos:[92,350] width:44 height:20 toolTip:"Deselect All"
	button btn_I5 "Invert" pos:[48,350] width:44 height:20 toolTip:"Invert Selection"
	button ntnRenUp "" pos:[4,384] width:12 height:12 toolTip:"First Literals Big"
	button ntnRenDown "" pos:[16,384] width:12 height:12 toolTip:"First Literals Small"
	button btn_I8 "" pos:[28,384] width:12 height:12 toolTip:"blank 2"
	checkButton ckb_1 "I" pos:[4,4] width:20 height:20 toolTip:"Isolate" checked:on
	checkButton ckb_2 "S" pos:[116,4] width:20 height:20 toolTip:"Select"
	edittext edtBox "" pos:[0,28] width:136 height:20
	----------------------------------------------------------------------------
	/* Structure */
	----------------------------------------------------------------------------
	struct mcIsolatePlus
	(
		fn changeFirstLetterInObjectsTo type =
		(
			local abc = case type of
			(
				#upper:"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
				#lower:"abcdefghijklmnopqrstuvwxyz"
			)
			for o in objects do
			(
				local objName = o.name
				local firstLetter = objName[1]
				local foundPos = findString abc firstLetter
				--format "oName:%\tLeter:%\tNum:%\n" objName firstLetter foundPos
				if foundPos != undefined do 
				(
					objName[1] = abc[foundPos]
					o.name = objName
				)
			)
		),
		fn changeAllLettersIn str type =
		(
			local abc = case type of
			(
				#upper:"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
				#lower:"abcdefghijklmnopqrstuvwxyz"
			)
			for n=1 to str.count do
			(
				local foundPos = findString abc str[n]
				if foundPos != undefined do str[n] = abc[foundPos]
			)
			return str
		),
		fn selectItemsFrom text = 
		(
			if text != "" do
			(
				local selNum = #()
				local itms = LBox.items
				local count = itms.count
				for i=1 to count do
				( 
					local subTxt = substring itms[i] 1 text.count
					local subTxtLower = mcIsolatePlus.changeAllLettersIn subTxt #lower
					--format "low:%\ttext:%\n" subTxtLower text
					if subTxtLower == text do append selNum i
				)
				LBox.selection = selNum
			)
		),
		fn collectObjects type=
		(			
			case type of
			(
				 --all names if not in a group
				#AllNGM:(for i in $objects where (not isGroupMember i and not isGroupHead i) collect i.name)+
				(for i in $objects where isGroupHead i collect i.name)-- "["+i.name+"]")
				 --all names if not in a clossed group 
				#VisNCM:(for i in $objects where (not isGroupMember i and not isGroupHead i and not i.isHidden) collect i.name)+
				(for i in $objects where (isOpenGroupMember i and not i.isHidden) collect i.name)+
				(for i in $objects where (isGroupHead i and not i.isHidden) collect i.name)-- "["+i.name+"]")
				--
				#LBoxNamSel:(for i in mcisoDialog.LBox.selection collect mcisoDialog.LBox.items[i])
				#AllNam:(for i in $objects collect i.name)
				#VisNam:(for i in $objects where not i.isHidden collect i.name)
				#VisNum:(for i in (for o in $objects where not o.isHidden collect o.name) collect (findItem mcisoDialog.LBox.items i))
				#SelNam:(for i in $Selection collect i.name)
				#SelNum:(for i in (for o in $Selection collect o.name) collect (findItem mcisoDialog.LBox.items i))
			)
		),
		fn updateListbox =
		(
			if mcisoDialog.ckb_1.checked then
			(
				mcisoDialog.LBox.items = sort (mcIsolatePlus.collectObjects #AllNGM)
				mcisoDialog.LBox.selection = mcIsolatePlus.collectObjects #VisNum
			) 
			else
			(
				mcisoDialog.LBox.items = sort (mcIsolatePlus.collectObjects #VisNCM)
				mcisoDialog.LBox.selection = mcIsolatePlus.collectObjects #SelNum
			)
		)
	)
	----------------------------------------------------------------------------
	/* Actions */
	----------------------------------------------------------------------------	
	-->Dialog settings
	
	-->If mcisoDialog is opened, get objects names to listbox and mark if visible.
	on mcisoDialog open do
	(
		mcIsolatePlus.updateListbox()
		setFocus mcisoDialog.edtBox--the text field gets focus!
		-->Callbacks
		callbacks.addScript #nodeHide            " mcIsolatePlus.updateListbox() " id:#mIsolateVis
		callbacks.addScript #nodeUnhide          " mcIsolatePlus.updateListbox() " id:#mIsolateVis
		callbacks.addScript #sceneUndo           " mcIsolatePlus.updateListbox() " id:#mIsolate
		callbacks.addScript #sceneRedo           " mcIsolatePlus.updateListbox() " id:#mIsolate
		callbacks.addScript #nodePostDelete      " mcIsolatePlus.updateListbox() " id:#mIsolate
		callbacks.addScript #nodeCreated         " mcIsolatePlus.updateListbox() " id:#mIsolate
		callbacks.addScript #nodeRenamed         " mcIsolatePlus.updateListbox() " id:#mIsolateRen
		callbacks.addScript #filePostOpen        " mcIsolatePlus.updateListbox() " id:#mIsolate	
		callbacks.addScript #systemPostReset     " mcIsolatePlus.updateListbox() " id:#mIsolate	
		callbacks.addScript #SelectionSetChanged " mcIsolatePlus.updateListbox() " id:#mIsolateSel
	)
	-->If mcisoDialog is closed or (alt + F4) then all Calbacks stoped.
	on mcisoDialog close do
	(
		mcCall.saveIniDialog "mcisoDialog" "Properties_2"
		callbacks.removeScripts id:#mIsolate
		callbacks.removeScripts id:#mIsolateVis
		callbacks.removeScripts id:#mIsolateSel
		callbacks.removeScripts id:#mIsolateRen
	)
	on mcisoDialog rbuttonup pos   do(destroyDialog mcisoDialog)
	-->MoveMode
	on mcisoDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcisoDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcisoDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do mcDialogSnap mcisoDialog DmPos
	)
		-->Switch Visibility Mode to Selection Mode
		on ckb_1 changed state do 
			(if mcisoDialog.ckb_1.checked then (mcisoDialog.ckb_2.checked=off) else (mcisoDialog.ckb_2.checked=on) ;mcIsolatePlus.updateListbox())
		on ckb_2 changed stat do
			(if mcisoDialog.ckb_2.checked then (mcisoDialog.ckb_1.checked=off) else (mcisoDialog.ckb_1.checked=on) ;mcIsolatePlus.updateListbox())
		-->Hide/Unhide/Select
		on LBox selected nLabel do
			(
			if mcisoDialog.ckb_1.checked then
				(
				--remove visibility callbacks to prevent flickering
				callbacks.removeScripts id:#mIsolateVis
				
				--local LBox_Sel_Name =  getNodeByName mcisoDialog.LBox.items[nLabel]
				local LBox_Sel_Name =  getNodeByName mcisoDialog.LBox.items[nLabel]
				
				--progress hidde unhide objects
				if isGroupHead LBox_Sel_Name then
					(
					if (GroupItems (LBox_Sel_Name))[1].isHidden
					then(unhide (GroupItems LBox_Sel_Name) dolayer:true)
					else (hide   (GroupItems LBox_Sel_Name) ; deselect (GroupItems LBox_Sel_Name))
					)
				else 
					(
					if LBox_Sel_Name.isHidden 
					then (unhide LBox_Sel_Name dolayer:true) 
					else (hide LBox_Sel_Name ; deselect LBox_Sel_Name)
					)

				--add visibility callbacks
				callbacks.addScript #nodeHide "mcIsolatePlus.updateListbox()" id:#mIsolateVis 
				callbacks.addScript #nodeUnhide "mcIsolatePlus.updateListbox()" id:#mIsolateVis
				)
			else 
				(
				--remove selection callbacks to prevent flickering
				callbacks.removeScripts id:#mIsolateSel
				
				local LBox_Sel =for i in LBox.selection collect getNodeByName LBox.items[i]
				select LBox_Sel
				
				--add selection callbacks
				callbacks.addScript #SelectionSetChanged " mcIsolatePlus.updateListbox() " id:#mIsolateSel
				)
			--Send number of selected items to button
			btn_I2.caption = "Zoom Extens: "+((mcisoDialog.LBox.selection as array).count)as string
			)
		-->Select object and Zoom Extents
		on LBox doubleClicked nLabel do 
			(select (getNodeByName LBox.items[nLabel]) ; actionMan.executeAction 0 "310" )
		-->Zoom extens | zoom extens selection	
		on btn_I2 pressed  do
			(
			actionMan.executeAction 0 "310"   
			)
		--Unhide/Unselect all Object
		on btn_I3 pressed  do
			(
			if mcisoDialog.ckb_1.checked then
				(
				--remove visibility callbacks to prevent flickering
				callbacks.removeScripts id:#mIsolateVis
				
				mcisoDialog.LBox.selection = (for i in 1 to $objects.count collect i)
				unhide $Objects dolayer:true
				mcisoDialog.btn_I2.caption = "Zoom Extens: "+((mcisoDialog.LBox.selection as array).count)as string
				
				--add visibility callbacks
				callbacks.addScript #nodeHide "mcIsolatePlus.updateListbox()" id:#mIsolateVis 
				callbacks.addScript #nodeUnhide "mcIsolatePlus.updateListbox()" id:#mIsolateVis
				)
			else 
				(
				local Listbox_Items_Num = (for i in 1 to mcisoDialog.LBox.items.count collect i)
				local Listbox_Items_Name = (for i in 1 to mcisoDialog.LBox.items.count collect (getNodeByName LBox.items[i])) 
				mcisoDialog.LBox.selection=Listbox_Items_Num
				Select Listbox_Items_Name
				mcisoDialog.btn_I2.caption = "Zoom Extens: "+((mcisoDialog.LBox.selection as array).count)as string
				)
			)
		--Deselect All items in Menu to Hide all Object
	on btn_I4 pressed  do
	(
		if mcisoDialog.ckb_1.checked then
		(
			--remove visibility callbacks to prevent flickering
			callbacks.removeScripts id:#mIsolateVis
			
			mcisoDialog.LBox.selection = 0
			deselect $Objects
			hide $Objects
			mcisoDialog.btn_I2.caption = "Zoom Extens: 0"
			
			--add visibility callbacks
			callbacks.addScript #nodeHide "mcIsolatePlus.updateListbox()" id:#mIsolateVis 
			callbacks.addScript #nodeUnhide "mcIsolatePlus.updateListbox()" id:#mIsolateVis
			
		)
		else 
		(
			mcisoDialog.LBox.selection = 0
			deselect $Objects
		)
	)
	--Invert Selection
	on btn_I5 pressed do
	(
		if mcisoDialog.ckb_1.checked then
			(
			--remove visibility callbacks to prevent flickering
			callbacks.removeScripts id:#mIsolateVis
			
			local Vis_Obj =(for i in $objects where i.isHidden==false collect i)
			unhide $Objects dolayer:true ; hide Vis_Obj
		
			--add visibility callbacks
			callbacks.addScript #nodeHide "mcIsolatePlus.updateListbox()" id:#mIsolateVis 
			callbacks.addScript #nodeUnhide "mcIsolatePlus.updateListbox()" id:#mIsolateVis
			)
		else (max select invert)
		mcIsolatePlus.updateListbox()
	)
	-- First Literals up
	on ntnRenUp pressed do undo "First Literals Big" on
	(
		--remove selection callbacks to prevent flickering
		callbacks.removeScripts id:#mIsolateRen
		callbacks.removeScripts id:#mIsolateSel
		mcIsolatePlus.changeFirstLetterInObjectsTo #upper
		callbacks.addScript #nodeRenamed " mcIsolatePlus.updateListbox() " id:#mIsolateRen
		callbacks.addScript #SelectionSetChanged " mcIsolatePlus.updateListbox() " id:#mIsolateSel
		mcIsolatePlus.updateListbox()	
	)
	-- First Literals down
	on ntnRenDown pressed do undo "First Literals Small" on 
	(
		--remove selection callbacks to prevent flickering
		callbacks.removeScripts id:#mIsolateRen
		callbacks.removeScripts id:#mIsolateSel
		mcIsolatePlus.changeFirstLetterInObjectsTo #lower
		callbacks.addScript #nodeRenamed " mcIsolatePlus.updateListbox() " id:#mIsolateRen
		callbacks.addScript #SelectionSetChanged " mcIsolatePlus.updateListbox() " id:#mIsolateSel
		mcIsolatePlus.updateListbox()	
	)
	on edtBox changed text do
	(
		mcIsolatePlus.selectItemsFrom text
		
		local selItems = LBox.selection
		local items = LBox.items
		
		if selItems.count == 0 do return OK 
		
		if mcisoDialog.ckb_1.checked then
		(	
			print "not ready yet"
		)
		else
		(
			local obj = for i in selItems collect (getNodeByName items[i])
			select obj 
		)
	)		
)
mcCall.createIniDialog "mcisoDialog" "Properties_2"
)
/*
print (callbacks.notificationParam()) 
*/