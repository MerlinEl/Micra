  -- setup dotnet classes / objects
   	local mb = dotNetClass "System.Windows.Forms.MessageBox"
   	local buttons = dotNetClass "System.Windows.Forms.MessageBoxButtons"
   	local icons = dotNetClass "System.Windows.Forms.MessageBoxIcon"
   	local defaultButton = dotNetClass "System.Windows.Forms.MessageBoxDefaultButton"
   	local dialogResult = dotNetClass "System.Windows.Forms.DialogResult"
	
	
	
	 ----------------------------------------------------------
 System.Windows.Forms.MessageBoxButtons (Enumeration)
 ----------------------------------------------------------
 .AbortRetryIgnore
 .OK
 .OKCancel
 .RetryCancel
 .YesNo
 .YesNoCancel
 
 ----------------------------------------------------------
 System.Windows.Forms.MessageBoxDefaultButton (Enumeration)
 ----------------------------------------------------------
 .Button1
 .Button2
 .Button3
 
 ----------------------------------------------------------
 System.Windows.Forms.MessageBoxIcon (Enumeration)
 ----------------------------------------------------------
 .Asterisk
 .Error
 .Exclamation
 .Hand
 .Information
 .None
 .Question
 .Stop
 .Warning
 
 ----------------------------------------------------------
 MessageBox.show (Method)
 ----------------------------------------------------------
 MessageBox.show ( text, caption, buttons, icon, defaultButton )
 
 */ 
 
 (
 	-- setup dotnet classes / objects
 	local mb = dotNetClass "System.Windows.Forms.MessageBox"
 	local buttons = dotNetClass "System.Windows.Forms.MessageBoxButtons"
 	local icons = dotNetClass "System.Windows.Forms.MessageBoxIcon"
 	local defaultButton = dotNetClass "System.Windows.Forms.MessageBoxDefaultButton"
 	local dialogResult = dotNetClass "System.Windows.Forms.DialogResult"
 	
 	local result = mb.show "Do you want to save before quitting ?" "Quit" buttons.YesNoCancel icons.Information defaultButton.Button3
 	
 	-- evaluate result of messageBox (which button has been pressed by the user)
 	if ( result == dialogResult.Yes ) then
 	(
 		format "YES\n"
 	)
 	else if ( result == dialogResult.No ) then
 	(
 		format "NO\n"
 	)
 	else if ( result == dialogResult.Cancel ) then
 	(
 		format "CANCEL\n"
 	)
 	
 )
