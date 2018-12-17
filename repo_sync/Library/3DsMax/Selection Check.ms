----------------------------------------------------------------------------------------------------------------
--Micra|Functions																					  	 //START
----------------------------------------------------------------------------------------------------------------
/* Function for displaying message */
fn mBox m: =
	( 	
	if m == 1 then messagebox "Object is Selected"
	if m == 2 then messagebox "Object's is Selected"
	if m == 3 then messagebox "Is a Editable_Poly"
	if m == 4 then messagebox "Is a Editable_Mesh"
	if m == 5 then messagebox "Modifier is Asinged"
	if m == 6 then messagebox "You made It:)"
	if m == 7 then messagebox "Superrrrr!!!"
	if m == 10 then messagebox "Object"
	if m == 19 then messagebox "Superrrrr!!!" 
	if m == 20 then messagebox "Yes:)"
--
	if m == 21 then messagebox "Object is not Selected"
	if m == 22 then messagebox "Object's is not Selected"
	if m == 23 then messagebox "Is not a Editable_Poly"
	if m == 24 then messagebox "Is not a Editable_Mesh"
	if m == 25 then messagebox "Modifier is not Asinged"
	if m == 26 then messagebox "Try something Else;)"
	if m == 27 then messagebox ""
	if m == 39 then messagebox "Imposible!?"
	if m == 40 then messagebox "No!"
	)
/* Call: mBox m:<num> | example: mBox m:1 */
----------------------------------------------------------------------------------------------------------------
if MicraRollout != undefined do DestroyDialog MicraRollout 										--Delete Rollout
----------------------------------------------------------------------------------------------------------------
rollout MicraRollout "Micra v4.0" width:160 height:352
(
----------------------------------------------------------------------------------------------------------------
	button btn1 "Object is Selected?" pos:[4,4] width:112 height:18 toolTip:"Up"
	button btn2 "Object's is Selected?" pos:[4,24] width:112 height:18 toolTip:"Up"
	button btn3 "Is a Editable_Poly?" pos:[4,44] width:112 height:18 toolTip:"Up"
	button btn4 "Is a Editable_Mesh?" pos:[4,64] width:112 height:18 toolTip:"Up"
	button btn5 "Poly VertexModeCheck" pos:[4,84] width:112 height:18 toolTip:"Up"
	on btn1 pressed do
	(	
	if Selection.count == 1 then mBox m:1 else mBox m:21
	)
	on btn2 pressed do
	(
	if Selection.count > 1 then mBox m:2 else mBox m:22
	)
	on btn3 pressed do
	(
	if classOf $ == Editable_Poly then mBox m:3 else mBox m:23
	)
	on btn4 pressed do
	(
	if classOf $ == Editable_Mesh then mBox m:4 else mBox m:24 --not working!
	)
	on btn5 pressed do
	(
	if ($ != undefined and ((classof $.baseobject) == Editable_Poly) and subobjectlevel==1) then mBox m:20 else mBox m:40
	)
)
----------------------------------------------------------------------------------------------------------------
CreateDialog MicraRollout 120 200 30 68 --style:#(#style_sysMenu) 								--Create Rollout
----------------------------------------------------------------------------------------------------------------

--numSubObjectLevels == 5 then mbox m:3
--and subobjectlevel == 1 then mbox y:
if classof (modPanel.getCurrentObject ()) == Editable_Mesh then 20 else 40
if classof (modPanel.getCurrentObject ()) == Editable_Poly then 20 else 40