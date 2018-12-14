--Calculate The Percentage Of Value To A Value 
if calculateThePercentageDialog != undefined do destroyDialog calculateThePercentageDialog
rollout CalculateThePercentageDialog "  Percentage Calculator:" width:592 height:180
(
	GroupBox grp5 "" pos:[8,4] width:576 height:168
	GroupBox grp3 "The Percentage Of Value To A Value < a/b*100 >" pos:[16,24] width:560 height:56
	GroupBox grp4 "The Value Of A Percentage Of A Value < a*b/100 >" pos:[16,84] width:560 height:56
	label lbl7 " is what percent of" pos:[112,48] width:92 height:16
	label lbl8 "?" pos:[288,48] width:16 height:16
	label lbl9 "Result:" pos:[308,48] width:36 height:16
	button btn_calc_a "Calculate Percent" pos:[464,44] width:104 height:24
	label lbl10 "What is" pos:[28,108] width:40 height:16
	label lbl11 "%         of" pos:[156,108] width:44 height:16
	label lbl12 "Result:" pos:[308,108] width:36 height:16
	button btn_calc_b "Calculate Percent" pos:[464,104] width:104 height:24
	label lbl13 "?" pos:[288,108] width:16 height:16
	label lbl21 "%" pos:[440,48] width:16 height:16
	edittext edt_1r "" pos:[344,48] width:91 height:15 enabled:true
	edittext edt_2r "" pos:[344,108] width:91 height:15 enabled:true
	button btn_clear "Clear Values" pos:[16,148] width:72 height:20
	button btn_close "Close" pos:[504,148] width:72 height:20
	edittext edt_2b "" pos:[200,108] width:84 height:15 enabled:true
	edittext edt_2a "" pos:[68,108] width:84 height:15 enabled:true
	edittext edt_1a "" pos:[24,48] width:84 height:15 enabled:true
	edittext edt_1b "" pos:[200,48] width:84 height:15 enabled:true
	on calculateThePercentageDialog open do setFocus edt_1a
	on btn_calc_a pressed do edt_1r.text = ( (edt_1a.text as float/edt_1b.text as float)*100 )as string
	on btn_calc_b pressed do edt_2r.text = ( (edt_2a.text as float*edt_2b.text as float)/100 )as string
	on btn_clear pressed do edt_1r.text = edt_2r.text = edt_1a.text = edt_1b.text = edt_2a.text = edt_2b.text= ""
	on btn_close pressed do destroyDialog calculateThePercentageDialog
)
createDialog calculateThePercentageDialog style:#(#style_toolWindow, #style_sysMenu)