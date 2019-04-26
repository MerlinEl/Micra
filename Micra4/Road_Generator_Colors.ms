Global roadGeneratorColorDialog
if roadGeneratorColorDialog != undefined do DestroyDialog roadGeneratorColorDialog
rollout roadGeneratorColorDialog "Types:" width:104 height:316
(
	GroupBox 'grp1' "Color:" pos:[4,4] width:96 height:308 align:#left
	label 'lbl2' "Dirt Road" pos:[48,28] width:48 height:16 align:#left
	colorPicker 'cp1' "" pos:[8,24] width:32 height:23 color:(color 101 45 0) align:#left
	label 'lbl3' "Shortcut" pos:[48,51] width:48 height:16 align:#left
	colorPicker 'cp2' "" pos:[8,47] width:32 height:23 color:(color 174 0 1) align:#left
	label 'lbl4' "1-6" pos:[48,74] width:48 height:16 align:#left
	colorPicker 'cp3' "" pos:[8,70] width:32 height:23 color:(color 246 0 0) align:#left
	label 'lbl5' "2-4" pos:[48,97] width:48 height:16 align:#left
	colorPicker 'cp4' "" pos:[8,93] width:32 height:23 color:(color 247 0 215) align:#left
	label 'lbl6' "2-5" pos:[48,120] width:48 height:16 align:#left
	colorPicker 'cp5' "" pos:[8,116] width:32 height:23 color:(color 174 0 247) align:#left
	label 'lbl7' "2-4P" pos:[48,143] width:48 height:16 align:#left
	colorPicker 'cp6' "" pos:[8,139] width:32 height:23 color:(color 46 1 247) align:#left
	label 'lbl8' "2-5P" pos:[48,166] width:48 height:16 align:#left
	colorPicker 'cp7' "" pos:[8,162] width:32 height:23 color:(color 0 145 247) align:#left
	label 'lbl9' "4-4P" pos:[48,189] width:48 height:16 align:#left
	colorPicker 'cp8' "" pos:[8,185] width:32 height:23 color:(color 0 221 247) align:#left
	label 'lbl10' "4-5" pos:[48,212] width:48 height:16 align:#left
	colorPicker 'cp9' "" pos:[8,208] width:32 height:23 color:(color 0 247 13) align:#left
	label 'lbl11' "2-2R" pos:[48,235] width:48 height:16 align:#left
	colorPicker 'cp10' "" pos:[8,231] width:32 height:23 color:(color 1 93 6) align:#left
	label 'lbl12' "2-4R" pos:[48,258] width:48 height:16 align:#left
	colorPicker 'cp11' "" pos:[8,254] width:32 height:23 color:(color 215 247 0) align:#left
	label 'lbl13' "2-4RP" pos:[48,281] width:32 height:16 align:#left
	colorPicker 'cp12' "" pos:[8,277] width:32 height:23 color:(color 247 168 2) align:#left
)
CreateDialog roadGeneratorColorDialog
if floaterGenerator != undefined do SetDialogPos roadGeneratorColorDialog [floaterGenerator.pos.x+floaterGenerator.size.x+8, floaterGenerator.pos.y]
	
