(
	local sel = selection as array
	for i in sel do 
	(
		local new_dummy = dummy pos:i.pos name:("dummy_"+ i.name)
		new_dummy.controller = i.controller
		local sk = skin()
		
		select i

		addmodifier i sk
		skinOps.addBone sk new_dummy 1
	)
	completeredraw()
)