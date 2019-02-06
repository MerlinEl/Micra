--Select identical objects v 1.0

/*
Navod
=====

Vyber libovolny object (musi to byt bud poly nebo mesh)
a
spust script.

Vsechny identicke obekty budou na konci selektnuty.

*/


fn isValidObject sel =
( 
	if sel == undefined do return false
	if classOf sel != Editable_Poly and classOf sel != Editable_Mesh do return false
	return true
)

(
	local sel = (selection as array)[1]
	if isValidObject sel do
	(
		local identicalObjects = #()
		local selObjVertCount = (getNumVerts sel)
		for i in objects where isValidObject i and getNumVerts i == selObjVertCount do 
		(
			identicalObjects += #(i)
		)
		if identicalObjects.count != 0 do select identicalObjects
	)
)