$00_pe_prototype001.parent = $Plane001


selectmore $.children


	fn getChain node =
	(
		if node == undefined do return false
		local nodes = #()
		for o in node.children do 
		(
			nodes += o
			getChain o
		)
		return nodes
	)
	x = getChain $


(
	struct chain (node = undefined, children = #())
	fn getChain node =
	(
		if node == undefined do return false
		local data = chain node
			for c in node.children do append data.children (getChain c)
		return data
	)
	x = getChain $
	
	for i=1 to x.children.count do format "%\n" x.children[i]
)

--for i in selection do format "name:%\tparent:%\n" i.name i.parent.name

	fn saveLinks nodes =
	(
		if nodes.count < 2 do return OK
		struct tree (node,parent)
		local data =#()
		for n in nodes do
		(
			append data (tree n n.parent)
		)
		return data
	)
	fn loadLinks data =
	(
		if data.count == 0 do return OK
		for d in data do
		(
			if (isDeleted d.node) do continue
			if d.parent == undefined then
				d.node.parent = undefined
			else
				d.node.parent = if (isDeleted d.parent) then undefined else d.parent
		)
	)
	
my_data = saveLinks $
loadLinks my_data
