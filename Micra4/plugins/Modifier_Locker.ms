--genClassID()
plugin modifier locker
name:"Locker"
classID:#(0xfb7ba38, 0x3809d735)
version:1(
	
	parameters main rollout:params(
		
		checkBox_01 type:#boolean ui:checkBox_01 default:false
	)
	rollout params "Locker Parameters"(
		
		checkbox checkBox_01 "Locked: " type:#boolean checked:false
		on checkBox_01 changed state do (
			--if state then messagebox "lock" else messagebox "unlock"
			if state then setTransformLockFlags selection #all else setTransformLockFlags selection #none
		)
		/*on params open do (
	
			if checkBox_01.checked then ....
		)*/
	)
)

/*
b = box isselected:on
m = EmptyModifier name:"Attribute"
ca = attributes TestAttribute
(
parameters params rollout:params
(
float_param type:#float ui:ui_float_param
bool_param type:#boolean ui:ui_bool_param
)
rollout params "Parameters"
(
slider ui_float_param "Float Parameter:" type:#float 
checkbox ui_bool_param "Boolean Parameter"
)
)
custattributes.add m ca
addmodifier b m 
*/