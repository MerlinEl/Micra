
for o in selection do (

	for i = 1 to o.vertices.count do (

		polyop.SetVertSelection o #{i}
		vc = o.getVertexColor #VertexColor
		--format "v:% c:% h:% s:% b:%\n" i vc vc.h vc.s vc.b
		if vc.s == 0 then ( --if is white color
			
			polyOp.setVertColor o 0 i blue
		
		) else if vc.s < 255 then ( ---if is gradient with white
			
			vc.s = 255	
			polyOp.setVertColor o 0 i vc
		)
	)
)



-- ============================================================================
-- Set the base colors you require:
-- Use: http://www.colorpicker.com
-- to find the RGB values of the base colour you wish to
-- suppress white backgrounds with:
-- Default gray provided:
-- ============================================================================

/*fn removeWhiteColor clr = (
	 --Get background-color RGB
	local r_needed  = 220
	local g_needed = 220
	local b_needed = 255
	if (clr.r>=220 and clr.g>=220 and clr.b>=220) then ( -- White range detection

		if (clr.r>=250 and clr.r<=255 and clr.g>=250 and clr.g<=255 and clr.b>=250 and clr.b<=255) then (
			
			r_needed  += 0
			g_needed += 0 
			
		) else if (clr.r>=240 and clr.r<=255 and clr.g>=240 and clr.g<=255 and clr.b>=240 and clr.b<=255) then (
			
			r_needed  += 6
			g_needed += 3
			
		) else if (clr.r>=230 and clr.r<=255 and clr.g>=230 and clr.g<=255 and clr.b>=230 and clr.b<=255) then (
			
			r_needed  += 10
			g_needed += 5
			
		) else if (clr.r>=220 and clr.r<=255 and clr.g>=220 and clr.g<=255 and clr.b>=220 and clr.b<=255) then (
			
			r_needed  += 14
			g_needed += 7 
		)
		clr = color r_needed  g_needed  b_needed -- The background-color you want
	)
	clr -- result color can be unchanged (depends on white color detection)
)

for i = 1 to $.vertices.count do (

	polyop.SetVertSelection $ #{i}
	vc = removeWhiteColor ($.getVertexColor #VertexColor)
	format "v:% c:%\n" i vc
	polyOp.setVertColor $ 0 i vc
)*/

