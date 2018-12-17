Global mc2ButtonForm
try mc2ButtonForm.close() catch()
-- Create buttons at routime
(
	--Using
	local netCursors      = (dotNetClass "Cursors")
	local netFlatStyle    = (dotnetClass "System.Windows.Forms.FlatStyle")
	local netContainer    = (dotnetObject "System.ComponentModel.Container")
	
	fn netDrColor clr     = ((dotNetClass "Drawing.Color").fromArgb clr.r clr.g clr.b)
	fn netDrPoint pos     = (dotnetObject "Drawing.Point" pos.x pos.y)
	fn netDrSize size     = (dotNetObject "Drawing.Size" size.x size.y)
	fn netDecimal val     = (dotnetObject "System.Decimal" val)
	
	
	mc2ButtonForm = dotnetObject "Form"
	local form = mc2ButtonForm
	local sp1 = dotnetObject "NumericUpDown"
	local sp2 = dotnetObject "NumericUpDown"
	
	--Clean up any resources being used
	local components = netContainer.Components
	if components.count != 0 do components.Dispose()
	--form.Container
	
	--This is the generate button routine
	fn rClickMenu =
	(
		rcMenu mainMenu
		(
			separator file_menu_1
			menuItem new_1 "Close Form..."
			separator file_menu_2
			on new_1 picked do (form.close())
		)
		PopupMenu mainMenu
	)
	fn button1Click s a = 
	(
		
		local al = dotnetObject "System.Collections.ArrayList"

		--get all buttons
		for i = 0 to form.controls.count-1 do 
		(
			local itm = form.controls.item[i]
			if (itm.GetType()).ToString() == "System.Windows.Forms.Button" do 
			(
				al.add( itm )
			)
		)

		--remove all buttons
		for i = 0 to al.count-1 do form.controls.Remove al.Item[ i ]
		
		--Resize to start size
		form.Size = netDrSize [248, 80]
		--First one is columns
		local columns = sp1.value
		local rows    = sp2.value
		local padding = 10
		local btn_size = 24
		local locX = padding
		local locY = 56
		--We assume space between is 20
		for i = 0 to columns * rows do
		(
			local b = dotNetObject "Button"
			b.Name = "b" + i as String
			b.Size = netDrSize [btn_size, btn_size]
			b.Location = netDrPoint [locX, locY]
			b.Cursor = netCursors.Default
			b.FlatStyle = netFlatStyle.System
			
			if mod (i+1) columns == 0 
			then
			(
				locX = padding
				locY += b.Height + padding
			)
			else
			(
				locX += b.Width + padding
			)
			dotNet.addEventHandler b "Click" button1Click
			form.Controls.Add(b)
			
			if ((b.Location.X + b.Width) > form.Width) do
			(
				form.Width += ((b.Location.X + b.Width) - form.Width) + btn_size
			)
			if ((b.Location.Y + b.Height) > form.Height) do
			(
				form.Height += ((b.Location.Y + b.Height) - form.Height) + btn_size
			)
		)
	)
	fn onGotFocus  = (enableAccelerators = false)
	fn onLostFocus = (enableAccelerators = true)
	fn InitializeComponent =
	(

		form.SuspendLayout()
		
		--spinner1
		sp1.Size = netDrSize [42, 20]
		sp1.Location = netDrPoint [16, 16]
		sp1.Name = "sp1"
		sp1.TabIndex = 0
		sp1.Minimum = netDecimal 1
		sp1.Maximum = netDecimal 40
		sp1.ReadOnly = true
--mc2System.show sp1
		dotNet.addEventHandler sp1 "ValueChanged" button1Click
		dotNet.addEventHandler sp1 "GotFocus" onGotFocus
		dotNet.addEventHandler sp1 "LostFocus" onLostFocus
		
		--spinner2
		sp2.Size = netDrSize [42, 20] 
		sp2.Location = netDrPoint [60, 16]
		sp2.Name = "sp2"
		sp2.TabIndex = 0
		sp2.Minimum = netDecimal 1
		sp2.Maximum = netDecimal 40
		sp2.ReadOnly = true
		
		dotNet.addEventHandler sp2 "ValueChanged" button1Click
		dotNet.addEventHandler sp2 "GotFocus" onGotFocus
		dotNet.addEventHandler sp2 "LostFocus" onLostFocus
		
		-- Form1
		form.AutoScaleBaseSize = netDrSize [5, 13]
		form.ClientSize = netDrSize [240, 46]
		--form.width = 200
		--form.height = 200
		form.backColor = netDrColor (color 0 255 0)
	    form.opacity = 0.8
		form.FormBorderStyle = form.FormBorderStyle.FixedDialog
	    form.ShowInTaskbar  = false --hide from windows task bar
	    form.ControlBox  = false --hide main bar
		form.StartPosition = form.StartPosition.Manual
		form.Location = netDrPoint [ 200, 100 ]
		form.Name = "Form1"
		
		dotNet.addEventHandler form "mouseUp" rClickMenu

		form.Controls.Add(sp2)
		form.Controls.Add(sp1)

		form.ResumeLayout(false)
--mc2system.show form 
	) 
	InitializeComponent()
	-- Load the class library created 
	try (dotNetObject "MaxCustomControls.MaxForm") catch (dotNet.loadAssembly "E:\\Micra2\\App\\MaxCustomControls.dll")
	local p = DotNetObject "System.IntPtr" ( Windows.GetMAXHWND() )
	maxHwnd = DotNetObject "MaxCustomControls.Win32HandleWrapper" p
	form.Show ( maxHwnd )
	--form.show()
	--form.BringToFront()
	--form.focus()
)