--Convert DX Mat To standard

fn convertDXMaterialToStandard =
(
	local sel = selection as array
	if sel.count == 0 do return false
	fn dXToStandard m =
	(
		local sm = Standardmaterial name:m.name diffusemap:(bitmapTexture())
		if classOf m != DirectX_9_Shader do return sm
		--print m.name
		local d_img = m.g_TopTexture
		local n_img = m.g_NormalTexture
		if d_img == undefined do return sm
		sm.diffusemap.filename= d_img.filename
		showTextureMap sm on
		sm
	)
	for o in sel where o.material != undefined do
	(
		local mat = o.material
		case (classOf mat) of
		(
			DirectX_9_Shader:(o.material = dXToStandard mat)
			Multimaterial:(for m=1 to mat.count do o.material[m] = dXToStandard mat[m])
		)
		
	)
	completeRedraw()
)
convertDXMaterialToStandard()