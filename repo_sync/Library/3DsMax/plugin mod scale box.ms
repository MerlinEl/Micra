plugin modifier Scale_BB
name:"Scale_BB"
classID:#(1588005280, 1571139831)
(
	local l,w,h,transform_enabled = false
	fn resize obj axis val = 
	(
		if classOf obj.baseobject != Editable_Poly do return false
		if not transform_enabled do return false
		format "axis:%\n" axis
		case axis of
		(
			#x:
			(
				local new_scale = obj.scale.x*val/w
				obj.scale.x=new_scale
				w=val
			)
			#y:
			(
				local new_scale = obj.scale.y*val/l
				obj.scale.y=new_scale
				l=val
				--format "scale x:%\t length:%\t old_length:%\t new_scale:%\n" obj.scale.y val l new_scale
			)
			#z:
			(
				local new_scale = obj.scale.z*val/h
				obj.scale.z=new_scale
				h=val
			)
		)
	)
	parameters main rollout:params
	(
		Lenght type:#worldUnits ui:spn_le default:0
		Width  type:#worldUnits ui:spn_wi default:0
		Height type:#worldUnits ui:spn_he default:0

		on Lenght set val do resize selection[1] #y val
		on Width  set val do resize selection[1] #x val
		on Height set val do resize selection[1] #z val
	)

	rollout params "Parameters:"
	(
		spinner spn_le "Lenght:" range:[-100000,100000,0] type:#worldUnits
		spinner spn_wi "Width:"  range:[-100000,100000,0] type:#worldUnits 
		spinner spn_he "Height:" range:[-100000,100000,0] type:#worldUnits
		fn getModelSize obj =
		(
			if classOf obj.baseobject != Editable_Poly do return false
			transform_enabled = false
			local mi = obj.min
			local ma = obj.max
			
			local len  = abs (mi.y - ma.y as float)
			local wid = abs (mi.x - ma.x as float)
			local hei  = abs (mi.z - ma.z as float)
			--format "length:%\t width:%\t height:%\n"  len wid hei
			spn_le.value = len
			spn_wi.value = wid
			spn_he.value = hei
			
			l=len
			w=wid
			h=hei
			transform_enabled = true
		)
		on params open do getModelSize selection[1]
    )
)