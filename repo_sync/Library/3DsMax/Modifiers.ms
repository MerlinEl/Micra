show $.modifiers

if obj.modifiers[#Morph_UV_Data] == undefined do addModifier obj (Morph_UV_Data()) before:2

$.modifiers[#Edit_Poly].ConvertSelection #Face #Element
$.modifiers[#Edit_Poly].getElementsUsingFace 

$.unwrap_uvw.enabled=on

----------------------------------
fn current_modifier_index obj = 
	(
	local current_mod_index
	try 
		(
		current_mod_index = modPanel.getModifierIndex $ (modPanel.getCurrentObject())
		)
	catch
		(
		current_mod_index = 0
		)
	return current_mod_index
	)



(

if selection.count == 1 then 
	(
	current_mod_index = current_modifier_index $
	if current_mod_index != 0 then
		(
		if current_mod_index == $.modifiers.count then
			(
			modPanel.setCurrentObject $
			)
		else 
			(
			current_mod_index = current_mod_index + 1
			modPanel.setCurrentObject $.modifiers[current_mod_index]
			)
		)
	)
)

modPanel.setCurrentObject $.MorphEditMod
modPanel.getModifierIndex $ $.modifiers[#MorphEditMod]
modPanel.setCurrentObject $.baseObject -- same as above

--Turn off all flex modifiers in the scene...
 (getClassInstances flex).enabled=false

theNodes = #()
 for o in getClassInstances TurboSmooth do 
 (
 for n in refs.dependentNodes o where isValidNode n do
 (
 appendIfUnique theNodes n
 )
 )
 print theNodes

--SET the material ID of your current selection.
 --//http://forums.cgsociety.org/archive/index.php/t-651273.html
 THE_CIL.modifiers[#Edit_Poly].SetOperation #SetMaterial
 THE_CIL.modifiers[#Edit_Poly].MaterialIDtoSet = (M-1) --The SET is zero based.
 THE_CIL.modifiers[#Edit_Poly].Commit ()
 THE_CIL.modifiers[#Edit_Poly].SetSelection #Face #{} ;--Clear the selection so the next time you Select, it will not append the polygons from last time.
---------------------------------------------------------------------------------------------
--if $.modifiers[1].MeshSmooth == true
--if modPanel.Selection meshsmooth() == true
--then
--messagebox "ok"
addmodifier $ (Bend())
deleteModifier $ 1 

setSelectionLevel $ #face
setSelectionLevel $ #object
setSelectionLevel $ #vertex
getSelectionLevel $
$.modifiers[#MeshSmooth].iterations = 2
$.MeshSmooth.iterations = 1
oSel = getCurrentSelection()
for i in oSel.[1] do $.modifiers[#MeshSmooth].iterations = 2
$.modifiers[#MeshSmooth].iterations = 2
for obj in $oSel* do $.modifiers[#MeshSmooth].iterations = 2

$.modifiers[2].enabled = true --enable disable modifier [2] = modifier number
modPanel.getCurrentObject() --show name of current modifier  
modPanel.setCurrentObject $.modifiers[2] --go to modifier 



ObjSel_1 = selection as array
clearSelection()
for i in ObjSel_1 do 
(
select i
modPanel.addModToSelection (Unwrap_UVW ())
deleteItem ObjSel_1 1
)

	fn mirrorObj = 
	(
		local sel = selection as array 
		if sel.count == 0 do return false
		local mod_mirror = mirror() 
		mod_mirror.mirror_axis = case rdo_axis.state of
		(
			1: 0
			2: 1
			3: 2
		)
		mod_mirror.mirror_center
		mod_mirror.copy = false
		mod_mirror.offset = 0.0
		for o in sel do ( addModifier o mod_mirror )
	)
