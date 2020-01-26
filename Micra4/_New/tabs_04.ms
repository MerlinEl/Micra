Global mcUnwrapEditorDialog_test
-- global rollout_01
if mcUnwrapEditorDialog_test != undefined do destroyDialog mcUnwrapEditorDialog_test
(	
	rollout rollout_01 "Select - Convert" category:1
	(
		button btn_border "B" pos:[4,4] width:24 height:24 images:(mcCall.getIcon 41) toolTip:"Select Edge border"
		button btn_sel_similar "B" pos:[40,20] width:24 height:24 images:(mcCall.getIcon 220) toolTip:"Select Similar Faces"
		label lbl_min "min:" pos:[72,12] width:24 height:16
		spinner spn_min "" pos:[96,12] width:50 height:16 range:[0,100,100] type:#float
		label lbl_max "max:" pos:[72,32] width:24 height:16
		spinner spn_max "" pos:[96,32] width:50 height:16 range:[0,10000,20] type:#float
		label lbl6 "%" pos:[148,32] width:12 height:16
		label lbl7 "%" pos:[148,12] width:12 height:16
		button btn_sel_over "B" pos:[4,32] width:24 height:24 images:(mcCall.getIcon 240) toolTip:"Select Overlapped Faces (+Ctrl Grow to Element)"
		
		on rollout_01 rolledUp state do (::mcUnwrapEditorDialog_test.updateDialogHeight())
	)
	rollout rollout_02 "Move - Resize" category:2
	(
		button btn_move_r "R" pos:[60,32] width:24 height:24 images:(mcCall.getIcon 177) tooltip:"Move Selection Right (+Ctrl Double Size In X)"
		button btn_move_l "L" pos:[4,32] width:24 height:24 images:(mcCall.getIcon 176)  tooltip:"Move Selection Left (+Ctrl Half Size In X)"
		button btn_move_u "U" pos:[32,4] width:24 height:24 images:(mcCall.getIcon 218) tooltip:"Move Selection Up (+Ctrl Double Size In Y)"
		button btn_move_d "D" pos:[32,60] width:24 height:24 images:(mcCall.getIcon 217) tooltip:"Move Selection Down (+Ctrl Half Size In Y)"
		button btn_move_c "c" pos:[32,32] width:24 height:24 images:(mcCall.getIcon 31) tooltip:"Move Selection Center (+Ctrl Double Size, +Alt Half Size)"
		
		on rollout_02 rolledUp state do (::mcUnwrapEditorDialog_test.updateDialogHeight())
	)
	rollout rollout_03 "Align" category:3
	(
		
		button btn_align_l "L" pos:[4,32] width:24 height:24 images:(mcCall.getIcon 289) toolTip:"Align Left"
		button btn_align_t "T" pos:[32,4] width:24 height:24 images:(mcCall.getIcon 291) toolTip:"Align Top"
		button btn_align_b "B" pos:[32,64] width:24 height:24 images:(mcCall.getIcon 292) toolTip:"Align Bottom"
		button btn_align_r "R" pos:[60,32] width:24 height:24 images:(mcCall.getIcon 290) toolTip:"Align Right"
		button btn_align_c "C" pos:[32,32] width:24 height:24 images:(mcCall.getIcon 303) toolTip:"Align Center"
		
		on rollout_03 rolledUp state do (::mcUnwrapEditorDialog_test.updateDialogHeight())
	)
	local all_rollouts = #(
		
		#(rollout_01, true),
		#(rollout_02, false),
		#(rollout_03, false)
	)
	rollout mcUnwrapEditorDialog_test "UVW+" width:96 height:648 (

			subRollout theSubRollout width:148 height:140 align:#center
			local roffset = 26
			fn updateDialogHeight = (
				
				local total_height = 0
				for rdata in all_rollouts do (
					
					local r = rdata[1]
					format "rollout: [ %  ] height:% open:%\n" r.title r.height r.open 
					total_height += if r.open then r.height+roffset else roffset
				)
				mcUnwrapEditorDialog_test.height = total_height
				theSubRollout.height = total_height
			)
			on mcUnwrapEditorDialog_test open do
			(	
				for rdata in all_rollouts do addSubRollout theSubRollout rdata[1] rolledUp:rdata[2]
				updateDialogHeight()
			)
	)
-- 	if (MaxVersion())[1] >= 21000 do mcUnwrapEditorDialog_test.autoLayoutOnResize = true 
	createDialog mcUnwrapEditorDialog_test 148 648
)


/*
distributeElementsToX selection[1] gap:0
distributeElementsToX selection[1] gap:1
mcPolyMap
mod_uvw.faceToVertSelect()

obj = $
mod_uvw = obj.modifiers[1]
uv_faces = mcPolyMap.getCurentSelectionAs mod_uvw #faces
uv_faces_elements = mcPolyMap.getElements mod_uvw uv_faces
for el in uv_faces_elements do format "left:%\n" el.left
mcArray.sortByParam uv_faces_elements "left"
el = uv_faces_elements[1]
el.left
el.moveTo [0,0,0] axis:"x"
el.moveTo [1,0,0] axis:"x" 
for el in uv_faces_elements do el.moveTo [0,0,0]
for el in uv_faces_elements do el.moveTo [0,0,0] axis:"x"
for el in uv_faces_elements do el.moveTo [1,0,0] axis:"x"
for el in uv_faces_elements do el.moveTo [0,1,0] axis:"y"
for el in uv_faces_elements do el.moveTo [0,0,0] axis:"y"
*/
