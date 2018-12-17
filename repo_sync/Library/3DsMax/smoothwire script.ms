--- smoothwire script beta
 --- edged faces need to be turned on to see the smoothwire 


 (

 rollout smoothwire "smooth wire" width:120 height:440
 (
 ---
 --- button and spinner definitions
 ---

 --- button and spinner main rollout

 groupBox grpb1 "SW Modifiers" pos:[5,5] width:110 height:90
 groupBox grpb1b "" pos:[120,5] width:240 height:90

 button btn1 "generate" pos:[10,25] width:100 height:20 
 button btn2 "delete" pos:[10,45] width:100 height:20
 button btn3 "update" pos:[10,65] width:100 height:20

 groupBox grpb2 "Display Settings" pos:[5,100] width:110 height:145
 groupBox grpb2b "" pos:[120,100] width:240 height:145

 button btn4 "base level" pos:[10,120] width:100 height:20
 button btn5 "normal wire" pos:[10,140] width:100 height:20
 button btn6 "red wire" pos:[10,160] width:100 height:20
 button btn7 "backface cull on" pos:[10,180] width:100 height:20
 button btn8 "control cage off" pos:[10,200] width:100 height:20

 spinner spn1 "" pos:[79,225] width:30 height:16 range:[0,5,3] type:#integer --- subdivision iterations spinner
 label lbl0 "Iterations" pos:[20,225] width:49 height:15

 groupBox grpb3 "misc" pos:[5,250] width:110 height:183
 groupBox grpb3b "" pos:[120,250] width:240 height:183

 button btn9 "create spline" pos:[10,265] width:100 height:20
 button btn10 "render viewport" pos:[10,285] width:100 height:20
 button btn11 "preview" pos:[10,305] width:100 height:100
 button btn12 " quick help >" pos:[10,405] width:100 height:20 


 -- help text

 button map1butt1 "" pos:[130,355] width:50 height:50
 button map1butt2 "" pos:[190,355] width:50 height:50
 button map1butt3 "" pos:[250,355] width:50 height:50
 --bitmap map1 pos:[120,270] width:50 height:50 bitmap:(render outputwidth:50 outputheight:50 vfb:false mapping:true shadows:true )--bitmap:render ()
 --bitmap map2 pos:[180,270] width:50 height:50 bitmap:(render outputwidth:50 outputheight:50 vfb:false mapping:false shadows:false)--bitmap:render ()
 --bitmap map3 pos:[240,270] width:50 height:50 bitmap:(render outputwidth:50 outputheight:50 vfb:false forcewireframe:true mapping:false shadows:false)--bitmap:render ()
 label lbl1 "<--- generates smooth-wire modifiers" pos:[125,25] width:230 height:20
 label lbl2 "<--- deletes smooth-wire modifiers" pos:[125,45] width:230 height:20
 label lbl3 "<--- updates smooth-wire (after geometry change)" pos:[125,65] width:230 height:20
 label lbl4 "<--- toggles to base level and back" pos:[125,120] width:230 height:20
 label lbl5 "<--- toggles to normal nurms wire and back" pos:[125,140] width:230 height:20
 label lbl6 "<--- toggles to red subdiv mode and back" pos:[125,160] width:230 height:20
 label lbl7 "<--- toggles backface cull on and off" pos:[125,180] width:230 height:20
 label lbl8 "<--- toggles controll cage on and off" pos:[125,200] width:230 height:20
 label lbl9 "<--- set the subdiv iterations" pos:[125,220] width:230 height:20
 label lbl10 "<--- creates a spline of smoothwire line" pos:[125,265] width:230 height:20 color:blue
 label lbl11 "<--- renders the viewport" pos:[125,285] width:230 height:20 color:blue
 label lbl12 "<--- click to render a small preview" pos:[125,305] width:230 height:20 color:blue
 label lbl13 "or use the other render types below" pos:[143,320] width:210 height:20 color:blue
 label lbl14 "mapping" pos:[135,338] width:100 height:20 color:blue
 label lbl15 "V solid" pos:[195,338] width:100 height:20 color:blue
 label lbl16 "V wire" pos:[255,338] width:100 height:20 color:blue
 spinner spn2 "" pos:[310,356] width:45 height:16 range:[0,1024,500] type:#integer
 spinner spn3 "" pos:[310,389] width:45 height:16 range:[0,1024,500] type:#integer 

 --- toggle states

 global abutt =1 -- button btn4 "base level" toggle state
 global bbutt =1 -- button btn5 "normal wire" toggle state
 global cbutt =1 -- button btn6 "red wire" toggle state
 global dbutt =1 -- button btn12 " quick help >" state
 global ebutt =1 -- button btn7 "backface cull on" toggle state
 global fbutt =1 -- button btn8 "control cage off" toggle state

 -- mics globals

 global spntemp = 1 --- spinner spn1 iterations tempstate
 global baseedgeselection = #() -- stores original edgeselection

 global modname1 = "SW Edit Mesh" --- define modifier name #1
 global modname2 = "SW Turn to Poly" --- define modifier name #2

 --- functions

 fn testPoly = --- single editable poly check
 (
 if selection.count == 1 AND classof selection[1] == Editable_Poly do (setcommandpaneltaskmode mode:#modify; return true)
 )

 fn modifiertest = --- no modifiers check

 (
 if $.modifiers.count == 0 do (setcommandpaneltaskmode mode:#modify; return true)
 )

 fn modifiertest2 = --- checks if smoothwire modifiers are assigned

 (
 if $.modifiers.count == 2 and $.modifiers[1].name == modname1 do (setcommandpaneltaskmode mode:#modify; return true)
 )

 fn catchoperation = --- error handling (redrawviews + messagebox)

 (
 enablesceneredraw()
 redrawViews()
 messagebox "error occured" title:"Smooth Wire"
 )






 on btn1 pressed do -- generate modifiers button

 (
 try
 (
 undo "sw generate" off
 (
 modPanel.setCurrentObject $.baseObject
 if modifiertest2() == true do (messagebox "modifiers already generated!" title:"Smooth Wire"; return())
 if testPoly() != true do (messagebox "Single Editable Poly only" title:"Smooth Wire"; return())
 if modifiertest() != true do (messagebox "please delete or collapse all other modifiers first" title:"Smooth Wire"; return())
 setWaitCursor()
 disablesceneredraw()
 $.surfSubdivide = on
 $.iterations = spn1.value
 baseedgeselection = (polyop.getEdgeSelection $.baseobject as array)
 subobjlev = subobjectLevel
 select $.Edges
 modPanel.addModToSelection (Turn_to_Poly ()) ui:on
 $.modifiers[1].name = modname2
 $.modifiers[1].selectionConversion = 2
 $.modifiers[1].selectionLevel = 3
 modPanel.addModToSelection (Edit_Mesh ()) ui:on
 $.modifiers[1].name = modname1
 modPanel.setCurrentObject $.modifiers[1]
 subobjectLevel = 2
 meshOps.invisibleEdge $.modifiers[1]
 subobjectLevel = 0
 modPanel.setCurrentObject $.baseObject
 subobjectLevel = subobjlev
 polyop.setEdgeSelection $.baseobject baseedgeselection
 showendresult = true
 enablesceneredraw()
 redrawViews()
 --btn1.enabled=false
 )
 )
 catch 
 (
 catchoperation ()
 )
 )


 on btn2 pressed do --- delete modifiers button
 (
 if modifiertest2() == true then (
 try
 (
 setWaitCursor()
 disablesceneredraw()
 deleteModifier $ 1
 deleteModifier $ 1
 enablesceneredraw()
 redrawViews()
 setArrowCursor()
 )
 catch
 (
 catchoperation ()
 )
 )
 else
 ()

 )


 on btn3 pressed do -- update modifiers button
 (
 try
 (
	 undo "sw update" off
	 (
		 if modifiertest2() != true do (messagebox "no modifiers generated! press generate first!" title:"Smooth Wire";return())
		 setWaitCursor()
		 disablesceneredraw()
		 showendresult = false
		 modPanel.setCurrentObject $.baseObject
		 baseedgeselection = (polyop.getEdgeSelection $.baseobject as array)
		 subobjlev = subobjectLevel
		 select $.Edges
		 deleteModifier $ 1
		 modPanel.addModToSelection (Edit_Mesh ()) ui:on
		 $.modifiers[1].name = modname1
		 modPanel.setCurrentObject $.modifiers[1]
		 subobjectLevel = 2
		 meshOps.invisibleEdge $.modifiers[1]
		 subobjectLevel = 0
		 modPanel.setCurrentObject $.baseObject
		 subobjectLevel = subobjlev
		 showendresult = true
		 polyop.setEdgeSelection $.baseobject (baseedgeselection as array)
		 enablesceneredraw()
		 redrawViews()
		 setArrowCursor() 
	 )
 )
 catch 
 (
 catchoperation () -- function
 )
 )

 on btn4 pressed do -- base level button
 (
 try
 (
 undo "sw base level" off
 (
 if modifiertest2() != true do (messagebox "no modifiers generated! press generate first!" title:"Smooth Wire";return())
 case of 
 (
 (abutt == 1) : (
 setWaitCursor()
 disablesceneredraw()
 showendresult = false
 modPanel.setCurrentObject $.baseObject
 $.iterations = 0
 $.surfSubdivide = off
 btn4.text = "leave base level"
 btn3.enabled=false
 btn5.enabled=false
 spn1.enabled=false
 btn6.enabled=false
 btn7.enabled=false
 btn8.enabled=false
 btn9.enabled=false
 lbl0.enabled=false
 spntemp = spn1.value
 spn1.value = 0
 abutt = 0 -- switch button state
 enablesceneredraw()
 redrawViews()
 )
 (abutt == 0) : (
 setWaitCursor()
 disablesceneredraw()
 showendresult = true
 modPanel.setCurrentObject $.baseObject
 $.iterations = spntemp
 $.surfSubdivide = on
 btn4.text = "base level"
 btn3.enabled=true
 btn5.enabled=true
 spn1.enabled=true
 btn6.enabled=true
 btn7.enabled=true
 btn8.enabled=true
 btn9.enabled=true
 lbl0.enabled=true
 spn1.value = spntemp
 abutt = 1 -- switch button state
 enablesceneredraw()
 redrawViews()
 )

 )
 )
 )
 catch 
 (
 catchoperation ()
 )
 )


 on btn5 pressed do -- normal wire button
 (
 try
 (
 undo "sw wire change1" off
 (
 if modifiertest2() != true do (messagebox "no modifiers generated! press generate first!" title:"Smooth Wire";return())
 case of 
 (
 (bbutt ==1) : (
 setWaitCursor()
 showendresult = false 
 bbutt = 0
 btn5.text = "lightwave style"
 btn4.enabled=false
 btn3.enabled=false
 spn1.enabled=false
 btn6.enabled=false
 btn9.enabled=false
 lbl0.enabled=false
 )

 (bbutt ==0) : (
 setWaitCursor()
 showendresult = true
 bbutt = 1
 btn5.text = "normal wire"
 btn4.enabled=true
 btn3.enabled=true
 spn1.enabled=true
 btn6.enabled=true
 btn9.enabled=true
 lbl0.enabled=true
 )
 )
 )
 )
 catch 
 (
 catchoperation ()
 )
 )

 on btn6 pressed do -- red wire button
 (
 try
 (
 undo "sw wire change2" off
 (
 if modifiertest2() != true do (messagebox "no modifiers generated! press generate first!" title:"Smooth Wire";return())
 case of 
 (
 (cbutt ==1) : (
 setWaitCursor()
 disablesceneredraw()
 modPanel.setCurrentObject $.modifiers[1]
 subobjectLevel = 2
 meshOps.visibleEdge $.modifiers[1]
 modPanel.setCurrentObject $.baseObject
 --subobjectLevel = 1
 showendresult = true
 enablesceneredraw()
 redrawViews()
 cbutt = 0
 btn6.text = "smoothwire line"
 )

 (cbutt ==0) : (
 setWaitCursor()
 disablesceneredraw()
 modPanel.setCurrentObject $.modifiers[1]
 meshOps.invisibleEdge $.modifiers[1]
 subobjectLevel = 0
 modPanel.setCurrentObject $.baseObject
 --subobjectLevel = 1
 showendresult = true
 enablesceneredraw()
 redrawViews()
 cbutt = 1
 btn6.text = "red wire"
 )
 )
 )
 )
 catch 
 (
 catchoperation ()
 )
 )



 on btn7 pressed do -- backface cull button

 (
 if modifiertest2() != true do (messagebox "no modifiers generated! press generate first!" title:"Smooth Wire";return())
 case of 
 (
 (ebutt == 1) : (
 setWaitCursor()
 disablesceneredraw()
 $.backfacecull = off

 ebutt = 0 -- switch button state
 enablesceneredraw()
 redrawViews()
 btn7.text = "backface cull on"
 )
 (ebutt == 0) : (
 setWaitCursor()
 disablesceneredraw()
 $.backfacecull = on

 ebutt = 1 -- switch button state
 enablesceneredraw()
 redrawViews()
 btn7.text = "backface cull off"
 )

 )
 )


 on btn8 pressed do -- controll cage button
 (
 if modifiertest2() != true do (messagebox "no modifiers generated! press generate first!" title:"Smooth Wire";return())
 case of 
 (
 (fbutt == 1) : (
 setWaitCursor()
 disablesceneredraw()
 $.showCage = off

 fbutt = 0 -- switch button state
 enablesceneredraw()
 redrawViews()
 btn8.text = "control cage on"
 )
 (fbutt == 0) : (
 setWaitCursor()
 disablesceneredraw()
 $.showCage = on

 fbutt = 1 -- switch button state
 enablesceneredraw()
 redrawViews()
 btn8.text = "control cage off"
 )

 )
 )



 on btn9 pressed do -- create spline button (creates a spline of the smoothwire-line)
 (
 try
 (
 undo "sw create spline" off
 (
 if modifiertest2() != true do (messagebox "no modifiers generated! press generate first!" title:"Smooth Wire";return())
 setWaitCursor()
 disablesceneredraw()
 showendresult = false
 modPanel.setCurrentObject $.baseObject
 baseedgeselection = (polyop.getEdgeSelection $.baseobject as array)
 subobjlev = subobjectLevel
 select $.Edges
 deleteModifier $ 1
 modPanel.addModToSelection (Edit_Mesh ()) ui:on
 $.modifiers[1].name = modname1
 modPanel.setCurrentObject $.modifiers[1]
 subobjectLevel = 2
 max select invert
 meshOps.createShapeFromEdges $.modifiers[1]
 max select invert

 if cbutt == 0 then 
 (
 meshOps.visibleEdge $.modifiers[1]
 subobjectLevel = 2
 modPanel.setCurrentObject $.baseObject
 subobjectLevel = 1
 showendresult = true
 enablesceneredraw()
 redrawViews()
 )
 else
 (
 meshOps.invisibleEdge $.modifiers[1]
 subobjectLevel = 0
 modPanel.setCurrentObject $.baseObject
 subobjectLevel = 1
 showendresult = true
 enablesceneredraw()
 redrawViews()
 )

 )
 )
 catch 
 (
 catchoperation ()
 )
 )







 on btn10 pressed do -- render viewport button

 (
 undo off
 (
 local tempstate = showEndresult
 showEndresult = True
 local tempsurf = $.surfSubDivide
 $.surfSubDivide = True
 local temprender = render renderer:#draft
 $.surfSubDivide = tempsurf
 showEndresult = tempstate
 temprender = undefined
 gc light: true
 )
 )


 on btn11 pressed do ---- preview render button
 (
 setWaitCursor()
 previewmap =(render outputwidth:133 outputheight:100 vfb:false mapping:true shadows:true rendertype:#selected)
 btn11.images=#(previewmap, undefined, 1, 1, 1, 1, 1)
 gc light: true
 )



 on btn12 pressed do -- help button
 (
 --try
 --(
 undo "help button" off
 (
 case of 
 (
 (dbutt ==1) : (
 for e = 120 to 365 by 5 do
 (
 smoothwire.width = e
 sleep 0.002
 dbutt=0
 )
 btn12.text = " quick help <"
 map1bitmap=(render outputwidth:50 outputheight:50 vfb:false mapping:true shadows:true renderer: #draft rendertype:#selected)--bitmap:render ()
 map2bitmap=(render outputwidth:50 outputheight:50 vfb:false mapping:false shadows:false renderer: #draft rendertype:#selected)--bitmap:render ()
 map3bitmap=(render outputwidth:50 outputheight:50 vfb:false forcewireframe:true mapping:false shadows:false renderer: #draft rendertype:#selected)--bitmap:render ()

 map1butt1.images=#(map1bitmap, undefined, 1, 1, 1, 1, 1) 
 map1butt2.images=#(map2bitmap, undefined, 1, 1, 1, 1, 1) 
 map1butt3.images=#(map3bitmap, undefined, 1, 1, 1, 1, 1) 
 )

 (dbutt ==0) : (
 for f = 350 to 120 by -5 do
 (
 sleep 0.002
 smoothwire.width = f
 dbutt=1
 )
 btn12.text = " quick help >"
 )
 )
 )
 --)
 --catch 
 -- (
 -- catchoperation ()
 -- )
 )

 on spn1 changed val1 do -- subdivision iteration spinner
 (
 undo "sw iterations" off
 (
 setWaitCursor()
 if modifiertest2() != true do return()
 try
 (

 if val1 == 0 then 
 (
 disablesceneredraw()
 showendresult = false
 modPanel.setCurrentObject $.baseObject
 $.iterations = val1
 $.surfSubdivide = off
 enablesceneredraw()
 redrawViews()
 )

 else
 (
 disablesceneredraw()
 showendresult = false
 modPanel.setCurrentObject $.baseObject
 $.surfSubdivide = on
 $.iterations = val1
 select $.Edges
 deleteModifier $ 1
 modPanel.addModToSelection (Edit_Mesh ()) ui:on
 $.modifiers[1].name = modname1
 modPanel.setCurrentObject $.modifiers[1]
 subobjectLevel = 2
 if cbutt == 0 then 
 (
 meshOps.visibleEdge $.modifiers[1]
 subobjectLevel = 2
 modPanel.setCurrentObject $.baseObject
 subobjectLevel = 1
 showendresult = true
 enablesceneredraw()
 redrawViews()
 )
 else
 (
 meshOps.invisibleEdge $.modifiers[1]
 subobjectLevel = 0
 modPanel.setCurrentObject $.baseObject
 subobjectLevel = 1
 showendresult = true
 enablesceneredraw()
 redrawViews()
 )

 )

 )
 catch 
 (
 catchoperation ()
 )
 )
 )

 on map1butt1 pressed do --- render an image with mapping, shadows, render selected, draft
 (
 render outputwidth:spn2.value outputheight:spn3.value vfb:true mapping:true renderer: #draft shadows:true rendertype:#selected
 gc light: true
 )

 on map1butt2 pressed do --- render an image with no mapping, no shadows, render selected, draft
 (
 render outputwidth:spn2.value outputheight:spn3.value vfb:true mapping:false renderer: #draft shadows:false rendertype:#selected
 gc light: true
 )

 on map1butt3 pressed do --- render an image with no mapping, no shadows, render selected, draft, force wireframe
 (
 render outputwidth:spn2.value outputheight:spn3.value vfb:true forcewireframe:true mapping:false renderer: #draft shadows:false force2sided:true wireThickness:2 rendertype:#selected
 gc light: true
 )


 )
 createdialog smoothwire
 )