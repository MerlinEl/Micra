if mcRandomizeDialog != undefined do destroyDialog mcRandomizeDialog
rollout mcRandomizeDialog "" width:152 height:332
(
	--Locals:----------------------------------------
	local dMove = false, DmPos
	groupBox grp1 "Randomize:" pos:[4,4] width:144 height:324
	label lbl1 "X:" pos:[24,52] width:16 height:16
	label lbl2 "Y:" pos:[24,72] width:16 height:16
	label lbl3 "Z:" pos:[24,92] width:16 height:16
	label lbl4 "X:" pos:[24,140] width:16 height:16
	label lbl5 "Y:" pos:[24,160] width:16 height:16
	label lbl6 "Z:" pos:[24,180] width:16 height:16
	label lbl10 "X:" pos:[24,228] width:16 height:16
	label lbl11 "Y:" pos:[24,248] width:16 height:16
	label lbl12 "Z:" pos:[24,268] width:16 height:16
	
	groupBox grp2 "Position:" pos:[16,28] width:124 height:84
	checkbox chk_pos "Checkbox" pos:[120,68] width:12 height:16
	spinner spn_pos_x "" pos:[44,48] width:68 height:16 type:#float
	spinner spn_pos_y "" pos:[44,68] width:68 height:16 range:[0,100,0] type:#float
	spinner spn_pos_z "" pos:[44,88] width:68 height:16 range:[0,100,0] type:#float
	
	groupBox grp3 "Rotation:" pos:[16,116] width:124 height:84
	checkbox chk_rot "Checkbox" pos:[120,156] width:12 height:16
	spinner spn_rot_y "" pos:[44,156] width:68 height:16 range:[0,180,0] type:#float
	spinner spn_rot_x "" pos:[44,136] width:68 height:16 range:[0,180,0] type:#float
	spinner spn_rot_z "" pos:[44,176] width:68 height:16 range:[0,180,0] type:#float
	
	groupBox grp5 "Scale:" pos:[16,204] width:124 height:84
	checkbox chk_siz "Checkbox" pos:[120,244] width:12 height:16
	spinner spn_siz_x "" pos:[44,224] width:68 height:16 range:[0,100,0] type:#float
	spinner spn_siz_y "" pos:[44,244] width:68 height:16 range:[0,100,0] type:#float
	spinner spn_siz_z "" pos:[44,264] width:68 height:16 range:[0,100,0] type:#float
	
	button btn_apply "Apply" pos:[16,292] width:124 height:28
	button btn_close "*" pos:[136,4] width:12 height:12
	-->Functions
	fn randomize =
	(
		local sel = selection as array
		if sel.count == 0 do return false
		local posx=spn_pos_x.value
		local posy=spn_pos_y.value
		local posz=spn_pos_z.value
		local rotx=spn_rot_x.value
		local roty=spn_rot_y.value
		local rotz=spn_rot_z.value
		local sizx=spn_siz_x.value
		local sizy=spn_siz_y.value
		local sizz=spn_siz_z.value
		undo "Randomize" on
		(
			for i in selection do 
			(
				in coordsys local
				(
					if chk_rot.checked
					then 
					(
						local r = (random rotx -rotx)
						if rotx != 0 do i.rotation.x_rotation += r
						if roty != 0 do i.rotation.y_rotation += r
						if rotz != 0 do i.rotation.z_rotation += r
					)
					else
					(
						if rotx != 0 do i.rotation.x_rotation += (random rotx -rotx)
						if roty != 0 do i.rotation.y_rotation += (random roty -roty)
						if rotz != 0 do i.rotation.z_rotation += (random rotz -rotz)	
					)					
									
					if chk_pos.checked
					then 
					(
						local r = (random posx -posx)
						i.pos += r
					)
					else
					(
						if posx != 0 do i.position.x += (random posx -posx)
						if posy != 0 do i.position.y += (random posy -posy)
						if posz != 0 do i.position.z += (random posz -posz)
					)
				)
				
				if chk_siz.checked
				then 
				(
					local r = (random sizx -sizx) /100 as float
					i.scale += r
				)
				else
				(
					if sizx != 0 do i.scale.x += (random sizx -sizx) /100 as float
					if sizy != 0 do i.scale.y += (random sizy -sizy) /100 as float
					if sizz != 0 do i.scale.z += (random sizz -sizz) /100 as float
				)
			)
		)
	)
	fn spinControll val type = 
	(
		case type of
		(
			#pos: if chk_pos.checked do (spn_pos_x.value = val ; spn_pos_y.value = val ; spn_pos_z.value = val)
			#rot: if chk_rot.checked do (spn_rot_x.value = val ; spn_rot_y.value = val ; spn_rot_z.value = val)
			#siz: if chk_siz.checked do (spn_siz_x.value = val ; spn_siz_y.value = val ; spn_siz_z.value = val)
		)
	)
	-->Dialog settings
	on mcRandomizeDialog close do(mcCall.saveIniDialog "mcRandomizeDialog" "Properties_2")
	on mcRandomizeDialog rbuttonup pos   do(destroyDialog mcRandomizeDialog)
	-->MoveMode
	on mcRandomizeDialog lbuttondown pos do (dMove = true; DmPos = pos; if not keyboard.shiftPressed do pushprompt "Pres Shift To Move...")
	on mcRandomizeDialog lbuttonup   pos do (dMove = false; pushprompt "")
	on mcRandomizeDialog mouseMove   pos do
	(
		if dMove and keyboard.shiftPressed do 
		(
			if mcDialogSnappingEnabled 
			then mcDialogSnap mcRandomizeDialog DmPos
			else setDialogPos mcRandomizeDialog (mouse.screenpos - DmPos)
		)
	)
	-->Actions
	on chk_pos changed state do if state do spn_pos_z.value = spn_pos_y.value = spn_pos_x.value
	on chk_rot changed state do if state do spn_rot_z.value = spn_rot_y.value = spn_rot_x.value
	on chk_siz changed state do if state do spn_siz_z.value = spn_siz_y.value = spn_siz_x.value
	on btn_apply pressed  do randomize()
	on spn_pos_x changed val do spinControll val #pos
	on spn_pos_y changed val do spinControll val #pos
	on spn_pos_z changed val do spinControll val #pos
	on spn_rot_x changed val do spinControll val #rot
	on spn_rot_y changed val do spinControll val #rot
	on spn_rot_z changed val do spinControll val #rot
	on spn_siz_x changed val do spinControll val #siz
	on spn_siz_y changed val do spinControll val #siz
	on spn_siz_z changed val do spinControll val #siz
	on btn_close pressed do destroyDialog mcRandomizeDialog
)
mcCall.createIniDialog "mcRandomizeDialog" "Properties_2" modal:false 