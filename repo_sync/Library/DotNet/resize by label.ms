 try(destroyDialog myRol)catch()
 
 rollout myRol "Testing .NET" width:200
 (
 		local IsResizing = false	-- whether the dialog is being resized
 		local StartPosition			-- mouse position at 'lbuttondown' event
 		local StartHeight			-- dialog height at 'lbuttondown' event
 
 	dotNetControl ResizeLabel "System.Windows.Forms.Label" pos:[0,200] width:200 height:8

 		on ResizeLabel MouseDown EventArgs do
 		(
 			-- left mousebutton pressed?
 			if EventArgs.Button == EventArgs.Button.Left then
 			(
 				-- store mouse position and dialog height
 				StartPosition = [EventArgs.X, EventArgs.Y]
 				StartHeight = myRol.height
 				
 				-- set resizing flag
 				IsResizing = true
 			)
 			else if IsResizing and EventArgs.Button == EventArgs.Button.Right then
 			(
 				-- revert to initial height
 				myRol.height = StartHeight
 				ResizeLabel.pos.y = myRol.height - ResizeLabel.height
 				
 				-- unset resizing flag
 				IsResizing = false
 			)
 		)
 		
 		on ResizeLabel MouseMove EventArgs do
 		(
 			-- resize flag set?
 			if IsResizing then
 			(
 				local MousePosition = [EventArgs.X, EventArgs.Y]
 				
 				-- resize the dialog
 				myRol.height = amin 400 (amax 40 (StartHeight + (MousePosition - StartPosition).y))
 				
 				-- update the label's position
 				local LabelPosition = myRol.height - ResizeLabel.height
 				StartPosition -= LabelPosition - ResizeLabel.pos.y
 				ResizeLabel.pos.y = LabelPosition
 			)
 		)
 		
 		on ResizeLabel MouseUp EventArgs do
 		(
 			-- unset resizing flag
 			if EventArgs.Button == EventArgs.Button.Left then IsResizing = false
 		)
 
 		on myRol open do
 		(
 			ResizeLabel.Cursor = (dotNetClass "System.Windows.Forms.Cursors").SizeNS
 		)
 
 )
 createDialog myRol