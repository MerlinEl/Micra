plugin modifier OutlineFaces
	name:"Outline Faces"
	classID:#(0x2133b7b8, 0x50ab9719)
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
		amount type:#float default:1 ui:spnAmount
		on amount set val do delegate.outlineAmount = val
	)
	
	on create do
	(
		delegate.animationMode = 1
		delegate.useStackSelection = on
		delegate.setEPolySelLevel #Face
		delegate.setOperation #Outline
	)

	on load do initUpdate (refs.dependentNodes this)[1]
	
	on attachedToNode node do
		if isValidNode node then initUpdate node
		else if this.updateHandler != undefined do deleteChangeHandler this.updateHandler

	rollout params "Parameters"
	(
		spinner spnAmount "Amount: " type:#worldUnits range:[-1e6, 1e6, 1]
	)
)