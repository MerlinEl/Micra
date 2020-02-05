clearListener()
/**
*@Usage
	button type:
		OK
		OKCancel
		RetryCancel
		YesNo
		YesNoCancel
		AbortRetryIgnore
	icon type:
		Asterisk 
		Error 
		Exclamation
		Hand
		Information
		None
		Question
		Stop
		Warning
*/
struct MICRA_MESSAGE_BOX (

	fn msgBox msg:"Default Message" title:"Default Title" iconType:#None buttonType:#YesNoCancel =	(
		
		local mb = DotNetClass "MessageBox"
		local icon = (execute("(DotNetClass \"MessageBoxIcon\")." + iconType))
		local msgbutton = (execute("(DotNetClass \"MessageBoxButtons\")." + buttonType))
		local result = mb.show msg title msgbutton icon

		-- this below will return the current position of the mouse
		print mouse.screenpos

		-- move the messagebox to the mouse position.
		-- the .location property does not exist.
		try(
			
			format "result:%\n" result
			print (result.location)
			
		) catch(print"No location here my friend")

		case result.ToString() of (
			
			"Yes" : true
			"OK" : true
			"Ignore" : true
			"Retry" : true
			"No" : false
			"None" : false
			"Cancel" : false
			"Abort " : false
			default : false
		)
	),
	fn show msg title:"Micra" type:#YesNoCancel = (
		
		case type of (
			
			#OK : ""
			#OKCancel : ""
			#RetryCancel : ""
			#YesNo : ""
			#YesNoCancel : msgBox msg:msg title:title  iconType:#Question buttonType:type
			#AbortRetryIgnore : ""
		)
	)
)
mcMessageBox = MICRA_MESSAGE_BOX()


if (mcMessageBox.show "Message goes here.\n\n2nd line."  title:"Do you want to continue?"  type:#YesNoCancel) then (
	
	format "accepted\n"
	
) else (
	
	format "canceled\n"
)