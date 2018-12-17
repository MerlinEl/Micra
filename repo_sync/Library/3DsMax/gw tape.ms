------------------------------------------------------------------------------------------------------------
if ((t_Tape != undefined) and (t_Tape.isDisplayed)) do (destroyDialog t_Tape)
------------------------------------------------------------------------------------------------------------
(
	unRegisterRedrawViewsCallback showObjectNames

	rollout t_Tape " Tape Measure v1.5" width:175 height:130
	(	
		fn showObjectNames =
		(	
			gw.setTransform(Matrix3 1)
			for o in Helpers where not o.isHidden and classof o == tape and o != Target do
			(
				gw.text ((o.pos+o.target.pos)/2+[0,0,0]) (distance o o.target as string) color:yellow
			)	--end o loop
			gw.enlargeUpdateRect #whole
			gw.updateScreen()
		) -- end function
		
		local pPoz, qPoz, pointA, pointB, rTape
		pickbutton pbt_picktS "Select start" pos:[10, 7] width:154 autoDisplay:true
		pickbutton pbt_picktT "Select end" width:154 autoDisplay:true
		button but_Go "Go" across:2 width:60
		button but_dtape "un-Go" width:60
		edittext edTxt_txt "Distance:" fieldWidth:101 align:#center bold:true 
		button but_sTape "Grab Tape" pos:[17, 107] width:67 height:16 
		button but_sTarg "Grab Target" pos:[93, 107] width:67 height:16 
			
		on pbt_picktS picked pointA do --pickbutton to select the first item
		(
			if pointA != undefined do
			(
				pPoz = pointA.pos as point3 --make the picked objects position a point3 and put to variable
			)
		)

		on pbt_picktT picked pointB do --pickbutton to select the second item
		(
				if pointB != undefined do
			(
				qPoz = pointB.pos as point3 --make the picked objects position a point3 and put to variable
			)
		)
		
		on but_dtape pressed do -- delete the tape and reset the buttons and textbox
		(
			if isValidNode rTape do
			(
				select rTape
				delete rTape
				pbt_picktS.text = "Select start"
				pbt_picktT.text = "Select end"
				edTxt_txt.text = ""
				but_sTape.text = "Grab tmTape"
				but_sTarg.text = "Grab Target"
				pPoz = qPoz = rTape = pbt_picktT.object = pbt_picktS.object = undefined
			)
		)
					
			on but_sTape pressed do
			(
			  if isValidNode rTape do
			  (
				select rTape
				but_sTape.text = rTape.name
			  )
			)
			
			on but_sTarg pressed do
			(
			  if isValidNode rTape do
			  (
				select rTape.target
				but_sTarg.text = rTape.Target.name
			  )
			)
		
		on but_Go pressed do
		(
			rTape = tape pos:pPoz target:(targetObject pos:qPoz) --create the tape and insert the start pos and the target pos
			fn getTapeDist TapeObj = distance TapeObj TapeObj.target --function to calculate the distance
			edTxt_txt.text = (getTapeDist rTape as string) --Call the function and insert into textbox
			setclipboardText edTxt_txt.text --Save the result into the clipboard
			select rTape -- select the tape
			
			if t_Tape != undefined then
			(
				unRegisterRedrawViewsCallback showObjectNames
				RegisterRedrawViewsCallback showObjectNames
				showObjectNames()
			) -- end if
				else
				(
					unRegisterRedrawViewsCallback showObjectNames 	
					max views redraw
				) --end else
		)
	)
	createdialog t_Tape style:#(#style_toolwindow, #style_sysmenu)
)