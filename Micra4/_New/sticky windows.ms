	/*
	*@Usage	> snap form or dialog to other panels or window borders (sticky snapp)
	*@Example

		onMouseDown --> mcDialog.init()
		onMouseMove --> mcDialog.moveAndSnap form start_pos
	*/
	fn snapTo formRect toRect inside_stick:false = (
	
		-- compare distance from toRect to formRect
		-- and then with the found distances, compare the most closed position
		if ( formRect.Bottom >= (toRect.Top - Stick_Gap) && formRect.Top <= (toRect.Bottom + Stick_Gap) )
		(
			if ( inside_stick )
			(
				if ( (abs(formRect.Left - toRect.Right) <= abs(Form_Offset_Point.X) ) )
				(	-- left 2 right
					Form_Offset_Point.X = toRect.Right - formRect.Left
				)
				if ( (abs(formRect.Left + formRect.Width - toRect.Left) <= abs(Form_Offset_Point.X) ) )
				(	-- right 2 left
					Form_Offset_Point.X = toRect.Left - formRect.Width - formRect.Left
				)
			)

			if ( abs(formRect.Left - toRect.Left) <= abs(Form_Offset_Point.X) )
			(	-- snap left 2 left
				Form_Offset_Point.X = toRect.Left - formRect.Left
			)
			if ( abs(formRect.Left + formRect.Width - toRect.Left - toRect.Width ) <= abs(Form_Offset_Point.X))
			(	-- snap right 2 right
				Form_Offset_Point.X = toRect.Left + toRect.Width - formRect.Width - formRect.Left
			)
		)
		if ( formRect.Right >= (toRect.Left - Stick_Gap) && formRect.Left <= (toRect.Right + Stick_Gap) )
		(
			if ( inside_stick )
			(
				if (abs(formRect.Top - toRect.Bottom) <= abs(Form_Offset_Point.Y) && inside_stick )
				(	-- Stick Top to Bottom
					Form_Offset_Point.Y = toRect.Bottom - formRect.Top
				)
				if (abs(formRect.Top + formRect.Height - toRect.Top) <= abs(Form_Offset_Point.Y) && inside_stick )
				(	-- snap Bottom to Top
					Form_Offset_Point.Y =  toRect.Top - formRect.Height - formRect.Top
				)
			)

			-- try to snap top 2 top also
			if (abs(formRect.Top - toRect.Top) <= abs(Form_Offset_Point.Y))
			(	-- top 2 top
				Form_Offset_Point.Y =  toRect.Top - formRect.Top
			)
			if ( abs(formRect.Top + formRect.Height - toRect.Top - toRect.Height ) <= abs(Form_Offset_Point.Y))
			(	-- bottom 2 bottom
				Form_Offset_Point.Y =  toRect.Top + toRect.Height - formRect.Height - formRect.Top
			)
		)
	),
	fn normalizeInside iP1 iM1 iM2 (
	
		if iP1 <= iM1 then (

			iM1

		) else if iP1 >= iM2 then ( 

			iM2 
			
		) else (

			iP1
		)
	),
	fn moveAndSnap src_form = (
	
		local p = src_form.PointToScreen ( mcDotnet.dPoint mouse.pos )
		local activeScr = Screen.FromPoint ( p )	-- get the screen from the point !!

		if ( !activeScr.WorkingArea.Contains ( p ) )
		(
			p.X = normalizeInside p.X activeScr.WorkingArea.Left activeScr.WorkingArea.Right
			p.Y = normalizeInside p.Y activeScr.WorkingArea.Top activeScr.WorkingArea.Bottom
		)

		p.Offset (mcDotnet.dPoint [-start_mouse_pos.X, -start_mouse_pos.Y])

		-- p is the exact location of the frame - so we can play with it
		-- to detect the new position acording to different bounds
		local formRect = src_form.Bounds
		formRect.Location = p	-- this is the new positon of the form

		Form_Offset_Point.X	= Stick_Gap + 1	-- (more than) maximum gaps
		Form_Offset_Point.Y	= Stick_Gap + 1
		-- First try snap to creen edges
		snapTo formRect activeScr.WorkingArea false
		-- Now try to snap to other windows (skip self)
		for w in Registred_Windows where w != src_form do snapTo formRect w.Bounds true
		--
		if ( Form_Offset_Point.X == Stick_Gap+1 ) do Form_Offset_Point.X = 0
		if ( Form_Offset_Point.Y == Stick_Gap+1 ) do Form_Offset_Point.Y = 0
		--
		formRect.Offset ( Form_Offset_Point )
		src_form.Bounds = formRect
	),