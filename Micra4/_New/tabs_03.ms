Global mcUnwrapEditorDialog
if mcUnwrapEditorDialog != undefined do destroyDialog mcUnwrapEditorDialog
(	
	rollout first_rollout "Selection" category:1
	(
		button btn_verts "V" pos:[8,24] width:24 height:24 images:(mcCall.getIcon 103)  tooltip:"Convert Selection to Vertices"
		button btn_edges "E" pos:[36,24] width:24 height:24 images:(mcCall.getIcon 216) tooltip:"Convert Selection to Edges"
		button btn_faces "F" pos:[64,24] width:24 height:24 images:(mcCall.getIcon 40) tooltip:"Convert Selection to Faces"
		button btn_border "B" pos:[8,52] width:24 height:24 images:(mcCall.getIcon 41) tooltip:"Select Edge border"
		button btn_sel_similar "B" pos:[64,52] width:24 height:24 images:(mcCall.getIcon 220) tooltip:"Select Similar Faces"
		label lbl_min "min:" pos:[8,84] width:24 height:16
		spinner spn_min "" pos:[32,84] width:44 height:16 range:[0,100,100] type:#float
		label lbl_max "max:" pos:[8,104] width:24 height:16
		spinner spn_max "" pos:[32,104] width:44 height:16 range:[0,10000,20] type:#float
		label lbl6 "%" pos:[76,104] width:12 height:16
		label lbl7 "%" pos:[76,84] width:12 height:16
		button btn_sel_over "B" pos:[36,52] width:24 height:24 images:(mcCall.getIcon 240) toolTip:"Select Overlapped Faces (+Ctrl Grow to Element)"
-- 		on first_rollout open do format "1 is opened\n"
-- 		on first_rollout close do format "1 is closed\n"
		on first_rollout changed state do
		(	
		print ( state as string)
		)
	)
	rollout second_rollout "Move / Resize" category:2
	(
		label second "Second"
	)
	local all_rollouts = #(
		
		#(first_rollout, true),
		#(second_rollout, false)
	)
	rollout mcUnwrapEditorDialog "UV+" width:96 height:648 (

			subRollout theSubRollout width:202 height:140 align:#center
			fn resizeDialogHeight = (
				
				local total_height = 0
				for rdata in all_rollouts do (	
					
-- 					if rdata[1].open do total_height += rdata[1].height	
					if rdata[2] do total_height += rdata[1].height	
				)
				mcUnwrapEditorDialog.height = total_height
			)
			on mcUnwrapEditorDialog open do
			(	
				for rdata in all_rollouts do (
					
					addSubRollout theSubRollout rdata[1]	rolledUp:rdata[2]
				)
				resizeDialogHeight()
			)
	)
-- 	createDialog mcUnwrapEditorDialog 202 150
	if (MaxVersion())[1] >= 21000 do mcUnwrapEditorDialog.autoLayoutOnResize = true 
	createDialog mcUnwrapEditorDialog 200 648
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

-- Global mcUnwrapEditorDialog
-- if mcUnwrapEditorDialog != undefined do closerolloutfloater mcUnwrapEditorDialog
-- (
-- 	rollout first_rollout "Selection" category:2
-- 	(
-- 		label rights "First"
-- 	)
-- 	rollout second_rollout "Move / Resize" category:1
-- 	(
-- 		label second "Second"
-- 	)
-- 	mcUnwrapEditorDialog = newRolloutFloater  "UV+" 100 648
-- 	addRollout first_rollout mcUnwrapEditorDialog
-- 	addRollout second_rollout mcUnwrapEditorDialog
-- )


-- (
-- 	local parentUVW = windows.getChildHWND 0 "Edit UVWs"
-- 	if parentUVW != undefined then (
-- 		
-- 		createdialog mcUnwrapEditorDialog  parent:parentUVW[1]
-- 	
-- 	) else (
-- 		createdialog mcUnwrapEditorDialog
-- 	)
-- )