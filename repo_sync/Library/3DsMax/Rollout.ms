mc2MultiPlanterDialog.rollouts[1].ObjectListArray
editText edt_name "" pos:[8,56] width:236 height:17 readOnly:true

-----------------------------------------------------------------
if utFloater != undefined then (closeRolloutFloater utFloater)
-----------------------------------------------------------------
rollout utRollout0 "Object Frabulator" width:160 height:144
	(
-- local variables
	local target_obj
-- local functions
	local prop_name
-- local rollouts
	local setup
	
		fn prop_name obj name =
			for c in obj.children do c.name = name + "_" + c.name
			
	checkbutton setup_btn "Setup"
	edittext name_box "New name:"
			
-- use a checkbutton to dynamically control presence of panels
	on setup_btn changed state do
			if state then addRollout setup utFloater else removeRollout setup utFloater
	on utRollout0 close do
			removeRollout setup utFloater -- always close rollouts
			
rollout setup "Setup fraber" -- local panel
	(
	label hello
	pickbutton pick_tgt "Pick object"
	on pick_tgt picked obj do
		(
		target_obj = obj -- access utility local
		name_box.text = obj.name -- access utility item
		prop_name obj obj.name -- call utility local fn
		)
	)
	)
-----------------------------------------------------------------
utFloater = newrolloutfloater "UT" 152 700 0 100
-----------------------------------------------------------------
addRollout utRollout0  utFloater rolledUp:false    -- (File)




align:#left
align:#center
align:#right

button foo "foo" align:#right --default alignment is center
button baz "baz" align:#right offset:[0,6] --align right and bump this 
-- button down a bit
radiobuttons btn1 "Size:" labels:#("Big", "Bigger", ...) columns:3 
–- three columns of buttons
checkbutton b1 "yes" across:3
checkbutton b2 "no"
checkbutton b3 "maybe" -- put b1, b2, b3 across
spinner s1 "Length:" align:#left -- default alignment is right

-----------------------------------------------------------------
utility foo "name"
(
	local ro1, ro2, ... -- declare local rollouts
	...
rollout ro1 "name"
	(
	local ...
	checkbox enable ...
	on ... do
	ro2.enable.checked = false
	)
	...
rollout ro2 "name1"
	(
	local ...
	checkbox enable ...
	on ... do
	ro1.enable.checked = true
	)
	...
)

