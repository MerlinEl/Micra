--Scripted Modifier Plug-ins
--GenclassID() 


plugin modifier dummy_settings
name:"Dummy Settings2"
classID:#(0x3c0334b1, 0x30f5be78)
(
	fn resize obj axis val = 
	(
		if classOf obj != dummy do return false
		case axis of
		(
			x:obj.boxsize.x = val
			y:obj.boxsize.y = val
			z:obj.boxsize.z = val
		)
	)
	
	parameters main rollout:params
	(

		Width  type:#worldUnits ui:spn_x default:0
		Lenght type:#worldUnits ui:spn_y default:0
		Height type:#worldUnits ui:spn_z default:0
		
		on Width  set val do resize selection[1] x val
		on Lenght set val do resize selection[1] y val
		on Height set val do resize selection[1] z val
	)
	
	rollout params "Parameters:"
	(
		spinner spn_x "Width:"  range:[-1000,1000,0] type:#worldUnits 
		spinner spn_y "Lenght:" range:[-1000,1000,0] type:#worldUnits
		spinner spn_z "Height:" range:[-1000,1000,0] type:#worldUnits
		fn getDummySize obj =
		(
			if classOf obj != dummy do return false
			spn_x.value = obj.boxsize.x
			spn_y.value = obj.boxsize.y
			spn_z.value = obj.boxsize.z
		)
		on params open do getDummySize selection[1]

    )
)