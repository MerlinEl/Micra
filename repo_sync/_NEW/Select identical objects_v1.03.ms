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
fn isIdenticalVerts objA objB =
(
	local vcountA = getNumVerts objA
	local vcountB = getNumVerts objB 
	if vcountA != vcountB do return false
	for i=1 to vcountA where (in coordsys local polyop.getvert objA i) != (in coordsys local polyop.getvert objB i) do return false
	return true
)

(
	local sel = (selection as array)[1]
	if isValidObject sel do
	(
		local identicalObjects = #()
		local selObjVertCount = (getNumVerts sel)
		for i in objects where isValidObject i and isIdenticalVerts sel i do 
		(
			identicalObjects += #(i)
		)
		if identicalObjects.count != 0 do select identicalObjects
	)
)