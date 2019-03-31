--******************************************************************************************************
-- Created: 		28-10-2014
-- Last Updated:	--	"11.3.2019 ?. 21:12:36"
-- Version:			1.3
--
-- Author :  Kostadin Kotev / miau_u@yahoo.com / http://miauumaxscript.blogspot.com/
-- Version:  3ds max 2009 (10) (should work in older versions too!)
--
-- Discription: Align align the pivot of the selected object to a vector defined by the two picked points.
-- 
-- Credits to Denis Trofimov
--
--******************************************************************************************************
-- MODIFY THIS AT YOUR OWN RISK

macroscript miauuAlignPivotToVector
category:"miauu"
tooltip:"Align Pivot to Direction"
buttonText:"APD"

(
	local objToAlignArr = #()
	local pickedPoint	
	
	function TransformPivot obj vec dir =
	(
		vec = obj.transform[1]
		tm = obj.transform
		vec = normalize vec
		dir = normalize dir
		rtm = angleaxis (acos (dot vec dir)) (normalize (cross dir vec))
		tempObjTM = translate (rotate (scalematrix tm.scale) (tm.rotation*rtm)) tm.pos
		--
		worldAlignPivot obj
		rotation = inverse tempObjTM.rotation
		in coordsys local obj.rotation *= rotation
		obj.objectoffsetrot *= rotation
		obj.objectoffsetpos *= rotation	
		
	)
	
	function AlignPivotToVector axis: pos: =
	(	
		local curSnapMode = snapMode.active
		local curSnapType = snapMode.type
		snapMode.active = true
		snapMode.type = #3D
		p1 =pickPoint snap:#3D
		if classOf p1 == point3 do
		(
			p2 = pickPoint snap:#3D	rubberBand:p1	
			if classOf p2 == point3 do
			(
				if axis == #xyz then
				(
					--	p1 and p2 define the X axis
					p3 = pickPoint snap:#3D 
					if classOf p3 == point3 do
					(
						p4 = pickPoint snap:#3D rubberBand:p3
						if classOf p4 == point3 do
						(
							--	p3 and p4 define the Y axis
							p5 = pickPoint snap:#3D 
							if classOf p5 == point3 do
							(
								--	p5 and p6 define the Z axis
								p6 = pickPoint snap:#3D rubberBand:p5
								if classOf p6 == point3 do
								(
									if classOf p1 == point3 and classOf p2 == point3 and classOf p3 == point3 and classOf p4 == point3 and classOf p5 == point3 and classOf p6 == point3 do
									(	
										
										dirX = normalize (p2 - p1)
										dirY = normalize (p4 - p3)
										dirZ = normalize (p6 - p5)
										for obj in objToAlignArr do
										(
											--	align X axis
											tm = obj.transform
											vec = normalize obj.transform[1]
											dir = normalize dirX
											rtm = angleaxis (acos (dot vec dir)) (normalize (cross dir vec))
											tempObjTM = translate (rotate (scalematrix tm.scale) (tm.rotation*rtm)) tm.pos
											worldAlignPivot obj
											rotation = inverse tempObjTM.rotation
											in coordsys local obj.rotation *= rotation
											obj.objectoffsetrot *= rotation
											obj.objectoffsetpos *= rotation
											--	align Y axis
											tm = obj.transform
											vec = normalize obj.transform[2]
											dir = normalize dirY
											rtm = angleaxis (acos (dot vec dir)) (normalize (cross dir vec))
											tempObjTM = translate (rotate (scalematrix tm.scale) (tm.rotation*rtm)) tm.pos
											worldAlignPivot obj
											rotation = inverse tempObjTM.rotation
											in coordsys local obj.rotation *= rotation
											obj.objectoffsetrot *= rotation
											obj.objectoffsetpos *= rotation
											--	align Z axis
											tm = obj.transform
											vec = normalize obj.transform[3]
											dir = normalize dirZ
											rtm = angleaxis (acos (dot vec dir)) (normalize (cross dir vec))
											tempObjTM = translate (rotate (scalematrix tm.scale) (tm.rotation*rtm)) tm.pos
											worldAlignPivot obj
											rotation = inverse tempObjTM.rotation
											in coordsys local obj.rotation *= rotation
											obj.objectoffsetrot *= rotation
											obj.objectoffsetpos *= rotation
											if pos == true do obj.pivot = p1
										)
									)
								)
							)
						)
					)
				)
				else
				(
					if classOf p1 == point3 and classOf p2 == point3 do
					(	
						dir = normalize (p2 - p1)
						for obj in objToAlignArr do
						(
							--	align the temporary matrix
							vec = case axis of
							(
								#x: obj.transform[1] 
								#y: obj.transform[2] 
								#z: obj.transform[3] 
							)
							tm = obj.transform
							vec = normalize vec
							dir = normalize dir
							rtm = angleaxis (acos (dot vec dir)) (normalize (cross dir vec))
							tempObjTM = translate (rotate (scalematrix tm.scale) (tm.rotation*rtm)) tm.pos
							--
							worldAlignPivot obj
							rotation = inverse tempObjTM.rotation
							in coordsys local obj.rotation *= rotation
							obj.objectoffsetrot *= rotation
							obj.objectoffsetpos *= rotation
							if pos == true do obj.pivot = p1
						)
					)
				)
				snapMode.active = curSnapMode
				try(snapMode.type = curSnapType)catch()				
			)
		)	
	)
		
	if selection.count != 0 then
	(
		objToAlignArr = selection as array
		try
		(
			rcMenu rcMapSize
			(
				menuItem alignX "Align X axis" checked:false
				menuItem alignY "Align Y axis" checked:false
				menuItem alignZ "Align Z axis" checked:false
				menuItem alignXYZ "Align XYZ axes" checked:false
				
				on alignX picked do with undo "Align Pivot to Vector" on
				(
					if keyboard.shiftPressed then
						AlignPivotToVector axis:#X pos:true
					else
						AlignPivotToVector axis:#X pos:false
				)
				on alignY picked do with undo "Align Pivot to Vector" on
				(
					if keyboard.shiftPressed then
						AlignPivotToVector axis:#Y pos:true
					else
						AlignPivotToVector axis:#Y pos:false
				)
				on alignZ picked do with undo "Align Pivot to Vector" on
				(
					if keyboard.shiftPressed then
						AlignPivotToVector axis:#Z pos:true
					else
						AlignPivotToVector axis:#Z pos:false
				)	
				on alignXYZ picked do with undo "Align Pivot to Vector" on
				(
					if keyboard.shiftPressed then
						AlignPivotToVector axis:#XYZ pos:true
					else
						AlignPivotToVector axis:#XYZ pos:false
				)
			) 
			rcPos = mouse.screenpos
			popUpMenu rcMapSize pos:rcPos
		)catch()		
	)
	else
		messagebox "Select some objects" title:"Invalid Selection"
)