plugin modifier InsetFaces
	name:"Inset Faces"
	classID:#(0x6bf4b41f, 0x37a012dc)
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
		type type:#integer animatable:off default:1 ui:rbType
		amount type:#float default:1 ui:spnAmount

		on type set index do delegate.insetType = index - 1
		on amount set val do delegate.insetAmount = val
	)
	
	on create do
	(
		delegate.animationMode = 1
		delegate.useStackSelection = on
		delegate.setEPolySelLevel #Face
		delegate.setOperation #Inset
	)

	on load do initUpdate (refs.dependentNodes this)[1]
	
	on attachedToNode node do
		if isValidNode node then initUpdate node
		else if this.updateHandler != undefined do deleteChangeHandler this.updateHandler

	rollout params "Parameters"
	(
		spinner spnAmount "Amount: " type:#worldUnits range:[-1e6, 1e6, 1]
		radioButtons rbType labels:#("Group", "By Polygon")
	)
)