try(destroyDialog TestRoll)catch() 
    
 Rollout TestRoll "test" 
 (
 	local size = 200 
 	Label lblX 
 	Label lblY 
 	Label lblK 
 	Label lblCross "+" pos: [(size/2)-3,(size/2)-7] 
    
 	Local followMouse = false 
 	fn moveCross pos = 
 	(
 		p = [pos.x-3,pos.y-7] 
 		lblCross.pos = p 
 	)
 	fn reportXY pos = 
 	(
 		lblX.text = pos.x as string 
 		lblY.text = pos.Y as string 
 		lblk.text = if keyboard.controlPressed then "ctrl" else "" 
 		moveCross pos
 	)
 	on TestRoll lbuttondown pos do 
 	(
 		followMouse = true 
 		setSysCur #select 
 		reportXY pos 
 	)
 	on TestRoll lbuttonup pos do followMouse = false 
 	on testRoll mousemove pos do
 	(
 		if followMouse do reportXY pos 
 	)
 	on TestRoll Rbuttondown pos do 
 	(
 		followMouse = false 
    
 	)
 )
    
 createDialog TestRoll 200 200




-----------------------------------------
---------------------------------------

	fn onLblTMouseMove s a = 
	(
		if netDMove do --dragForm
		(
			local netDPos = [s.MousePosition.x, s.MousePosition.y] - netDmPos
			form.Location = netDrPoint [netDPos.x, netDPos.y]
		)
	)
	
			fn showMenu s a =
		(
			if a.Button == a.Button.right do
			(
				local contextMenu = dotNetObject "ContextMenuStrip"
				fn closeForm a s = (mc2System.show a)--form.close()),
				fn hideForm  = (form.hide())
				fn showForm  = (form.show())
				dotnet.addeventhandler (contextMenu.Items.Add "Close...") "Click" closeForm
				dotnet.addeventhandler (contextMenu.Items.Add "Edit..." ) "Click" closeForm
				dotnet.addeventhandler (contextMenu.Items.Add "Lock..." ) "Click" closeForm
				contextmenu.Show (s.PointToScreen (netDrPoint a.location))
			)
		),