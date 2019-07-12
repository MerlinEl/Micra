plugin modifier ExtrudeEdges
	name:"Extrude Edges"
	classID:#(0x2684a25e, 0x2d977f07)
	extends:Edit_Poly
	replaceUI:on
(
	local owner
	local updateHandler

	fn initUpdate node =
	(
		this.owner = node
		this.updateHandler =
			when geometry this.owner changes do
				if isValidObj (local obj = modPanel.getCurrentObject()) do
					notifyDependents obj partIDmsg:#display
	)

	parameters main rollout:params
	(
		height type:#worldUnits default:1 ui:spnHeight
		width type:#worldUnits default:1 ui:spnWidth

		on height set val do delegate.extrudeEdgeHeight = val
		on width set val do delegate.extrudeEdgeWidth = val
	)
	
	on create do
	(
		delegate.animationMode = 1
		delegate.useStackSelection = on
		delegate.setEPolySelLevel #Edge
		delegate.setOperation #ExtrudeEdge
	)

	on load do initUpdate (refs.dependentNodes this)[1]
	
	on attachedToNode node do
		if isValidNode node then initUpdate node
		else if this.updateHandler != undefined do deleteChangeHandler this.updateHandler

	rollout params "Parameters"
	(
		spinner spnHeight "Height: " type:#worldUnits range:[-1e6, 1e6, 1]
		spinner spnWidth "Width: " type:#worldUnits range:[0, 1e6, 1]
	)
)