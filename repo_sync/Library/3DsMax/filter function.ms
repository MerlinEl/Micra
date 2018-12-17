-- filter used by pickButton. Prevents duplicate entries
 fn filterUnique obj = findItem this.theNodeList obj == 0



rollout unnamedRollout "Untitled" width:140 height:100
(
	fn shapesOnly obj = isKindOf obj shape
	pickButton btn1 "PickButton" pos:[32,28] width:76 height:44 filter:shapesOnly
	on btn1 picked obj do
	(
		btn1.text = obj.name
	)
)
createDialog unnamedRollout
