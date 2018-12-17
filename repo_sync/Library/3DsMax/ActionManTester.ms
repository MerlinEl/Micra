----------------------------------------------------------------------------
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--

if AmFloater != undefined then (closeRolloutFloater AmFloater)

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
----------------------------------------------------------------------------
rollout AmRollout "File" width:160 height:144
(
	Local acNum
	button btn1 "TEST" pos:[84,4] width:46 height:24 toolTip:"ReLoad" 
	spinner spn1 "" pos:[8,8] width:68 height:16 range:[0,1000,0] type:#integer
	on btn1 pressed do
	(
		actionMan.executeAction 0 acNum
	)
	on spn1 changed val do
	(
		acNum = val as string
	)
)
--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
	
AmFloater = newrolloutfloater "Tester" 152 100 0 100 -- Create Micra Floater

--xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx--
----------------------------------------------------------------------------
addRollout AmRollout  AmFloater rolledUp:false