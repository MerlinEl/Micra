--------------------------------------------------------------------------------
/* mcAnimation by Orien 2019 */
--------------------------------------------------------------------------------
Global mcAnimation
Global mcTempControllerData
/*
*@Used Structures
	Micra
*
*@Used Objects
	undefined
*
*@Usage
	undefined
*
*@Example	
	undefined
*
*/
struct mcAnimation
(
	fn getSource = getSourceFileName(), --get path of this script
	fn reverse begin end =
	(
		sel = selection as array
		if sel.count != 4 do return false
		undo "Reverse Animation" on for i in sel do 
		(
			reverseTime i.rotation.controller begin end #incLeft #incRight
		)
	),
	fn store = 
	(
		local obj = selection[1]
		if obj == undefined do return false
		mcTempControllerData = #(copy obj.position.controller, copy obj.rotation.controller, copy obj.scale.controller)
	),
	fn paste = 
	(
		local obj = selection[1]
		if obj == undefined do return false
		local old_obj_pos = obj.pos
		if mcTempControllerData != undefined and mcTempControllerData.count == 3 do undo "Paste Animation" on
		(
			obj.position.controller = mcTempControllerData[1]
			obj.rotation.controller = mcTempControllerData[2]
			obj.scale.controller    = mcTempControllerData[3]
			obj.pos = old_obj_pos
		)
	)
	/*<end>*/
)
