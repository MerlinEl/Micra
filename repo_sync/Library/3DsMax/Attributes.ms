

(
	local ca = attributes dummy_settings  
	(
		fn resize obj x y z = if classOf obj == dummy do obj.boxsize = [x,y,z]
		
		parameters main rollout:params
		(
			Width  type:#worldUnits ui:spn_x default:0
			Lenght type:#worldUnits ui:spn_y default:0
			Height type:#worldUnits ui:spn_z default:0
		)
		rollout params "Parameters:"
		(
			spinner spn_x "Width:"  range:[-1000,1000,0] type:#worldUnits 
			spinner spn_y "Lenght:" range:[-1000,1000,0] type:#worldUnits
			spinner spn_z "Height:" range:[-1000,1000,0] type:#worldUnits
			
			on spn_x changed val do resize selection[1] val spn_y.value spn_z.value
			on spn_y changed val do resize selection[1] spn_x.value val spn_z.value
			on spn_z changed val do resize selection[1] spn_x.value spn_y.value val
	    )
		
	)
	
	local obj = selection[1]
	if classOf obj == dummy do
	(
		local em = EmptyModifier name:"Dummy Settings"
		addModifier obj em
		custAttributes.add obj.modifiers[1] ca
		em.width  = obj.boxsize.x
		em.lenght = obj.boxsize.y
		em.height = obj.boxsize.z
	)
)


/*
	
	attributes "Game Data"
	redefine:def
	(
		parameters ...
		rollout ...
	)
	
	local new_def = "attributes \"Game Data\" ( ... )"
	custAttributes.redefine def new_def



	custAttributes.getDefs $.modifiers[1]
	$.modifiers[1].width = 50
	attri = (custAttributes.getDefs $.modifiers[#Attribute_Holder])[1].name as string
	
	
	for i in (custAttributes.getSceneDefs ()) do print i --get all custom attributes in scene
	$.modifiers[#Attribute_Holder].custAttributes
	$.modifiers[#Attribute_Holder].planeFace
	
	custAttributes.getDefs $.modifiers[#Attribute_Holder]
	custAttributes.count $.modifiers[#Attribute_Holder]
	custAttributes.get $.modifiers[#Attribute_Holder] 1
	att[1].name
	att[1].source 
*/