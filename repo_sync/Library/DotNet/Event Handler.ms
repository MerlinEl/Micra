  (
  	fn whenCheckboxIsPressed a b = 
  	(
  		-- This links us to the "OnExecute" event, which returns
  		-- OK and throws an error.
  		
  		if a.checked do print "checked"
		-- We want to link to the "OnChecked" event...
		--a.checked = action
  	)
  	
  --Create a DotNet Checkbox
  mCheckbox = dotNetObject "System.Windows.Forms.Checkbox"
  mCheckbox.text = "BIG DotNet Button"
  mCheckbox.size = dotNetObject "System.Drawing.Size" 160 160
  mCheckbox.location = dotNetObject "System.Drawing.Point" 60 60
   
  --Create a DotNet Form
  hForm = dotNetObject "System.Windows.Forms.Form"  
  hForm.controls.add mCheckbox --add the Button to the Form
  hForm.topmost = true
  --Add an Event Handler for the click event:
  dotNet.addEventHandler mCheckbox "click" whenCheckboxIsPressed 
   
  hForm.show() --show the Form with the Checkbox
  )
