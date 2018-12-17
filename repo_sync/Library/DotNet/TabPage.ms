 try(destroyDialog myRol)catch()
 
 rollout myRol "Testing .NET" width:200
 (
 		local IsResizing = false	-- whether the dialog is being resized
 		local StartPosition			-- mouse position at 'lbuttondown' event
 		local StartHeight			-- dialog height at 'lbuttondown' event
 
 	dotNetControl dnc "system.windows.forms.tabcontrol" height:190
 	dotNetControl ResizeLabel "System.Windows.Forms.Label" pos:[0,200] width:200 height:8
 	dotNetControl myButton "system.windows.forms.button" width:112 height:45 pos:[4,5]
 
 	fn DNET theTabs =
 	(
 		t1 = dotNetObject "System.Windows.Forms.TabPage" "One"
 		t2 = dotNetObject "System.Windows.Forms.TabPage" "Two"
 		dnc.controls.add t1
 		dnc.controls.add t2
 	)
 
 		on myButton mouseDown senderArg thearg do
 	(
 		if thearg.button == thearg.button.left then
 		(
 		senderArg.backColor = senderArg.backColor.aliceblue
 		print ("left")
 		)
 	)
 
 	on myButton mouseUp senderArg thearg do
 	(
 		if thearg.button == thearg.button.right then
 		(
 		print ("right")
 		)
 
 		if thearg.button == thearg.button.middle then
 		(
 		print ("middle")
 		)
 	)
 	
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
 			DNET dnc
 			ResizeLabel.Cursor = (dotNetClass "System.Windows.Forms.Cursors").SizeNS
 	
 			myButton.flatstyle = (dotnetclass "System.Windows.Forms.Flatstyle").flat
 			myButton.flatappearance.MouseoverBackColor = (dotnetclass"System.Drawing.color").darkgray
 			  myButton.flatappearance.MousedownBackColor = (dotnetclass"System.Drawing.color").lightgray
 			TheTip = dotnetobject "System.Windows.Forms.ToolTip"
 			TheTip.SetToolTip myButton "here is the tooltip .NET"
 			TheTip.Active = True
 			TheTip.isballoon = True			
 		)
 
 )
 createDialog myRol
 
 
 ------------------------------
 
 
 try(destroyDialog my_Rol)catch()
rollout my_Rol "Testing .NET" height:200 width:200
(
	dotNetControl tabControl "system.windows.forms.TabControl" width:180 height:190

	fn DNET theTabs =
	(
	b1 = dotNetObject "system.windows.forms.button"
	b1.Size = dotNetObject "system.drawing.size" 100 50
	b1.Location = dotNetObject "system.drawing.point" 50 50
	b1.flatstyle = (dotnetclass "System.Windows.Forms.Flatstyle").flat
	b1.flatappearance.MouseoverBackColor = (dotnetclass"System.Drawing.color").gray

	b2 = dotNetObject "system.windows.forms.button"
	b2.Size = dotNetObject "system.drawing.size" 70 20
	b2.Location = dotNetObject "system.drawing.point" 40 20

	tab1 = dotNetObject "System.Windows.Forms.TabPage" "One"
	tab2 = dotNetObject "System.Windows.Forms.TabPage" "Two"

	theTip = dotnetobject "System.Windows.Forms.ToolTip"
	TheTip.SetToolTip b1 "the tooltip .NET"
	TheTip.Active = True
	TheTip.isballoon = True			

		tabControl.controls.add (tab1)
		tabControl.controls.add (tab2)

		tab1.controls.add (b1)
		tab2.controls.add (b2)
	)

------------------------------------------------ NOT WORKING...

		on b1 mouseDown senderArg thearg do
		(
		if thearg.button == thearg.button.left then
			(
			senderArg.backColor = senderArg.backColor.aliceblue
			print ("left")
			)
		)
		
		on b1 mouseUp senderArg thearg do
		(	
			senderArg.backColor = senderArg.backColor.lightgray
	
			if thearg.button == thearg.button.right then
			(
			senderArg.backColor = senderArg.backColor.lightblue
			print ("right")
			)
			if thearg.button == thearg.button.middle then
			(
			senderArg.backColor = senderArg.backColor.lightgreen
			print ("middle")
			)
		)

		on b2 mouseDown senderArg thearg do
		(
		if thearg.button == thearg.button.left then
			(
			senderArg.backColor = senderArg.backColor.aliceblue
			print ("left")
			)
		)
		
		on b2 mouseUp senderArg thearg do
		(	
			senderArg.backColor = senderArg.backColor.lightgray
	
			if thearg.button == thearg.button.right then
			(
			senderArg.backColor = senderArg.backColor.lightblue
			print ("right")
			)
			if thearg.button == thearg.button.middle then
			(
			senderArg.backColor = senderArg.backColor.lightgreen
			print ("middle")
			)
		)

------------------------------------------------ NOT WORKING...

	on my_Rol open do
	(
		DNET tabControl
	)
)
createDialog my_Rol BGcolor:(color 130 130 130) style:#(#style_titlebar,#style_minimizebox,#style_sysmenu)



-------------------
---------------------
theForm = dotnetobject "System.Windows.Forms.Form"
thetab = dotnetobject "System.Windows.Forms.TabControl"
theAlignment = dotnetclass"System.Windows.Forms.TabAlignment"
theSize = dotnetobject "System.Drawing.Size" 25 100

theDrawMode = dotnetclass "System.Windows.Forms.TabDrawMode"
theSizeMode = dotnetclass"System.Windows.Forms.TabSizeMode"
theDockStyle = dotnetclass"System.Windows.Forms.DockStyle" 


thetabPage_1 = dotnetobject "System.Windows.Forms.TabPage"  "Controls" 
thetabPage_2 = dotnetobject "System.Windows.Forms.TabPage"  "Shapes" 
thetabPage_3= dotnetobject "System.Windows.Forms.TabPage"  "Geometry" 
thetabPage_4 = dotnetobject "System.Windows.Forms.TabPage"  "Helpers" 


thetab.TabPages.Add(thetabPage_1)
thetab.TabPages.Add(thetabPage_2)
thetab.TabPages.Add(thetabPage_3)
thetab.TabPages.Add(thetabPage_4)


thetab.itemSize= theSize


thetab.Alignment = theAlignment.Right
thetab.Drawmode = theDrawMode.OwnerDrawFixed
thetab.SizeMode = theSizeMode.Fixed
thetab.Dock = theDockStyle.fill

theForm.Controls.add(thetab)
theForm.show()
