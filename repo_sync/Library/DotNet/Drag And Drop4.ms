try teste_form.close() catch()
(
 	-- Dotnet form settings
 	teste_form = dotNetObject "Form"
 	teste_form.Size = dotNetObject "System.Drawing.Size" 200 100
 	teste_form.text = "Drag Drop test"
 
 	-- Dotnet class that is used to set the icon of the mouse
 	dragDropEffect=dotNetClass "System.Windows.Forms.DragDropEffects"
 
 	-- Button A and B settings
 	a = dotnetobject "button"
 	a.text = "button A"
 	b = dotnetobject "button"
 	b.text = "button B"
 	b.location.x = 100
 	-- Must change allowdrop to true in the control that you want to drop data from the dragndrop operation
 	b.allowdrop = true
 	
 	-- Function when mousedown the button A
 	fn a_mousedown sender args =
 	(
 		print "MouseDown"
 		-- Start the dragndrop effect, I used in this example a text data "Data dragndrop", you can try other data types
		sender.DoDragDrop (dotNetObject "System.String" "Data dragndrop") dragDropEffect.copy
		--sender.DoDragDrop "Data dragndrop" dragDropEffect.copy
 	)
 	
 	-- Function when the Drag enters the button B
 	fn b_dragenter sender args =
 	(
 		-- Dotnet class to get the type of data
 		dataformats = dotnetclass "dataformats"
 		-- in this case, if data is Text type, change the drag icon effect
 		if args.Data.GetDataPresent(DataFormats.Text) then 
		(
			args.Effect = dragDropEffect.copy
		)
 	)
 	
 	-- Function when Drag is released
 	fn b_dragdrop sender args =
 	(
 		-- Dotnet class to get the text information as string
 		dataformats = dotnetclass "dataformats"
 		-- get the data as string from the event
 		thedata = args.data.GetData(dataformats.text)
 		print "Drop"
 		b.text = thedata
 	)
 
 	-- adding the previous functions to the buttons
 	dotNet.addEventHandler a "MouseDown" a_mousedown
 	dotNet.addEventHandler b "DragEnter" b_dragenter
 	dotNet.addEventHandler b "DragDrop" b_dragdrop
 
 	-- adding the buttons A and B to the test_form
 	teste_form.controls.add(a)
 	teste_form.controls.add(b)
 
 
 	teste_form.Show()
 )
 
 -- Instructions, drag from the Button A to the Button B
 