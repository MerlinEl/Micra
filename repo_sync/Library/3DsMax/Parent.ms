for i in selection do format "model:%\tparent:%\n" i.name i.parent




fn getParentChain obj =
(
	local parents = #()
	local pp = obj.parent
	while pp != undefined do 
	(
		parents += #(pp)
		pp = parent.parent
	)
	return parents
)