if mcUnitsConverterDialog != undefined do destroyDialog mcUnitsConverterDialog
rollout mcUnitsConverterDialog " Units Converter:" width:164 height:220
(
	GroupBox grp1 "" pos:[4,8] width:156 height:204
	radiobuttons rdo_type "Type:" pos:[12,32] width:83 height:46 labels:#("inches to cm", "cm to inches")
	button btn_convert "Convert" pos:[16,168] width:132 height:32
	edittext edt_text "" pos:[12,144] width:136 height:20
	on btn_convert pressed do
	(
		local val = execute edt_text.text
		if val != undefined and (classOf val == integer or classOf val == float) do
		(
			local new_val = case rdo_type.state of
			(
				1:(val  *  2.54) --inches to cm
				2:(val  *  0.39) --cm to inches
			)
			edt_text.text = new_val as string
		)
	)
)
createDialog mcUnitsConverterDialog
