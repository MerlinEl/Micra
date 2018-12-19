undo "scale UV" on (
	local sel = selection as array
	if (sel.count < 1) do return false
	local uv_channel = 1
	local scale_center = [0,0,0] 
	local u_scale_factor = 1
	local v_scale_factor = 1.5
	for o in sel where iskindof o Editable_Poly do
	(
		format "scale uv on:%\n" o.name
		for v=1 to (polyop.getnummapverts o uv_channel) do
		(
			local pos = polyop.getmapvert o uv_channel v
			pos = (pos - scale_center)*[u_scale_factor,v_scale_factor,1] + scale_center
			polyop.setmapvert o uv_channel v pos
		)
	)
)