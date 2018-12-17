GLOBAL NEW_FORM
(
    struct FORM_DATA (name, age, weight, childerns, buttons)
    
    local f = dotnetobject "form"
    

    local b1 = dotnetobject "button"
    b1.text = "Get Name"
    local b2 = dotnetobject "button"
    b2.text = "Get Age"
    local b3 = dotnetobject "button"
    b3.text = "Get Weight"
    local b4 = dotnetobject "button"
    b4.text = "Get Childerns"
	
	local FORM_CONTAINER = dotnetObject "System.ComponentModel.Container"
	FORM_CONTAINER.dispose()
	FORM_CONTAINER.add f
	FORM_CONTAINER.add b1
	FORM_CONTAINER.add b2
	FORM_CONTAINER.add b3
	FORM_CONTAINER.add b4

	f.tag    = dotNetMXSValue (FORM_DATA "merlin" 240 58.24 #("a","b","c") (FORM_CONTAINER.components.item 1))--#(b1, b2, b3, b4))
    
    fn _getName     s a = (format "Name:%\n" s.parent.parent.tag.value.name)
    fn _getAge     s a = (format "Age:%\n" s.parent.parent.tag.value.age)
    fn _getWeight    s a = (format "Name:%\n" s.parent.parent.tag.value.weight)
    fn _getChilderns s a = (format "Name:%\n" s.parent.parent.tag.value.childerns)
    
    dotNet.addeventhandler b1 "MouseUp" _getName
    dotNet.addeventhandler b2 "MouseUp" _getAge
    dotNet.addeventhandler b3 "MouseUp" _getWeight
    dotNet.addeventhandler b4 "MouseUp" _getChilderns
    
    --b1.InitializeLifetimeService()	
	--b2.InitializeLifetimeService()	
	--b3.InitializeLifetimeService()	
	--b4.InitializeLifetimeService()
	--f.InitializeLifetimeService()
	--mc2system.show b1
	
	local lp = dotNetObject "TableLayoutPanel"
    lp.autosize = true
    lp.controls.addRange( #(b1,b2,b3,b4) )
    f.controls.add( lp )
  
 	
	NEW_FORM = f
    f = undefined
    
	NEW_FORM.show()
)