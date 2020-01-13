Global mcRoadMarkingGeneratorDialog
if mcRoadMarkingGeneratorDialog != undefined do destroyDialog mcRoadMarkingGeneratorDialog
rollout mcRoadMarkingGeneratorDialog "Road Marking Generator:" width:296 height:220
(
	GroupBox 'grp5' "Selected Type Settings:" pos:[128,4] width:164 height:172 align:#left
	GroupBox 'grp4' "Marking Type:" pos:[4,4] width:120 height:172 align:#left
	
	button 'btn_draw_line' "Create" pos:[4,180] width:84 height:36 align:#left
	button 'btn_fix_corner' "Fix Corner Mapping" pos:[128,180] width:84 height:36 align:#left
	
	spinner 'spn_width' "" pos:[228,32] width:56 height:16 range:[2,100,15] align:#left
	spinner 'spn_offset' "" pos:[228,56] width:56 height:16 range:[0.1,0.4,0.2] align:#left
	spinner 'spn_mat_id' "" pos:[228,80] width:56 height:16 range:[0,1000,15] type:#integer scale:1 align:#left
	spinner 'spn_ratio_x' "" pos:[228,102] width:56 height:16 range:[0,1000,15] type:#integer scale:1 align:#left
	
	radiobuttons 'rdo_texture' "" pos:[12,20] width:101 height:144 labels:#("Full", "Full Stop", "Full Double", "Full Double Dots", "Simple", "Zebra", "Dots", "Gap Thin", "Gap Fat") default:1 columns:1 align:#left
	
	label 'lbl5' "Marking Width:" pos:[140,32] width:84 height:16 align:#left
	label 'lbl8' "Bottom Offset:" pos:[140,56] width:84 height:16 align:#left
	label 'lbl9' "Material ID:" pos:[140,80] width:84 height:16 align:#left
	label 'lbl7' "Mapping Scale X:" pos:[140,104] width:84 height:16 align:#left
	radioButtons 'rdo_inverted' "inverted:" pos:[220,184] width:66 height:30 enabled:true labels:#("Y", "N") default:2 columns:2 align:#left
	local markings_data = #()
	fn fixCornerMapping obj = (

		try with redraw off (
			local inverted = rdo_inverted.state == 1
			if subObjectLevel != 2 do return (mcMsgList.warn "not_esel_1")
			local sublvl = subObjectLevel	
			local eindex = (polyop.getEdgeSelection obj as array)[1]
			local everts = polyop.getVertsUsingEdge obj eindex
			local efaces = polyop.getFacesUsingEdge obj eindex
			--store Editable_Poly geometry data
			local geo_data = mcPoly.getGeometryData obj faces:efaces
			--calculate angle between edges
			local corner_vert = (everts as array)[1]
			local corner_edges = polyOp.getEdgesUsingVert obj corner_vert
			corner_edges -=  #{eindex} --get only two edges
			local edges_angle = (mcPoly.getAngleBetweenTwoEdges obj corner_edges )/10
			--exit from edit mode
			subObjectLevel = 0
			--add unwrap modifier
			local mod_uvw = Unwrap_UVW () 
			modPanel.addModToSelection mod_uvw ui:on
			mod_uvw.edit()	
			mod_uvw.fit()
			--gather vertex uv data
			mcPolyMap.collectUnwrapData obj geo_data
			subObjectLevel = 1
			--convert geometry vert selection to UV vetr selection
			local uv_verts = mcPoly.geoVertsToMapVerts everts geo_data
		-- 	format "verts geo:% uv:%\n" everts.numberset  uv_verts.numberset
			local vsel_left = vsel_right = #{}
			if everts.numberset == uv_verts.numberset do ( --split edges
				mod_uvw.selectVertices uv_verts
				--select edges from verts and break them
				mod_uvw.vertToEdgeSelect()
				subObjectLevel = 2
				mod_uvw.breakSelected()
				subObjectLevel = 1	
				--remove old UV data
				mcPolyMap.clearUnwrapData geo_data
				--recolect new UV data
				mcPolyMap.collectUnwrapData obj geo_data
				--gather left and right vertices from splited edge
				vsel_left = mod_uvw.getSelectedVertices()
				mod_uvw.selectVertices (mcPoly.geoVertsToMapVerts everts geo_data)
				vsel_right = (mod_uvw.getSelectedVertices()) - vsel_left
			) 
			--fix UV distortion on left vertices
			mcPolyMap.skewVerticesUvs mod_uvw vsel_left (if inverted then -edges_angle/2 else edges_angle/2)
			--fix UV distortion on left vertices
			mcPolyMap.skewVerticesUvs mod_uvw vsel_right (if inverted then edges_angle/2 else -edges_angle/2)
			--
			maxOps.CollapseNodeTo obj 1 true
			select obj
			subObjectLevel = sublvl	
		) catch (
			
		)
		completeRedraw()
	)
	fn addSweepMod sp_path sp_profile btm_offset = (

		local sweep_mod = sweep ()
		addModifier sp_path sweep_mod ui:on
		sweep_mod.CustomShape = 1
		sweep_mod.shapes[1] = sp_profile.baseObject
		sweep_mod.yOffset = btm_offset
		-- $.modifiers[#Sweep].yOffset = 0.2
		sweep_mod.PivotAlignment = 5
		sweep_mod.GenerateMappingCoords = on
		sweep_mod.realWorldMapSize = on
	)
	fn mapLine obj mat mat_id ratio_x collapsed:false = (
				
		--add multi_material and set id
		obj.material = mat
		local mat_mod = Materialmodifier()
		addModifier obj mat_mod ui:on
		mat_mod.materialID = mat_id
		--Fix Texture Stretch
		mcMax.deselectAll()--TODO 0001 
		select obj--TODO 0001 
		local mod_uvw = Unwrap_UVW () 
		addModifier obj mod_uvw ui:on
		resumeEditing()
		mod_uvw.unwrap2.setTVSubObjectMode 3
		mod_uvw.selectByMatID mat_id --TODO 0001 check it for deselected object, may not work
		--fit size to texture
		mcPolyMap.stretchUvsToSquareProportionally mod_uvw move_zero:true
		--remove x stretch 
		mcPolyMap.resizeUVW mod_uvw (1.0/ratio_x) #x
		mcPolyMap.alignSelectionTo mod_uvw #left	
		suspendEditing()
		if collapsed do convertToPoly obj
	)
	fn drawlineFromPoints obj = (
			
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		local vsel = mcPoly.getChainVertsFromEdges obj (polyOp.getEdgeSelection obj)
		if vsel.count == 0 do return (mcMsgList.warn "not_vsel_esel")
		local points_array = for v in vsel collect polyOp.getVert obj v 
		mcSpline.splinesFromPoints points_array type:#corner color:green centerPivot:true
	)
	fn createLine obj = (
	
		format "material_id:% bottom_offset:% marking_width:%\n" spn_mat_id.value spn_offset.value spn_width.value
		with redraw off try(
			--store settings
			local slev = subObjectLevel
			suspendEditing()
			--get material
			local terrain_mat = currentMaterialLibrary["bc_terrain_main"]
			if terrain_mat == undefined do return return (mcMsgList.warn "not_termat")
			--create spline from points
			local sps = drawlineFromPoints obj
			if classOf sps != SplineShape do return false
			sps.name = uniqueName "Road_Line_"
			--create or pick layer and add mesh in to int
			local layer_item = mcMax.getetOrCreateLayer "road_markings"
			format "lyer:%\n" layer_item
			layer_item.addNode sps
			sps.parent = obj.parent --link it at same node
			sps.wirecolor = yellow
			format "sps:%\n" sps
			--fn create profile
			local sp_profile = mcSpline.drawLineBetweenTwoPoints [0, 0, 0] [-spn_width.value, 0, 0]
			--create mesh from spline
			local btm_offset = spn_offset.value
			addSweepMod sps sp_profile btm_offset
			--add texture to mesh
			mapLine sps terrain_mat spn_mat_id.value spn_ratio_x.value collapsed:true 
			delete sp_profile
			--restore settings
			mcMax.deselectAll()
			resumeEditing()
			select obj
			subObjectLevel = slev
		) catch (resumeEditing())
		completeRedraw()
	)

	fn setupParams index = (
	
		local item = markings_data[index]
		spn_mat_id.value = item.mat_id
		spn_offset.value = item.bottom_offset
		spn_width.value = item.marking_width
		spn_ratio_x.value = item.scale_x_ratio
	)
	on mcRoadMarkingGeneratorDialog open do (
	
		struct mcRMItem ( key, mat_id, bottom_offset, marking_width, scale_x_ratio) --(R)oad (M)arking Item
		/*
			1 texture full, simple, full stop (18, 15, 23)	id 477
			2 texture zebra (15)
			3 texture full double (15 + 4 + 15)
			4 texture full double dots (15 +  15 + 15)
			5 texture dots (15) 							id:478
		*/
		--build data
		markings_data = #(

			mcRMItem key:"Full"			mat_id:477	bottom_offset:0.2	marking_width:18 scale_x_ratio:16,
			mcRMItem key:"Full Stop"		mat_id:477	bottom_offset:0.3	marking_width:23 scale_x_ratio:16,
			mcRMItem key:"Full Double"		mat_id:479	bottom_offset:0.4	marking_width:34 scale_x_ratio:16,
			mcRMItem key:"Full Double Dots"	mat_id:478	bottom_offset:0.2	marking_width:45 scale_x_ratio:8,
			mcRMItem key:"Simple"			mat_id:477	bottom_offset:0.3	marking_width:15 scale_x_ratio:16,
			mcRMItem key:"Zebra"			mat_id:477	bottom_offset:0.3	marking_width:15 scale_x_ratio:16,
			mcRMItem key:"Dots"			mat_id:480	bottom_offset:0.2	marking_width:15 scale_x_ratio:16,
			mcRMItem key:"Gap Thin"		mat_id:482	bottom_offset:0.1	marking_width:7.5 scale_x_ratio:32,
			mcRMItem key:"Gap Fat"		mat_id:481	bottom_offset:0.1	marking_width:20 scale_x_ratio:16
		)
		setupParams 1
	)
	on btn_draw_line pressed do undo "Create Road Line" on  createLine(selection[1])
	on rdo_texture changed index do setupParams index
	on btn_fix_corner pressed do (undo "Fix Corner Mapping" on fixCornerMapping $)
)
createDialog mcRoadMarkingGeneratorDialog



/*
local sps = mcSpline.createSplineAt(obj.pos)

format "Sorted Vertices Chain -> %
" (getChainVerts $ (polyop.getEdgeSelection $))
gc light:true


remove x stretch (depend on texture proportionality 1024 / 64 = 16)  NOT WORKS
local texture_size = mcLS3D.getTextureSize mat[mat_id]
format "mapLine > Material [ % ] Texture Size % \n" mat[mat_id].name texture_size 
local height_in_width = texture_size[1] / texture_size[2]
format "mapLine > height_in_width:%\n" height_in_width
local ratio_x = (1.0/16) 
format "mapLine > ratio_x:%\n" ratio_x

mcPolyMap.resizeUVW $.modifiers[1] (1.0/16) #x
mcPolyMap.alignSelectionTo $.modifiers[1] #left	
*/