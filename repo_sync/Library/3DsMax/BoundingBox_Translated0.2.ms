/*
"Translated Bounding Box" v.0.2 [2009-12-20]
	by Anubis [http://project3d.narod.ru]
Compatibility:
	All 3ds max versions
Description:
	Create Box or Dummy (if CTRL key pressed) for each selected objects
	using their translated bounding boxes
Reference:
	The script relevant to this forum topic:
	http://area.autodesk.com/forum/autodesk-3ds-max/maxscript/local-bounding-box-primitives/
	First script version (v.0.1) for 3ds max 2008 and higher:
	http://www.scriptspot.com/3ds-max/translated-bounding-box
*/
macroScript TranslatedBoundingBox
	category:"Objects"
	tooltip:"Translated Bounding Box"
	icon:#("standard", 1)
(
	on isEnabled return selection.count > 0
	on execute do (
		if keyboard.controlPressed then (
			for i in selection do with undo off (
				c = snapshot i
				c.transform = matrix3 1
				d = dummy boxsize:(c.max - c.min)
				delete c
				d.transform = i.transform
				d.pos = i.center
				d.name = i.name + "_box"
			)
		)
		else (
			for i in selection do with undo off (
				c = snapshot i
				c.transform = matrix3 1
				bb = c.max - c.min
				b = box width:bb[1] length:bb[2] height:bb[3]
				CenterPivot b
				delete c
				b.transform = i.transform
				b.pos = i.center
				b.pivot = i.pivot
				b.name = i.name + "_box"
			)
		)
	)
)
