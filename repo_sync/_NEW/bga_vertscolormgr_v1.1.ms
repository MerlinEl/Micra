/*//////////   SCRIPT:   VertsColorMgr v1.1   //////////*/
/*//////////   WRITTEN BY:   Branko Zivkovic   //////////*/
/*//////////   EMAIL:   barigazy@hotmail.com   //////////*/
try(destroyDialog ::vcmRoll)catch()
rollout vcmRoll "VertsColorMgr"
(
	local poSetVC = polyop.setvertcolor, poGetVC = polyop.getvertsbycolor, poGetVS = polyop.getVertSelection, poCDS = polyop.collapseDeadStructs
	local vertClrs = #(red, green, blue, white, black)
	
	button btn_set "Set Selected Verts Color" pos:[5,5] width:125
	dropdownlist dd_colorlist pos:[135,5] width:60 items:#("red", "green", "blue", "white", "black")
	button btn_show "Show | Hide Vertex Color" pos:[5,30] width:190
	dropdownlist dd_firstClr pos:[5,55] width:60 items:#("red", "green", "blue", "white", "black", "custom")
	dropdownlist dd_secondClr pos:[70,55] width:60 items:#("red", "green", "blue", "white", "black", "custom")
	button btn_swap "Swap" pos:[135,55] width:60 height:46
	button btn_getFirst "Get" pos:[5,80] width:30 enabled:off
	colorpicker clr_one "" pos:[32,80] fieldWidth:28 height:21 title:"Set First Color" color:red enabled:off
	button btn_getSecond "Get" pos:[70,80] width:30 enabled:off
	colorpicker clr_two "" pos:[97,80] fieldWidth:28 height:21 title:"Set Second Color" color:red enabled:off
	
	on dd_firstClr selected itm do 
	(
		if itm != 6 then (clr_one.color = vertClrs[itm] ; btn_getFirst.enabled = clr_one.enabled = off) else (btn_getFirst.enabled = clr_one.enabled = on)
	)
	on dd_secondClr selected itm do 
	(
		if itm != 6 then (clr_two.color = vertClrs[itm] ; btn_getSecond.enabled = clr_two.enabled = off) else (btn_getSecond.enabled = clr_two.enabled = on)
	)	
	on btn_set pressed do
	(
		if selection.count == 1 and isKindOf (obj = selection[1]) Editable_Poly do
		(
			if (verts = poGetVS obj).isEmpty then (messageBox "Select Some Verts FIrst!" title:"Warning" beep:off) else (poSetVC obj 0 verts vertClrs[dd_colorlist.selection] ; update obj ; poCDS obj)
		)
	)
	on btn_show pressed do (if selection.count == 1 and isKindOf (obj = selection[1]) Editable_Poly do obj.showVertexColors = not obj.showVertexColors)
	on btn_swap pressed do
	(
		if selection.count == 1 and isKindOf (obj = selection[1]) Editable_Poly do
		(
			if dd_firstClr.selected == dd_secondClr.selected then (messageBox "Why do you want to swap same color!" title:"Warning" beep:off) else
			(
				local c1 = if (itm = dd_firstClr.selection) != 6 then (vertClrs[itm]) else clr_one.color
				local c2 = if (itm = dd_secondClr.selection) != 6 then (vertClrs[itm]) else clr_twocolor
				local first = poGetVC obj c1 0 0 0 channel:0, second = poGetVC obj c2 0 0 0 channel:0
				if first.isEmpty then (messageBox ("This object not have assigned " + dd_firstClr.selected +" vertex color!") title:"Warning" beep:off) else
				(
					if second.isEmpty then (messageBox ("This object not have assigned " + dd_secondClr.selected +" vertex color!") title:"Warning" beep:off) else
					(
						poSetVC obj 0 first c2 ; poSetVC obj 0 second c1
						update obj ; poCDS obj ; first = second = null
					)
				)
			)
		)
	)
	on btn_getFirst pressed do
	(
		if selection.count == 1 and isKindOf (obj = selection[1]) Editable_Poly do
		(
			if (poGetVS obj).numberset != 1 then (messageBox "Select only one vertex!" title:"Warning" beep:off) else (clr_one.color = obj.GetVertexColor #VertexColor)
		)
	)
	on btn_getSecond pressed do
	(
		if selection.count == 1 and isKindOf (obj = selection[1]) Editable_Poly do
		(
			if (poGetVS obj).numberset != 1 then (messageBox "Select only one vertex!" title:"Warning" beep:off) else (clr_two.color = obj.GetVertexColor #VertexColor)
		)
	)	
)
createDialog vcmRoll 200 105 10 110 style:#(#style_titlebar, #style_sysmenu, #style_toolwindow)