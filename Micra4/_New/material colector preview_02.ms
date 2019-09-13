fn makeMaterialRollout =
(
	ss  = "rollout params \"\"
"
	ss += "(
"
	ss += "	bitmap bmp_preview \"\" width:264 height:200
"
	ss += ")
"
	execute (ss as string)
)
try(closeRolloutFloater usedMaterialsDialog) catch()
usedMaterialsDialog = newrolloutfloater "Used Materials" 218 800 
for k=1 to 10 do 
(
	rol = makeMaterialRollout()
	addrollout rol usedMaterialsDialog
	--rol.setMaterial meditmaterials[k] 
) 
