if foo != undefined do DestroyDialog foo
----------------------------------------------------------------------------
rollout foo "Change Radius" width:160 height:240
	(
	local myController=bezier_float()
	
	spinner ball_radius "Ball radius" range:[0,1000,1] \
	controller:myController --type:#integer scale:1
	button apply "Apply Radius Controller"
	on apply pressed do
		(
		animate off at time 0 $.radius=myController.value
		$.radius.controller=myController
		)
	)
CreateDialog foo 144 80 50 130 --style:#(#style_titlebar)



There is an example in the EditablePoly Interface chapter showing the Preview function based on an Extrusion script.

I quickly changed it to a Chamfer example - see the code below:

p = convertToPoly(Box()) --create a box, turn to Epoly.
select p --select the box
max modify mode --enter Modify panel
subobjectlevel = 2 --set Sub-Object mode to Edge
rollout chamfer_edges "My Chamfer Dialog" --define a rollout
(
spinner chamfer_value "Chamfer Value" range:[0,100,1] --the value
on chamfer_value changed val do p.edgeChamfer = val --assign spinner value to chamfer value
button try_it "Preview" across:3 --a button to start a new chamfer
button cancel_it "Cancel" --a button to cancel preview
button accept_it "Accept" --a button to accept
on cancel_it pressed do p.previewCancel() --cancel
on accept_it pressed do p.previewAccept() --accept
on try_it pressed do p.previewBegin #Chamfer--begin again
)
createDialog chamfer_edges 200 60 --create a dialog with the rollout
--Run the script, select some edges, press Preview
--and watch them chamfer interactively.
--Press Accept if you like the result, press Cancel to discard.
--Press Preview again for next chamfer etc.
--Works exactly as the built-in dialog, but it is still a custom one!