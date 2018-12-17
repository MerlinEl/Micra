(
	/* 
		DotNet Joystick Test.
	
		Usage:
			Hold SHIFT while dragging to allow X movement only
			Hold CONTROL while dragging to allow Y movement only
			Right click while dragging to cancel and revert to previous position
			Double click to reset stick
	
		To add a joystick:
			1. Add another "System.Windows.Forms.Label" dotNetControl below
			2. Add 4 event handlers (see 'Joystick_01 MouseDown' etc below)
			3. Add the control to the 'Joysticks' and 'JoystickTitles' arrays (in the rollout's open handler)
	 */
	
	rollout JoystickRollout "DotNet Joystick Test" width:184 height:184
	(
		local Joysticks
		local JoystickTitles

		dotNetControl Joystick_01 "System.Windows.Forms.Label" pos:[8,8] width:80 height:80
		dotNetControl Joystick_02 "System.Windows.Forms.Label" pos:[96,8] width:80 height:80
		dotNetControl Joystick_03 "System.Windows.Forms.Label" pos:[8,96] width:80 height:80
		dotNetControl Joystick_04 "System.Windows.Forms.Label" pos:[96,96] width:80 height:80
		
		
		/*
			Moves stick to the specified position.
		 */
		fn Joystick_Position s pos =
		(
			local x = if keyboard.controlPressed then s.Tag.X else (if pos.x < 0 then 0 else if pos.x > s.Width - 2 then s.Width - 2 else pos.x)
			local y = if keyboard.shiftPressed then s.Tag.Y else (if pos.y < 0 then 0 else if pos.y > s.Height - 2 then s.Height - 2 else pos.y)
			
			s.Controls.Item[0].Location.X = x - 4
			s.Controls.Item[0].Location.Y = y - 4
			
			/* Uncomment below two lines to view joystick outputs in listener. */
			-- local i = findItem Joysticks s
			-- format "Joystick % : [%, %]\n" i (x as float / (s.Width - 2)) (y as float / (s.Height - 2))
		)
		
		
		/*
			Event delegates for joysticks.
		 */
		fn Joystick_MouseDown s e =
		(
			if (dotNet.CompareEnums e.Button e.Button.Left) then
			(
				s.Tag = s.Controls.Item[0].Location
				Joystick_Position s [e.X, e.Y]
			)
			if (dotNet.CompareEnums e.Button e.Button.Right) and s.Tag != undefined then
			(
				s.Controls.Item[0].Location = s.Tag
				s.Tag = undefined
			)
		)
		fn Joystick_MouseMove s e =
		(
			if (dotNet.CompareEnums e.Button e.Button.Left) and s.Tag != undefined then
				Joystick_Position s [e.X, e.Y]
		)
		fn Joystick_MouseUp s e =
		(
			if (dotNet.CompareEnums e.Button e.Button.Left) and s.Tag != undefined then
				s.Tag = undefined
		)
		fn Joystick_DoubleClick s e =
		(
			Joystick_Position s [(s.Width - 2) / 2, (s.Height - 2) / 2]
		)
		
		
		/*
			Event handlers for joysticks.
		 */
		on Joystick_01 MouseDown s e do Joystick_MouseDown s e
		on Joystick_01 MouseMove s e do Joystick_MouseMove s e
		on Joystick_01 MouseUp s e do Joystick_MouseUp s e
		on Joystick_01 DoubleClick s e do Joystick_DoubleClick s e
		on Joystick_02 MouseDown s e do Joystick_MouseDown s e
		on Joystick_02 MouseMove s e do Joystick_MouseMove s e
		on Joystick_02 MouseUp s e do Joystick_MouseUp s e
		on Joystick_02 DoubleClick s e do Joystick_DoubleClick s e
		on Joystick_03 MouseDown s e do Joystick_MouseDown s e
		on Joystick_03 MouseMove s e do Joystick_MouseMove s e
		on Joystick_03 MouseUp s e do Joystick_MouseUp s e
		on Joystick_03 DoubleClick s e do Joystick_DoubleClick s e
		on Joystick_04 MouseDown s e do Joystick_MouseDown s e
		on Joystick_04 MouseMove s e do Joystick_MouseMove s e
		on Joystick_04 MouseUp s e do Joystick_MouseUp s e
		on Joystick_04 DoubleClick s e do Joystick_DoubleClick s e
		
		
		/*
			Initialize joysticks when rollout is opened.
		 */
		on JoystickRollout open do
		(
			-- Array containing joystick controls and their captions.
			Joysticks		= #(Joystick_01, Joystick_02, Joystick_03, Joystick_04)
			JoystickTitles	= #("Joystick", "Another one", "Yet another joystick", "Last one")
			
			-- Initialize joysticks.
			for i = 1 to Joysticks.count do
			(
				-- Setup joystick background.
				Joysticks[i].ForeColor		= (dotNetClass "System.Drawing.Color").FromARGB 164 164 164
				Joysticks[i].BackColor		= (dotNetClass "System.Drawing.Color").FromARGB 255 255 255
				Joysticks[i].BorderStyle	= (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
				Joysticks[i].Padding		= dotNetObject "System.Windows.Forms.Padding" 2 2 2 2
				Joysticks[i].TextAlign		= (dotNetClass "System.Drawing.ContentAlignment").TopCenter
				Joysticks[i].Text			= JoystickTitles[i]
				
				-- Setup "stick".
				Stick = dotNetObject "System.Windows.Forms.Label"
				Stick.Enabled		= false
				Stick.Size			= dotNetObject "System.Drawing.Size" 8 8
				Stick.BackColor		= (dotNetClass "System.Drawing.Color").FromARGB 255 128 0
				Stick.BorderStyle	= (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
				Stick.Location		= dotNetObject "System.Drawing.Point" (((Joysticks[i].Width - 2) / 2) - 4) (((Joysticks[i].Height - 2) / 2) - 4)
				
				-- Add "stick" to joystick.
				Joysticks[i].Controls.Add Stick
			)
		)
	)
	
	createDialog JoystickRollout
	
)
