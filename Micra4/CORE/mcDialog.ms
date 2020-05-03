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

	Registred_Windows = #(), 						-- all visible forms and rollouts
	Mouse_Point = mcDotnet.PointClass.empty,		-- mouse screen pos
	Offset_Point = mcDotnet.PointClass.empty,		-- primary offset
	Form_Offset_Point = mcDotnet.PointClass.empty,	-- calculated offset rect to be added !! (min distances in all directions!!)
	Stick_Gap = 10,									-- distance to stick
	fn getSource = getSourceFileName(),				-- get path of this script
	fn isValidDialog form = (
	
		form != undefined and (
		
			superClassOf 	form == StructDef or 
			classOf 		form == RolloutClass or 
			classOf 		form == dotNetObject
		)
	),
	fn init form = (
	
		Mouse_Point		= mcDotnet.dPoint mouse.screenPos
		local formRect	= form.Bounds
		Offset_Point	= Mouse_Point
		Offset_Point.offset (mcDotnet.dPoint [-formRect.Left, -formRect.Top])
		--[src_form.MousePosition.x, src_form.MousePosition.y]
		--get all Micra Dialog names
		local form_names	= mcFile.readSettings Micra.UserProfile "Properties_1" type:"keys" 
		--filter only visible forms
		join form_names (mcFile.readSettings Micra.UserProfile "Properties_2" type:"keys")	 
		Registred_Windows = for i in form_names where (
		
			local form = execute i
			if form != undefined then (
			
				if superClassOf form == StructDef and form.form != undefined then (
					
					form.form.visible
					
				) else if classOf form == dotNetObject then (
					
					form.visible 
					
				) else if classOf form == RolloutClass then (
				
					form.isDisplayed
					
				) else (
				
					false
				)
				
			) else false
			
		) collect form
		-- format "mcDialog > getActiveDialogs > Registred_Windows:\n\t%\n" Registred_Windows
	),
	fn snapTo formRect toRect inside_stick:false = (
	
		-- compare distance from toRect to formRect
		-- and then with the found distances, compare the most closed position
		if ( formRect.Bottom >= (toRect.Top - Stick_Gap) and formRect.Top <= (toRect.Bottom + Stick_Gap) ) do (
		
			if ( inside_stick ) do (
				-- left 2 right
				if ( (abs(formRect.Left - toRect.Right) <= abs(Form_Offset_Point.X) ) ) do (	
				
					Form_Offset_Point.X = toRect.Right - formRect.Left
				)
				-- right 2 left
				if ( (abs(formRect.Left + formRect.Width - toRect.Left) <= abs(Form_Offset_Point.X) ) ) do (
				
					Form_Offset_Point.X = toRect.Left - formRect.Width - formRect.Left
				)
			)
			-- snap left 2 left
			if ( abs(formRect.Left - toRect.Left) <= abs(Form_Offset_Point.X) ) do (
			
				Form_Offset_Point.X = toRect.Left - formRect.Left
			)
			-- snap right 2 right
			if ( abs(formRect.Left + formRect.Width - toRect.Left - toRect.Width ) <= abs(Form_Offset_Point.X)) do (
			
				Form_Offset_Point.X = toRect.Left + toRect.Width - formRect.Width - formRect.Left
			)
		)
		if ( formRect.Right >= (toRect.Left - Stick_Gap) and formRect.Left <= (toRect.Right + Stick_Gap) ) do (
		
			if ( inside_stick ) do (
			
				-- Stick Top to Bottom
				if (abs(formRect.Top - toRect.Bottom) <= abs(Form_Offset_Point.Y) and inside_stick ) do (	
				
					Form_Offset_Point.Y = toRect.Bottom - formRect.Top
				)
				-- snap Bottom to Top
				if (abs(formRect.Top + formRect.Height - toRect.Top) <= abs(Form_Offset_Point.Y) and inside_stick ) do (	
				
					Form_Offset_Point.Y =  toRect.Top - formRect.Height - formRect.Top
				)
			)

			-- try to snap top 2 top also
			if (abs(formRect.Top - toRect.Top) <= abs(Form_Offset_Point.Y)) do ( 
				-- top 2 top
				Form_Offset_Point.Y =  toRect.Top - formRect.Top
			)
			if ( abs(formRect.Top + formRect.Height - toRect.Top - toRect.Height ) <= abs(Form_Offset_Point.Y)) do (
				-- bottom 2 bottom
				Form_Offset_Point.Y =  toRect.Top + toRect.Height - formRect.Height - formRect.Top
			)
		)
	),
	fn normalizeInside iP1 iM1 iM2 = (
	
		if iP1 <= iM1 then (

			iM1

		) else if iP1 >= iM2 then ( 

			iM2 
			
		) else (

			iP1
		)
	),
	/*
	*@Credits > many tanks to Corneliu Tusnea for C# version
	*@Usage	> snap form to other panels or window borders (sticky snapp)
	*@Example

		onMouseDown --> mcDialog.init form
		onMouseMove --> mcDialog.moveAndSnap form
	*/
	fn moveAndSnap src_form = (
	
		Mouse_Point = mcDotnet.dPoint mouse.screenPos
		local p = Mouse_Point --src_form.PointToScreen Mouse_Point
		local activeScr = mcDotnet.Screen.FromPoint ( p ) -- get the screen from the point !!

		if ( not activeScr.WorkingArea.Contains ( p ) ) do (
		
			p.X = normalizeInside p.X activeScr.WorkingArea.Left activeScr.WorkingArea.Right
			p.Y = normalizeInside p.Y activeScr.WorkingArea.Top activeScr.WorkingArea.Bottom
		)

		p.Offset (mcDotnet.dPoint [-Offset_Point.X, -Offset_Point.Y])

		-- p is the exact location of the frame - so we can play with it
		-- to detect the new position acording to different bounds
		local formRect = src_form.Bounds
		formRect.Location = p	-- this is the new positon of the form

		Form_Offset_Point.X	= Stick_Gap + 1	-- (more than) maximum gaps
		Form_Offset_Point.Y	= Stick_Gap + 1
		-- First try snap to creen edges
		snapTo formRect activeScr.WorkingArea inside_stick:false
		-- Now try to snap to other windows (skip self)
		for w in Registred_Windows where w != src_form do (
		
			local target_bounds = if superClassOf w == StructDef then ( --structure with dotnet form inside
			
				w.form.bounds --if form is inside struct
				
			) else if classOf w == dotNetObject then ( --dotnet form
			
				w.Bounds
				
			) else if classOf w == RolloutClass then ( --max rollout
			
				local pos  = getDialogPos w
				local size = (getDialogSize w) + [4, 4]
				mcRect2D pos size
			)
			if target_bounds == undefined do continue
			snapTo formRect target_bounds inside_stick:true
		)
		--
		if ( Form_Offset_Point.X == Stick_Gap+1 ) do Form_Offset_Point.X = 0
		if ( Form_Offset_Point.Y == Stick_Gap+1 ) do Form_Offset_Point.Y = 0
		--
		formRect.Offset ( Form_Offset_Point )
		src_form.Bounds = formRect
	),
	fn getPos form = (
	
		if superClassOf form == StructDef then ( --structure with dotnet form inside
			
			[form.form.location.x, form.form.location.y]
			
		) else if classOf form == dotNetObject then ( --dotnet form
			
			[form.location.x, form.location.y]
			
		) else if classOf form == RolloutClass then ( --max rollout
		
			getDialogPos form
			
		) else ( --none
		
			undefined
		)
	),
	fn setPos form pos = (
	
		if superClassOf form == StructDef then (
			
			form.form.location = mcDotnet.dPoint pos
			
		) else if classOf form == dotNetObject then (
			
			form.location = mcDotnet.dPoint pos
			
		) else if classOf form == RolloutClass then (
		
			setDialogPos form pos
			
		) else (
		
			undefined
		)
	),
	fn getSize form = (
	
		if superClassOf form == StructDef then (
			
			[form.form.width, form.form.height]
			
		) else if classOf form == dotNetObject then (
			
			[form.width, form.height]
			
		) else if classOf form == RolloutClass then (
		
			getDialogSize form
			
		) else (
		
			undefined
		)
	),
	--Old way will be deleted
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
