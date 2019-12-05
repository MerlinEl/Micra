-- polyAverageNormals [2010-08-15] by Anubis [project3d.narod.ru]
macroScript polyAverageNormals category:"Anubis Tools" internalCategory:"Anubis Tools" ButtonText: "Average Normals" toolTip:"Average Normals" 
(
	obj = selection[1] ; run = false
	if isValidNode obj do if (run = canConvertTo obj Editable_Poly) do convertTo obj Editable_Poly
	
	if run do (
		max modify mode -- important!
			with redraw off (
			enm = Edit_Normals selectBy:3
			addModifier obj enm
			normals = #{}
			loop = (enm.GetNumNormals ()) / 4
			
			for i = 1 to loop do (
				obj.EditablePoly.SetSelection #Face #{i}
				enm.ConvertFaceSelection #{i} normals
				enm.EditNormalsMod.Select normals
				enm.EditNormalsMod.Average ()
				enm.EditNormalsMod.SetSelection #{}
			)
			collapsestack obj
		)
		redrawViews()
	)
)
