/*//////////   SCRIPT:   Random UVW GizmoTM v1.0   //////////*/
/*//////////   WRITTEN BY:   Branko Zivkovic   //////////*/
/*//////////   EMAIL:   barigazy@hotmail.com   //////////*/
(
try(destroydialog ::rnd_UVWgizmo_TM)catch()
rollout rnd_UVWgizmo_TM "Random UVW GizmoTM v1.0"
(
	fn defLbl dnLbl txt =
	(
		local maxBC = (colorMan.getColor #background) * 255.
		local maxFC = (colorMan.getColor #Text) * 255.
		dnLbl.BackColor = (dotNetClass "System.Drawing.Color").FromArgb maxFC.x maxFC.y maxFC.z
		dnLbl.ForeColor = (dotNetClass "System.Drawing.Color").FromArgb maxBC.x maxBC.y maxBC.z
		dnLbl.Text = txt ; dnLbl.TextAlign = dnLbl.TextAlign.MiddleCenter
	)
	fn filtGeo o = (isKindOf o GeometryClass and not isKindOf o TargetObject)
	fn filtModyGeo m = (isKindOf m GeometryClass and not isKindOf m TargetObject and m.modifiers.count != 0)
	fn checkInput txt =
	(
		local result = #(false)
		if (fs = filterString txt " ").count != 0 do
		(
			if (arr = for s in 1 to fs.count where (num = fs[s] as float) != undefined collect num).count != 0 do result = #(true, arr)
		)
		result
	)
	fn getADuvw mody str = 
	(
		local ss = StringStream str, sizeVals = #()
		while not eof ss do append sizeVals (readValue ss)
		sizeVals
	)
	fn setADuvw mody = 
	(
		local ss = stringstream ""
		print (mody.length) to:ss
		print (mody.width) to:ss
		print (mody.height) to:ss
		print (mody.gizmo.transform) to:ss
		setAppData mody 1706 ss
	)
	fn setModSize mody = 
	(
		if (size = (getAppData mody 1706)) != undefined do 
		(
			local sizeVals = getADuvw mody size
			mody.length = sizeVals[1] ; mody.width = sizeVals[2] ; mody.height = sizeVals[3] ; mody.gizmo.scale = sizeVals[4].scalepart
		)
	)

dotnetcontrol lbl1 "Label" pos:[5,5] width:190 height:16
	button btn1 "Add UVWMap" pos:[5,25] width:100 height:21
	dropdownlist ddl "" pos:[110,25] width:85 height:18 items:#("Plane","Box")
	spinner spn1 "Size:" pos:[5,50] fieldwidth:65 range:[1,1e5,100]
	spinner spn2 "Channel:" pos:[110,50] fieldwidth:30 range:[1,99,1] type:#integer
	radiobuttons rb1 "" labels:#("as Unique","as Instance") pos:[5,70] columns:2
dotnetcontrol lbl2 "Label" pos:[5,90] width:190 height:16	
	checkbox p_cb1 "X - Axis" pos:[5,110] checked:on	
	checkbox p_cb2 "Y - Axis" pos:[73,110] checked:on
	checkbox p_cb3 "Z - Axis" pos:[138,110] checked:on
	edittext et1 "" pos:[0,130] width:195 height:17 text:"-100 100 50 -50 200 -200"
dotnetcontrol lbl3 "Label" pos:[5,150] width:190 height:16
	checkbox r_cb1 "X - Axis" pos:[5,170] checked:off	
	checkbox r_cb2 "Y - Axis" pos:[73,170] checked:off
	checkbox r_cb3 "Z - Axis" pos:[138,170] checked:on
	edittext et2 "" pos:[0,190] width:195 height:17 text:"0 -90 90 -180 180 -270 270"
dotnetcontrol lbl4 "Label" pos:[5,210] width:190 height:16
	checkbox s_cb1 "Length" pos:[5,230] checked:on	
	checkbox s_cb2 "Width" pos:[73,230] checked:on
	checkbox s_cb3 "Height" pos:[138,230] checked:on
	edittext et3 "" pos:[0,250] width:195 height:17 text:"0.5 0.8 1 1.25 1.5 1.75 2"	
dotnetcontrol lbl5 "Label" pos:[5,270] width:190 height:16
	checkbox cb1 "Affect Only Enabled Modifiers" pos:[5,290] checked:on
	checkbox cb2 "Affect Only With Channel:" pos:[5,310] width:145
	spinner spn3 "" pos:[150,310] fieldwidth:35 range:[1,99,1] type:#integer enabled:off
	checkbox cb3 "" pos:[5,330] width:12
	button btn2 "Random Seed" pos:[20,330] width:80 height:16 enabled:off
	spinner spn4 "" pos:[100,330] fieldwidth:85 height:16 range:[1,9e8,12345678] type:#integer enabled:off	
	button btn3 "Reset UVW Gizmo" pos:[5,350] width:125 height:25
	button btn4 "Randomize UVW Gizmo" pos:[5,380] width:125 height:25
	radiobuttons rb2 "" labels:#("Position","Rotation","Scale","All") pos:[135,348] default:4
	
	fn resetUVW mody = 
	(
		if (size = getAppData mody 1706) != undefined do
		(
			local tm = (getADuvw mody size)[4]
			case rb2.state of
			(
				1: mody.gizmo.pos = tm.row4
				2: mody.gizmo.rotation = tm.rotationpart
				3: setModSize mody
				4: (mody.gizmo.transform = tm ; setModSize mody)
			)
			size
			--mody.gizmo.transform = (tm = matrix3 1 ; tm.row4 = (in coordsys obj.transform obj.center) ; tm)
		)			
	)
	fn randomUVW mods = 
	(
		if cb3.checked then seed spn4.value else seed (spn4.value = timestamp())
		for m in mods do
		(
			if (resetUVW m) == undefined do setADuvw m
			case rb2.state of
			(
				1:(
					if (rndVals = checkInput et1.text)[1] do
					(
						if p_cb1.checked do m.gizmo.pos.x = rndVals[2][random 1 rndVals[2].count] 
						if p_cb2.checked do m.gizmo.pos.y = rndVals[2][random 1 rndVals[2].count] 
						if p_cb3.checked do m.gizmo.pos.z = rndVals[2][random 1 rndVals[2].count]
					)
				)
				2:( 
					if (rndVals = checkInput et2.text)[1] == true do
					(
						rx = if rnd_UVWgizmo_TM.r_cb1.checked then 1 else 0
						ry = if rnd_UVWgizmo_TM.r_cb2.checked then 1 else 0
						rz = if rnd_UVWgizmo_TM.r_cb3.checked then 1 else 0
						val = rndVals[2][random 1 rndVals[2].count] 
       				m.gizmo.rotation = (angleaxis val [rx,ry,rz]) as quat
					)
				)
				3:(
					if (rndVals = checkInput et3.text)[1] do
					(
						val = rndVals[2][random 1 rndVals[2].count] 
						if s_cb1.checked do m.length *= val
						if s_cb2.checked do m.width *= val
						if s_cb3.checked do m.height *= val
					)
				)			
				4:(
					if (rndVals = checkInput et1.text)[1] do
					(
						if p_cb1.checked do m.gizmo.pos.x = rndVals[2][random 1 rndVals[2].count] 
						if p_cb2.checked do m.gizmo.pos.y = rndVals[2][random 1 rndVals[2].count] 
						if p_cb3.checked do m.gizmo.pos.z = rndVals[2][random 1 rndVals[2].count]
					)
					if (rndVals = checkInput et2.text)[1] == true do
					(
						rx = if rnd_UVWgizmo_TM.r_cb1.checked then 1 else 0
						ry = if rnd_UVWgizmo_TM.r_cb2.checked then 1 else 0
						rz = if rnd_UVWgizmo_TM.r_cb3.checked then 1 else 0
						val = rndVals[2][random 1 rndVals[2].count]
						m.gizmo.rotation = (angleaxis val [rx,ry,rz]) as quat
					)
					if (rndVals = checkInput et3.text)[1] do
					(
						val = rndVals[2][random 1 rndVals[2].count] 
						if s_cb1.checked do m.length *= val
						if s_cb2.checked do m.width *= val
						if s_cb3.checked do m.height *= val
					)		
				)
			)
		)
	)
	fn wipeOutInstances arr =
	(
		local newArr = #(), haveInstance = true
		for i = arr.count to 1 by -1 do
		(
			if newArr.count == 0 then (append newArr arr[arr.count] ; deleteItem arr arr.count) else
			(
				for j = 1 to newArr.count where (areNodesInstances arr[i] newArr[j]) do haveInstance = false
				if haveInstance do insertItem arr[i] newArr (random 1 (newArr.count+1)) 
				deleteItem arr i ; haveInstance = true
			)
		)
		newArr
	)	
	fn collectUVWMap obj opt1:(cb1.checked) opt2:(cb2.checked) val:(spn3.value) =
	(
		local mods = #()
		for m in 1 to obj.modifiers.count where isKindOf (mody = obj.modifiers[m]) Uvwmap do
		(
			case of
			(
				(opt1==true and opt2==true): (if mody.enabled and mody.mapChannel == val do append mods mody)
				(opt1==true and opt2==false): (if mody.enabled do append mods mody)
				(opt1==false and opt2==true): (if mody.mapChannel == val do append mods mody) 
				default: append mods mody
			)
		) ; mods
	)
	on rnd_UVWgizmo_TM open do 
	(
		defLbl lbl1 "ASSIGNE UVWMAP MODIFIER"
		defLbl lbl2 "RANDOM POSITION"
		defLbl lbl3 "RANDOM ROTATION"
		defLbl lbl4 "RANDOM SCALE | SIZE"
		defLbl lbl5 "RESET | RANDOMIZE OPTIONS"		
	)
	on cb2 changed state do spn3.enabled = state
	on cb3 changed state do btn2.enabled = spn4.enabled = state
	on btn1 pressed do
	(
		if selection.count != 0 do
		(
			local nodes = wipeOutInstances (selection as array)
			local mody = UVWMap maptype:(if ddl.selection == 1 then 0 else 4) length:(spn1.value) width:(spn1.value) height:(spn1.value) mapChannel:(spn2.value)
			with undo label:"Asign UVWMap's" on 
			(
				for o in nodes where filtGeo o do
				(
					addmodifier o (if rb1.state == 1 then copy mody else mody)
				)
			)
		)
	)
	on btn2 pressed do (spn4.value = random 10000000. 99999999)
	on btn3 pressed do 
	(
		if selection.count != 0 do
		(
			local nodes = wipeOutInstances (selection as array)
			max create mode
			with redraw off 
			(
				for o in nodes where filtModyGeo o do
				(
					for o in nodes where filtModyGeo o do (if (mods = collectUVWMap o).count != 0 do (for m in mods do resetUVW m))
				)
			) ; free nodes
		)
	) 
	on btn4 pressed do 
	(
		if selection.count != 0 do
		(
			if (nodes = wipeOutInstances (selection as array)).count == 0 then (messageBox "Select Only Geomety Objects!" title:"Warning" beep:off) else
			(
				max create mode
				with redraw off 
				(
					local mods = #()
					for o in nodes where filtModyGeo o do join mods (collectUVWMap o)
					if mods.count != 0 do randomUVW mods
				)
			)
		)
	)
)
createdialog rnd_UVWgizmo_TM 200 408 10 110 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow) ; ok
)