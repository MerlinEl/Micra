fn makeMaterialRollout =
(
	ss  = "rollout params \"\"
"
	ss += "(
"
	ss += "	materialbutton bt \"\" width:180
"
	ss += "	fn setMaterial mat title:on = if iskindof mat Material do
"
	ss += "	(
"
	ss += "		if bt.material != mat do bt.material = mat
"
	ss += "		bt.text = mat.name 	
"
	ss += "		if title do params.title = mat.name 
"
	ss += "		mat
"
	ss += "	)
"
	ss += "	on bt picked mat do setMaterial mat
"
	ss += ")
"
	execute (ss as string)
)
try(closeRolloutFloater usedMaterialsDialog) catch()
usedMaterialsDialog = newrolloutfloater "Used Materials" 218 600 
for k=1 to 10 do 
(
	rol = makeMaterialRollout()
	addrollout rol usedMaterialsDialog
	rol.setMaterial meditmaterials[k] 
) 