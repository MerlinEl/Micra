(
	-- Load MaxCustomControls assembly
	-- This assembly contains UI components built on the .NET Framework for use in 3ds Max
	dotNet.loadAssembly "MaxCustomControls.dll"

	-- Create TextBox
	hTextBox = dotNetObject "System.Windows.Forms.TextBox"
	hTextBox.Location = dotNetObject "System.Drawing.Point" 10 10
	hTextBox.Width = 280
	hTextBox.Height = 280
	hTextBox.Visible = true
	hTextBox.MultiLine = true
	ScrollBars = dotNetClass "System.Windows.Forms.ScrollBars"
	hTextBox.ScrollBars = ScrollBars.Vertical
	hTextBox.AcceptsReturn = true
	hTextBox.AcceptsTab = true
	hTextBox.WordWrap = true
	
	-- Create Max Form
	hMaxForm = dotNetObject "MaxCustomControls.MaxForm"
	hMaxForm.Size = dotNetObject "System.Drawing.Size" 310 335
	hMaxForm.Text = "Max Form with TextBox"
	hMaxForm.Controls.Add(hTextBox)
	hMaxForm.TopMost = true
	FormBorderStyle = dotNetClass "System.Windows.Forms.FormBorderStyle"
	hMaxForm.FormBorderStyle = FormBorderStyle.FixedDialog
	hMaxForm.ShowInTaskbar = false
	hMaxForm.MinimizeBox = false
	hMaxForm.MaximizeBox = false
    
	-- Show MaxForm
	hMaxForm.ShowModeless()
)


----------------
dotNet.loadAssembly "E:\\Micra2\\App\\test\\ManagedServices.dll"
dotNet.loadAssembly "E:\Micra2\\App\\test\\XPTable.dll"
dotNet.loadAssembly "E:\\Micra2\\App\\test\\MaxCustomControls.dll"
form=dotNetObject "MaxCustomControls.MaxForm"
form.AllowTransparency=false
form.BackColor=(dotNetClass "system.drawing.color").fromArgb 0 0 255 
--form.TransparencyKey=(dotNetClass "system.drawing.color").fromArgb 0 0 255 
form.ShowInTaskBar =false
form.FormBorderStyle=form.FormBorderStyle.none
form.TopMost=true

form.showmodal()



-------------------

(
  form = dotNetObject "Form"
  mc2system.show form
  p = DotNetObject "System.IntPtr" ( Windows.GetMAXHWND() )
  --maxHwnd = DotNetObject "System.Windows.Forms.IWin32Window" p
  dotNet.loadAssembly "E:\\Micra2\\App\\test\\MaxCustomControls.dll"
  maxHwnd = DotNetObject "MaxCustomControls.Win32HandleWrapper" p -- I like it!
  form.Show ( maxHwnd )
)

--.Show <System.Windows.Forms.IWin32Window>owner