
Global mcZeroIsoDialog
if mcZeroIsoDialog != undefined do destroyDialog mcZeroIsoDialog
rollout mcZeroIsoDialog "v0.01" width:144 height:96
(
	groupBox 'grp1' "ISOLATE - AT - ZERO:" pos:[8,4] width:128 height:84 align:#left
	checkButton 'ckbISO' "ISOLATE" pos:[14,24] width:116 height:56 align:#left
	fn zeroisolate obj = (

		local zeropos = getUserProp obj "isozeropos" 
		if zeropos == undefined or zeropos == "undefined" then ( --store current pos
			zeropos = obj.pos
			setUserProp obj "isozeropos" zeropos   
		)
		IsolateSelection.EnterIsolateSelectionMode()
		obj.pos = [0, 0, 0]
	)
	
	fn zerounisolate obj = (

		IsolateSelection.ExitIsolateSelectionMode()
		local zeropos = getUserProp obj "isozeropos" 
		if zeropos != undefined do (

			obj.pos = execute zeropos
			setUserProp obj "isozeropos" undefined   
		)
	)
	
	fn isoSwitch state = (
		
		for o in $selection as array do(
				
			if state then zeroisolate o else zerounisolate o
		)
		if state do max zoomext sel
	)
	
	on mcZeroIsoDialog open do (
			
		ckbISO.checked =  IsolateSelection.IsolateSelectionModeActive() 
	)
	on mcZeroIsoDialog close do (
		
		if ckbISO.checked do isoSwitch false
	)
	on ckbISO changed state do (
		
		--if state and IsolateSelection.IsolateSelectionModeActive() do return false
		--if not state and not IsolateSelection.IsolateSelectionModeActive() do return false
		if $selection.count == 0 do (
			
			messagebox "Geometry must be selected."
			ckbISO.checked = not ckbISO.checked
			return false
		)
		isoSwitch state
	)
)
createDialog mcZeroIsoDialog pos:[44, 150]


/*
setUserProp $ "isozeropos" 123 --set-create value at key
getUserProp $ "isozeropos" --get value by key
getUserPropBuffer $ --get all user data
setUserPropBuffer $ "isozeropos = 123" --ovrride all user data
)
*/

