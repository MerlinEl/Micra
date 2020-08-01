rollout a "	Spermanpunch script pack 5.0" width:277 height:106
(
	label lbl_Maker "Supermanpunch_Mirror Tool_5.0" pos:[58,8] width:200 height:13
	
	
	
	button btn3 "<- skinmirror" pos:[6,47] width:65 height:35
	button btn4 "<- mirror" pos:[73,47] width:65 height:35 toolTip:""
	button btn5 "mirror->" pos:[140,47] width:65 height:35 toolTip:""
	button btn6 "skinmirror->" pos:[208,47] width:65 height:35
	HyperLink SupermanpunchYoutube "Supermanpunch_Youtube" pos:[72,28] width:132 height:15 color:[255,142,28] address:"https://goo.gl/ZeoKXF"
	
	on a open do
	(
		
		)
	on a close do
	(
		
		)
	on a okToClose do
	(
		
		)
	on a resized size do
	(
		
		)
	on a moved pos do
	(
		
		)
	on btn3 pressed do
	(
				$.modifiers[#Skin].mirrorEnabled = off
				modPanel.setCurrentObject $.baseObject
				macros.run "Modifiers" "Symmetry"
				$.modifiers[#Symmetry].weld = 0
				modPanel.setCurrentObject $.modifiers[#Symmetry]
				maxOps.CollapseNodeTo $ 2 off
				modPanel.setCurrentObject $.modifiers[#Skin]
				modPanel.setCurrentObject $.baseObject
				subobjectLevel = 3
				actionMan.executeAction 0 "40021"  -- Selection: Select All
				$.EditablePoly.ConvertSelection #Border #Vertex
				subobjectLevel = 1
				actionMan.executeAction 369982487 "40057"
				$.weldThreshold = 0.001
				$.EditablePoly.weldFlaggedVertices ()
				subobjectLevel = 0
				clearSelection()
	)
	on btn4 pressed do
	(
				modPanel.addModToSelection (symmetry ()) ui:on
				$.modifiers[#Symmetry].threshold = 0.01
				maxOps.CollapseNodeTo $ 1 off
	)
	on btn5 pressed do
	(
				modPanel.addModToSelection (symmetry ()) ui:on
				$.modifiers[#Symmetry].flip = on
				$.modifiers[#Symmetry].threshold = 0.01
				maxOps.CollapseNodeTo $ 1 off
	)
	on btn6 pressed do
	(
				$.modifiers[#Skin].mirrorEnabled = off
				modPanel.setCurrentObject $.baseObject
				macros.run "Modifiers" "Symmetry"
				$.modifiers[#Symmetry].flip = on
				$.modifiers[#Symmetry].weld = 0
				modPanel.setCurrentObject $.modifiers[#Symmetry]
				maxOps.CollapseNodeTo $ 2 off
				modPanel.setCurrentObject $.modifiers[#Skin]
				modPanel.setCurrentObject $.baseObject
				subobjectLevel = 3
				actionMan.executeAction 0 "40021"  -- Selection: Select All
				$.EditablePoly.ConvertSelection #Border #Vertex
				subobjectLevel = 1
				actionMan.executeAction 369982487 "40057"
				$.weldThreshold = 0.001
				$.EditablePoly.weldFlaggedVertices ()
				subobjectLevel = 0
				clearSelection()
	)
)
createDialog  a width:277 height:92
