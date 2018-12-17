(
	DotNetForm = dotNetObject "Form"
	DotNetForm.size = dotNetObject "System.Drawing.Size" 250 300
	DotNetForm.text = "Max DotNet Dialog"
	
	local dotnetTabel = dotnetObject "TableLayoutPanel"
	dotnetTabel.size = dotNetObject "System.Drawing.Size" 230 280

	local dotnetLayout1 = dotnetObject "Windows.Forms.Panel"
	local dotnetLayout2 = dotnetObject "Windows.Forms.Panel"
	
	dotnetLayout1.BorderStyle = dotnetLayout1.BorderStyle.fixed3d
	dotnetLayout2.BorderStyle = dotnetLayout1.BorderStyle.fixed3d
	dotnetLayout1.allowDrop = true
	dotnetLayout2.allowDrop = true
	
	dragDropEffect=dotNetClass "System.Windows.Forms.DragDropEffects"
	
	local dButton = dotNetclass "System.Windows.Forms.Button"
	
 	fn a_mousedown sender args =
 	(
 		-- Start the dragndrop effect, I used in this example a text data "Data dragndrop", you can try other data types
		sender.DoDragDrop sender dragDropEffect.Move		
 	)
	
	fn b_dragenter sender args =
 	(
 		-- Dotnet class to get the type of data
 		dataformats = dotnetclass "dataformats"
 		-- in this case, if data is Text type, change the drag icon effect
		args.Effect = dragDropEffect.Move
 	)
	
	PointClass = dotnetclass "System.Drawing.Point"
	fn b_dragdrop sender args =
 	(
 		-- Dotnet class to get the text information as string
 		dataformats = dotnetclass "dataformats"
 		-- get the data as string from the event
		formats = args.Data.GetFormats()
 		thedata = args.data.GetData formats[1]

--mcsystem.show	thedata
if classOf thedata == dotnetObject do 
(
	format "name:%\ttag:%\ttext:%\n" thedata.name thedata.tag thedata.text
	print (thedata.ToString())
	print (thedata.GetType())
	print (sender.GetType())
	print (thedata.FindForm())
)
--
		if (thedata != undefined)  then
		(  
			thedata.Location = sender.PointToClient(dotnetobject PointClass args.X args.Y);  
			sender.Controls.AddRange #(thedata)
		)
print (sender.Controls.item 0) -- the button
 	)
	
	_check = dotnetobject dButton
	_check.text = "Test"
	netToolTip #set _check "Test Tooltip"
	
	dotNet.addEventHandler _check "MouseDown" a_mousedown
 	dotNet.addEventHandler dotnetLayout1 "DragEnter" b_dragenter
 	dotNet.addEventHandler dotnetLayout1 "DragDrop" b_dragdrop	
	dotNet.addEventHandler dotnetLayout2 "DragEnter" b_dragenter
 	dotNet.addEventHandler dotnetLayout2 "DragDrop" b_dragdrop
	
	dotnetLayout1.controls.Add _check
	
	dotnetTabel.Controls.AddRange #(dotnetLayout1,dotnetLayout2)
	
	DotNetForm.Controls.AddRange #(dotnetTabel)
	
	DotNetForm.show(WindowWrapper)	
)