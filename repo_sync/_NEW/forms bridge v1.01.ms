
Global form1
Global form2

form2 =  dotNetObject "MaxCustomControls.Maxform"
form2.bounds = netDrRect [800,200] [240,100]
btn2 = dotNetObject "Button"
btn2.name = "btn2"
btn2.bounds = netDrRect [4,4] [200,24]
btn2.text = "Register Event"
form2.controls.add btn2

dotNet.setLifetimeControl btn2 #dotnet
dotNet.setLifetimeControl form2 #dotnet

form1 =  dotNetObject "MaxCustomControls.Maxform"
form1.bounds = netDrRect [200,200] [240,100]
btn1 = dotNetObject "Button"
btn1.name = "btn_1"
btn1.bounds = netDrRect [4,4] [200,24]
btn1.text = "Register Event"
form1.controls.add btn1




fn onMouseUpRegisterEvent s a = (
	
	 format "MouseDown s:% a:% \n" s  a
	
	--local toolbar_edit = form.controls.Item("toolbar_edit")
	format "MouseDown f2 items:% \n" ( form2.controls.Item("btn_2") )
	--dotnet.addEventHandler form2.controls.item("btn_2") "MouseUp" onMouseUpRegisterEvent
	form2.showModeless()
)


dotnet.addEventHandler btn1 "MouseUp" onMouseUpRegisterEvent
form1.showModeless()

gc()