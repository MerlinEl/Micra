   
   dnForm1 = dotnetobject "Form"
   dnButton1  = dotnetobject "Button"
   dnToolTip = dotnetobject "ToolTip"
   mcsystem.show dnToolTip
   dnButton1.text =  "Do Nothing"
   
    
   dnToolTip.AutoPopDelay = 5000
   dnToolTip.InitialDelay = 300
   dnToolTip.ReshowDelay = 300
   dnToolTip.ShowAlways = true
   
   dnToolTip.SetToolTip dnForm1 "I'm a Form"		 
   dnToolTip.SetToolTip dnButton1  "I'm a Button"  
   
   
   dnForm1.controls.add  dnButton1
   dnForm1.show()



	ToolTipObj = dotnetobject "System.Windows.Forms.ToolTip"
   	ToolTipObj.SetToolTip dotnettest.mbutton "Funky cold medina"
   	ToolTipObj.SetToolTip dotnettest.mbutton2 "Get out of my dreams, get into my car"
	
	

try(destroyDialog DotNetRoll)catch()

rollout DotNetRoll "Test"
(
	dotNetControl myButton "system.windows.forms.button" width:112 height:45 pos:[4,5]

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

		on DotNetRoll open do
		(

			  myButton.flatstyle = (dotnetclass "System.Windows.Forms.Flatstyle").flat
			  myButton.flatappearance.MouseoverBackColor = (dotnetclass"System.Drawing.color").darkgray
			  myButton.flatappearance.MousedownBackColor = (dotnetclass"System.Drawing.color").lightgray
		
		MyTipString = "here is the tooltip .NET"
		TheTip = dotnetobject "System.Windows.Forms.ToolTip"
		TheTip.SetToolTip myButton MyString
		TheTip.Active = True
		TheTip.isballoon = True			
		)
)
	createDialog DotNetRoll