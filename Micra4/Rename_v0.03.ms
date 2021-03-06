--******************************************
-- Object Renaming Utility
-- 1.29.99 v1.06
-- David Humpherys
-- david@rezn8.com
--******************************************
--Dialog--------------------------------------------------------------------
if mcRenameDialog != undefined then destroyDialog mcRenameDialog
----------------------------------------------------------------------------
(	
	global ReNameFloater
	local MyAry = #()
	local PickAry = #()
	local checked = false
	rollout mcRenameDialog "" width:224 height:368
	(
		local dMove = false, DmPos
		--Menu:---------------------------------------------------------------------
		groupBox grp11 "Rename Objects" pos:[4,4] width:216 height:304
		radiobuttons objs "" pos:[52,24] width:129 height:16 labels:#("Selected", "Pick") columns:2
		checkbox base "" pos:[12,52] width:16 height:16 --checked:true
		edittext base_text "Base Name: " pos:[30,52] width:172 height:16 enabled:true fieldwidth:101 
		checkbox prefix "" pos:[12,85] width:16 height:16
		edittext pre_text "Prefix: " pos:[30,85] width:172 height:16 enabled:true fieldwidth:101 
		spinner delPreSpin "" pos:[100,109] width:45 height:16 range:[0,20,0] type:#integer
		checkbox delPre "Remove First:" pos:[12,109] width:89 height:16 
		checkbox suffix "" pos:[12,142] width:16 height:16
		edittext suf_text "Suffix: " pos:[30,142] width:172 height:16 enabled:true fieldwidth:101 
		spinner delSufSpin "" pos:[100,166] width:45 height:16 range:[0,20,0] type:#integer
		checkbox delSuf "Remove Last:" pos:[12,166] width:90 height:16 
		checkbox suf_num "Numbered" pos:[12,199] width:73 height:16
		spinner base_num "Base Number: " pos:[62,219] width:90 height:16 range:[0,9999,0] type:#integer 
		spinner num_step "Step: " pos:[85,240] width:68 height:16 range:[-999,999,1] type:#integer 
		button 'btn_rename' "Rename" pos:[8,328] width:100 height:30 align:#left
		button 'btn_unique_rename' "Unique Name" pos:[112,328] width:100 height:30 align:#left
	
		label lbl16 "Digits" pos:[149,109] width:40 height:16
		label lbl17 "Digits" pos:[149,166] width:40 height:16
		
		checkbox 'chk_replace' "Replace" pos:[12,256] width:73 height:16 align:#left
		edittext 'edt_replace_form' "from: " pos:[28,276] width:172 height:16 enabled:true fieldwidth:101 align:#left
		edittext 'edt_replace_to' "to    : " pos:[28,300] width:172 height:16 enabled:true fieldwidth:101 align:#left
		-----------------------------------------------------------------------------------------------		
		fn uniqueRenameSelection = (
			
			local base_name = if base.state do (
				
				if base_text.text.count == 0 then (
					
					messagebox "Base name is empty." Title:"Warning"
					return false
				)
				base_text.text
			)
			
			for o in selection do (
				
				if base_name == undefined do base_name = o.name
				o.name = uniqueName base_name
			)
		)
		fn replaceStringInObjectName obj str_from str_to = (
			
			local obj_name = obj.name 
			local str_start = findString obj_name  str_from	
			if str_start != undefined do (

				--format "replace obj:% from:% str:% by:%\n" obj_name str_start str_from str_to
				local new_name = replace obj_name str_start str_from.count str_to
				obj.name = new_name
			)
		)
		
		on mcRenameDialog rbuttonup pos do (destroyDialog mcRenameDialog )
		on mcRenameDialog close do 
		(
			mcFile.saveDialogSettings "mcRenameDialog" "Properties_2"
			checked = false ; updateToolbarButtons() 
		)
		-->MoveMode
		on mcRenameDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
		on mcRenameDialog lbuttonup   pos do (dMove = false; pushprompt "")
		on mcRenameDialog mouseMove   pos do
		(
			if dMove and keyboard.shiftPressed do mcDialog.snapDialog mcRenameDialog DmPos
		)
		-----------------------------------------------------------------------------------------------				
		on objs changed state do
		(
			if objs.state==2 then
			(
			-- CAL-06/21/02: use the previously picked object if selectByName is canceled
			MyAry =selectByName title:"Pick Objects to Rename" buttonText:"Use"
			if MyAry == undefined then MyAry = PickAry else PickAry = MyAry
			print MyAry
			)
		)
		on btn_rename pressed do with undo on
		(	
			if objs.state==1 then MyAry=selection
			findErrors=0
			CountNum=1
			for i in MyAry do
			(		
				if chk_replace.state  do (
					
					replaceStringInObjectName i edt_replace_form.text edt_replace_to.text
					continue --skip other steps
				)
				
				if base.state==true then 
					(
					if base_text.text.count==0 then 
						(
						messagebox "Base Name text field empty." Title:"Base Rename Error"
						exit loop
						)
					i.name=base_text.text
					)
		
				if delpre.state==true then 
					(	
					if delprespin.value >= i.name.count then 
						(
						messagebox "The object being renamed doesn't have enough characters in
its name to remove the requested number. Rename cancelled." Title:"Prefix Rename Error:" 
						FindErrors=1
						exit loop
						)
					i.name=(substring i.name (delprespin.value+1) i.name.count)
					)
					
				if prefix.state==true then 
					(
					if Pre_text.text.count==0 then 
						(
						messagebox "Add Prefix text field empty." Title:"Prefix Rename Error:"
						FindErrors=1
						exit loop
						)
					i.name=(pre_text.text + i.name)
					)
							
				if delsuf.state==true then 
					(
					if delsufspin.value>=i.name.count then 
						(
						messagebox "The object being renamed doesn't have enough characters in
its name to remove the requested number. Rename cancelled." Title:"Suffix Rename Error:"
						FindErrors=1
						exit loop
						)
					i.name=(substring i.name 1 (i.name.count-delsufspin.value))
					)
					
				if suffix.state==true then 
					(
					if suf_text.text.count==0 then 
						(
						messagebox "Add Suffix text field empty." Title:"Suffix Rename Error:"
						FindErrors=1
						exit loop
						)
					i.name=(i.name + suf_text.text)
					)
		
				if suf_num.state==true then 
					(
					NumberPad=((base_num.value + ((CountNum-1)*num_step.value)) as string)
					if NumberPad.count == 1 then NumberPad=("0"+NumberPad)
					i.name=i.name + NumberPad
					CountNum+=1
					-- print "hello"
					)
			)
		)
		on btn_unique_rename pressed do uniqueRenameSelection()
	)
on execute do
	(
	-----------------------------------------------------------------------------------------------
	mcCall.createXMLDialog "mcRenameDialog" "Properties_2"  modal:false 
	checked = true
	-----------------------------------------------------------------------------------------------
	)
on isChecked return (checked)
)




