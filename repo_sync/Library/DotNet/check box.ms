  (
  	fn whenCheckboxIsPressed a b = 
  	(
  		-- This links us to the "OnExecute" event, which returns
  		-- OK and throws an error.
  		
  		-- We want to link to the "OnChecked" event...
  		a.checked = (Macros.run 22615)
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
  
  ----------------
  
  MCRUtils.IsCreating Box

--------------------------



 global hForm, mCheckbox, thisTimer
 
 (
 fn whenCheckboxIsPressed a b = 
 (
 	if MCRUtils.IsCreating Box
 		then (Max Select; try((hForm.controls.item(0)).checked = false) catch())
 	else Macros.run 26615
 )
 
 fn updateUI =
 (
 	try(
 	(hForm.controls.item(0)).checked = MCRUtils.IsCreating Box
 	) catch()
 )
 
 --Create a DotNet Checkbox
 mCheckbox = dotNetObject "System.Windows.Forms.Checkbox"
 mCheckbox.appearance = (dotnetClass "System.Windows.Forms.Appearance").Button
 mCheckbox.text = "Box Button"
 mCheckbox.location = dotNetObject "System.Drawing.Point" 0 0
 
 --Create a DotNet Form
 global hForm = dotNetObject "System.Windows.Forms.Form"
 hForm.topmost = true
 hForm.controls.add mCheckbox --add the Button to the Form
 
 thisTimer = dotNetObject "System.Windows.Forms.Timer"
 thisTimer.interval = 10
 thisTimer.start()
 
 --Add an Event Handler for the click event:
 dotNet.addEventHandler mCheckbox "click" whenCheckboxIsPressed
 dotNet.addEventHandler thisTimer "tick" updateUI
 
 hForm.show() --show the Form with the Checkbox
 )
