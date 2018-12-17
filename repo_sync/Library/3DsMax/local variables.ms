rollout d1 "" width:162 height:300
(
	local a = "c:\\temp"
	
	fn create_d2 =
	(
		rollout d2 "" width:162 height:300
		(
			local b
			fn variableCheck = format "var_check:%\n" b
			on d2 open do 
			(
				b=a+"\\test\\"
				variableCheck()
			)
		)
		createDialog d2
	)
)
createDialog d1
d1.create_d2()