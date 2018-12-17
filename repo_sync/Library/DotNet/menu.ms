(
fn OnExit =
(
hApp = dotNetClass "System.Windows.Forms.Application"
hApp.Exit() -- Close and exit form application
)

-- Access application to enable visual styles
hApp = dotNetClass "System.Windows.Forms.Application"
hApp.EnableVisualStyles() -- Enable Office 2005/.Net 2.0 style

-- Create menu and menu items
mMenu = dotNetObject "System.Windows.Forms.MenuStrip"
mFileMenu = dotNetObject "System.Windows.Forms.ToolStripMenuItem"
mExitMenu = dotNetObject "System.Windows.Forms.ToolStripMenuItem"
mFileMenu.Text = "File";
mExitMenu.Text = "Exit";

-- Add file menu item to menu
mMenu.Items.AddRange(#(mFileMenu))

-- Add exit menu item to file menu
mFileMenu.DropDownItems.AddRange(#(mExitMenu))

-- Create a DotNet Form
hForm = dotNetObject "System.Windows.Forms.Form"
hForm.Size = dotNetObject "System.Drawing.Size" 300 300
hForm.Text = ".Net 2.0 Form with Menu"
hForm.Controls.Add(mMenu) -- Add menu control to form controls
hForm.MainMenuStrip = mMenu -- Set menu control as main menu of the form
hForm.topmost = true -- Always displayed over the others windows

-- Add click event to exit menu item
dotNet.addEventHandler mExitMenu "click" OnExit

-- Show form
hForm.show()
)

-----------------
 	menuItem = contextMenu.Items.Add(arrFavtmp[i])
 	menuItem.image = imageClass.fromFile <bitmap filename>

		fn showMenu s a =
		(
			if a.Button == a.Button.right do
			(
				local itms = #("Close...", "Edit...", "Lock...")
				local contextMenu = dotNetObject "ContextMenuStrip"
				for i = 1 to itms.count do
				(
					local itm = contextMenu.Items.Add(itms[i])
					dotnet.addeventhandler itm "Click" closeForm
				)
				contextmenu.Show (s.PointToScreen (netDrPoint a.location))
				--mc2System.show contextMenu.Items
			)
		),