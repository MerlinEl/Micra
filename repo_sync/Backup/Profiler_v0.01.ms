--Profiler v 0.01

rollout unnamedRollout "" width:244 height:416
(
	local activeSubRoll
	GroupBox grp1 "Profiler:" pos:[4,4] width:100 height:404
	button btn_add "Add New" pos:[12,20] width:88 height:20 toolTip:"Shape must be created from front view"
	button btn_del "Delete" pos:[12,40] width:88 height:20
	button btn_apply "Apply" pos:[12,60] width:88 height:20
	subRollout subRollThumbs "" pos:[108,12] width:132 height:396
			fn higlightThumbs_old tag lbl state = --for this function need assinged struct instance: fun
	(
		case state of 
		(
			#dragend:
			(
				--
				tmr_drag.active = false
				old_mousepos = undefined
				new_mousepos = undefined
				cursor.Current = cursor_harrow
				--
				local selected_tag = findItem fun.selectedTags tag 
				if selected_tag != 0 and not fun.selected_tag_active do --unmark
				(
					local t = fun.selectedTags[selected_tag]
					local fPath = tag.bitmap.filename
					if not doesFileExist fPath do return false -- if thumbnail file is missing
					t.bitmap = openBitMap fPath -- restore tags img
					setBorder tag yellow  --set it hilighted
					deleteItem fun.selectedTags selected_tag
					deleteItem fun.selectedLbls selected_tag
				)
			)
			#hilight:
			(
				cursor.Current = cursor_harrow
				local fPath = tag.bitmap.filename
				if not doesFileExist fPath do return false -- if thumbnail file is missing
				fun.hilightThumb   = fPath
				if findItem fun.selectedTags tag != 0 do return false -- if selected not hilight
				setBorder tag yellow 
			)
			#select: 
			(
				if dnd.drag_enabled do return false
				cursor.Current = cursor_hmove
				tmr_drag.active = true
				local selected_tag = findItem fun.selectedTags tag 
				if selected_tag == 0 
				then --mark
				(
					fun.selected_tag_active = true
					fun.selectedTags += #(tag)
					fun.selectedLbls += #(lbl)
					local fPath = tag.bitmap.filename
					if not doesFileExist fPath do return false -- if thumbnail file is missing
					setBorder tag red 
				)
				else --if tag is marked then realse active tag
				(
					fun.selected_tag_active = false
				)
			)
			#restore:
			(
				if findItem fun.selectedTags tag != 0 do return false -- if selected not clear
				if fun.hilightThumb == undefined do return false -- if thumb has ben deleted
				tag.bitmap = openBitMap fun.hilightThumb
				fun.hilightThumb == undefined
			)
		)
		--format "fun.selectedTags:%\n" fun.selectedTags
	)
--| NEW
	fn deleteSubrollout =
	(
		if activeSubRoll != undefined and classOf activeSubRoll == RolloutClass do 
		(removeSubRollout subRollThumbs activeSubRoll)
	)
	fn getAcrossPos count subRollWidth thumbSize thumbPos offset:[2,2] labelHeight:13 =
	(
		if count == 1 do (thumbPos = offset ; return (thumbPos as string)) -- in first time
		if (local newPos = thumbPos.x + thumbSize.x + offset.x) < (subRollWidth - thumbSize.x) then --new column
		(
			thumbPos.x = newPos
		)
		else --new line
		(
			thumbPos.x  = offset.x
			thumbPos.y += (thumbSize.y + offset.y + labelHeight)
		)
		--format "thumbPos:%\tsubRollWidth:%\n" thumbPos (subRollWidth + thumbSize.x)
		return (thumbPos as string)
	)
	fn createSubrollout = -->DINAMIC ROLLOUT<--
	(	
		deleteSubrollout()--remove old subRollout
		--create newRoll string for Subrollout
		local lastSubCat = "rolik"
		local thumbSize    = [128,96]
		local thumbPos     = [2,2]
		local subRollWidth = subRollThumbs.width
		local thumbBgColor = "(color 120 34 150)"
		local thumbCount =10
		
		local newRoll      = "rollout roll"+ lastSubCat + " \"" + lastSubCat + "\"\n" --width:368 height:1000
		newRoll +="(\n"
		if thumbCount > 0 do
		(
			--local variables
			newRoll += "\tlocal thumbSize    = "+thumbSize as string+"\n"
			--functions
			newRoll += "\tfn getLabelPos tag = ([tag.pos.x,tag.pos.y + tag.height])\n"
			--thumbnails
			for n=1 to thumbCount do
			(
				local nu = n as string --number
				local tagPos  = (getAcrossPos n subRollWidth thumbSize thumbPos offset:[2,2] labelHeight:13)
				local creationDate = "11111"
				local lbl = "aaaa"
				--Buttons and Labels
				newRoll +="\tImgTag tag_" +nu+ " \"thumb_" +nu+ "\" width:thumbSize.x height:thumbSize.y \ 
					tooltip:" + "\"" + creationDate + "\" bitmap:(bitmap 10 10 color:gray) pos:"+tagPos+" transparent:"+thumbBgColor+" style:#bmp_stretch\n"
				newRoll +="\tlabel  lbl_" +nu+ " \"" +lbl+ "\" pos:(getLabelPos tag_" +nu+ ") width:thumbSize.x height:13 align:#left\n"
			)
		)
		newRoll +=")\n"
		AddSubRollout subRollThumbs (execute newRoll)
		activeSubRoll = (execute ("roll"+ lastSubCat))
	)
--||
			
			
			
			
			
			fn createSubrollout_old = -->DINAMIC ROLLOUT<--
	(	
		deleteSubrollout()--remove old subRollout
		
		if lastMainCat == undefined or lastSubCat == undefined do return false
		
		local thumbSize    = execute (getIniSetting mcUserINI "3DGallery" "Thumb_Size")
		local thumbPos     = [2,2]
		local subRollWidth = subRollThumbs.width
		local thumbBgColor = "(color 120 34 150)"
		jpg_files = getFiles (rootPath+lastMainCat+"\\"+lastSubCat+"\\*.jpg")
		local thumbCount = jpg_files.count --saved models count
		--format "thumbSize:%\t thumbPos:%\t subRollWidth:%\t jpg_files:%\n thumbCount:%\n" thumbSize thumbPos subRollWidth jpg_files thumbCount
	
		--create newRoll string for Subrollout
		local newRoll      = "rollout roll"+ lastSubCat + " \"" + lastSubCat + "\"\n" --width:368 height:1000
		newRoll +="(\n"
		if thumbCount > 0 do
		(
			--local variables
			newRoll += "\tlocal thumbSize    = "+thumbSize as string+"\n"
			--functions
			newRoll += "\tfn getLabelPos tag = ([tag.pos.x,tag.pos.y + tag.height])\n"
			--thumbnails
			for n=1 to thumbCount do
			(
				local nu = n as string --number
				local tagPos  = (getAcrossPos n subRollWidth thumbSize thumbPos offset:[2,2] labelHeight:13)
				local creationDate = getFileCreateDate jpg_files[n]
				local ImageFilePath = filterPath jpg_files[n]
				local lbl = getFilenameFile ImageFilePath
				--Buttons and Labels
				newRoll +="\tImgTag tag_" +nu+ " \"thumb_" +nu+ "\" width:thumbSize.x height:thumbSize.y \ 
					tooltip:" + "\"" + creationDate + "\" bitmap:(openBitMap" + " \"" + ImageFilePath + "\") pos:"+tagPos+" transparent:"+thumbBgColor+" style:#bmp_stretch\n"
				newRoll +="\tlabel  lbl_" +nu+ " \"" +lbl+ "\" pos:(getLabelPos tag_" +nu+ ") width:thumbSize.x height:13 align:#left\n"
				--Actions
				newRoll +="\ton tag_"+nu+" mouseup      do (mcDGalleryExtr.higlightThumbs  tag_"+nu+" lbl_"+nu+" #dragend )\n"
				newRoll +="\ton tag_"+nu+" mousedown do (mcDGalleryExtr.higlightThumbs  tag_"+nu+" lbl_"+nu+" #select )\n"
				newRoll +="\ton tag_"+nu+" mouseover  do (mcDGalleryExtr.higlightThumbs tag_"+nu+" lbl_"+nu+" #hilight)\n"
				newRoll +="\ton tag_"+nu+" mouseout    do (mcDGalleryExtr.higlightThumbs  tag_"+nu+" lbl_"+nu+" #restore)\n"
				newRoll +="\ton tag_"+nu+" rightclick     do (mcDGalleryExtr.showMenu tag_"+nu+" lbl_"+nu+" )\n"
			)
		)
		newRoll +=")\n"
		AddSubRollout subRollThumbs (execute newRoll)
		activeSubRoll = (execute ("roll"+ lastSubCat))
		return true
	)
	fn renderToLibrary = --rendered shape must be created from front view
	(
		local sel = selection[1]
		if classOf sel != SplineShape do return false
		local sp = copy sel
		addmodifier sp (extrude())
		sp.material = standardMaterial diffuseColor:gray
		old_view = viewport.getType()
		--old_tm = viewport.getTM()
		if old_view != #view_front do viewport.setType #view_front
		max zoomext sel
		select sp
		max hide inv
		local w = 128, h =96
		local pic = render outputwidth:w outputheight:h vfb:off
		max undo
		delete sp 
		viewport.setType old_view
		--gw.setTransform old_tm
		tg_draw.bitmap = pic
		select sel
	)
	fn splineToScript sp =
	(
		if classOf sp != SplineShape do return false
		local SPLINE_DATA, VERTEX_DATA
		struct SPLINE_DATA (pos, steps, clr, splines, closed = #())
		struct VERTEX_DATA (pos, type, invec, outvec)
		local splines =#() --collect verts for each spline
		for s=1 to (numSplines sp) do --for all splines
		(
			local points_array = #()
			for v=1 to (numKnots sp s) do --for verts in current spline
			(
				points_array += #(VERTEX_DATA (getKnotPoint sp s v) (getKnotType sp s v) (getInVec sp s v) (getOutVec sp s v))
			)
			append splines points_array
		)
		local SD = SPLINE_DATA sp.pos sp.steps sp.wirecolor splines
		for s=1 to (numSplines sp) do SD.closed += #(isClosed sp s) -- collect if spline is closed
		return SD
	)
	fn scriptToSpline str =
	(
		local sps = SplineShape pos:str.pos wirecolor:str.clr --create spline
		for s=1 to str.splines.count do --for all splines
		(	
			addNewSpline sps
			--for verts in current spline
			for v in str.splines[s] do (addKnot sps s v.type #curve v.pos v.inVec v.OutVec)
			if str.closed[s] do close sps s
		)
		updateShape sps
		return sps
	)

	on btn_add   pressed  do(createSubrollout())--renderToLibrary())
	on btn_del   pressed  do()
	on btn_apply pressed  do()

)
createDialog unnamedRollout
