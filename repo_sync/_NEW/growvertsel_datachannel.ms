plugin modifier growVertSel
name:"Grow Vertex Selection"
classID:#(0x4b26c0b1, 0x47b8b887)
extends:DataChannelModifier
replaceUI:false
(
	local cloned = false
	local counter = 0
	local dataMod, dataModParams
	local script = "on process theNode theMesh elementType outputType outputArray do
	(
		fn growVertSel obj sel iterations =
		(
			for i = 1 to iterations do sel = polyop.getVertsUsingFace obj (polyop.getFacesUsingVert obj sel)
			return sel
		)

		if theMesh == undefined then return 0
		local numVerts = polyop.getNumVerts theMesh
		if numVerts == 0 then return 0

		local dcm = for ref in refs.dependents theMesh where isKindOf ref DataChannelModifier do exit with ref
		local vertSel = for v = 1 to numVerts where polyop.getVDataValue theMesh 2 v > 0 collect v
		local grownSel = growVertSel theMesh (vertSel as bitArray) dcm.numIters

		outputArray.count = numVerts
		for i = 1 to numVerts do outputArray[i] = if grownSel[i] then 1. else 0.
	)"

	on create do
	(
		dataMod = delegate
		this.name = delegate.name = "DataChannel_Grow"
		dataModParams = attributes "MXS_Params" attribID:#(0x79177be, 0x53ba62b7)
		(
			parameters main rollout:params
			(
				numIters default:1 type:#integer ui:spnIters
				on numIters set val do notifyDependents this partIDmsg:#select
			)

			rollout params "MAXScript Parameters"
			(
				spinner spnIters "Iterations: " type:#integer range:[0,100,1]
			)
		)
	)

	on attachedToNode obj do if not cloned and (counter += 1) == selection.count do
	(
		custAttributes.add dataMod dataModParams
		replaceInstances this dataMod

		disableRefMsgs()
		try (
			dataMod.AddOperator 3658656257L 0L -1 
			dataMod.AddOperator 2882382387L 0L -1 
			dataMod.AddOperator 2597005274L 0L -1 
			dataMod.AddOperator 2882382387L 0L -1 
			for i = 1 to dataMod.operator_ops.count do dataMod.operator_ops[i] = 1
			dataMod.operators[1].input = 201
			dataMod.operators[2].output = 6
			dataMod.operators[2].replace = 0
			dataMod.operators[2].channelNum = 1
			dataMod.operators[3].script = script
			dataMod.operators[4].output = 4
			dataMod.operators[4].replace = 0
		) catch ()
		enableRefMsgs()

		modPanel.addModToSelection (Turn_to_Poly removeMidEdgeVertices:off useSoftSelection:off selectionLevel:2 selectionConversion:0)
		modPanel.setCurrentObject dataMod ui:on
	)

	on clone original do cloned = true
)