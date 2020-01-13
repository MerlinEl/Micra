Global mcRoadMarkingGeneratorDialog
if mcRoadMarkingGeneratorDialog != undefined do destroyDialog mcRoadMarkingGeneratorDialog
rollout mcRoadMarkingGeneratorDialog "Road Marking Generator:" width:296 height:200
(
	local road_types = #("Full", "Full Stop", "Full Double", "Full Double Dots", "Simple", "Zebra", "Dots")
	GroupBox 'grp1' "Create:" pos:[4,132] width:288 height:66 align:#left
	GroupBox 'grp5' "Selected Type Settings:" pos:[128,4] width:164 height:124 align:#left
	GroupBox 'grp4' "Marking Type:" pos:[4,4] width:120 height:124 align:#left
	
	button 'btn_draw_arc' "Arc" pos:[204,150] width:80 height:36 enabled:false align:#left
	button 'btn_draw_line' "Line" pos:[12,150] width:80 height:36 align:#left
	button 'btn_draw_rect' "Rectangle" pos:[108,150] width:80 height:36 enabled:false align:#left
	
	spinner 'spn_width' "" pos:[228,32] width:56 height:16 range:[10,40,15] align:#left
	spinner 'spn_offset' "" pos:[228,56] width:56 height:16 range:[0.2,0.4,0.2] align:#left
	spinner 'spn_mat_id' "" pos:[228,80] width:56 height:16 range:[0,1000,15] type:#integer scale:1 align:#left
	
	radiobuttons 'rdo_texture' "" pos:[12,20] width:101 height:96 labels:road_types default:1 columns:1 align:#left
	
	label 'lbl5' "Marking Width:" pos:[140,32] width:84 height:16 align:#left
	label 'lbl8' "Bottom Offset:" pos:[140,56] width:84 height:16 align:#left
	label 'lbl9' "Material ID:" pos:[140,80] width:84 height:16 align:#left
	
	local markings_data = #()
	-- local material_id = 477
	-- local bottom_offset = 0.2
	-- local marking_width = 15
	-- Pass to the function the "editable poly object" and the "edge selection"
	function getChainVerts oEditPoly baEdgeSelection =(
		-- Init Edge Selection
		local baChainEdges = baEdgeSelection
		local iNumChainEdges = baEdgeSelection.numberSet

		-- Init Vert Selection
		local baChainVerts = (polyop.getVertsUsingEdge oEditPoly baEdgeSelection)
		local baInnerVerts = copy baChainVerts

		-- Sort out if it is a closed edge loop
		if (iNumChainEdges != baChainVerts.numberSet) then
		(
			-- Get chain extreme vertices
			
			-- The for loop runs through all selected edges, gets their vertices,
			-- then inverts their bit value in the baInnerVerts bitArray. Each vertex
			-- is inverted two times [true -> false -> true], with the exception
			-- of the extremes, which are inverted only once [true -> false],
			-- taking them away from the bitArray.
			-- Obtain extreme vertices by subtracting baInnerVerts from all
			-- baChainVerts bitArray.
			
			for iEdge in baChainEdges do
			(
				local baEdgeVerts = (polyop.getVertsUsingEdge oEditPoly iEdge)
				for iVert in baEdgeVerts do
				(
					baInnerVerts[iVert] = not baInnerVerts[iVert]
				)
			)
			local baExtremeVerts = (baChainVerts - baInnerVerts)

			-- Choose the extreme vertex to start from to collect vertices.
			
			-- This determines the direction of the vertices chain collection, but
			-- since it comes from a bitArray, it's quite random.
			
			local iExtremeStartVert = (baExtremeVerts as Array)[1] -- or [2]
		
			-- Init array for vertices collection
			local aiSortedVerts = #(iExtremeStartVert)
			
			-- Init current vertex index
			local iCurrentVert = iExtremeStartVert
			
			-- Init bitArray of processed edges to avoid walking back in the chain
			local baCrossedEdges = #{}

			-- Collect Vertices
			for i = 1 to iNumChainEdges do
			(
				-- do one step
				local baEdgesFromVert = (polyop.getEdgesUsingVert oEditPoly iCurrentVert)
				local baStepEdge = ((baEdgesFromVert * baChainEdges) - baCrossedEdges)
				
				-- non linear chain error catching
				if (baStepEdge.numberSet == 1) then
				(
					baCrossedEdges += baStepEdge
			
					-- collect the vertex
					local iCurrentVert = (((polyop.getVertsUsingEdge oEditPoly baStepEdge) - (aiSortedVerts as BitArray)) as Array)[1]
					aiSortedVerts[i+1] = iCurrentVert				
				)
				else
				(
					aiSortedVerts = #()
					messageBox "Edge Selection is not a linear chain"
					exit
				)
			)
		)
		else
		(
			-- Choose a vertex to start the collection
			local iStartVert = (baChainVerts as Array)[1]

			-- Init array for vertices collection
			local aiSortedVerts = #(iStartVert)
			
			-- Init current vertex index
			local iCurrentVert = iStartVert
				
			-- Init bitArray of processed edges to avoid walking back in the chain
			local iStartEdge = (((polyop.getEdgesUsingVert oEditPoly iCurrentVert) * baChainEdges) as Array)[1]
			local baCrossedEdges = #{iStartEdge}

			-- Collect Vertices
			for i = 1 to (iNumChainEdges - 1) do
			(
				-- do one step
				local baEdgesFromVert = (polyop.getEdgesUsingVert oEditPoly iCurrentVert)
				local baStepEdge = ((baEdgesFromVert * baChainEdges) - baCrossedEdges)

				-- non linear chain error catching
				if (baStepEdge.numberSet == 1) then
				(
					baCrossedEdges += baStepEdge
			
					-- collect the vertex
					local iCurrentVert = (((polyop.getVertsUsingEdge oEditPoly baStepEdge) - (aiSortedVerts as BitArray)) as Array)[1]
					aiSortedVerts[i+1] = iCurrentVert
				)
				else
				(
					aiSortedVerts = #()
					messageBox "Edge Selection is not a linear chain"
					exit
				)
			)	
		)
		-- Return sorted chain vertices array  
		return aiSortedVerts
	)
	fn addSweepMod sp_path sp_profile btm_offset = (

		local sweep_mod = sweep ()
		addModifier sp_path sweep_mod ui:on
		sweep_mod.CustomShape = 1
		sweep_mod.shapes[1] = sp_profile.baseObject
		sweep_mod.yOffset = btm_offset
		-- $.modifiers[#Sweep].yOffset = 0.2
		sweep_mod.GenerateMappingCoords = on
		sweep_mod.realWorldMapSize = on
	)
	fn mapLine obj mat mat_id collapsed:false = (
	
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
		mod_uvw.unwrap2.setTVSubObjectMode 3
		mod_uvw.selectByMatID material_id --TODO 0001 check it for deselected object, may not work
		--fit size to texture
		mcPolyMap.stretchUvsToSquareProportionally mod_uvw move_zero:true
		local ratio = (1.0/16) 
		--remove x stretch (depend on texture proportionality 1024 x 64 = 16x)
		mcPolyMap.resizeUVW mod_uvw ratio #x
		mcPolyMap.alignSelectionTo mod_uvw #left	
		if collapsed do convertToPoly obj
	)
	fn drawlineFromPoints obj = (
			
		if classOf obj != Editable_Poly do return (mcMsgList.warn "not_poly")
		-- local vsel = #{}
		-- case subObjectLevel of (
		
			-- 1: vsel = polyOp.getVertSelection obj
			-- 2: vsel = polyOp.getVertsUsingEdge obj (polyOp.getEdgeSelection obj)
		-- )
		-- format "verts:%\n" vsel
		local vsel = getChainVerts obj (polyOp.getEdgeSelection obj)
		if vsel.count == 0 do return (mcMsgList.warn "not_vsel_esel")
		local points_array = for v in vsel collect polyOp.getVert obj v 
		mcSpline.splinesFromPoints points_array type:#corner color:green centerPivot:true
		
	)
	fn createLine obj = (
	
		format "material_id:% bottom_offset:% marking_width:%\n" material_id bottom_offset marking_width
		--store settings
		local slev = subObjectLevel
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
		local sp_profile = mcSpline.drawLineBetweenTwoPoints [0, 0, 0] [-marking_width, 0, 0]
		--create mesh from spline
		local btm_offset = bottom_offset
		addSweepMod sps sp_profile btm_offset
		--add texture to mesh
		mapLine sps terrain_mat material_id collapsed:true 
		delete sp_profile
		--restore settings
		mcMax.deselectAll()
		select obj
		subObjectLevel = slev
	)

	fn setupParams index = (
	
		local item = markings_data[index]
		spn_mat_id.value = material_id = item.mat_id
		spn_offset.value = bottom_offset = item.offset
		spn_width.value = marking_width = item.w
	)
	on mcRoadMarkingGeneratorDialog open do (
	
		struct mcRMItem ( key, mat_id, offset, w ) --(R)oad (M)arking Item
		/*
			1 texture full, simple, full stop (18, 15, 23)	id 477
			2 texture zebra (15)
			3 texture full double (15 + 4 + 15)
			4 texture full double dots (15 +  15 + 15)
			5 texture dots (15) 							id:478
		*/
		markings_data = #(

			mcRMItem key:"Full"			mat_id:477	offset:0.2	w:18,
			mcRMItem key:"Full Stop"		mat_id:477	offset:0.3	w:23,
			mcRMItem key:"Full Double"		mat_id:477	offset:0.4	w:34,
			mcRMItem key:"Full Double Dots"	mat_id:477	offset:0.2	w:45,
			mcRMItem key:"Simple"			mat_id:477	offset:0.3	w:15,
			mcRMItem key:"Zebra"			mat_id:477	offset:0.3	w:15,
			mcRMItem key:"Dots"			mat_id:478	offset:0.2	w:15
		)
		setupParams 1
	)
	on btn_draw_line pressed do undo "Create Road Line" on  createLine(selection[1])
	on rdo_texture changed index do setupParams index
)
createDialog mcRoadMarkingGeneratorDialog



/*
local sps = mcSpline.createSplineAt(obj.pos)

format "Sorted Vertices Chain -> %
" (getChainVerts $ (polyop.getEdgeSelection $))
gc light:true
*/