
------------------------
------------------------
--	                  --
--	Uni Poly Counter  --
--	                  --
------------------------
------------------------

/*
unregisterRedrawViewsCallback mcPolyCount.Count
mcPolyCount = undefined
completeredraw()
*/

Global mcSystem
Global mcPolyCount

---------------------------------------------------------------------------------
if mcPolyCount == undefined do
---------------------------------------------------------------------------------
(
	struct PCount
	(
		last_text = "", view_text = "", text_pos, last_viewport, last_tm, units_type,
		last_sel = #(),
		fn clean =
		(
			if mcPolyCount.last_text == undefined or mcPolyCount.last_text == "" do return ok -- dont need claaning
			--print "Clearing"
			local text_size = (gw.getTextExtent mcPolyCount.last_text)+[2,0]
			local updateRect = box2 (mcPolyCount.text_pos.x) (mcPolyCount.text_pos.y) (text_size.x+1) (text_size.y+1)
			gw.clearscreen updateRect useBkg:true
			gw.enlargeUpdateRect updateRect 
			gw.updateScreen()
			gw.resetUpdateRect()
			if mcPolyCount.last_viewport != viewport.activeViewport do completeRedraw()
			mcPolyCount.last_sel  = #()
			mcPolyCount.last_text = ""
		),
		fn objChanges sel = 
		(
			--print "check"
			local arr_b = mcPolyCount.last_sel 
			local count  = if sel.count > arr_b.count then sel.count else arr_b.count
			local d = for i=1 to count where sel[i] != arr_b[i] collect i
			if d.count  == 0
			then (return false)
			else (mcPolyCount.last_sel = sel; return true)
		),
		fn viewChanges = 
		(
			if mcPolyCount.last_viewport == viewport.activeViewport
			then (mcPolyCount.last_viewport = viewport.activeViewport ; return true) 
			else (return false)
		),
		fn textChanges =
		(
			mcPolyCount.view_text != mcPolyCount.last_text
		),
		fn needReDraw =
		(
			textChanges() or viewChanges()
		),
		fn getGeoData sel =
		(
			local obj = sel[1]
			if (classof obj != Editable_Poly and classof obj != PolyMeshObject) do return (" " + obj.name) --ad a space becouse max crash if world begins with leter z. omg!	
			--print "pass"		
			local size = ""
			if (getINISetting Micra.UserSettings "Settings" "UC_ShowSize") == "true" do
			(
				local mi=try obj.min catch [0,0,0]
				local ma=try obj.max catch [0,0,0]
				--[length,width,height]
				local s = [(ma.y - mi.y), (ma.x - mi.x), (ma.z - mi.z)]
				s = mcTransform.round3Matrix s 2
				size = "      L:"+s.x as string+"  W:"+s.y as string+"  H:"+s.z as string
			)
			--Get subobject segment selection count as string (view_text)
			case subObjectLevel of 
			(
				undefined : ( --#createmode
				
					return (" " + obj.name)
				)
				1:--#vertex
				(
					local vSel = try (mcPoly.get #vSel) catch (#())
					local vCount = try ((obj.Verts.count) as string) catch ("")
					local vSelCount = (if vSel.count == 1 then vSel[1] else vSel.count )
					return "Vertices: "+ (vSelCount as string)   + "  / " + vCount 
				)
				2:--#edge
				(
					local eSel = try (mcPoly.get #eSel) catch (#())
					local eCount = try ((obj.Edges.count) as string) catch ("")
					local eSelCount = (if eSel.count == 1 then eSel[1] else eSel.count )
					
					if eSelCount != 0 
					then 
					(
						local verts = mcPoly.getVertsFrom eSel[1] as array
						--format "verts(#edge):%\n" verts
						--(return "Edges: "+ (eSelCount as string) + "  / " + eCount )
						--/*

						if verts != undefined and verts.count == 2 do
						(
							local vert1 = (modPanel.getCurrentObject()).GetVertex verts[1]
							local vert2 = (modPanel.getCurrentObject()).GetVertex verts[2]
							local eLength = (mcTransform.round (distance vert1 vert2) 100) as string
							return "Edges: "+ (eSelCount as string) + "  / " + eCount  + "  [ " + eLength + " ]" + mcPolyCount.units_type 
						)
						--*/
					)
					else (return "Edges: "+ (eSelCount as string) + "  / " + eCount )
				) 
				3:--#border1
				(
					return (" " + obj.name)
				)
				4:--#face
				( 
					local fSel = try (mcPoly.get #fSel) catch (#())
					local fCount = try ((obj.Faces.count) as string) catch ("")
					local fSelCount = (if fSel.count == 1 then fSel[1] else fSel.count )
					return "Polys: "+ (fSelCount as string)   + "  / " + fCount + size 
				)
				5:--#element
				(
					return (" " + obj.name)
				)
				0:--#object 
				(
					return (" " + obj.name)
				)
			)	
		),
		fn draw =
		(
			if needRedraw() do clean()
			--print "drawing"
			if mcPolyCount.view_text == undefined or mcPolyCount.view_text  == "" do return ok
			local text_size = (gw.getTextExtent mcPolyCount.view_text)+[2,0]
			local updateRect = box2 (mcPolyCount.text_pos.x) (mcPolyCount.text_pos.y) (text_size.x+1) (text_size.y+1)
			gw.hText  [5,5,1000]  mcPolyCount.view_text  color:(color 120 255 120)
			gw.enlargeUpdateRect updateRect
			gw.updateScreen()
			mcPolyCount.last_text = mcPolyCount.view_text
		),
		fn count =
		(
			local sel = selection as array
			if sel.count == 0 then
			(
				clean()
				return ok
			)
	
			if (sel.count > 1 and objChanges sel) 
			then 
			(
				--print "sel 2"
				mcPolyCount.view_text = "Selected: " + sel.count as string
			)
			else if sel.count == 1 do
			(
				--print "sel 1"
				mcPolyCount.view_text = getGeoData sel
			)
			
			draw()	 				
		)
	)
	mcPolyCount = PCount()
	mcPolyCount.text_pos   = [5, gw.getWinSizeY()-18, 1000]
	mcPolyCount.units_type = mcSystem.unitsType()
)
--Switch is preventing double Runs
unregisterRedrawViewsCallback mcPolyCount.Count
--register new callbacks
registerRedrawViewsCallback mcPolyCount.Count
completeredraw()

---------------------------------------------------------------------------------
--**\ Created by Merlin el' 03.10.2008 16:46:58 /**--
---------------------------------------------------------------------------------






/*
---------------------------------------------------------------------------------
if mcPolyCount == undefined do
---------------------------------------------------------------------------------
(
	fn mcPolyCount =
	(	
		print "tick"
		--Local variables
		local uType, needClearArea, canFillArea, tex_pos, view_text = "" , last_text, last_viewport
		local tex_pos = [5, gw.getWinSizeY()-18, 1000]
		local sel = selection as array
		local obj = sel[1]
		
		--System Units Type
		local uType = mcSystem.unitsType()
	
		-->if selection == 1
		if  (obj != undefined and (classof obj == Editable_Poly or classof obj == PolyMeshObject)) then
		(
			local size = ""
			if (getINISetting Micra.UserSettings "Settings" "UC_ShowSize") == "true" do
			(
				local mi=try obj.min catch [0,0,0]
				local ma=try obj.max catch [0,0,0]
				--[length,width,height]
				local s = [(ma.y - mi.y), (ma.x - mi.x), (ma.z - mi.z)]
				s = mcTransform.round3Matrix s 2
				size = "      L:"+s.x as string+"  W:"+s.y as string+"  H:"+s.z as string
			)
			--Get subobject segment selection count as string (view_text)
			case subObjectLevel of 
			(
				1:--#vertex
				(
					local vSelCount = try (((mcPoly.get #vSel).count) as string) catch ("")
					local vCount = try ((obj.Verts.count) as string) catch ("")
					view_text = "Vertices: "+ vSelCount   + "  / " + vCount
				)
				2:--#edge
				(
					local eSelCount = ""
					local theEdge = try ((mcPoly.get #eSel) as array) catch (#())
					eSelCount = try ((theEdge.count) as string) catch ("")
					local eCount = try ((obj.Edges.count) as string) catch ("")
					if eSelCount == "1" 
					then 
					(
						if theEdge.count == 0 do return false
						local verts = mcPoly.getVertsFrom theEdge[1] as array
						if verts.count == 2 then
						(
							local vert1 = (modPanel.getCurrentObject()).GetVertex verts[1] 
							local vert2 = (modPanel.getCurrentObject()).GetVertex verts[2]
							local eLength = (mcTransform.round (distance vert1 vert2) 100) as string
							view_text = "Edges: "+ eSelCount + "  / " + eCount  + "  [ " + eLength + " ]" + uType 
						)
						else (view_text = "Edges: 0" + "  / " + eCount )

					)
					else (view_text = "Edges: "+ eSelCount + "  / " + eCount )
				) 
				3:--#border
				(
					view_text = obj.name
				)
				4:--#face
				( 
					local fSelCount = try (((mcPoly.get #fSel).count) as string)catch ("")  
					local fCount = try ((obj.Faces.count) as string)catch ("")
					view_text = "Polys: "+ fSelCount + "  / " + fCount + size 
				)
				5:--#element
				(
					view_text = obj.name
				)
				0:--#object 
				(
					view_text = obj.name
				)
			)	
		)
		--else if (is #sel_1) then (view_text = $.name+" "+ (getSize $) as string)
		-->if selection == 2
		else if sel.count > 0 then (view_text = "Object: "+ (sel.count as string))
		else (view_text = "")

		local needClearArea = (view_text != last_text)
		local canFillArea =  view_text != ""

		if viewport.activeViewport != last_viewport then
		(	
			print "Viewports Changes"
			completeredraw()
			last_viewport = viewport.activeViewport 
		)

		else if needClearArea then
		(	
			print "Clearing"
			local text_size = (gw.getTextExtent last_text)+[2,0]
			local updateRect = box2 (tex_pos.x) (tex_pos.y) (text_size.x+1) (text_size.y+1)
			gw.clearscreen updateRect useBkg:true
			gw.enlargeUpdateRect updateRect 
			gw.updateScreen()
			gw.resetUpdateRect()
		)

		if canFillArea do
		(
			print "Painting"
			local text_size = (gw.getTextExtent view_text)+[2,0]
			local updateRect = box2 (tex_pos.x) (tex_pos.y) (text_size.x+1) (text_size.y+1)
			gw.hText  [5,5,1000]  view_text  color:(color 120 255 120)
			gw.enlargeUpdateRect updateRect
			gw.updateScreen()
		)
		--format "size:%\n" size
		--format "%\t%\n" view_text last_text 
		last_text = view_text
	)
---------------------------------------------------------------------------------
)

---------------------------------------------------------------------------------	
	--Switch is preventing for double Runs
	unregisterRedrawViewsCallback mcPolyCount
	registerRedrawViewsCallback mcPolyCount
	completeredraw()
---------------------------------------------------------------------------------
*/
--**\ Created by Merlin el' 28.4.2006 23:53:42 /**--
