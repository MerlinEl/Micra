-------------------- snapshotAsEPoly --------------------
(
	local objs = #()
	fn epFilt o = canConvertTo o Editable_Poly
	fn Sel_fn = selectByName buttonText:"Get" filter:epFilt \
	title:"Select objects to snapshot as Editable Poly"
	fn snAsEPoly = for o in objs do (p = copy o;convertTo p Editable_Poly)
	if $ != undefined then
	(
		if queryBox "Snapshot selected?" title:"snapshotAsEPoly" beep:false then
		(
			objs = for i in selection where canConvertTo i Editable_Poly collect i
			if objs.count > 0 then snAsEPoly()
		)
		else (objs = Sel_fn();if objs != undefined then snAsEPoly())
	)
	else (objs = Sel_fn();if objs != undefined then snAsEPoly())
)
