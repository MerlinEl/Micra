Global mcRoadLineGeneratorDialog
if mcRoadLineGeneratorDialog != undefined do destroyDialog mcRoadLineGeneratorDialog
rollout mcRoadLineGeneratorDialog "Road Line Generator:" width:328 height:112
(
	GroupBox 'grp1' "Methods:" pos:[4,60] width:320 height:48 align:#left
	button 'btn_draw_arc' "Draw Arc" pos:[220,76] width:100 height:24 align:#left
	button 'btn_draw_line' "Draw Line" pos:[12,76] width:100 height:24 align:#left
	GroupBox 'grp3' "Params:" pos:[4,4] width:320 height:48 align:#left
	spinner 'spn_width' "" pos:[52,24] width:56 height:16 range:[0,100,15] align:#left
	label 'lbl5' "width:" pos:[12,24] width:36 height:16 align:#left
	radioButtons 'rdo_texture' "" pos:[196,24] width:120 height:16 labels:#("Full", "Dashed") columns:2 align:#left
	label 'lbl6' "texture:" pos:[140,24] width:44 height:16 align:#left
	button 'btn_draw_rect' "Draw Rectangle" pos:[116,76] width:100 height:24 align:#left
	local line_mat_id = 477
	fn addSweepMod sp_path sp_profile = (

		local sweep_mod = sweep ()
		addModifier sp_path sweep_mod ui:on
		sweep_mod.CustomShape = 1
		sweep_mod.shapes[1] = sp_profile.baseObject
		sweep_mod.yOffset = 0.2
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
		mod_uvw.selectByMatID line_mat_id --TODO 0001 check it for deselected object, may not work
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
		local vsel = #{}
		case subObjectLevel of (
		
			1: vsel = polyOp.getVertSelection obj
			2: vsel = polyOp.getVertsUsingEdge obj (polyOp.getEdgeSelection obj)
		)
		format "verts:%\n" vsel
		if vsel.numberset == 0 do return (mcMsgList.warn "not_vsel_esel")
		local points_array = for v in vsel collect polyOp.getVert obj v 
		mcSpline.splinesFromPoints points_array type:#corner color:green centerPivot:true
		
	)
	fn createLine obj = (
	
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
		local sp_profile = mcSpline.drawLineBetweenTwoPoints [0, 0, 0] [-spn_width.value, 0, 0]
		--create mesh from spline
		addSweepMod sps sp_profile
		--add texture to mesh
		mapLine sps terrain_mat line_mat_id collapsed:true 
		--restore settings
		mcMax.deselectAll()
		select obj
		subObjectLevel = slev
	)
	
	on btn_draw_line pressed do undo "Create Road Line" on  createLine(selection[1])
)
createDialog mcRoadLineGeneratorDialog



/*
local sps = mcSpline.createSplineAt(obj.pos)



-- Pass to the function the "editable poly object" and the "edge selection"
function getChainVerts oEditPoly baEdgeSelection =
(
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

format "Sorted Vertices Chain -> %
" (getChainVerts $ (polyop.getEdgeSelection $))
gc light:true
*/