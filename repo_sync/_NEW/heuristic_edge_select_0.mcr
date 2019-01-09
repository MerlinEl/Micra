-------------------------------------------------------------------------------------
-- Heuristic Edge Loop
--
-- File: heuristic_edge_loop.mcr
-- Author: Vojtech Cada
-- e-mail: vojta@krypton.cz
--
-- Created on: 12/2014
-- Last Updated: 12/2014
-- Version: 0.01b
--
-- Compatibility: Max 9+/VIZ 2008+
-- Description: Select next most probable edge in a loop.
--
-- Used Code Snippets by:
-------------------------------------------------------------------------------------

macroScript heuristicEdgeLoop
	category:   "Advanced Poly Ops"
	buttonText: "Heuristic Edge Select"
	toolTip:	"Heuristic Edge Select"
(
	---------------------------------------------------------------------------------
	-- Private Globals
	---------------------------------------------------------------------------------

	local obj, universal, edgeSel = #{}

	---------------------------------------------------------------------------------
	-- Structs
	---------------------------------------------------------------------------------

	struct polyFns
	(
		getVertPos = polyOp.getVert,
		getEdgeVerts = polyOp.getEdgeVerts,
		getEdgeSel = polyOp.getEdgeSelection,
		setEdgeSel = polyOp.setEdgeSelection,
		getVertsByEdges = polyOp.getVertsUsingEdge,
		getEdgesByVerts = polyOp.getEdgesUsingVert
	)

	struct polyModFns
	(
		fn getListData list = case (classOf list) of (BitArray: list; Integer: #{list}; default: #{});,
		fn getVertPos obj vert = obj.getVertex vert,
		fn getEdgeVerts obj edge = #(obj.getEdgeVertex edge 1, obj.getEdgeVertex edge 2),
		fn getEdgeSel obj = obj.getSelection #Edge,
		fn setEdgeSel obj edgeList =
		(
			obj.setEPolySelLevel #Edge
			obj.setSelection #Edge #{}
			obj.select #Edge edgeList
		),
		fn getVertsByEdges obj edgeList vertList:#{} =
		(
			edgeList = getListData edgeList
			obj.getVertsUsingEdge &vertList &edgeList
			vertList
		),
		fn getEdgesByVerts obj vertList edgeList:#{} =
		(
			vertList = getListData vertList
			obj.getEdgesUsingVert &edgeList &vertList
			edgeList
		)
	)

	struct edgeDef
	(
		edge,
		startVert,
		endVert,
		endVertPos = universal.getVertPos obj endVert,
		dir = normalize (universal.getVertPos obj startVert - endVertPos)
	)

	struct stopConditionsDef
	(
		angle = true,
		fork = true,
		pole = false,

		angleCos = cos 30,
		forkTol = 5,
		poleVal = 5,

		result,

		fn meet candidates =
		(
			result = if candidates.count > 0 then candidates[1].v1

			if candidates.count == 0 then true
			else if angle AND candidates[1].v2 < angleCos then true
			else if fork AND candidates.count > 1 AND abs(acos candidates[1].v2 - acos candidates[2].v2) < forkTol then true
			else if pole AND candidates.count == poleVal then true
			else false
		)
	)

	local stopConditions = stopConditionsDef()

	---------------------------------------------------------------------------------
	-- Functions
	---------------------------------------------------------------------------------

	fn getFirstItem bitArr item:0 =
	(
		for i in bitArr while NOT item > 0 do item = i
		item
	)

	fn compareAngle edge1 edge2 =
		if edge1.v2 < edge2.v2 then 1
		else if edge1.v2 > edge2.v2 then -1
		else 0

	fn getEdgeByVertData edge edgeVerts sharedVerts =
		if (edgeVerts - sharedVerts).numberSet < 1 then edgeDef edge:edge startVert:(getFirstItem edgeVerts) endVert:(edgeVerts as array)[2]
		else edgeDef edge:edge startVert:(getFirstItem (edgeVerts * sharedVerts)) endVert:(getFirstItem (edgeVerts - sharedVerts))
		
	fn getEdgeByEdgeIndex edge =
		getEdgeByVertData edge (universal.getVertsByEdges obj edge) (universal.getVertsByEdges obj (edgeSel - #{edge}))

	fn getTerminalEdges obj edges terminalEdges:#() =
	(
		for edge in edges do
		(
			local edgeCount = (universal.getEdgesByVerts obj (local edgeVerts = universal.getVertsByEdges obj edge) * edgeSel).numberSet

			if edgeCount == 2 do
				append terminalEdges (getEdgeByVertData edge edgeVerts (universal.getVertsByEdges obj (edgeSel - #{edge})))
			if edgeCount == 1 do
			(
				edgeVerts = edgeVerts as array
				append terminalEdges (edgeDef edge:edge startVert:edgeVerts[1] endVert:edgeVerts[2])
				append terminalEdges (edgeDef edge:edge startVert:edgeVerts[2] endVert:edgeVerts[1])
			)
		)
		terminalEdges
	)

	fn getCandidates obj edge =
	(
		local indices = universal.getEdgesByVerts obj edge.endVert - edgeSel
		local candidates = for i in indices collect
			dataPair i (dot edge.dir (normalize (edge.endVertPos - universal.getVertPos obj (getFirstItem (universal.getVertsByEdges obj i - #{edge.endVert})))))

		qSort candidates compareAngle
		candidates
	)

	mapped fn modifyLoop edges modify =
	(
		modify edgeSel edges.edge
		universal.setEdgeSel obj edgeSel
		edges
	)

	mapped fn growLoop edges =
		if (NOT stopConditions.meet (getCandidates obj edges)) do
			modifyLoop (getEdgeByEdgeIndex stopConditions.result) append

	mapped fn selectLoop edges =
		if (NOT stopConditions.meet (getCandidates obj edges)) do
			selectLoop (modifyLoop (getEdgeByEdgeIndex stopConditions.result) append)

	fn initLoopData sel =
	(
		edgeSel = sel
		getTerminalEdges obj edgeSel
	)

	fn tryInit =
	(
		if subObjectLevel == undefined then max modify mode
		obj = Filters.GetModOrObj()

		case (classOf obj) of
		(
			Editable_Poly: (universal = polyFns(); true)
			Edit_Poly: (universal = polyModFns(); true)
			default: (messageBox "This script only works with editable poly objects."; false)
		)
	)

	rollout heuristicEdgeLoopRollout "Heuristic Edge Loop" width:335 height:125
	(
		---------------------------------------------------------------------------------
		-- Layout Section
		---------------------------------------------------------------------------------

		checkBox chxStopOnAngle "Stop when next angle is bigger than: " pos:[22, 13] checked:stopConditions.angle
		spinner spnStopAngle range:[0, 180, acos stopConditions.angleCos] pos:[277, 12] width:50 enabled:stopConditions.angle
		checkBox chxStopOnFork "Stop when next angles are similar; threshold: " pos:[22, 37] checked:stopConditions.fork
		spinner spnStopFork range:[0, 90, stopConditions.forkTol] pos:[277, 36] width:50 enabled:stopConditions.fork
		checkBox chxStopOnPole "Stop when the edge meets given nr. of edges: " pos:[22, 61] checked:stopConditions.pole
		spinner spnStopPole range:[2, 100, stopConditions.poleVal] pos:[277, 60] type:#integer width:50 enabled:stopConditions.pole

		button btnLoop "Loop" pos:[51, 91] width:85 height:18
		spinner spnLoopGrow pos:[150, 91] width:0 range:[-1e6, 1e6, 0] type:#integer
		button btnClose "Close" pos:[192, 91] width:85 height:18

		local growVal = 0

		---------------------------------------------------------------------------------
		-- Rollout Event Handlers
		---------------------------------------------------------------------------------

		on chxStopOnAngle changed state do
			stopConditions.angle = spnStopAngle.enabled = state

		on chxStopOnFork changed state do
			stopConditions.fork = spnStopFork.enabled = state

		on chxStopOnPole changed state do
			stopConditions.pole = spnStopPole.enabled = state

		on spnStopAngle changed val do
			stopConditions.angleCos = cos val

		on spnStopFork changed val do
			stopConditions.forkTol = val

		on spnStopPole changed val do
			stopConditions.poleVal = val

		on spnLoopGrow changed val do with redraw off, undo "Heuristic Loop" on
		(
			if val - growVal > 0 then
				growLoop (initLoopData (universal.getEdgeSel obj))
			else if val - growVal < 0 do
				modifyLoop (initLoopData (universal.getEdgeSel obj)) deleteItem

			growVal = val
			setNeedsRedraw()
		)

		on btnLoop pressed do with redraw off, undo "Heuristic Loop" on
		(
			selectLoop (initLoopData (universal.getEdgeSel obj))
			setNeedsRedraw()
		)

		on btnClose pressed do
			destroyDialog heuristicEdgeLoopRollout
	)
	
	---------------------------------------------------------------------------------
	-- MacroScript Event Handlers
	---------------------------------------------------------------------------------

	on isEnabled return
		Filters.Is_EPolySpecifyLevel #{3..4}

	on isVisible return
		Filters.Is_EPolySpecifyLevel #{3..4}

	on execute do
		if (tryInit()) do with redraw off, undo "Heuristic Loop" on
		(
			selectLoop (initLoopData (universal.getEdgeSel obj))
			setNeedsRedraw()
		)

	on altExecute type do
		if (tryInit()) AND NOT heuristicEdgeLoopRollout.open do
			createDialog heuristicEdgeLoopRollout
)