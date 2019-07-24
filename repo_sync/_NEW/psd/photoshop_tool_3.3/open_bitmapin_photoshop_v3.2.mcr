--------------------------------------------------------------------------------
--	Open bitmaps in photoshop
--	version 3.2
--	max version 6, 7, 8, 9, 2008, 2009, 2010
--	written by Joshua Newman
--	written		25/05/04
--	updated 	21/07/09
--	www.joshuanewman.net 
--	copyright 2004, 2009
--------------------------------------------------------------------------------

-- if the material editor is open, the current materials bitmaps will be opened in photoshop.
-- otherwise all the bitmaps used in the current selection will be opened.

-- 21/07/09 - Added test to make sure bitmaps are valid before trying to open in photoshop

macroScript Photoshop category:"JN Scripts" tooltip:"Load bitmaps in Photoshop." icon:#("JNpshp",1)
(

	On isEnabled return (Try((Selection.count!=0 and selection[1].material!=undefined) or mateditor.isopen())Catch())
	On isVisible return (Try((Selection.count!=0 and selection[1].material!=undefined) or mateditor.isopen())Catch()) 
	On Execute Do	
	(
		bitmaps=#()
		if mateditor.isopen() then
		(	
			a=medit.getcurmtl()
			bitmaps=getClassInstances Bitmaptexture target:a
		) else
		(
			sel=selection as array
			for s in sel do 
			(
				if s.material!=undefined then 
				(
					newbitmaps=getclassinstances Bitmaptexture target:s.material
                    for b in newbitmaps do if (finditem bitmaps b==0) then append bitmaps b
				)
			)
		)
		pshop=CreateOLEObject"Photoshop.Application" 
		pshop.Visible=true
		for b in bitmaps do if (doesfileexist b.filename) then pshop.open b.filename else (print b.filename)
	)
) 